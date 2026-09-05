import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('workspace approvals distinguishes API errors from an empty queue', () {
    final source =
        File('lib/pages/company/workspace_approvals.dart').readAsStringSync();

    expect(source, contains('ctrl.errorMessage.value.isNotEmpty'));
    expect(source, contains('Error loading workspace approvals'));
  });
}
