import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('daily routine tab uses the dedicated routine API and error state', () {
    final controllerSource =
        File('lib/pages/company/controllers/daily_routine_controller.dart')
            .readAsStringSync();
    final pageSource =
        File('lib/pages/company/widget/role_detail_tabs/daily_routine_tab.dart')
            .readAsStringSync();

    expect(controllerSource, contains('RoleDailyRoutineService'));
    expect(controllerSource, contains('listRoutine'));
    expect(controllerSource, isNot(contains('WorkReportService')));
    expect(controllerSource, isNot(contains('EmployeeService')));
    expect(pageSource, contains('Error loading daily routine'));
    expect(pageSource, contains('ctrl.items'));
  });
}
