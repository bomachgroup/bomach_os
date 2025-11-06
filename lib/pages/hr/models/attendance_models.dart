/// Clock-in/Clock-out record model
class AttendanceRecord {
  final String employeeId;
  final String employeeName;
  final String employeeEmail;
  final DateTime date;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String status; // Present, Absent, Late, Early Leave, On Leave
  final String? notes;

  AttendanceRecord({
    required this.employeeId,
    required this.employeeName,
    required this.employeeEmail,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.notes,
  });

  /// Get duration between check-in and check-out
  Duration? getWorkDuration() {
    if (checkInTime == null || checkOutTime == null) return null;
    return checkOutTime!.difference(checkInTime!);
  }

  /// Format work hours and minutes
  String getFormattedWorkDuration() {
    final duration = getWorkDuration();
    if (duration == null) return '---';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  /// Check if employee is late
  bool isLate({Duration threshold = const Duration(minutes: 30)}) {
    if (checkInTime == null) return false;
    final expectedCheckInTime = DateTime(date.year, date.month, date.day, 8, 0);
    return checkInTime!.isAfter(expectedCheckInTime.add(threshold));
  }

  /// Copy with method for immutability
  AttendanceRecord copyWith({
    String? employeeId,
    String? employeeName,
    String? employeeEmail,
    DateTime? date,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? status,
    String? notes,
  }) {
    return AttendanceRecord(
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      employeeEmail: employeeEmail ?? this.employeeEmail,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}

/// Clock-in summary for a single day
class DailyAttendanceSummary {
  final int totalEmployees;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int earlyLeaveCount;
  final int onLeaveCount;

  DailyAttendanceSummary({
    required this.totalEmployees,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.earlyLeaveCount,
    required this.onLeaveCount,
  });

  /// Calculate attendance percentage
  double getAttendancePercentage() {
    if (totalEmployees == 0) return 0;
    return (presentCount / totalEmployees) * 100;
  }

  /// Calculate on-time percentage
  double getOnTimePercentage() {
    final onTimeCount = presentCount - lateCount;
    if (totalEmployees == 0) return 0;
    return (onTimeCount / totalEmployees) * 100;
  }
}

/// Status enum for attendance
enum AttendanceStatus {
  present('Present'),
  absent('Absent'),
  late('Late'),
  earlyLeave('Early Leave'),
  onLeave('On Leave'),
  halfDay('Half Day'),
  remote('Remote');

  final String displayName;
  const AttendanceStatus(this.displayName);

  /// Get status color for UI
  String getStatusColor() {
    switch (this) {
      case AttendanceStatus.present:
        return '#2DAB03'; // Green
      case AttendanceStatus.absent:
        return '#EC2623'; // Red
      case AttendanceStatus.late:
        return '#FFA500'; // Orange
      case AttendanceStatus.earlyLeave:
        return '#FF6B6B'; // Light Red
      case AttendanceStatus.onLeave:
        return '#9B59B6'; // Purple
      case AttendanceStatus.halfDay:
        return '#3498DB'; // Blue
      case AttendanceStatus.remote:
        return '#27AE60'; // Dark Green
    }
  }
}
