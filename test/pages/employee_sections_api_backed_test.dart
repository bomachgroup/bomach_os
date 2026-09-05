import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const pages = {
    'employee_attendance.dart': 'AttendancePage',
    'employee_performance.dart': 'PerformanceReviewPage',
    'employee_training.dart': 'TrainingProgramPage',
  };

  for (final entry in pages.entries) {
    test('${entry.key} delegates to ${entry.value}', () {
      final source = File('lib/pages/employee/${entry.key}').readAsStringSync();

      expect(source, contains(entry.value));
      expect(source, isNot(contains('No ${entry.key.split('_')[1]} records found')));
    });
  }
}
