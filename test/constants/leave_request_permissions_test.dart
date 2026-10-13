import 'package:bomach_os/src/app_routes/app_route_constants.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Leave request permission boundaries', () {
    test('self-service employees cannot open the all-requests page', () {
      final permissions = PermissionService()..loadDefaultPermissions();

      expect(permissions.has(Perms.leaveRequestsCreate), isTrue);
      expect(permissions.has(Perms.leaveRequestsListOwn), isTrue);
      expect(permissions.canAccessRouteTyped(RouteConstants.leaves), isTrue);
      expect(
        permissions.canAccessRouteTyped(RouteConstants.leaveRequest),
        isFalse,
      );
      expect(
        permissions.canAccessRoute(
          RouteConstants.leaveRequest,
          [PermissionConstants.resLeaveRequests],
        ),
        isFalse,
      );
    });

    test('the review queue requires the all-requests list permission', () {
      expect(
        routeRequirements[RouteConstants.leaveRequest],
        [Perms.leaveRequestsList],
      );

      final permissions = PermissionService()
        ..testInjectPermissions(const {
          'leave_requests': {'list'},
        });
      expect(
        permissions.canAccessRouteTyped(RouteConstants.leaveRequest),
        isTrue,
      );
      expect(permissions.has(Perms.leaveRequestsApprove), isFalse);
      expect(permissions.has(Perms.leaveRequestsReject), isFalse);
      expect(permissions.has(Perms.leaveRequestsUpdate), isFalse);
      expect(permissions.has(Perms.leaveRequestsCreate), isFalse);
    });

    test('approval and rejection permissions are independent', () {
      final permissions = PermissionService()
        ..testInjectPermissions(const {
          'leave_requests': {'approve'},
        });

      expect(permissions.has(Perms.leaveRequestsApprove), isTrue);
      expect(permissions.has(Perms.leaveRequestsReject), isFalse);
      expect(permissions.has(Perms.leaveRequestsUpdate), isFalse);
    });
  });
}
