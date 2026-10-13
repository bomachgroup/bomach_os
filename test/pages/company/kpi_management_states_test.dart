import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('KPI management wires search and exposes API errors', () {
    final source =
        File('lib/pages/company/kpi_management.dart').readAsStringSync();

    expect(source, contains('fetchAllKpis(search:'));
    expect(source, contains('ctrl.errorMessage.value'));
    expect(source, contains("label: const Text('Retry')"));
    expect(source, contains('_KpiPagination(ctrl: ctrl)'));
  });

  test('KPI management loads once from initState instead of every build', () {
    final source =
        File('lib/pages/company/kpi_management.dart').readAsStringSync();

    expect(source, contains('class KpiManagementPage extends StatefulWidget'));
    expect(source, contains('void initState()'));
    expect(source, contains('ctrl.fetchAllKpis();'));
    expect(
        source,
        isNot(contains(
            '\n    ctrl.fetchAllKpis();\r\n\n    return PageScaffold')));
  });

  test('global Add KPI selects the role before rendering metric selection', () {
    final source =
        File('lib/pages/company/widget/kpi_dialogs.dart').readAsStringSync();
    final rolePosition = source.indexOf(
      'The global form requires a role before it can determine',
    );
    final metricPosition = source.indexOf('// ── Metric Selector');

    expect(rolePosition, isNonNegative);
    expect(metricPosition, greaterThan(rolePosition));
  });

  test('assignment removal explains its scope and preserves shared metric data',
      () {
    final source =
        File('lib/pages/company/widget/kpi_dialogs.dart').readAsStringSync();

    expect(source, contains('Remove KPI from role?'));
    expect(
        source,
        contains(
            'The shared metric and historical employee KPI data will remain.'));
    expect(source, contains("'Remove from role'"));
  });

  test(
      'role KPI tab aligns list, edit, create, and delete with API permissions',
      () {
    final source = File(
      'lib/pages/company/widget/role_detail_tabs/kpi_tab.dart',
    ).readAsStringSync();

    expect(source, contains('Perms.roleKpisList'));
    expect(source, contains('Perms.roleKpisCreate'));
    expect(source, contains('Perms.roleKpisUpdate'));
    expect(source, contains('Perms.roleKpisDelete'));
    expect(source, contains('final canEditKpi'));
    expect(source, contains('final canDeleteKpi'));
    expect(source, isNot(contains('Perms.rolesList')));
  });

  test(
      'management controller uses searchable global pagination with stale-response protection',
      () {
    final source = File(
      'lib/pages/company/controllers/role_kpi_controller.dart',
    ).readAsStringSync();

    expect(source, contains('listAllRoleKpis'));
    expect(source, contains('_allKpisRequestId'));
    expect(source, contains('setAllKpisPage'));
    expect(source, contains('_friendlyError(e)'));
  });
}
