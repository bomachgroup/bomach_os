import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('router remembers the requested URI while authentication initializes', () {
    final source = File('lib/src/app_routes/app_router.dart').readAsStringSync();
    expect(source, contains('_pendingReturnUri'));
    expect(source, contains('state.uri.toString()'));
    expect(source, contains('overridePlatformDefaultLocation: false'));
    expect(source, contains('_pendingReturnUri = null'));
    expect(source, contains('if (!isLoggedIn && location == RouteConstants.login)'));
  });

  test('role detail route has a durable role id path', () {
    final constants = File('lib/src/app_routes/app_route_constants.dart').readAsStringSync();
    final router = File('lib/src/app_routes/app_router.dart').readAsStringSync();
    expect(constants, contains("roleDetailPath(int roleId)"));
    expect(router, contains('state.pathParameters'));
    expect(router, contains('RoleDetailPage(roleId: roleId)'));
    expect(router.indexOf('buildRoute(path),') <
        router.indexOf("buildRoute('/company/roles/:roleId'"), isTrue);
  });

  test('estate detail routes have URL identifiers and fetch by id', () {
    final constants =
        File('lib/src/app_routes/app_route_constants.dart').readAsStringSync();
    final router = File('lib/src/app_routes/app_router.dart').readAsStringSync();
    final management =
        File('lib/pages/services/estate_management.dart').readAsStringSync();
    expect(constants, contains('estateDetailPath(int estateId)'));
    expect(constants, contains('estatePerformancePath(int estateId)'));
    expect(router, contains("'/services/estate/:estateId'"));
    expect(router, contains("'/services/estate-performance/:estateId'"));
    expect(router, contains('getEstate'));
    expect(management, contains('RouteConstants.estateDetailPath(estate.id)'));
    expect(router.indexOf('buildRoute(path),') <
        router.indexOf("buildRoute(durablePath, durableEstatePath: true)"), isTrue);
  });
}
