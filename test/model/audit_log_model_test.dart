import 'package:bomach_os/src/model/company_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps audit user and metadata fields from the API response', () {
    final auditLog = AuditLog.fromJson({
      'id': 7,
      'activity': 'Updated profile',
      'audit_type': 'update',
      'audit_type_display': 'Update',
      'audit_status': 'success',
      'audit_status_display': 'Success',
      'ip_address': '10.0.0.7',
      'metadata': {'source': 'web', 'resource_id': 12},
      'user': {
        'id': 3,
        'email': 'admin@example.com',
        'full_name': 'Admin User',
      },
      'created_at': '2026-03-01T10:00:00Z',
    });

    expect(auditLog.userId, 3);
    expect(auditLog.userEmail, 'admin@example.com');
    expect(auditLog.userFullName, 'Admin User');
    expect(auditLog.metadata, {'source': 'web', 'resource_id': 12});
  });
}
