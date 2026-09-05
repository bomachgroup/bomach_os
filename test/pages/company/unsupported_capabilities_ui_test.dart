import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('OKR Board declares its missing backend contract', () {
    final source = File('lib/pages/company/okr_board.dart').readAsStringSync();

    expect(source, contains('BackendCapabilityUnavailable'));
    expect(source, contains('objective'));
    expect(source, contains('key result'));
    expect(source, isNot(contains('ComingSoonTab')));
  });

  test('Knowledge Base declares its missing backend contract', () {
    final source = File('lib/pages/company/company_knowledge_base.dart')
        .readAsStringSync();

    expect(source, contains('BackendCapabilityUnavailable'));
    expect(source, contains('role resources'));
    expect(source, isNot(contains('ComingSoonTab')));
  });

  test('role editing does not consume the unsupported role OKR API', () {
    final source = File('lib/pages/company/widget/roles_dialogs.dart')
        .readAsStringSync();

    expect(source, contains('BackendCapabilityUnavailable'));
    expect(source, contains("featureName: 'Role OKRs'"));
    expect(source, isNot(contains('RoleOkrController')));
    expect(source, isNot(contains('CreateEditOkrDialog')));
  });

  test('orphaned role OKR tab does not consume the unsupported API', () {
    final source = File(
      'lib/pages/company/widget/role_detail_tabs/okr_tab.dart',
    ).readAsStringSync();

    expect(source, contains('BackendCapabilityUnavailable'));
    expect(source, contains("featureName: 'Role OKRs'"));
    expect(source, isNot(contains('RoleOkrController')));
  });

  test('orphaned role reports tab does not consume the unsupported API', () {
    final source = File(
      'lib/pages/company/widget/role_detail_tabs/reports_tab.dart',
    ).readAsStringSync();

    expect(source, contains('BackendCapabilityUnavailable'));
    expect(source, contains("featureName: 'Role Reports'"));
    expect(source, isNot(contains('RoleReportController')));
    expect(source, isNot(contains('CreateEditReportDialog')));
  });
}
