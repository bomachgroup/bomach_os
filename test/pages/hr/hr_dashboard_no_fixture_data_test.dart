import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('HR dashboard does not render fabricated people, audit, leave, or chart data', () {
    final source = File('lib/pages/hr/hr.dart').readAsStringSync();

    for (final fixture in [
      'Clark Changed Rose Ells',
      'Garrett added a new employee',
      'David West',
      'Sarah Musa',
      'Benji Rider 1',
      '78 employees',
      '42 employees',
      '56 employees',
    ]) {
      expect(source, isNot(contains(fixture)), reason: fixture);
    }
  });

  test('HR dashboard routes supported audit and leave work to their API-backed pages', () {
    final source = File('lib/pages/hr/hr.dart').readAsStringSync();

    expect(source, contains('RouteConstants.auditLog'));
    expect(source, contains('RouteConstants.leaveRequest'));
    expect(source, contains('BackendCapabilityUnavailable'));
  });
}
