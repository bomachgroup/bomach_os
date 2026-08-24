import 'package:bomach_os/src/app_routes/app_route_constants.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Spec — Awards & Recognition is a boss/HR-only area of the HR module.
///
/// The default employee baseline grants `awards: {list_own}` to EVERYONE,
/// so the old requirement `[awardsListOwn, awardsList]` let every staff
/// member see the award management section. The route (and therefore the
/// sidebar entry, via `canAccessRoute`) must now require the ADMIN-level
/// `awards:list` action — regular employees keep no access.
void main() {
  group('Awards & Recognition gating', () {
    test('route requires the admin awards:list action', () {
      final required = routeRequirements[RouteConstants.awardsRecognition];
      expect(required, isNotNull);
      expect(required, contains(Perms.awardsList));
      expect(required, isNot(contains(Perms.awardsListOwn)),
          reason: 'list_own is a default-employee action; allowing it '
              'defeats the boss/HR-only gate');
    });

    test('default employee CANNOT access awards & recognition', () {
      final service = PermissionService()..loadDefaultPermissions();
      expect(service.canAccessRouteTyped(RouteConstants.awardsRecognition),
          isFalse);
    });

    test('user with admin awards:list access CAN access it', () {
      final service = PermissionService();
      service.testInjectPermissions(const {
        'awards': {'list'},
      });
      expect(service.canAccessRouteTyped(RouteConstants.awardsRecognition),
          isTrue);
    });
  });
}
