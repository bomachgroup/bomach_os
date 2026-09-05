import 'package:flutter_test/flutter_test.dart';
import 'package:bomach_os/pages/hr/asset_action_permissions.dart';

void main() {
  test('asset actions always include view and only include permitted mutations', () {
    expect(
      visibleAssetActions(canEdit: false, canDelete: false),
      ['view'],
    );
    expect(
      visibleAssetActions(canEdit: true, canDelete: false),
      ['view', 'edit'],
    );
    expect(
      visibleAssetActions(canEdit: false, canDelete: true),
      ['view', 'delete'],
    );
    expect(
      visibleAssetActions(canEdit: true, canDelete: true),
      ['view', 'edit', 'delete'],
    );
  });
}
