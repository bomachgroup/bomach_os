import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('approval workflow tabs expose API failures separately from empty data',
      () {
    final page =
        File('lib/pages/company/approval_workflow.dart').readAsStringSync();
    final controller =
        File('lib/pages/company/controllers/approval_controller.dart')
            .readAsStringSync();

    expect(page, contains('controller.flowErrorMessage.value.isNotEmpty'));
    expect(page, contains('controller.requestErrorMessage.value.isNotEmpty'));
    expect(page, contains('Error loading approval workflows'));
    expect(page, contains('Error loading approval requests'));
    expect(controller, contains('flowErrorMessage'));
    expect(controller, contains('requestErrorMessage'));
  });
}
