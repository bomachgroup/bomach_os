import 'package:bomach_os/pages/hr/models/workspace_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('backend can_be_used=false blocks clock-in even when approved', () {
    final workspace = WorkspaceConfig.fromJson({
      'id': 1,
      'name': 'HQ',
      'location_type': 'branch',
      'latitude': 6.52,
      'longitude': 3.37,
      'allowed_radius_meters': 100,
      'status': 'APPROVED',
      'is_active': true,
      'is_expired': false,
      'can_be_used': false,
    });

    expect(workspace.canClockIn, isFalse);
  });
}
