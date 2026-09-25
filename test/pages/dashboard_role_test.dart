import 'package:bomach_os/pages/auth/controller.dart';
import 'package:bomach_os/pages/dashboad/role.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/model/role_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets(
      'role page renders role metadata, branches, and grouped permissions',
      (tester) async {
    final controller = AuthController();
    controller.currentRoles.assign(
      Role(
        id: 42,
        name: 'Operations Lead',
        branches: [RoleBranch(id: 7, branchName: 'Lagos')],
        permissions: {
          'roles': ['view_own'],
          'work_reports': ['list_own', 'create'],
        },
        createdAt: DateTime.utc(2026, 9, 1),
        updatedAt: DateTime.utc(2026, 9, 2),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: RolePage(controller: controller, autoRefresh: false),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Role'), findsWidgets);
    expect(find.text('Operations Lead'), findsOneWidget);
    expect(find.textContaining('Lagos'), findsOneWidget);
    expect(find.text('Work Reports'), findsOneWidget);
    expect(find.text('list_own'), findsOneWidget);
    expect(find.text('create'), findsOneWidget);
  });

  testWidgets('role page shows an explicit no-role state', (tester) async {
    final controller = AuthController();

    await tester.pumpWidget(
      MaterialApp(
        home: RolePage(controller: controller, autoRefresh: false),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No role assigned yet'), findsOneWidget);
  });

  testWidgets('role page shows forbidden state without fabricating permissions',
      (tester) async {
    final controller = AuthController();
    controller.currentRolesError.value = 'Access denied';
    controller.currentRolesErrorStatus.value = 403;

    await tester.pumpWidget(
      MaterialApp(
        home: RolePage(controller: controller, autoRefresh: false),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('You do not have permission to view your role details'),
      findsOneWidget,
    );
    expect(find.text('No permissions returned for this role.'), findsNothing);
  });

  testWidgets('role page remains usable at a phone width', (tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = AuthController();
    controller.currentRoles.assign(
      Role(
        id: 42,
        name: 'Operations Lead',
        permissions: const {
          'work_reports': ['list_own', 'create'],
        },
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: RolePage(controller: controller, autoRefresh: false),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PageScaffold), findsOneWidget);
    expect(find.text('Operations Lead'), findsOneWidget);
  });
}
