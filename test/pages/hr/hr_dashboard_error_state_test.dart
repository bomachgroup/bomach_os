import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('HR dashboard exposes stats loading failures and a retry action', () {
    final source = File('lib/pages/hr/hr.dart').readAsStringSync();

    expect(source, contains('controller.errorMessage.value'));
    expect(source, contains('Retry'));
    expect(source, contains('fetchDashboardStats'));
  });
}
