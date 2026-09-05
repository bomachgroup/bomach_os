import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const consumers = [
    'lib/pages/hr/controller/department_controller.dart',
    'lib/pages/operations/widget/add_task_dialog.dart',
  ];

  test('all direct department consumers use the published organization path', () {
    for (final path in consumers) {
      final source = File(path).readAsStringSync();
      expect(source, contains('/api/v1/organization/department'), reason: path);
      expect(source, isNot(contains('/api/v1/employees/department')), reason: path);
    }
  });
}
