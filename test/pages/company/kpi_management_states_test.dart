import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('KPI management wires search and exposes API errors', () {
    final source =
        File('lib/pages/company/kpi_management.dart').readAsStringSync();

    expect(source, contains('fetchAllKpis(search:'));
    expect(source, contains('ctrl.errorMessage.value'));
    expect(source, contains('Error loading KPIs'));
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
}
