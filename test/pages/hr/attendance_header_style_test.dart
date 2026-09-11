import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('attendance status chips use readable light-mode colors', () {
    final source = File('lib/pages/hr/attendance.dart').readAsStringSync();

    expect(source, contains('color: AppColors.primarySubtle'));
    expect(source, contains('border: Border.all(color: AppColors.primarySoft)'));
    expect(source, contains('color: AppColors.textPrimary'));
  });
}
