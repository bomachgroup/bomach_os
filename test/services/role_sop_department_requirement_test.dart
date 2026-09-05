import 'package:bomach_os/src/services/role_sop_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('requires a department before loading available SOPs', () {
    final service = RoleSopService();

    expect(
      () => service.fetchAvailableSops('token'),
      throwsA(isA<ArgumentError>()),
    );
  });
}
