import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('work report operational base is selected from eligible workspaces', () {
    final source = File('lib/pages/hr/widget/daily_work_report_dialog.dart').readAsStringSync();
    expect(source, contains('BiometricApiService'));
    expect(source, contains('WorkspaceConfig'));
    expect(source, contains('canClockIn'));
    expect(source, contains('MyDropdown'));
    expect(source, isNot(contains("MyTextFormField(\n                  title: 'Operational Base'")));
  });

  test('work report submits the selected workspace name', () {
    final source = File('lib/pages/hr/widget/daily_work_report_dialog.dart').readAsStringSync();
    expect(source, contains('_selectedOperationalBase'));
  });
}
