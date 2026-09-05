import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const controllerPath =
      'lib/pages/hr/controller/training_program_controller.dart';
  const pagePath = 'lib/pages/hr/training_program.dart';

  test('training controller does not fabricate assessment data', () {
    final source = File(controllerPath).readAsStringSync();

    expect(source, isNot(contains('Mock')));
    expect(source, isNot(contains('Future.delayed')));
    expect(source, isNot(contains('Evelyn George')));
    expect(source, isNot(contains('Mathew Parker')));
    expect(source, isNot(contains('Silvia Torres')));
  });

  test('training page displays only API-backed program facts', () {
    final source = File(pagePath).readAsStringSync();

    expect(source, isNot(contains('Applicants: 5')));
    expect(source, isNot(contains('3 Weeks  •  Management')));
    expect(source, isNot(contains('totalEnrolled')));
    expect(source, contains('program.durationDays'));
    expect(source, contains('program.targetAudience'));
  });
}
