import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('role SOP tab exposes controller errors separately from empty state',
      () {
    final source =
        File('lib/pages/company/widget/role_detail_tabs/sop_tab.dart')
            .readAsStringSync();

    expect(source, contains('ctrl.errorMessage.value.isNotEmpty'));
    expect(source, contains('Error loading SOPs'));
  });

  test('SOP selection uses the role department instead of a default department',
      () {
    final roleDetailSource =
        File('lib/pages/company/role_detail.dart').readAsStringSync();
    final tabSource =
        File('lib/pages/company/widget/role_detail_tabs/sop_tab.dart')
            .readAsStringSync();
    final dialogSource =
        File('lib/pages/company/widget/sop_dialog.dart').readAsStringSync();

    expect(roleDetailSource, contains('departmentId: role.departmentId'));
    expect(tabSource, contains('final int? departmentId'));
    expect(tabSource, contains('departmentId: departmentId'));
    expect(dialogSource,
        contains('fetchAvailableSops(deptId: widget.departmentId)'));
  });
}
