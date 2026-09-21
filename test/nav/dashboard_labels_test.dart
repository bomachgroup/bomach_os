import 'package:flutter_test/flutter_test.dart';
import 'package:bomach_os/src/app_routes/menu_structure.dart';

void main() {
  test('dashboard uses user-facing labels without the My prefix', () {
    final dashboard = sidebarStructure
        .expand((section) => section.items)
        .firstWhere((item) => item.label == 'Dashboard');

    final labels = dashboard.children.map((child) => child.label).toList();

    expect(labels, containsAll(<String>[
      'Overview',
      'Profile',
      'Tasks',
      'Work Reports',
      'Target',
    ]));
    expect(labels.where((label) => label.startsWith('My ')), isEmpty);
  });
}
