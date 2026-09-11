import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('compliance keeps a dedicated error state for failed loads', () {
    final controller = File('lib/pages/company/controllers/company_controller.dart').readAsStringSync();
    final page = File('lib/pages/company/compliance.dart').readAsStringSync();

    expect(controller, contains('complianceErrorMessage'));
    expect(page, contains('Retry'));
    expect(page, contains('complianceErrorMessage'));
  });

  test('compliance actions use compliance permissions', () {
    final page = File('lib/pages/company/compliance.dart').readAsStringSync();
    expect(page, contains('Perms.complianceRecordsCreate'));
    expect(page, contains('Perms.complianceRecordsUpdate'));
    expect(page, contains('PermissionGate'));
  });

  test('failed controller actions use error toast severity', () {
    final controller = File('lib/pages/company/controllers/company_controller.dart').readAsStringSync();
    expect(controller, contains('AppToast.error(context, message)'));
    expect(controller, contains('AppToast.info(context, message)'));
  });

  test('compliance route uses compliance-list permission', () {
    final source =
        File('lib/src/constants/permissions.dart').readAsStringSync();
    expect(source, contains(
        'RouteConstants.complianceDashboard: [Perms.complianceRecordsList]'));
  });
}
