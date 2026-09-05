import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('HR header actions are wired to existing employee and job-posting flows', () {
    final source = File('lib/pages/hr/hr.dart').readAsStringSync();

    expect(source, contains('AddEmployeeDialog'));
    expect(source, contains('RouteConstants.jobPost'));
    expect(source, isNot(contains('onPressed: () {}')));
  });
}
