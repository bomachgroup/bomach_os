import 'package:bomach_os/pages/hr/models/assets_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Asset.fromJson preserves nullable integer assignment fields', () {
    final asset = Asset.fromJson({
      'name': 'Company laptop',
      'asset_type': 'Laptop',
      'branch': 'HQ',
      'assigned_to_id': 42,
      'department_id': 7,
      'status': 'assigned',
      'documents': [],
    });

    expect(asset.assignedToId, 42);
    expect(asset.departmentId, 7);
  });

  test('Asset.fromJson preserves the OpenAPI documents array', () {
    final asset = Asset.fromJson({
      'name': 'Company laptop',
      'asset_type': 'Laptop',
      'branch': 'HQ',
      'status': 'available',
      'documents': [
        {'name': 'Invoice', 'url': 'https://example.test/invoice.pdf'},
      ],
    });

    expect(asset.documents, isA<List<dynamic>>());
    expect(asset.documents, hasLength(1));
  });
}
