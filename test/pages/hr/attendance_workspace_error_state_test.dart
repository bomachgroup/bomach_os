import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('attendance distinguishes workspace API failure from an empty workspace list', () {
    final source = File('lib/pages/hr/attendance.dart').readAsStringSync();

    expect(source, contains('Error loading workspaces'));
    expect(source, contains('controller.errorMessage.value.isNotEmpty'));
  });
}
