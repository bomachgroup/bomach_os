import 'package:bomach_os/pages/hr/models/attendance_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('attendance response retains backend location verification fields', () {
    final record = BiometricAttendanceRecord.fromJson({
      'id': 42,
      'attendance_type': 'CLOCK_IN',
      'timestamp': '2026-09-04T08:30:00Z',
      'verification_method': 'FACE',
      'notes': 'Verified at HQ',
      'location_verified': true,
      'location_used_name': 'Head Office',
      'distance_meters': 14.5,
    });

    expect(record.locationVerified, isTrue);
    expect(record.locationUsedName, 'Head Office');
    expect(record.distanceMeters, 14.5);
  });
}
