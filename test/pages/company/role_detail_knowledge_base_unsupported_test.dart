import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('role detail knowledge base does not consume an unsupported API', () {
    final source = File(
            'lib/pages/company/widget/role_detail_tabs/knowledge_base_tab.dart')
        .readAsStringSync();

    expect(source, contains('BackendCapabilityUnavailable'));
    expect(source, contains('Knowledge Base'));
    expect(source, isNot(contains('RoleKnowledgeBaseController')));
    expect(source, isNot(contains('fetchEntries')));
  });
}
