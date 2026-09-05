import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('operations task detail is an active dashboard route registration', () {
    final source = File('lib/src/app_routes/app_router.dart').readAsStringSync();

    expect(
      RegExp(r'^\s*RouteConstants\.operationsTaskDetail\s*:', multiLine: true)
          .hasMatch(source),
      isTrue,
      reason: 'The operations task detail route must be registered, not commented out.',
    );
  });
}
