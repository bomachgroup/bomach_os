import 'package:bomach_os/pages/hr/models/attendance_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizes the API clock_in value for daily attendance processing', () {
    final record = BiometricAttendanceRecord.fromJson({
      'id': 1,
      'attendance_type': 'clock_in',
      'timestamp': '2026-09-10T08:30:00Z',
      'verification_method': 'face',
    });

    expect(record.attendanceType, 'CLOCK_IN');
  });

  test('normalizes the API clock_out value for daily attendance processing',
      () {
    final record = BiometricAttendanceRecord.fromJson({
      'id': 2,
      'attendance_type': 'clock_out',
      'timestamp': '2026-09-10T17:00:00Z',
      'verification_method': 'face',
    });

    expect(record.attendanceType, 'CLOCK_OUT');
  });
}
