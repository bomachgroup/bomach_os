import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('authority limits page consumes the authority-limit controller', () {
    final source =
        File('lib/pages/company/authority_limits.dart').readAsStringSync();

    expect(source, contains('AuthorityLimitController'));
    expect(source, contains('authorityLimits'));
    expect(source, contains('No authority limits found'));
    expect(source, isNot(contains('ComingSoonTab')));
  });

  test('authority limits page shows the contract fields', () {
    final source =
        File('lib/pages/company/authority_limits.dart').readAsStringSync();

    expect(source, contains('limit.resource'));
    expect(source, contains('limit.action'));
    expect(source, contains('limit.maxAmount'));
    expect(source, contains('limit.maxQuantity'));
    expect(source, contains('limit.approvalLevel'));
  });

  test('authority-limit controller exposes request failures to the UI', () {
    final source = File(
      'lib/pages/company/controllers/authority_limit_controller.dart',
    ).readAsStringSync();

    expect(source, contains("errorMessage.value = '"));
  });
}
