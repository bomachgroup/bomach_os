import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('org chart uses the dedicated reporting controller', () {
    final source = File(
      'lib/pages/company/widget/role_detail_tabs/org_chart_tab.dart',
    ).readAsStringSync();

    expect(source, contains('RoleReportingController'));
    expect(source, contains('Error loading reporting relationships'));
  });
}
