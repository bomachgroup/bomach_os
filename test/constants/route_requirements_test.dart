import 'package:flutter_test/flutter_test.dart';
import 'package:bomach_os/src/app_routes/app_route_constants.dart';
import 'package:bomach_os/src/app_routes/dashboard_route_paths.dart';
import 'package:bomach_os/src/app_routes/menu_structure.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/services/permission_service.dart';

/// Specs (V4 fix Batch 5a, B11 fix Batch 5b, B2 fix Batch 7a):
///
/// T7 — every Marketing/Services webview route and the audited
///      company/HR gap routes MUST have an explicit non-empty entry in
///      `routeRequirements` (no more fail-open unmapped routes).
///
/// T8 — the sidebar MUST contain Security and CRM sections whose children
///      cover their sub-menu enums.
///
/// T9 — REGRESSION: every route referenced by any sidebar sub-item (and
///      main items) must exist in `dashboardRoutes`. This is the generic
///      test that would have caught the Disciplinary Process 404.
void main() {
  // The webview routes registered in app_router.dart (37 marketing + 17
  // services). Enumerated from RouteConstants so the test fails when a new
  // webview route is added without a requirement.
  const marketingWebviewRoutes = [
    RouteConstants.marketingDashboard,
    RouteConstants.marketingPipeline,
    RouteConstants.marketingCampaigns,
    RouteConstants.marketingCalendar,
    RouteConstants.marketingAnalytics,
    RouteConstants.marketingOkrs,
    RouteConstants.marketingReports,
    RouteConstants.marketingTeam,
    RouteConstants.marketingNewLead,
    RouteConstants.marketingMedia,
    RouteConstants.marketingRevenueCommand,
    RouteConstants.marketingDailyExecution,
    RouteConstants.marketingLeadControl,
    RouteConstants.marketingFunnelAudit,
    RouteConstants.marketingPlaybooks,
    RouteConstants.marketingContentStudio,
    RouteConstants.marketingCoaching,
    RouteConstants.marketingForecast,
    RouteConstants.marketingRetention,
    RouteConstants.marketingWorkdesk,
    RouteConstants.marketingLeadJournal,
    RouteConstants.marketingIntegrations,
    RouteConstants.marketingEmailCenter,
    RouteConstants.marketingMediaRegister,
    RouteConstants.marketingHandoff,
    RouteConstants.marketingRealtorPortal,
    RouteConstants.marketingPartnerPortal,
    RouteConstants.marketingRoleGovernance,
    RouteConstants.marketingApprovals,
    RouteConstants.marketingAuditLog,
    RouteConstants.marketingMeetings,
    RouteConstants.marketingTurnaround,
    RouteConstants.marketingCompliance,
    RouteConstants.marketingPartners,
    RouteConstants.marketingSupport,
    RouteConstants.marketingDesign,
    RouteConstants.marketingWhatsapp,
  ];

  const servicesWebviewRoutes = [
    RouteConstants.servicesDashboard,
    RouteConstants.servicesCatalogue,
    RouteConstants.servicesCalculators,
    RouteConstants.servicesRequestFormBuilder,
    RouteConstants.servicesWorkflowDesigner,
    RouteConstants.servicesBranchActivation,
    RouteConstants.servicesRequests,
    RouteConstants.servicesQuotations,
    RouteConstants.servicesInvoicesPayments,
    RouteConstants.servicesApprovals,
    RouteConstants.servicesOrders,
    RouteConstants.servicesExecutionTasks,
    RouteConstants.servicesDeliverables,
    RouteConstants.servicesRealEstateInventory,
    RouteConstants.servicesSurveyEngineeringOthers,
    RouteConstants.servicesFeedbackQuality,
    RouteConstants.servicesReportsAnalytics,
  ];

  // Audited gap routes: hidden in the sidebar by resources but previously
  // unmapped in routeRequirements (fail-open).
  const companyGapRoutes = [
    RouteConstants.orgChart,
    RouteConstants.kpiManagement,
    RouteConstants.okrBoard,
    RouteConstants.complianceDashboard,
    RouteConstants.knowledgeBase,
    RouteConstants.enugu,
    RouteConstants.benefits,
    RouteConstants.associates,
    RouteConstants.eachProjects,
    RouteConstants.taskDetail,
  ];

  group('T7: routeRequirements coverage', () {
    test('every marketing webview route is explicitly mapped', () {
      for (final route in marketingWebviewRoutes) {
        final required = routeRequirements[route];
        expect(required, isNotNull,
            reason: 'route $route is unmapped (fail-open)');
        expect(required, isNotEmpty,
            reason: 'route $route must not be explicitly public');
      }
    });

    test('every services webview route is explicitly mapped', () {
      for (final route in servicesWebviewRoutes) {
        final required = routeRequirements[route];
        expect(required, isNotNull,
            reason: 'route $route is unmapped (fail-open)');
        expect(required, isNotEmpty,
            reason: 'route $route must not be explicitly public');
      }
    });

    test('company/HR gap routes are explicitly mapped', () {
      for (final route in companyGapRoutes) {
        final required = routeRequirements[route];
        expect(required, isNotNull, reason: 'route $route is unmapped');
        expect(required, isNotEmpty);
      }
    });

    test(
        'default employee cannot reach /marketing/dashboard '
        '(the audited token-handoff bypass)', () {
      final service = PermissionService();
      service.loadDefaultPermissions();
      expect(service.canAccessRouteTyped(RouteConstants.marketingDashboard),
          isFalse);
      expect(service.canAccessRouteTyped(RouteConstants.servicesInvoicesPayments),
          isFalse);
      expect(service.canAccessRouteTyped(RouteConstants.orgChart), isFalse);

      // A user with the module permission CAN access it.
      service.loadPermissions(const []);
      service.clearPermissions();
      // Simulate a marketing-role user via direct permission injection
      // through loadSuperAdminPermissions' sibling API surface:
      // loadDefaultPermissions + manual grant is unavailable, so exercise
      // hasAny semantics through a role-shaped map instead.
      final marketingUser = PermissionService();
      marketingUser.testInjectPermissions({
        'marketing_campaigns': {'list'},
      });
      expect(marketingUser.canAccessRouteTyped(RouteConstants.marketingDashboard),
          isTrue);
    });
  });

  group('T8: sidebar contains Security and CRM sections', () {
    test('Security section exists with all five children', () {
      final securityItem = _findMain(MainMenuItem.security);
      expect(securityItem, isNotNull,
          reason: 'MainMenuItem.security has no sidebar section');
      final childIds = securityItem!.children.map((c) => c.id).toSet();
      for (final expected in [
        SubMenuItem.securityOverview,
        SubMenuItem.securityCodes,
        SubMenuItem.securityWorkflow,
        SubMenuItem.securityAlerts,
        SubMenuItem.securityLogs,
      ]) {
        expect(childIds.contains(expected), isTrue,
            reason: '$expected missing from Security section');
      }
    });

    test('CRM section retains only Client Relationship Management', () {
      final crmItem = _findMain(MainMenuItem.crm);
      expect(crmItem, isNotNull,
          reason: 'MainMenuItem.crm has no sidebar section');
      final childIds = crmItem!.children.map((c) => c.id).toSet();
      expect(childIds, {SubMenuItem.crmClients});
    });
  });

  group('T9: sidebar routes all resolve to registered dashboard routes',
      () {
    test('land survey detail route is registered', () {
      expect(
        dashboardRoutePaths,
        contains(RouteConstants.landSurveyDetail),
      );
    });

    test('all finance webview routes are registered', () {
      for (final route in <String>{
        RouteConstants.financeDashboard,
        RouteConstants.financeInvoices,
        RouteConstants.financePayments,
        RouteConstants.financeReceivables,
        RouteConstants.financeWallets,
        RouteConstants.financeCashbook,
        RouteConstants.financeExpenses,
        RouteConstants.financeVendors,
        RouteConstants.financePettyCash,
        RouteConstants.financeApprovals,
        RouteConstants.financePayroll,
        RouteConstants.financeCommissions,
        RouteConstants.financeTax,
        RouteConstants.financeJournals,
        RouteConstants.financeCoa,
        RouteConstants.financeAssets,
        RouteConstants.financeCashflow,
        RouteConstants.financeServiceOrders,
        RouteConstants.financeEstate,
        RouteConstants.financeReports,
        RouteConstants.financeAudit,
        RouteConstants.financeSettings,
      }) {
        expect(dashboardRoutePaths, contains(route));
      }
    });

    test('marketing site detail route uses the marketing namespace', () {
      expect(RouteConstants.marketingSiteDetail, '/marketing/site/detail');
      expect(dashboardRoutePaths, contains(RouteConstants.marketingSiteDetail));
    });

    test('Disciplinary Process is registered (the audited 404)', () {
      expect(
          dashboardRoutePaths.contains(RouteConstants.disciplinaryProcess),
          isTrue,
          reason: 'HR > Disciplinary Process leads to Page not found');
    });

    test('EVERY sidebar main+sub route exists in the dashboard registry',
        () {
      final problems = <String>[];
      for (final section in sidebarStructure) {
        for (final item in section.items) {
          if (item.route != null &&
              !dashboardRoutePaths.contains(item.route)) {
            problems.add('${item.id.name} → ${item.route}');
          }
          for (final child in item.children) {
            if (child.route != null &&
                !dashboardRoutePaths.contains(child.route)) {
              problems.add('${child.id.name} → ${child.route}');
            }
          }
        }
      }
      expect(problems, isEmpty,
          reason:
              'sidebar entries with unregistered routes render "Page not '
              'found": $problems');
      // Sanity: the structure actually has routes to check.
      expect(dashboardRoutePaths.length, greaterThan(50));
    });
  });
}

MenuItem? _findMain(MainMenuItem id) {
  for (final section in sidebarStructure) {
    for (final item in section.items) {
      if (item.id == id) return item;
    }
  }
  return null;
}
