import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('branch detail tabs do not present fabricated branch records', () {
    final source = File(
      'lib/pages/company/widget/view_branch_dialog.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('mockDepartments')));
    expect(source, isNot(contains('mockProjects')));
    expect(source, isNot(contains('_buildMockTransactions')));
    expect(source, isNot(contains('mockPeople')));
    expect(source, isNot(contains('This tab uses sample data')));
    expect(source, contains('BackendCapabilityUnavailable'));
  });
}
