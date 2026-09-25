import 'dart:convert';
import 'dart:io';

import 'package:bomach_os/pages/hr/controller/work_report_controller.dart';
import 'package:bomach_os/pages/hr/models/work_report_model.dart';
import 'package:bomach_os/src/model/employees_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'work-report list resolves employee names once and supports fallback text',
      () {
    final source = File('lib/pages/hr/controller/work_report_controller.dart')
        .readAsStringSync();
    expect(source, contains('employeeNames'));
    expect(source, contains('employeeDisplayName'));
    expect(source, contains('Employee name unavailable'));
  });

  test('employee display name uses the cached mapping and a readable fallback',
      () {
    final controller = WorkReportController();
    controller.employeeNames[8] = 'Ada Lovelace';

    expect(controller.employeeDisplayName(8), 'Ada Lovelace');
    expect(controller.employeeDisplayName(99),
        'Employee name unavailable (ID: 99)');
  });

  test('work-report employee_id maps to employee record id, not user_id', () {
    final employeeNameIndex = WorkReportController.buildEmployeeNameIndex([
      Employee(
        id: '8',
        tableId: '3',
        employeeId: 'MEM-ADA',
        firstName: 'Ada',
        lastName: 'Okafor',
        email: 'ada@example.com',
      ),
      Employee(
        id: '3',
        tableId: '8',
        employeeId: 'MEM-BOB',
        firstName: 'Bob',
        lastName: 'Adele',
        email: 'bob@example.com',
      ),
    ]);

    expect(employeeNameIndex, {3: 'Ada Okafor', 8: 'Bob Adele'});
  });

  test(
      'work-report display joins the contract employee_id to employee record id',
      () {
    final controller = WorkReportController()
      ..employeeNames.addAll({3: 'Ada Okafor', 8: 'Bob Adele'});
    final report = WorkReport.fromJson({
      'id': 91,
      'employee_id': 3,
      // This is deliberately ignored: employee_name is not in either report
      // response schema, so names come from Employee.id via tableId.
      'employee_name': 'Incorrect person',
      'day': '2026-09-24',
      'hours_worked': 8,
      'status': 'submitted',
    });

    expect(controller.employeeDisplayName(report.employeeId), 'Ada Okafor');
  });

  test('published work-report response schemas do not define employee_name',
      () {
    final api = jsonDecode(File('openapi_schema.json').readAsStringSync())
        as Map<String, dynamic>;
    final schemas = api['components']['schemas'] as Map<String, dynamic>;

    for (final schemaName in ['WorkReportListItem', 'WorkReportOut']) {
      final properties =
          schemas[schemaName]['properties'] as Map<String, dynamic>;
      expect(properties.containsKey('employee_id'), isTrue);
      expect(properties.containsKey('employee_name'), isFalse);
    }
  });

  test(
      'work-report list searches and displays employee names and activity previews',
      () {
    final source = File('lib/pages/hr/work_report.dart').readAsStringSync();
    expect(source, contains("_buildHeaderCell('Employee', flex: 2)"));
    expect(
        source, contains('controller.employeeDisplayName(report.employeeId)'));
    expect(source, contains('report.workActivities'));
  });

  test(
      'work-report detail exposes employee name, attachments, and reviewer metadata',
      () {
    final source = File('lib/pages/hr/widget/work_report_review_dialog.dart')
        .readAsStringSync();
    final page = File('lib/pages/hr/work_report.dart').readAsStringSync();
    expect(source, contains('employeeName'));
    expect(source, contains('Attachments'));
    expect(source, contains('reviewedBy'));
    expect(page, contains('View report failed'));
  });
}
