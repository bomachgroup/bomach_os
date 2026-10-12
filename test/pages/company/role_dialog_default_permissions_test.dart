import 'package:bomach_os/pages/company/controllers/roles_controller.dart';
import 'package:bomach_os/pages/company/widget/roles_dialogs.dart';
import 'package:bomach_os/src/model/role_model.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

void main() {
  setUp(() {
    Get.put(PermissionService()).testInjectPermissions(const {});
  });

  tearDown(Get.reset);

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

    final selectAll = find.text('Select All');
    await tester.ensureVisible(selectAll);
    await tester.tap(selectAll);
    await tester.pump();
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

  testWidgets('Select All state changes only after all actions are selected',
      (tester) async {
    final controller = buildController();
    await pumpCreateRoleDialog(tester, controller);

    expect(find.text('Select All'), findsOneWidget);
    final selectAll = find.text('Select All');
    await tester.ensureVisible(selectAll);
    await tester.tap(selectAll);
    await tester.pump();
    expect(find.text('Unselect All'), findsOneWidget);

    final unselectAll = find.text('Unselect All');
    await tester.ensureVisible(unselectAll);
    await tester.tap(unselectAll);
    await tester.pump();
    expect(find.text('Select All'), findsOneWidget);
  });

  testWidgets('description fields are hidden without description permission',
      (tester) async {
    await pumpCreateRoleDialog(tester, buildController());

    expect(find.text('Mission / Purpose'), findsNothing);
    expect(find.text('Job Description'), findsNothing);
    expect(find.text('Responsibilities'), findsNothing);
  });

  testWidgets('new description fields require create permission',
      (tester) async {
    Get.find<PermissionService>().testInjectPermissions(const {
      'role_descriptions': {'create'},
    });
    await pumpCreateRoleDialog(tester, buildController());

    expect(find.text('Mission / Purpose'), findsOneWidget);
  });

  testWidgets('edit role hides KPI controls without KPI list permission',
      (tester) async {
    final now = DateTime.now();
    final role = Role(
      id: 7,
      name: 'Operations Lead',
      permissions: const {},
      createdAt: now,
      updatedAt: now,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CreateEditRoleDialog(ctrl: buildController(), role: role),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('KPIs'), findsNothing);
    expect(find.text('Add KPI'), findsNothing);
  });

  test('default permission source remains the central baseline', () {
    expect(
      PermissionService.defaultEmployeePermissions['employees'],
      containsAll(['view_own', 'update_own']),
    );
  });
}
