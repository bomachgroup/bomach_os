import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/pages/dashboad/dashboard.dart';
import 'package:bomach_os/pages/dashboad/my_profile.dart';
import 'package:bomach_os/pages/dashboad/my_tasks.dart';
import 'package:bomach_os/pages/dashboad/my_work_reports.dart';
import 'package:bomach_os/pages/employee/employee.dart';
import 'package:bomach_os/pages/finance/finance.dart';
import 'package:bomach_os/pages/workspace/workspace.dart';
import 'package:bomach_os/pages/crm/interactions.dart';
import 'package:bomach_os/pages/events/events.dart';
import 'package:bomach_os/pages/branch/branch.dart';
import 'package:bomach_os/pages/auth/controller.dart';
import 'package:bomach_os/src/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(() {
    Get.reset();
  });

  Future<void> pumpPage(
    WidgetTester tester,
    Widget page, {
    Size size = const Size(1440, 900),
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: Scaffold(body: page),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('dashboard uses the canonical responsive page frame',
      (tester) async {
    await pumpPage(tester, const DashboardScreen());

    expect(find.byType(PageScaffold), findsOneWidget);
  });

  testWidgets('my tasks uses the canonical responsive page frame',
      (tester) async {
    await pumpPage(tester, const MyTasksPage());

    expect(find.byType(PageScaffold), findsOneWidget);
  });

  testWidgets('my work reports uses the canonical responsive page frame',
      (tester) async {
    await pumpPage(tester, const MyWorkReportsPage());

    expect(find.byType(PageScaffold), findsOneWidget);
  });

  testWidgets('my profile uses the canonical responsive page frame',
      (tester) async {
    final authController = AuthController();
    Get.put(authController);
    authController.currentUser.value = User(
      userId: 1,
      username: 'test-admin',
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'Admin',
      isVerified: true,
      isActive: true,
      id: 1,
      branchId: 1,
      departmentId: 1,
      levelId: 1,
      createdAt: '2026-01-01T00:00:00Z',
    );
    await pumpPage(tester, const MyProfilePage());

    expect(find.byType(PageScaffold), findsOneWidget);
  });

  testWidgets('employee management uses the canonical responsive page frame',
      (tester) async {
    await pumpPage(tester, const EmployeePage());

    expect(find.byType(PageScaffold), findsOneWidget);
  });

  testWidgets('dashboard remains usable on a phone width', (tester) async {
    await pumpPage(tester, const DashboardScreen(), size: const Size(375, 800));
    expect(tester.takeException(), isNull);
  });

  testWidgets('my tasks remains usable on a phone width', (tester) async {
    await pumpPage(tester, const MyTasksPage(), size: const Size(375, 800));
    expect(tester.takeException(), isNull);
  });

  testWidgets('my work reports remains usable on a phone width',
      (tester) async {
    await pumpPage(tester, const MyWorkReportsPage(),
        size: const Size(375, 800));
    expect(tester.takeException(), isNull);
  });

  testWidgets('my work reports scrolls past summary cards on a compact phone',
      (tester) async {
    await pumpPage(tester, const MyWorkReportsPage(),
        size: const Size(375, 550));

    expect(tester.takeException(), isNull);
  });

  testWidgets('my profile remains usable on a phone width', (tester) async {
    final authController = AuthController();
    Get.put(authController);
    authController.currentUser.value = User(
      userId: 1,
      username: 'test-admin',
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'Admin',
      isVerified: true,
      isActive: true,
      id: 1,
      branchId: 1,
      departmentId: 1,
      levelId: 1,
      createdAt: '2026-01-01T00:00:00Z',
    );
    await pumpPage(tester, const MyProfilePage(), size: const Size(375, 800));
    expect(tester.takeException(), isNull);
  });

  testWidgets('finance overview remains usable on a phone width',
      (tester) async {
    await pumpPage(tester, const FinancePage(), size: const Size(375, 800));
    expect(tester.takeException(), isNull);
  });

  testWidgets('legacy workspace remains usable on a phone width',
      (tester) async {
    await pumpPage(tester, const WorkspacePage(), size: const Size(375, 800));
    expect(tester.takeException(), isNull);
  });

  testWidgets('CRM interactions remain usable on a phone width',
      (tester) async {
    await pumpPage(tester, const InteractionsPage(),
        size: const Size(375, 800));
    expect(tester.takeException(), isNull);
  });

  testWidgets('events remain usable on a phone width', (tester) async {
    await pumpPage(tester, const EventsPage(), size: const Size(375, 800));
    expect(tester.takeException(), isNull);
  });

  testWidgets('branch management remains usable on a phone width',
      (tester) async {
    await pumpPage(tester, const BranchPage(), size: const Size(375, 800));
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard remains usable on a tablet width', (tester) async {
    await pumpPage(tester, const DashboardScreen(),
        size: const Size(768, 1024));
    expect(tester.takeException(), isNull);
  });

  testWidgets('my tasks remains usable on a tablet width', (tester) async {
    await pumpPage(tester, const MyTasksPage(), size: const Size(768, 1024));
    expect(tester.takeException(), isNull);
  });

  testWidgets('my work reports remains usable on a tablet width',
      (tester) async {
    await pumpPage(
      tester,
      const MyWorkReportsPage(),
      size: const Size(768, 1024),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('my profile remains usable on a tablet width', (tester) async {
    final authController = AuthController();
    Get.put(authController);
    authController.currentUser.value = User(
      userId: 1,
      username: 'test-admin',
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'Admin',
      isVerified: true,
      isActive: true,
      id: 1,
      branchId: 1,
      departmentId: 1,
      levelId: 1,
      createdAt: '2026-01-01T00:00:00Z',
    );
    await pumpPage(
      tester,
      const MyProfilePage(),
      size: const Size(768, 1024),
    );
    expect(tester.takeException(), isNull);
  });
}
