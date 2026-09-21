import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('view details shows a blocking progress state while loading', () {
    final source =
        File('lib/pages/dashboad/my_work_reports.dart').readAsStringSync();

    expect(source, contains('barrierDismissible: false'));
    expect(source, contains('CircularProgressIndicator'));
    expect(source, contains('Navigator.of(context).pop()'));
  });

  test('edit resubmit resolves the full report before opening the form', () {
    final source =
        File('lib/pages/dashboad/my_work_reports.dart').readAsStringSync();

    expect(source, contains("await _openReportForEdit(report, token);"));
    expect(
        source, contains('DailyWorkReportDialog(existingReport: fullReport'));
  });

  test('successful edit does not use the disposed dialog context for its toast', () {
    final source =
        File('lib/pages/hr/widget/daily_work_report_dialog.dart').readAsStringSync();

    expect(source, contains('final navigatorContext = Navigator.of(context).context;'));
    expect(source, contains("AppToast.success(navigatorContext, 'Report submitted')"));
  });
}
