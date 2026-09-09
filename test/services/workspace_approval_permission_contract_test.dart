import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('workspace approval actions use the backend approval resource', () {
    final permissions = PermissionService();
    permissions.testInjectPermissions({
      'work_location_approvals': {'approve', 'reject'},
    });

    expect(Perms.workLocationsApprove.resource, 'work_location_approvals');
    expect(Perms.workLocationsReject.resource, 'work_location_approvals');
    expect(permissions.has(Perms.workLocationsApprove), isTrue);
    expect(permissions.has(Perms.workLocationsReject), isTrue);
  });
}
