import 'package:bomach_os/pages/hr/models/workspace_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('work location parses branch and administrative deactivation fields',
      () {
    final location = WorkspaceConfig.fromJson({
      'id': 18,
      'name': 'Enugu office',
      'location_type': 'branch',
      'latitude': '6.4412',
      'longitude': '7.4981',
      'branch_id': '4',
      'branch_name': 'Enugu',
      'status': 'APPROVED',
      'is_active': false,
      'is_expired': false,
      'deactivated_at': '2026-09-28T12:00:00Z',
      'deactivation_reason': 'admin',
      'deactivation_note': 'Branch moved',
    });

    expect(location.branchId, 4);
    expect(location.branchName, 'Enugu');
    expect(location.lifecycleLabel, 'Revoked');
    expect(location.deactivationNote, 'Branch moved');
    expect(location.canClockIn, isFalse);
  });

  test('expired approval is presented as expired, not generic inactive', () {
    final location = WorkspaceConfig.fromJson({
      'id': 19,
      'name': 'Temporary site',
      'latitude': 6.4,
      'longitude': 7.5,
      'status': 'APPROVED',
      'is_active': false,
      'is_expired': true,
      'deactivation_reason': 'expired',
    });

    expect(location.lifecycleLabel, 'Expired');
    expect(location.canClockIn, isFalse);
  });

  test('extension and audit responses preserve review context', () {
    final extension = WorkLocationExtension.fromJson({
      'id': 8,
      'work_location_id': 18,
      'location_name': 'Enugu office',
      'requested_by_id': 3,
      'requested_by_name': 'Ada Employee',
      'requested_expires_at': '2026-12-31T22:59:59Z',
      'expiry_at_request': '2026-10-01T22:59:59Z',
      'reason': 'Project continues through December.',
      'status': 'pending',
      'created_at': '2026-09-29T09:00:00Z',
    });
    final event = WorkLocationAuditEvent.fromJson({
      'id': 26,
      'event_type': 'admin_deactivated',
      'actor_name': 'A. Admin',
      'reason': 'Branch moved',
      'metadata': {'source': 'admin'},
      'created_at': '2026-09-29T09:10:00Z',
    });

    expect(extension.workLocationId, 18);
    expect(extension.requestedByName, 'Ada Employee');
    expect(extension.status, 'pending');
    expect(event.actorName, 'A. Admin');
    expect(event.metadata['source'], 'admin');
  });
}
