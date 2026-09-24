import 'package:bomach_os/pages/hr/models/attendance_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('missed clock-out notice eligibility', () {
    final today = DateTime(2026, 9, 24, 9);

    test('shows only an unfinished shift from the previous WAT day', () {
      final records = [
        DailyAttendance(
          date: '2026-09-18',
          clockInTime: '08:30 AM',
          clockOutTime: '--:--',
        ),
        DailyAttendance(
          date: '2026-09-23',
          clockInTime: '08:30 AM',
          clockOutTime: '--:--',
        ),
      ];

      expect(
        missedClockOutNoticeForPreviousWatDay(records, today)?.date,
        '2026-09-23',
      );
    });

    test('does not show an older missed shift, but history still marks it', () {
      final older = DailyAttendance(
        date: '2026-09-18',
        clockInTime: '08:30 AM',
        clockOutTime: '--:--',
      );

      expect(missedClockOutNoticeForPreviousWatDay([older], today), isNull);
      expect(older.isMissedClockOut, isTrue);
    });

    test('does not show a completed previous-day shift', () {
      final completed = DailyAttendance(
        date: '2026-09-23',
        clockInTime: '08:30 AM',
        clockOutTime: '05:00 PM',
      );

      expect(missedClockOutNoticeForPreviousWatDay([completed], today), isNull);
    });

    test('does not show today’s unfinished shift as a missed prior shift', () {
      final todayShift = DailyAttendance(
        date: '2026-09-24',
        clockInTime: '08:30 AM',
        clockOutTime: '--:--',
      );

      expect(
          missedClockOutNoticeForPreviousWatDay([todayShift], today), isNull);
    });

    test('handles month and year boundaries in WAT calendar dates', () {
      expect(
        missedClockOutNoticeForPreviousWatDay(
          [
            DailyAttendance(
              date: '2026-12-31',
              clockInTime: '08:30 AM',
              clockOutTime: '--:--',
            ),
          ],
          DateTime(2027, 1, 1, 9),
        )?.date,
        '2026-12-31',
      );

      expect(
        missedClockOutNoticeForPreviousWatDay(
          [
            DailyAttendance(
              date: '2026-08-31',
              clockInTime: '08:30 AM',
              clockOutTime: '--:--',
            ),
          ],
          DateTime(2026, 9, 1, 9),
        )?.date,
        '2026-08-31',
      );
    });
  });
}
