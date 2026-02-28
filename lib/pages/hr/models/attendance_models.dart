class BiometricAttendanceRecord {
  final int id;
  final String? employeeId; 
  final String attendanceType; // 'CLOCK_IN' or 'CLOCK_OUT'
  final DateTime timestamp;
  final String verificationMethod;
  final String? notes;

  BiometricAttendanceRecord({
    required this.id,
    this.employeeId,
    required this.attendanceType,
    required this.timestamp,
    required this.verificationMethod,
    this.notes,
  });

  factory BiometricAttendanceRecord.fromJson(Map<String, dynamic> json) {
    return BiometricAttendanceRecord(
      id: json['id'] ?? 0,
      employeeId: json['employee_id']?.toString(),
      attendanceType: json['attendance_type'] ?? 'UNKNOWN',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      verificationMethod: json['verification_method'] ?? 'MANUAL',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'attendance_type': attendanceType,
      'timestamp': timestamp.toIso8601String(),
      'verification_method': verificationMethod,
      'notes': notes,
    };
  }
}

// --- Helper Model for UI Table Row ---
class DailyAttendance {
  final String date;
  final String employeeName; // Placeholder, as API might only give ID
  final String role;         // Placeholder
  final String? clockInTime;
  final String? clockOutTime;
  final String hoursWorked;

  DailyAttendance({
    required this.date,
    this.employeeName = 'Unknown',
    this.role = 'Staff',
    this.clockInTime,
    this.clockOutTime,
    this.hoursWorked = '--:--',
  });
}