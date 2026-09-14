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
    final rawType = json['attendance_type']
            ?.toString()
            .trim()
            .toUpperCase()
            .replaceAll('-', '_')
            .replaceAll(' ', '_') ??
        'UNKNOWN';
    final normalizedType = (rawType == 'IN' || rawType == 'CLOCKIN')
        ? 'CLOCK_IN'
        : (rawType == 'OUT' || rawType == 'CLOCKOUT')
            ? 'CLOCK_OUT'
            : rawType;

    final parsedTimestamp = parseTimestamp(json['timestamp']);

    return BiometricAttendanceRecord(
      id: json['id'] ?? 0,
      employeeId: json['employee_id']?.toString(),
      attendanceType: normalizedType,
      timestamp: parsedTimestamp,
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

  /// Parses timestamps from the backend, treating naive ISO strings as UTC
  /// before converting to the client's local timezone.
  static DateTime parseTimestamp(dynamic raw) {
    if (raw == null) return DateTime.now();
    if (raw is DateTime) return raw.toLocal();
    final str = raw.toString().trim();
    if (str.isEmpty) return DateTime.now();

    String normalizedStr = str.replaceFirst(' ', 'T');
    final hasTimezone = normalizedStr.endsWith('Z') ||
        normalizedStr.endsWith('z') ||
        (normalizedStr.contains(':') &&
            RegExp(r'[+-]\d{2}(:?\d{2})?$').hasMatch(normalizedStr));

    if (!hasTimezone) {
      normalizedStr = '${normalizedStr}Z';
    }

    final parsed = DateTime.tryParse(normalizedStr) ??
        DateTime.tryParse(str) ??
        DateTime.now();
    return parsed.toLocal();
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

  bool get hasClockedIn =>
      clockInTime != null &&
      clockInTime != '--:--' &&
      clockInTime!.trim().isNotEmpty;

  bool get hasClockedOut =>
      clockOutTime != null &&
      clockOutTime != '--:--' &&
      clockOutTime!.trim().isNotEmpty;

  bool get isCompleted => hasClockedIn && hasClockedOut;
}
