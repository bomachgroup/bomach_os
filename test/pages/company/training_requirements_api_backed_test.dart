import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'role training uses role training requirements rather than audience heuristics',
      () {
    final controller =
        File('lib/pages/company/controllers/training_controller.dart')
            .readAsStringSync();
    final tab =
        File('lib/pages/company/widget/role_detail_tabs/training_tab.dart')
            .readAsStringSync();
    final serviceFiles = Directory('lib/src/services')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.toLowerCase().contains('training'))
        .map((file) => file.readAsStringSync())
        .join('\n');

    expect(
        serviceFiles, contains('/api/v1/roles/\$roleId/training-requirements'));
    expect(controller, contains('RoleTrainingRequirementService'));
    expect(controller, isNot(contains('targetAudience')));
    expect(controller, isNot(contains("audience.contains('role')")));
    expect(tab, contains('ctrl.errorMessage.value.isNotEmpty'));
  });
}
