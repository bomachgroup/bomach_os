import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('asset controller does not seed fictitious branch filters', () {
    final source = File('lib/pages/hr/controller/assets_controller.dart')
        .readAsStringSync();

    expect(source, contains('BranchService'));
    expect(source, contains('getBranches'));
    expect(source, isNot(contains('Enugu Branch')));
    expect(source, isNot(contains('Lagos Branch')));
    expect(source, isNot(contains('Abuja Branch')));
  });

  test('asset page exposes API errors instead of showing an empty success state', () {
    final source = File('lib/pages/hr/assets.dart').readAsStringSync();

    expect(source, contains('Error loading assets'));
    expect(source, contains('errorMessage'));
  });

  test('asset mutations are permission-gated', () {
    final source = File('lib/pages/hr/assets.dart').readAsStringSync();

    expect(source, contains('PermissionGate'));
    expect(source, contains('Perms.assetsCreate'));
    expect(source, contains('Perms.assetsUpdate'));
    expect(source, contains('Perms.assetsDelete'));
  });
}
