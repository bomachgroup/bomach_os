/// Formats the attendance-day totals shown on the Attendance summary cards.
class AttendancePeriodLabel {
  const AttendancePeriodLabel._();

  static String week(int clockedDays) => '$clockedDays/5';

  static String month(int clockedDays, DateTime date) {
    final firstDay = DateTime(date.year, date.month);
    final nextMonth = DateTime(date.year, date.month + 1);
    var workingDays = 0;

    for (var day = firstDay;
        day.isBefore(nextMonth);
        day = day.add(const Duration(days: 1))) {
      if (day.weekday >= DateTime.monday && day.weekday <= DateTime.friday) {
        workingDays++;
      }
    }

    return '$clockedDays/$workingDays';
  }
}
