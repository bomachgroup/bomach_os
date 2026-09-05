import 'package:flutter_test/flutter_test.dart';

import 'package:bomach_os/pages/hr/models/location_verification_result.dart';
import 'package:bomach_os/pages/hr/models/clock_in_location_policy.dart';

void main() {
  test('backend rejection makes location verification unavailable', () {
    final result = LocationVerificationResult.fromJson({
      'is_valid': false,
      'distance_meters': 125.4,
      'location_name': 'HQ',
    });

    expect(result.isAllowed, isFalse);
    expect(result.distanceMeters, 125.4);
    expect(result.locationName, 'HQ');
  });

  test('backend approval makes location verification available', () {
    final result = LocationVerificationResult.fromJson({
      'is_valid': true,
      'distance_meters': 12.5,
    });

    expect(result.isAllowed, isTrue);
  });

  test('clock-in location policy rejects a backend-invalid location', () {
    final result = LocationVerificationResult.fromJson({'is_valid': false});

    expect(ClockInLocationPolicy.canProceed(result), isFalse);
  });
}
