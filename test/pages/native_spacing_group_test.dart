import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/pages/analytics/overview.dart';
import 'package:bomach_os/pages/analytics/revenue.dart';
import 'package:bomach_os/pages/analytics/projects.dart';
import 'package:bomach_os/pages/analytics/performance.dart';
import 'package:bomach_os/pages/analytics/branch_performance_analysis.dart';
import 'package:bomach_os/pages/branch/branch.dart';
import 'package:bomach_os/pages/client/clients_database.dart';
import 'package:bomach_os/pages/crm/interactions.dart';
import 'package:bomach_os/pages/crm/lead.dart';
import 'package:bomach_os/pages/events/events.dart';
import 'package:bomach_os/pages/finance/budget.dart';
import 'package:bomach_os/pages/finance/finance.dart';
import 'package:bomach_os/pages/legal/legal.dart';
import 'package:bomach_os/pages/security/security.dart';
import 'package:bomach_os/pages/services/service_leads.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:bomach_os/pages/workspace/workspace.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  Future<void> expectResponsiveFrame(
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
    expect(find.byType(PageScaffold), findsOneWidget);
  }

  testWidgets('finance overview uses the canonical responsive page frame',
      (tester) async {
    await expectResponsiveFrame(tester, const FinancePage());
  });

  testWidgets('budget uses the canonical responsive page frame',
      (tester) async {
    await expectResponsiveFrame(tester, const BudgetPage());
  });

  testWidgets('legacy workspace uses the canonical responsive page frame',
      (tester) async {
    await expectResponsiveFrame(tester, const WorkspacePage());
  });

  testWidgets('analytics overview uses the canonical responsive page frame',
      (tester) async {
    await expectResponsiveFrame(tester, const AnalyticsOverviewPage());
  });

  testWidgets('analytics revenue uses the canonical responsive page frame',
      (tester) async {
    await expectResponsiveFrame(tester, const RevenueAnalyticsPage());
  });

  testWidgets('analytics projects uses the canonical responsive page frame',
      (tester) async {
    await expectResponsiveFrame(tester, const ProjectsAnalytics());
  });

  testWidgets('analytics performance uses the canonical responsive page frame',
      (tester) async {
    await expectResponsiveFrame(tester, const PerformanceAnalytics());
  });

  testWidgets('branch performance uses the canonical responsive page frame',
      (tester) async {
    await expectResponsiveFrame(tester, const BranchPerformanceAnalysisPage());
  });

  testWidgets('CRM leads uses the canonical responsive page frame',
      (tester) async {
    await expectResponsiveFrame(tester, const CrmLeadsPage());
  });

  testWidgets('CRM interactions uses the canonical responsive page frame',
      (tester) async {
    await expectResponsiveFrame(tester, const InteractionsPage());
  });

  testWidgets('events uses the canonical responsive page frame',
      (tester) async {
    await expectResponsiveFrame(tester, const EventsPage());
  });

  testWidgets('security uses the canonical responsive page frame',
      (tester) async {
    await expectResponsiveFrame(tester, const SecurityPage(page: 1));
  });

  testWidgets('service leads uses the canonical responsive page frame',
      (tester) async {
    Get.put(PermissionService());
    await expectResponsiveFrame(tester, const ServiceLeadsPage());
  });

  testWidgets('legal uses the canonical responsive page frame', (tester) async {
    await expectResponsiveFrame(tester, const LegalsPage());
  });

  testWidgets('branch uses the canonical responsive page frame',
      (tester) async {
    await expectResponsiveFrame(tester, const BranchPage());
  });

  testWidgets('clients database uses the canonical responsive page frame',
      (tester) async {
    await expectResponsiveFrame(tester, const ClientsDatabasePage());
  });

  testWidgets('analytics pages remain usable on a phone width', (tester) async {
    await expectResponsiveFrame(
      tester,
      const RevenueAnalyticsPage(),
      size: const Size(375, 800),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('analytics projects remain usable on a phone width',
      (tester) async {
    await expectResponsiveFrame(
      tester,
      const ProjectsAnalytics(),
      size: const Size(375, 800),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('analytics performance remains usable on a phone width',
      (tester) async {
    await expectResponsiveFrame(
      tester,
      const PerformanceAnalytics(),
      size: const Size(375, 800),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('branch performance remains usable on a phone width',
      (tester) async {
    await expectResponsiveFrame(
      tester,
      const BranchPerformanceAnalysisPage(),
      size: const Size(375, 800),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('budget remains usable on a phone width', (tester) async {
    await expectResponsiveFrame(
      tester,
      const BudgetPage(),
      size: const Size(375, 800),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('legacy workspace remains usable on a phone width',
      (tester) async {
    await expectResponsiveFrame(
      tester,
      const WorkspacePage(),
      size: const Size(375, 800),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('CRM leads remain usable on a phone width', (tester) async {
    await expectResponsiveFrame(
      tester,
      const CrmLeadsPage(),
      size: const Size(375, 800),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('legal remains usable on a phone width', (tester) async {
    await expectResponsiveFrame(
      tester,
      const LegalsPage(),
      size: const Size(375, 800),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('security remains usable on a phone width', (tester) async {
    await expectResponsiveFrame(
      tester,
      const SecurityPage(page: 1),
      size: const Size(375, 800),
    );
    expect(tester.takeException(), isNull);
  });
}
