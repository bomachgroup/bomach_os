/// Formats the attendance-day totals shown on the Attendance summary cards.
class AttendancePeriodLabel {
  const AttendancePeriodLabel._();

  static String week(int clockedDays) => '$clockedDays/5';

  static String month(int clockedDays, DateTime date) {
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    return '$clockedDays/$daysInMonth';
  }
}
