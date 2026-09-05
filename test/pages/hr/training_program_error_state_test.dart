import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('training programs expose API errors with a retry action', () {
    final source =
        File('lib/pages/hr/training_program.dart').readAsStringSync();

    expect(source, contains('_ctrl.errorMessage.value'));
    expect(source, contains('Retry'));
    expect(source, contains('_ctrl.fetchData()'));
  });
}
