import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  String read(String path) => File(path).readAsStringSync();

  void expectMultiline(String path, String marker) {
    final source = read(path);
    final markerIndex = source.indexOf(marker);
    expect(markerIndex, greaterThanOrEqualTo(0), reason: '$marker not found');

    final start = markerIndex > 160 ? markerIndex - 160 : 0;
    final end = (markerIndex + 520).clamp(0, source.length);
    final fieldSource = source.substring(start, end);
    expect(
      RegExp(r'maxLines\s*:\s*[2-9]').hasMatch(fieldSource),
      isTrue,
      reason: '$marker should expose a multiline input',
    );
  }

  test(
      'long-form company, HR, service, finance, and operations fields are multiline',
      () {
    expectMultiline(
      'lib/pages/company/widget/add_branch_dialog.dart',
      "title: 'Office Address'",
    );
    expectMultiline(
      'lib/pages/company/widget/add_partner_dialog.dart',
      "title: 'Address'",
    );
    expectMultiline(
      'lib/pages/company/widget/kpi_dialogs.dart',
      'controller: descCtrl',
    );
    expectMultiline(
      'lib/pages/hr/widget/add_associate_dialog.dart',
      "title: 'Address'",
    );
    expectMultiline(
      'lib/pages/hr/widget/add_candidate_dialog.dart',
      "title: 'Address/Location'",
    );
    expectMultiline(
      'lib/pages/hr/widget/add_candidate_dialog.dart',
      "title: 'Key Skills (Comma separated)'",
    );
    expectMultiline(
      'lib/pages/services/widget/add_estate_dialog.dart',
      "title: 'Precise Address *'",
    );
    expectMultiline(
      'lib/pages/services/widget/add_property_dialog.dart',
      "title: 'Location/Address*'",
    );
    expectMultiline(
      'lib/pages/finance/widget/generate_invoice_dialog.dart',
      "title: 'Description*'",
    );
    expectMultiline(
      'lib/pages/services/widget/add_invoice_dialog.dart',
      "title: 'Description*'",
    );
    expectMultiline(
      'lib/pages/operations/widget/add_project_dialog.dart',
      "title: 'Location'",
    );
    expectMultiline(
      'lib/pages/operations/widget/add_worksite_dialog.dart',
      "title: 'Location'",
    );
    expectMultiline(
      'lib/pages/services/land_survey_calculator.dart',
      "title: 'Location'",
    );
    expectMultiline(
      'lib/pages/services/services_calculator.dart',
      "title: 'Location'",
    );
    expectMultiline(
      'lib/pages/events/widget/add_event_dialog.dart',
      "title: 'Meeting Location'",
    );
    expectMultiline(
      'lib/pages/company/widget/broadcast_event_dialogs.dart',
      "hintText: 'Physical address or virtual link'",
    );
    expectMultiline(
      'lib/pages/company/widget/edit_company_dialog.dart',
      "title: 'Company Slogan'",
    );
  });

  test('workspace and operations message composers accept multiline messages',
      () {
    expectMultiline(
      'lib/pages/workspace/workspace_dashboard.dart',
      "hintText: 'Message #general...'",
    );
    expectMultiline(
      'lib/pages/operations/widget/meeting_table.dart',
      "hintText: 'Write a message...'",
    );
  });
}
