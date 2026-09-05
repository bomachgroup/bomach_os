class BiometricAttendanceRecord {
  final int id;
  final String? employeeId;
  final String attendanceType; // 'CLOCK_IN' or 'CLOCK_OUT'
  final DateTime timestamp;
  final String verificationMethod;
  final String? notes;
  final bool? locationVerified;
  final String? locationUsedName;
  final double? distanceMeters;

  BiometricAttendanceRecord({
    required this.id,
    this.employeeId,
    required this.attendanceType,
    required this.timestamp,
    required this.verificationMethod,
    this.notes,
    this.locationVerified,
    this.locationUsedName,
    this.distanceMeters,
  });

  factory BiometricAttendanceRecord.fromJson(Map<String, dynamic> json) {
    return BiometricAttendanceRecord(
      id: json['id'] ?? 0,
      employeeId: json['employee_id']?.toString(),
      attendanceType: json['attendance_type'] ?? 'UNKNOWN',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      verificationMethod: json['verification_method'] ?? 'MANUAL',
      notes: json['notes'],
      locationVerified: json['location_verified'] as bool?,
      locationUsedName: json['location_used_name']?.toString(),
      distanceMeters: json['distance_meters'] is num
          ? (json['distance_meters'] as num).toDouble()
          : double.tryParse(json['distance_meters']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'attendance_type': attendanceType,
      'timestamp': timestamp.toIso8601String(),
      'verification_method': verificationMethod,
      'notes': notes,
      'location_verified': locationVerified,
      'location_used_name': locationUsedName,
      'distance_meters': distanceMeters,
    };
  }
}

// --- Derived model for the user's attendance history table ---
class DailyAttendance {
  final String date;
  final String? clockInTime;
  final String? clockOutTime;
  final String hoursWorked;

  DailyAttendance({
    required this.date,
    this.clockInTime,
    this.clockOutTime,
    this.hoursWorked = '--:--',
  });
}
