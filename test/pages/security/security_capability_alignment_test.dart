import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const securityRoot = 'lib/pages/security';

  test('security tabs do not render local mock datasets', () {
    const activeSlides = [
      '$securityRoot/slides/codes.dart',
      '$securityRoot/slides/alerts.dart',
      '$securityRoot/slides/workflow.dart',
      '$securityRoot/slides/overview_slide.dart',
    ];

    for (final path in activeSlides) {
      final source = File(path).readAsStringSync();
      expect(source, isNot(contains('mock')),
          reason: '$path must not render fabricated security data');
    }
  });

  test('unsupported security code and alert capabilities are explicit', () {
    for (final path in [
      '$securityRoot/slides/codes.dart',
      '$securityRoot/slides/alerts.dart',
    ]) {
      final source = File(path).readAsStringSync();
      expect(source, contains('BackendCapabilityUnavailable'), reason: path);
      expect(source, contains('backend'), reason: path);
    }
  });

  test('security overview does not expose fake generation or metric counts',
      () {
    final source = File('$securityRoot/security.dart').readAsStringSync();

    expect(source, isNot(contains('GenerateSecurityCodeDialog')));
    expect(source, isNot(contains('showSecurityCodeDialog')));
    expect(source, isNot(contains('securityMetrics')));
  });

  test('orphaned security fixture files are removed from the production tree',
      () {
    for (final path in [
      '$securityRoot/model.dart',
      '$securityRoot/dialogs/generate_code.dart',
      '$securityRoot/dialogs/workflow_approval.dart',
    ]) {
      expect(File(path).existsSync(), isFalse, reason: path);
    }
  });

  test('security workflow and audit routes use supported API-backed pages', () {
    final source =
        File('lib/src/app_routes/app_router.dart').readAsStringSync();

    expect(
        source,
        contains(
            'RouteConstants.securityWorkflow: const ApprovalWorkflowPage()'));
    expect(
        source, contains('RouteConstants.securityLogs: const AuditLogPage()'));
  });
}
