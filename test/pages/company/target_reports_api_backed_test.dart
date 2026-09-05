import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('target report page uses the published target reports API', () {
    final page = File('lib/pages/hr/target_reports.dart').readAsStringSync();
    final controller =
        File('lib/pages/hr/controller/target_report_controller.dart')
            .readAsStringSync();

    expect(page, contains('My Target Reports'));
    expect(page, contains('TargetReportController'));
    expect(page, contains('Error loading target reports'));
    expect(controller, contains('listMine'));
    expect(controller, contains('create'));
    expect(controller, contains('approve'));
    expect(controller, contains('reject'));
  });
}
