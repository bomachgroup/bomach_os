import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('security page exposes the missing platform and device contracts', () {
    final source = File('lib/pages/security/security.dart').readAsStringSync();

    expect(source, contains('BackendCapabilityUnavailable'));
    expect(source, contains('Employee Platforms Verification'));
    expect(source, contains('Device Whitelisting'));
    expect(source, contains('BOMACH OS shell'));
    expect(source, contains('Mobile client'));
    expect(source, contains('Embedded BOMACH OS Services'));
    expect(source, contains('device registration'));
  });
}
