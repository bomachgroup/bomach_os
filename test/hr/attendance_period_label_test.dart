import 'package:bomach_os/pages/hr/attendance_period_label.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('weekly attendance label uses a five-workday target', () {
    expect(AttendancePeriodLabel.week(3), '3/5');
  });

  test('monthly attendance label uses weekdays in the calendar month', () {
    expect(
      AttendancePeriodLabel.month(8, DateTime(2026, 9, 24)),
      '8/22',
    );
    expect(
      AttendancePeriodLabel.month(2, DateTime(2028, 2, 12)),
      '2/21',
    );
    expect(
      AttendancePeriodLabel.month(1, DateTime(2026, 4, 1)),
      '1/22',
    );
    expect(
      AttendancePeriodLabel.month(4, DateTime(2026, 1, 1)),
      '4/22',
    );
  });
}
