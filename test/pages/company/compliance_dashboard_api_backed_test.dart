import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('company compliance dashboard uses the supported compliance register', () {
    final source = File('lib/pages/company/compliance_dashboard.dart')
        .readAsStringSync();

    expect(source, contains('CompliancePage'));
    expect(source, contains('CompanyController'));
    expect(source, isNot(contains('ComingSoonTab')));
  });
}
