import 'package:bomach_os/src/app_routes/app_route_constants.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/model/role_model.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:bomach_os/pages/hr/controller/leave_request_controller.dart';
import 'package:bomach_os/src/model/user_model.dart';
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

    test('admin role labels do not replace explicit leave review permissions',
        () {
      final permissions = PermissionService()
        ..loadPermissions([
          Role(
            id: 1,
            name: 'CEO',
            permissions: const {},
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        ]);

      expect(permissions.isSuperAdmin, isTrue);
      expect(permissions.has(Perms.leaveRequestsList), isTrue);
      expect(permissions.hasExplicit(Perms.leaveRequestsList), isFalse);
      expect(permissions.canAccessRouteTyped(RouteConstants.leaveRequest),
          isFalse);
    });

    test('self-review compares Employee profile IDs, not auth account IDs', () {
      final profile = User.fromJson(const {
        'user_id': 7,
        'id': 3,
        'username': 'employee',
        'email': 'employee@example.com',
        'first_name': 'Test',
        'last_name': 'Employee',
        'is_verified': true,
        'is_active': true,
        'branch_id': 1,
        'department_id': 1,
        'level_id': 1,
        'created_at': '2026-01-01T00:00:00Z',
      });

      expect(profile.userId, 7);
      expect(profile.id, 3);
      expect(
        LeaveRequestController.isOwnRequest(
          currentEmployeeRecordId: profile.id,
          requestEmployeeId: '3',
        ),
        isTrue,
      );
      expect(
        LeaveRequestController.isOwnRequest(
          currentEmployeeRecordId: profile.id,
          requestEmployeeId: '7',
        ),
        isFalse,
      );
    });
  });
}
