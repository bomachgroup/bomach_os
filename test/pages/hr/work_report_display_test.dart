import 'dart:io';

import 'package:bomach_os/pages/hr/controller/work_report_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('work-report list resolves employee names once and supports fallback text', () {
    final source = File('lib/pages/hr/controller/work_report_controller.dart')
        .readAsStringSync();
    expect(source, contains('employeeNames'));
    expect(source, contains('employeeDisplayName'));
    expect(source, contains('Employee name unavailable'));
  });

  test('employee display name uses the cached mapping and a readable fallback', () {
    final controller = WorkReportController();
    controller.employeeNames[8] = 'Ada Lovelace';

    expect(controller.employeeDisplayName(8), 'Ada Lovelace');
    expect(controller.employeeDisplayName(99), 'Employee name unavailable (ID: 99)');
  });

  test('work-report list searches and displays employee names and activity previews', () {
    final source = File('lib/pages/hr/work_report.dart').readAsStringSync();
    expect(source, contains("_buildHeaderCell('Employee', flex: 2)"));
    expect(source, contains('controller.employeeDisplayName(report.employeeId)'));
    expect(source, contains('report.workActivities'));
  });

  test('work-report detail exposes employee name, attachments, and reviewer metadata', () {
    final source =
        File('lib/pages/hr/widget/work_report_review_dialog.dart').readAsStringSync();
    final page = File('lib/pages/hr/work_report.dart').readAsStringSync();
    expect(source, contains('employeeName'));
    expect(source, contains('Attachments'));
    expect(source, contains('reviewedBy'));
    expect(page, contains('View report failed'));
  });
}
