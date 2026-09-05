import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('performance review screen wires search and visible error state', () {
    final page =
        File('lib/pages/hr/performance_review.dart').readAsStringSync();
    final controller =
        File('lib/pages/hr/controller/performance_review_controller.dart')
            .readAsStringSync();

    expect(page, contains('controller.onSearchChanged'));
    expect(page, contains('Error loading performance reviews'));
    expect(controller, contains('searchQuery'));
    expect(controller, contains('employeeId: query'));
  });
}
