import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('review/view shows progress while loading report details', () {
    final source = File('lib/pages/hr/work_report.dart').readAsStringSync();

    expect(source, contains('barrierDismissible: false'));
    expect(source, contains('CircularProgressIndicator'));
    expect(source, contains('Navigator.of(context, rootNavigator: true).pop()'));
  });

  test('admin edit report resolves the full report before opening the dialog', () {
    final source = File('lib/pages/hr/work_report.dart').readAsStringSync();

    expect(source, contains('await _openReportForEdit(report, token);'));
    expect(
      source,
      contains('DailyWorkReportDialog(existingReport: fullReport'),
    );
  });
}
