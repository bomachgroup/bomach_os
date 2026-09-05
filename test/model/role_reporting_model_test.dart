import 'package:bomach_os/src/model/role_reporting_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses reports-to and direct-report role nodes', () {
    final tree = RoleReportingTree.fromJson({
      'role_id': 12,
      'reports_to': {'id': 3, 'name': 'Chief Operating Officer'},
      'direct_reports': [
        {'id': 21, 'name': 'Site Manager'},
        {'id': 22, 'name': 'Facilities Manager'},
      ],
    });

    expect(tree.roleId, 12);
    expect(tree.reportsTo?.name, 'Chief Operating Officer');
    expect(tree.directReports.map((node) => node.id), [21, 22]);
  });

  test('supports an empty reporting tree without fabricating roles', () {
    final tree = RoleReportingTree.fromJson({'role_id': 12});

    expect(tree.reportsTo, isNull);
    expect(tree.directReports, isEmpty);
  });
}
