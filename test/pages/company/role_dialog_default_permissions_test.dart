import 'package:bomach_os/pages/company/controllers/roles_controller.dart';
import 'package:bomach_os/pages/company/widget/roles_dialogs.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax/iconsax.dart';

void main() {
  RolesController buildController() {
    final controller = RolesController();
    controller.permissionsMap
      ..clear()
      ..addAll({
        'employees': ['view_own', 'update_own', 'list'],
        'dashboard': ['view'],
        'work_reports': ['create', 'view_own'],
      })
      ..refresh();
    return controller;
  }

  Future<void> pumpCreateRoleDialog(
    WidgetTester tester,
    RolesController controller,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(splashFactory: NoSplash.splashFactory),
        home: Scaffold(
          body: CreateEditRoleDialog(ctrl: controller),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder actionChip(String label) {
    return find
        .ancestor(
          of: find.text(label),
          matching: find.byType(InkWell),
        )
        .first;
  }

  testWidgets('new roles start with the supported default permissions ticked',
      (tester) async {
    final controller = buildController();
    await pumpCreateRoleDialog(tester, controller);

    expect(
      find.descendant(
        of: actionChip('Update Own'),
        matching: find.byIcon(Iconsax.tick_circle),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: actionChip('View'),
        matching: find.byIcon(Iconsax.tick_circle),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: actionChip('List'),
        matching: find.byIcon(Iconsax.tick_circle),
      ),
      findsNothing,
    );
  });

  testWidgets('Apply Default Permissions restores the baseline selection',
      (tester) async {
    final controller = buildController();
    await pumpCreateRoleDialog(tester, controller);

    expect(find.text('Apply Default Permissions'), findsOneWidget);

    final unselectAll = find.text('Unselect All');
    await tester.ensureVisible(unselectAll);
    await tester.tap(unselectAll);
    await tester.pump();
    expect(
      find.descendant(
        of: actionChip('Update Own'),
        matching: find.byIcon(Iconsax.tick_circle),
      ),
      findsNothing,
    );

    final applyDefaults = find.text('Apply Default Permissions');
    await tester.ensureVisible(applyDefaults);
    await tester.tap(applyDefaults);
    await tester.pump();
    expect(
      find.descendant(
        of: actionChip('Update Own'),
        matching: find.byIcon(Iconsax.tick_circle),
      ),
      findsOneWidget,
    );
  });

  test('default permission source remains the central baseline', () {
    expect(
      PermissionService.defaultEmployeePermissions['employees'],
      containsAll(['view_own', 'update_own']),
    );
  });
}
