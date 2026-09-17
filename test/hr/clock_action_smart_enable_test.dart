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

    test('missed clock out on previous day does not block next day clock in', () {
      // Previous day was never clocked out
      final yesterday = DailyAttendance(
        date: '2020-01-01',
        clockInTime: '08:30 AM',
        clockOutTime: '--:--',
      );
      expect(yesterday.isMissedClockOut, isTrue,
          reason: 'Past day with clock in but no clock out is a missed clock out');

      final list = [yesterday];

      // Current/new day arrives
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final todayRecord = list.firstWhere(
        (r) => r.date == todayStr,
        orElse: () => DailyAttendance(date: todayStr),
      );

      expect(todayRecord.hasClockedIn, isFalse);
      expect(todayRecord.hasClockedOut, isFalse);
      expect(todayRecord.isMissedClockOut, isFalse);

      final canClockIn = !todayRecord.hasClockedIn;
      expect(canClockIn, isTrue,
          reason: 'Unclosed previous day must never block today\'s clock in');
    });

    test('history list take(7) limits entries to 7 when more exist', () {
      final records = List.generate(
        15,
        (i) => DailyAttendance(
          date: '2026-09-${(i + 1).toString().padLeft(2, '0')}',
          clockInTime: '08:00 AM',
          clockOutTime: '05:00 PM',
        ),
      );

      final displayed = records.take(7).toList();
      expect(displayed.length, 7);
      expect(records.length, 15);
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

    test('option C: does not dilute completed days average when shift is in progress today', () {
      final now = DateTime(2026, 9, 15, 7, 47);
      final records = [
        // Day 1 (yesterday): Completed 7h 30m shift
        BiometricAttendanceRecord(
          id: 1,
          attendanceType: 'CLOCK_IN',
          timestamp: DateTime(2026, 9, 14, 8, 30),
          verificationMethod: 'FACE',
        ),
        BiometricAttendanceRecord(
          id: 2,
          attendanceType: 'CLOCK_OUT',
          timestamp: DateTime(2026, 9, 14, 16, 0),
          verificationMethod: 'FACE',
        ),
        // Day 2 (today): Clocked in 7 minutes ago
        BiometricAttendanceRecord(
          id: 3,
          attendanceType: 'CLOCK_IN',
          timestamp: DateTime(2026, 9, 15, 7, 40),
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

      Duration completedMonthTotal = Duration.zero;
      int completedMonthDays = 0;
      Duration ongoingTodayShift = Duration.zero;
      bool hasOngoingTodayShift = false;

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
              completedMonthTotal += diff;
              completedMonthDays++;
            }
          } else if (dateKey == todayKey && now.isAfter(ci.timestamp)) {
            final ongoing = now.difference(ci.timestamp);
            if (!ongoing.isNegative && ongoing.inMinutes > 0) {
              ongoingTodayShift = ongoing;
              hasOngoingTodayShift = true;
            }
          }
        }
      });

      expect(completedMonthDays, 1);
      expect(completedMonthTotal.inMinutes, 450); // 7h 30m
      expect(hasOngoingTodayShift, isTrue);
      expect(ongoingTodayShift.inMinutes, 7);

      final avgMinutes = completedMonthTotal.inMinutes ~/ completedMonthDays;
      final h = avgMinutes ~/ 60;
      final m = avgMinutes % 60;
      expect('${h}h ${m}m', '7h 30m',
          reason: 'Average must stay at 7h 30m instead of dropping to 3h 48m');
    });

    test('option C: counts active ongoing shift time when 0 completed shifts exist yet', () {
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

      Duration completedMonthTotal = Duration.zero;
      int completedMonthDays = 0;
      Duration ongoingTodayShift = Duration.zero;
      bool hasOngoingTodayShift = false;

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
              completedMonthTotal += diff;
              completedMonthDays++;
            }
          } else if (dateKey == todayKey && now.isAfter(ci.timestamp)) {
            final ongoing = now.difference(ci.timestamp);
            if (!ongoing.isNegative && ongoing.inMinutes > 0) {
              ongoingTodayShift = ongoing;
              hasOngoingTodayShift = true;
            }
          }
        }
      });

      expect(completedMonthDays, 0);
      expect(hasOngoingTodayShift, isTrue);
      expect(ongoingTodayShift.inMinutes, 140,
          reason: '8:35 to 10:55 is exactly 140 minutes (2h 20m)');

      String avgLabel = '0h';
      if (completedMonthDays > 0) {
        final avgMinutes = completedMonthTotal.inMinutes ~/ completedMonthDays;
        avgLabel = '${avgMinutes ~/ 60}h ${avgMinutes % 60}m';
      } else if (hasOngoingTodayShift) {
        avgLabel = '${ongoingTodayShift.inHours}h ${ongoingTodayShift.inMinutes.remainder(60)}m';
      }

      expect(avgLabel, '2h 20m',
          reason: 'Avg Hours must reflect current shift when 0 completed days exist');
    });
  });
}
