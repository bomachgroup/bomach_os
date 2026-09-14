import 'package:bomach_os/pages/hr/models/attendance_models.dart';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  group('DailyAttendance smart button state flags', () {
    test('fresh day (no clock in, no clock out)', () {
      final today = DailyAttendance(date: '2026-09-14');

      expect(today.hasClockedIn, isFalse);
      expect(today.hasClockedOut, isFalse);
      expect(today.isCompleted, isFalse);

      // Button states
      final canClockIn = !today.hasClockedIn;
      final canClockOut = today.hasClockedIn && !today.hasClockedOut;

      expect(canClockIn, isTrue, reason: 'User should be able to clock in');
      expect(canClockOut, isFalse,
          reason: 'User cannot clock out without clocking in');
    });

    test('clocked in today (active shift in progress)', () {
      final today = DailyAttendance(
        date: '2026-09-14',
        clockInTime: '08:35 AM',
        clockOutTime: '--:--',
      );

      expect(today.hasClockedIn, isTrue);
      expect(today.hasClockedOut, isFalse);
      expect(today.isCompleted, isFalse);

      final canClockIn = !today.hasClockedIn;
      final canClockOut = today.hasClockedIn && !today.hasClockedOut;

      expect(canClockIn, isFalse,
          reason: 'Clock In must be disabled once already clocked in today');
      expect(canClockOut, isTrue,
          reason: 'Clock Out must be enabled after clocking in');
    });

    test('clocked in and clocked out today (completed day)', () {
      final today = DailyAttendance(
        date: '2026-09-14',
        clockInTime: '08:35 AM',
        clockOutTime: '05:00 PM',
        hoursWorked: '8h 25m',
      );

      expect(today.hasClockedIn, isTrue);
      expect(today.hasClockedOut, isTrue);
      expect(today.isCompleted, isTrue);

      final canClockIn = !today.hasClockedIn;
      final canClockOut = today.hasClockedIn && !today.hasClockedOut;

      expect(canClockIn, isFalse,
          reason: 'Clock In must be disabled once completed');
      expect(canClockOut, isFalse,
          reason: 'Clock Out must be disabled once completed');
    });

    test('day rollover allows clocking in on the next day', () {
      // Previous day is completed
      final yesterday = DailyAttendance(
        date: '2026-09-13',
        clockInTime: '08:30 AM',
        clockOutTime: '05:00 PM',
      );
      final list = [yesterday];

      // New day arrives: Sep 14
      const nextDayStr = '2026-09-14';
      final nextDayRecord = list.firstWhere(
        (r) => r.date == nextDayStr,
        orElse: () => DailyAttendance(date: nextDayStr),
      );

      expect(nextDayRecord.hasClockedIn, isFalse);
      expect(nextDayRecord.hasClockedOut, isFalse);

      final canClockInNextDay = !nextDayRecord.hasClockedIn;
      final canClockOutNextDay =
          nextDayRecord.hasClockedIn && !nextDayRecord.hasClockedOut;

      expect(canClockInNextDay, isTrue,
          reason: 'Fresh day must allow clocking in');
      expect(canClockOutNextDay, isFalse,
          reason: 'Fresh day must not allow clocking out before clocking in');
    });
  });

  group('BiometricAttendanceRecord normalization', () {
    test('handles various casing and separator formats for clock_in and clock_out', () {
      final inRecord1 = BiometricAttendanceRecord.fromJson({
        'id': 1,
        'attendance_type': 'clock_in',
        'timestamp': '2026-09-14T08:35:00Z',
      });
      expect(inRecord1.attendanceType, 'CLOCK_IN');

      final inRecord2 = BiometricAttendanceRecord.fromJson({
        'id': 2,
        'attendance_type': 'CLOCK-IN',
        'timestamp': '2026-09-14T08:35:00Z',
      });
      expect(inRecord2.attendanceType, 'CLOCK_IN');

      final outRecord1 = BiometricAttendanceRecord.fromJson({
        'id': 3,
        'attendance_type': 'clock_out',
        'timestamp': '2026-09-14T17:00:00Z',
      });
      expect(outRecord1.attendanceType, 'CLOCK_OUT');

      final outRecord2 = BiometricAttendanceRecord.fromJson({
        'id': 4,
        'attendance_type': 'CLOCK-OUT',
        'timestamp': '2026-09-14T17:00:00Z',
      });
      expect(outRecord2.attendanceType, 'CLOCK_OUT');
    });

    test('parseTimestamp treats naive UTC timestamps without Z as UTC and converts to local', () {
      // Suppose backend returns naive UTC string: "2026-09-14 10:44:00"
      final parsedNaive = BiometricAttendanceRecord.parseTimestamp('2026-09-14 10:44:00');
      final parsedWithZ = BiometricAttendanceRecord.parseTimestamp('2026-09-14T10:44:00Z');

      // Both should resolve to the exact same local instant
      expect(parsedNaive.millisecondsSinceEpoch, equals(parsedWithZ.millisecondsSinceEpoch));
      expect(parsedNaive.isUtc, isFalse);
    });
  });

  group('Avg Hours / Day calculation', () {
    test('calculates accurate average with completed shifts', () {
      final records = [
        BiometricAttendanceRecord(
          id: 1,
          attendanceType: 'CLOCK_IN',
          timestamp: DateTime(2026, 9, 1, 8, 0),
          verificationMethod: 'FACE',
        ),
        BiometricAttendanceRecord(
          id: 2,
          attendanceType: 'CLOCK_OUT',
          timestamp: DateTime(2026, 9, 1, 16, 0), // 8 hours
          verificationMethod: 'FACE',
        ),
        BiometricAttendanceRecord(
          id: 3,
          attendanceType: 'CLOCK_IN',
          timestamp: DateTime(2026, 9, 2, 9, 0),
          verificationMethod: 'FACE',
        ),
        BiometricAttendanceRecord(
          id: 4,
          attendanceType: 'CLOCK_OUT',
          timestamp: DateTime(2026, 9, 2, 17, 0), // 8 hours
          verificationMethod: 'FACE',
        ),
      ];

      final now = DateTime(2026, 9, 2, 18, 0);
      final monthStart = DateTime(now.year, now.month, 1);
      final nextMonth = DateTime(now.year, now.month + 1, 1);
      final todayKey = DateFormat('yyyy-MM-dd').format(now);

      final Map<String, List<BiometricAttendanceRecord>> byDay = {};
      for (final r in records) {
        final key = DateFormat('yyyy-MM-dd').format(r.timestamp.toLocal());
        byDay.putIfAbsent(key, () => []).add(r);
      }

      Duration monthTotal = Duration.zero;
      int monthDaysWithHours = 0;

      byDay.forEach((dateKey, events) {
        events.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        final dayDate = DateTime.tryParse(dateKey) ?? DateTime.now();
        final hasClockIn = events.any((e) => e.attendanceType == 'CLOCK_IN');
        if (!hasClockIn) return;

        final isThisMonth =
            !dayDate.isBefore(monthStart) && dayDate.isBefore(nextMonth);
        if (isThisMonth) {
          final ci = events.firstWhere((e) => e.attendanceType == 'CLOCK_IN');
          final co = events.lastWhereOrNull((e) => e.attendanceType == 'CLOCK_OUT');

          if (co != null && co.timestamp.isAfter(ci.timestamp)) {
            final diff = co.timestamp.difference(ci.timestamp);
            if (!diff.isNegative) {
              monthTotal += diff;
              monthDaysWithHours++;
            }
          } else if (dateKey == todayKey && now.isAfter(ci.timestamp)) {
            final ongoing = now.difference(ci.timestamp);
            if (!ongoing.isNegative && ongoing.inMinutes > 0) {
              monthTotal += ongoing;
              monthDaysWithHours++;
            }
          }
        }
      });

      expect(monthDaysWithHours, 2);
      expect(monthTotal.inHours, 16);
      final avgMinutes = monthTotal.inMinutes ~/ monthDaysWithHours;
      expect(avgMinutes ~/ 60, 8);
    });

    test('counts active ongoing shift time so average is not 0 for working shift', () {
      final shiftStart = DateTime(2026, 9, 14, 8, 35);
      final now = DateTime(2026, 9, 14, 10, 55); // 2h 20m elapsed

      final records = [
        BiometricAttendanceRecord(
          id: 1,
          attendanceType: 'CLOCK_IN',
          timestamp: shiftStart,
          verificationMethod: 'FACE',
        ),
      ];

      final monthStart = DateTime(now.year, now.month, 1);
      final nextMonth = DateTime(now.year, now.month + 1, 1);
      final todayKey = DateFormat('yyyy-MM-dd').format(now);

      final Map<String, List<BiometricAttendanceRecord>> byDay = {};
      for (final r in records) {
        final key = DateFormat('yyyy-MM-dd').format(r.timestamp.toLocal());
        byDay.putIfAbsent(key, () => []).add(r);
      }

      Duration monthTotal = Duration.zero;
      int monthDaysWithHours = 0;

      byDay.forEach((dateKey, events) {
        events.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        final dayDate = DateTime.tryParse(dateKey) ?? DateTime.now();
        final hasClockIn = events.any((e) => e.attendanceType == 'CLOCK_IN');
        if (!hasClockIn) return;

        final isThisMonth =
            !dayDate.isBefore(monthStart) && dayDate.isBefore(nextMonth);
        if (isThisMonth) {
          final ci = events.firstWhere((e) => e.attendanceType == 'CLOCK_IN');
          final co = events.lastWhereOrNull((e) => e.attendanceType == 'CLOCK_OUT');

          if (co != null && co.timestamp.isAfter(ci.timestamp)) {
            final diff = co.timestamp.difference(ci.timestamp);
            if (!diff.isNegative) {
              monthTotal += diff;
              monthDaysWithHours++;
            }
          } else if (dateKey == todayKey && now.isAfter(ci.timestamp)) {
            final ongoing = now.difference(ci.timestamp);
            if (!ongoing.isNegative && ongoing.inMinutes > 0) {
              monthTotal += ongoing;
              monthDaysWithHours++;
            }
          }
        }
      });

      expect(monthDaysWithHours, 1,
          reason: 'Ongoing shift today should count toward active hours');
      expect(monthTotal.inMinutes, 140,
          reason: '8:35 to 10:55 is exactly 140 minutes (2h 20m)');

      final avgMinutes = monthTotal.inMinutes ~/ monthDaysWithHours;
      final h = avgMinutes ~/ 60;
      final m = avgMinutes % 60;
      expect('${h}h ${m}m', '2h 20m',
          reason: 'Avg Hours must reflect current shift instead of being 0h');
    });
  });
}
