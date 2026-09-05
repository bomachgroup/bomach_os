import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('daily attendance rows do not invent employee identity or role data', () {
    final model = File('lib/pages/hr/models/attendance_models.dart').readAsStringSync();
    final controller = File('lib/pages/hr/controller/biometrics_controller.dart').readAsStringSync();

    expect(model, isNot(contains('Placeholder')));
    expect(controller, isNot(contains('employeeName: "Current User"')));
    expect(controller, isNot(contains('role: "Employee"')));
  });
}
