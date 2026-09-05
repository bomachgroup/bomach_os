import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('performance review creation is permission-gated', () {
    final source =
        File('lib/pages/hr/performance_review.dart').readAsStringSync();

    expect(
        source,
        contains(
            "import 'package:bomach_os/components/permission/permission_gate.dart';"));
    expect(source, contains('PermissionGate('));
    expect(source, contains('Perms.performanceReviewsCreate'));
  });

  test('training program creation is permission-gated', () {
    final source =
        File('lib/pages/hr/training_program.dart').readAsStringSync();

    expect(
        source,
        contains(
            "import 'package:bomach_os/components/permission/permission_gate.dart';"));
    expect(source, contains('PermissionGate('));
    expect(source, contains('Perms.trainingProgramsCreate'));
  });

  test('role editing is permission-gated', () {
    final source =
        File('lib/pages/company/role_detail.dart').readAsStringSync();

    expect(
        source,
        contains(
            "import 'package:bomach_os/components/permission/permission_gate.dart';"));
    expect(source, contains('PermissionGate('));
    expect(source, contains('Perms.rolesUpdate'));
  });

  test('KPI mutations are permission-gated', () {
    final source =
        File('lib/pages/company/kpi_management.dart').readAsStringSync();

    expect(
      source,
      contains(
          "import 'package:bomach_os/components/permission/permission_gate.dart';"),
    );
    expect(source, contains('PermissionGate('));
    expect(source, contains('Perms.rolesUpdate'));
  });

  test('role-detail KPI mutations are permission-gated', () {
    final source = File(
      'lib/pages/company/widget/role_detail_tabs/kpi_tab.dart',
    ).readAsStringSync();

    expect(source, contains('PermissionGate('));
    expect(source, contains('Perms.rolesUpdate'));
  });

  test('employee profile mutations are permission-gated', () {
    final source =
        File('lib/pages/hr/employee_profile.dart').readAsStringSync();

    expect(source, contains('PermissionGate('));
    expect(source, contains('Perms.employeesUpdate'));
    expect(source, contains('Perms.performanceReviewsCreate'));
    expect(source, contains('Perms.employeesExit'));
  });

  test(
      'employee profile gates do not crash before permission service bootstrap',
      () {
    final source =
        File('lib/pages/hr/employee_profile.dart').readAsStringSync();

    expect(source, contains('Get.isRegistered<PermissionService>()'));
  });
}
