import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('target reports has a registered dashboard route', () {
    final constants =
        File('lib/src/app_routes/app_route_constants.dart').readAsStringSync();
    final router =
        File('lib/src/app_routes/app_router.dart').readAsStringSync();
    final paths = File('lib/src/app_routes/dashboard_route_paths.dart')
        .readAsStringSync();

    expect(constants, contains('employeeMyTargetReports'));
    expect(router, contains('TargetReportsPage'));
    expect(paths, contains("'/dashboard/my-target-reports'"));
  });
}
