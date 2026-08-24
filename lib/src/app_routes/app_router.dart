// Component imports
import 'dart:developer';

import 'package:bomach_os/components/section/responsive_widget.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/pages/analytics/overview.dart';
// Page imports
import 'package:bomach_os/pages/auth/biometric.dart';
import 'package:bomach_os/pages/auth/login.dart';
import 'package:bomach_os/pages/auth/splash_screen.dart';
import 'package:bomach_os/pages/branch/branch.dart';
import 'package:bomach_os/pages/clients_portal/portal.dart';
import 'package:bomach_os/pages/company/audit_log.dart';
import 'package:bomach_os/pages/company/board.dart';
import 'package:bomach_os/pages/company/broadcast.dart';
import 'package:bomach_os/pages/company/roles.dart';
import 'package:bomach_os/pages/company/role_detail.dart';
import 'package:bomach_os/pages/company/org_chart.dart';
import 'package:bomach_os/pages/company/kpi_management.dart';
import 'package:bomach_os/pages/company/okr_board.dart';
import 'package:bomach_os/pages/company/compliance_dashboard.dart';
import 'package:bomach_os/pages/company/company_knowledge_base.dart';
import 'package:bomach_os/pages/company/approval_workflow.dart';
import 'package:bomach_os/pages/company/workspace_approvals.dart';
import 'package:bomach_os/pages/company/branch.dart';
import 'package:bomach_os/pages/company/company.dart';
import 'package:bomach_os/pages/company/department_units.dart';
import 'package:bomach_os/pages/crm/crm.dart';
import 'package:bomach_os/pages/marketing_crm/marketing_crm.dart';
import 'package:bomach_os/pages/dashboad/dashboard.dart';
import 'package:bomach_os/pages/dashboad/my_tasks.dart';
import 'package:bomach_os/pages/dashboad/my_profile.dart';
import 'package:bomach_os/pages/dashboad/my_work_reports.dart';
import 'package:bomach_os/pages/employee/employee.dart';
import 'package:bomach_os/pages/employee/employee_attendance.dart';
import 'package:bomach_os/pages/employee/employee_directory.dart';
import 'package:bomach_os/pages/employee/employee_performance.dart';
import 'package:bomach_os/pages/employee/employee_training.dart';
import 'package:bomach_os/pages/hr/loans.dart';
import 'package:bomach_os/pages/hr/employee_database.dart';
import 'package:bomach_os/pages/hr/employee_profile.dart';
import 'package:bomach_os/pages/finance/budget.dart';
import 'package:bomach_os/pages/finance/contract_payment.dart';
import 'package:bomach_os/pages/finance/expenses.dart';
import 'package:bomach_os/pages/finance/finance.dart';
import 'package:bomach_os/pages/finance/invoice.dart';
import 'package:bomach_os/pages/finance/payments.dart';
import 'package:bomach_os/pages/hr/assets.dart';
import 'package:bomach_os/pages/hr/associates.dart';
import 'package:bomach_os/pages/hr/attendance.dart';
import 'package:bomach_os/pages/marketing/widget/marketing_webview.dart';
import 'package:bomach_os/pages/hr/hr.dart';
import 'package:bomach_os/pages/hr/job_post.dart';
import 'package:bomach_os/pages/hr/leave_request.dart';
import 'package:bomach_os/pages/hr/leaves.dart';
import 'package:bomach_os/pages/hr/meetings.dart';
import 'package:bomach_os/pages/hr/performance_review.dart';
import 'package:bomach_os/pages/hr/training_program.dart';
import 'package:bomach_os/pages/hr/work_report.dart';
import 'package:bomach_os/pages/hr/monthly_scorecard.dart';
import 'package:bomach_os/pages/hr/awards_recognition.dart';
import 'package:bomach_os/pages/hr/performance_leaderboard.dart';
import 'package:bomach_os/pages/hr/employee_evaluation.dart';
import 'package:bomach_os/pages/large_screen.dart';
import 'package:bomach_os/pages/legal/legal.dart';
import 'package:bomach_os/pages/marketing/campaign_detail.dart';
import 'package:bomach_os/pages/marketing/lead_detail.dart';
import 'package:bomach_os/pages/marketing/marketing.dart';
import 'package:bomach_os/pages/marketing/site_detail.dart';
import 'package:bomach_os/pages/operations/contract.dart';
import 'package:bomach_os/pages/operations/contract_detail.dart';
import 'package:bomach_os/pages/operations/each_project.dart';
import 'package:bomach_os/pages/operations/operations.dart';
import 'package:bomach_os/pages/operations/project_detail.dart';
import 'package:bomach_os/pages/operations/projects.dart';
import 'package:bomach_os/pages/operations/task.dart';
import 'package:bomach_os/pages/operations/task_detail.dart';
import 'package:bomach_os/pages/operations/timeline_detail.dart';
import 'package:bomach_os/pages/operations/worksite_detail.dart';
import 'package:bomach_os/pages/services/clients.dart';
import 'package:bomach_os/pages/services/estate_detail_page.dart';
import 'package:bomach_os/pages/services/estate_management.dart';
import 'package:bomach_os/pages/services/estate_performance_page.dart';
import 'package:bomach_os/pages/services/generate_invoice_page.dart';
import 'package:bomach_os/pages/services/land_survey.dart';
import 'package:bomach_os/pages/services/land_survey_calculator.dart';
import 'package:bomach_os/pages/services/land_survey_detail.dart';
import 'package:bomach_os/pages/services/land_survey_property_detail.dart';
import 'package:bomach_os/pages/services/models/estate_models.dart';
import 'package:bomach_os/pages/services/payment_approval.dart';
import 'package:bomach_os/pages/services/property_detail.dart';
import 'package:bomach_os/pages/services/property_document_upload.dart';
import 'package:bomach_os/pages/services/property_list.dart';
import 'package:bomach_os/pages/services/real_estate.dart';
import 'package:bomach_os/pages/services/real_estate_detail.dart';
import 'package:bomach_os/pages/services/service_invoices.dart';
import 'package:bomach_os/pages/services/service_leads.dart';
import 'package:bomach_os/pages/services/service_order.dart';
import 'package:bomach_os/pages/services/services.dart';
import 'package:bomach_os/pages/services/services_calculator.dart';
import 'package:bomach_os/pages/services/services_property.dart';
import 'package:bomach_os/pages/services/widget/services_webview.dart';
import 'package:bomach_os/pages/small_screen.dart';
import 'package:bomach_os/pages/workspace/workspace.dart';
import 'package:bomach_os/pages/workspace/workspace_dashboard.dart';
import 'package:bomach_os/src/app_routes/app_route_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../pages/analytics/performance.dart';
import '../../pages/analytics/projects.dart';
import '../../pages/analytics/revenue.dart';
import '../../pages/analytics/branch_performance_analysis.dart';
import '../../pages/auth/controller.dart';
import '../../pages/auth/forgot_password.dart';
import '../../pages/auth/reset_password.dart';
import '../../pages/auth/two_factor_verify.dart';
import '../../pages/crm/clients.dart';
import '../../pages/crm/interactions.dart';
import '../../pages/crm/lead.dart';
import '../../pages/events/events.dart';
import '../../pages/hr/benefits.dart';
import '../../pages/operations/work_site.dart';
import '../../pages/security/security.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'detail_fallbacks.dart';
import 'refresh_route.dart';

final Map<String, Widget> _dashboardRoutes = {
  RouteConstants.home: const DashboardScreen(),
  RouteConstants.employeeMyTasks: const MyTasksPage(),
  RouteConstants.employeeMyReports: const MyWorkReportsPage(),
  RouteConstants.employeeMyProfile: const MyProfilePage(),

  // hr
  RouteConstants.hr: const HRPage(),
  RouteConstants.employees: const EmployeeDatabase(),
  RouteConstants.employeeProfile: const EmployeeProfile(),
  // Employee module
  RouteConstants.employee: const EmployeePage(),
  RouteConstants.employeeDirectory: const EmployeeDirectoryPage(),
  RouteConstants.employeePerformance: const EmployeePerformancePage(),
  RouteConstants.employeeAttendance: const EmployeeAttendancePage(),
  RouteConstants.employeeTraining: const EmployeeTrainingPage(),

  RouteConstants.projects: const ProjectsPage(),
  RouteConstants.eachProjects: const EachProjects(),
  RouteConstants.worksite: const WorkSite(),
  RouteConstants.tasks: const TaskPage(),
  RouteConstants.realEstate: const RealEstateScreen(),
  RouteConstants.leaves: const LeavesPage(),
  RouteConstants.meetings: const Meetings(),
  RouteConstants.department: const DepartmentsUnitsPage(),
  RouteConstants.serviceOrder: const ServiceOrder(),
  RouteConstants.landSurvey: const LandSurveyScreen(),
  RouteConstants.realEstateDetail: const RealEstateDetailScreen(),
  RouteConstants.landSurveyDetail: const LandSurveyDetailScreen(),
  RouteConstants.taskDetail: const TaskDetail(),
  RouteConstants.contracts: const ContractPage(),
  RouteConstants.servicesProperty: const ServicesPropertyPage(),
  RouteConstants.serviceDetail: const ServiceDetailScreen(),
  RouteConstants.company: const CompanyProfilePage(),
  RouteConstants.branch: const BranchListPage(),
  RouteConstants.auditLog: const AuditLogPage(),
  RouteConstants.board: const BoardPage(),
  RouteConstants.broadcast: const BroadcastPage(),
  RouteConstants.roles: const RolesPage(),
  RouteConstants.roleDetail: Container(), // Handled via state.extra
  RouteConstants.complianceDashboard: const ComplianceDashboardPage(),
  RouteConstants.knowledgeBase: const CompanyKnowledgeBasePage(),
  RouteConstants.orgChart: const OrgChartPage(),
  RouteConstants.kpiManagement: const KpiManagementPage(),
  RouteConstants.okrBoard: const OkrBoardPage(),
  RouteConstants.approvalWorkflow: const ApprovalWorkflowPage(),
  RouteConstants.workspaceApprovals: const WorkspaceApprovalsPage(),
  // RouteConstants.compliance: const CompliancePage(),
  RouteConstants.enugu: const BranchPage(),
  RouteConstants.finance: const FinancePage(),
  RouteConstants.invoice: const InvoicePage(),
  RouteConstants.payment: const PaymentsPage(),
  RouteConstants.expense: const ExpensesPage(),
  RouteConstants.contractPayment: const ContractPaymentPage(),
  RouteConstants.budget: const BudgetPage(),
  RouteConstants.jobPost: const JobPostPage(),
  RouteConstants.attendance: const AttendancePage(),
  // RouteConstants.clockIn: const ClockInScreen(),
  RouteConstants.leaveRequest: const LeaveRequestPage(),
  RouteConstants.benefits: const BenefitsPage(),
  RouteConstants.trainingProgram: const TrainingProgramPage(),
  RouteConstants.loans: const LoanPage(),
  RouteConstants.performanceReview: const PerformanceReviewPage(),
  RouteConstants.associates: const AssociatesPage(),
  RouteConstants.assets: const AssetsPage(),
  RouteConstants.workReport: const WorkReportPage(),
  RouteConstants.monthlyScorecard: const MonthlyScorecardPage(),
  RouteConstants.awardsRecognition: const AwardsRecognitionPage(),
  RouteConstants.performanceLeaderboard: const PerformanceLeaderboardPage(),
  RouteConstants.employeeEvaluation: const EmployeeEvaluationPage(),
  RouteConstants.services: const ServicesPage(),
  RouteConstants.servicesDashboard: const ServicesWebView(route: '/app/dashboard'),
  RouteConstants.servicesCatalogue: const ServicesWebView(route: '/app/service-catalogue'),
  RouteConstants.servicesCalculators: const ServicesWebView(route: '/app/calculator-library'),
  RouteConstants.servicesRequestFormBuilder: const ServicesWebView(route: '/app/request-form-builder'),
  RouteConstants.servicesWorkflowDesigner: const ServicesWebView(route: '/app/workflow-designer'),
  RouteConstants.servicesBranchActivation: const ServicesWebView(route: '/app/branch-activation'),
  RouteConstants.servicesRequests: const ServicesWebView(route: '/app/service-requests'),
  RouteConstants.servicesQuotations: const ServicesWebView(route: '/app/quotations'),
  RouteConstants.servicesInvoicesPayments: const ServicesWebView(route: '/app/invoices-payments'),
  RouteConstants.servicesApprovals: const ServicesWebView(route: '/app/approvals'),
  RouteConstants.servicesOrders: const ServicesWebView(route: '/app/service-orders'),
  RouteConstants.servicesExecutionTasks: const ServicesWebView(route: '/app/execution-tasks'),
  RouteConstants.servicesDeliverables: const ServicesWebView(route: '/app/deliverables'),
  RouteConstants.servicesRealEstateInventory: const ServicesWebView(route: '/app/real-estate-inventory'),
  RouteConstants.servicesSurveyEngineeringOthers: const ServicesWebView(route: '/app/survey-engineering-others'),
  RouteConstants.servicesFeedbackQuality: const ServicesWebView(route: '/app/feedback-quality'),
  RouteConstants.servicesReportsAnalytics: const ServicesWebView(route: '/app/reports-analytics'),
  RouteConstants.landSurveyCalculator: const LandSurveyCalculatorPage(),
  RouteConstants.servicesCalculator: const ServicesCalculatorPage(),
  // Property Management
  RouteConstants.propertyList: const PropertyListPage(),
  RouteConstants.propertyDetail: const PropertyDetailPage(),
  // Estate Management
  RouteConstants.estateManagement: const EstateManagementPage(),
  RouteConstants.estateDetail:
      Container(), // Placeholder, handled via state.extra
  RouteConstants.estatePerformance: const EstatePerformancePage(),
  // Payment Approval
  RouteConstants.paymentApproval: const PaymentApprovalPage(),
  RouteConstants.serviceClients: const ClientListPage(),
  RouteConstants.serviceClientUpload: const LandDocumentUploadPage(),
  // Service Invoice Management
  RouteConstants.generateInvoice: const GenerateInvoicePage(),
  RouteConstants.serviceLeads: const ServiceLeadsPage(),
  RouteConstants.serviceInvoices: const ServiceInvoicesPage(),

  // operations
  RouteConstants.operations: const OperationsPage(),
  RouteConstants.operationsProjectDetail: const ProjectDetailPage(),
  // RouteConstants.operationsTaskDetail: const TaskDetailPage(),
  RouteConstants.operationsWorksiteDetail: const WorksiteDetailPage(),
  RouteConstants.operationsContractDetail: const ContractDetailPage(),
  RouteConstants.operationsTimelineDetail: const TimelineDetailPage(),
  // marketing
  RouteConstants.marketing: const MarketingPage(),
  RouteConstants.marketingDashboard: const MarketingWebView(route: '/dashboard'),
  RouteConstants.marketingPipeline: const MarketingWebView(route: '/pipeline'),
  RouteConstants.marketingCampaigns: const MarketingWebView(route: '/campaigns'),
  RouteConstants.marketingCalendar: const MarketingWebView(route: '/calendar'),
  RouteConstants.marketingAnalytics: const MarketingWebView(route: '/analytics'),
  RouteConstants.marketingOkrs: const MarketingWebView(route: '/okrs'),
  RouteConstants.marketingReports: const MarketingWebView(route: '/audit-log'),
  RouteConstants.marketingTeam: const MarketingWebView(route: '/team-directory'),
  RouteConstants.marketingNewLead: const MarketingWebView(route: '/new-lead'),
  RouteConstants.marketingMedia: const MarketingWebView(route: '/media'),

  // revenue execution
  RouteConstants.marketingRevenueCommand: const MarketingWebView(route: '/revenue-command'),
  RouteConstants.marketingDailyExecution: const MarketingWebView(route: '/daily-execution'),
  RouteConstants.marketingLeadControl: const MarketingWebView(route: '/lead-control'),
  RouteConstants.marketingFunnelAudit: const MarketingWebView(route: '/funnel-audit'),
  RouteConstants.marketingPlaybooks: const MarketingWebView(route: '/playbooks'),
  RouteConstants.marketingContentStudio: const MarketingWebView(route: '/content-studio'),
  RouteConstants.marketingCoaching: const MarketingWebView(route: '/coaching'),
  RouteConstants.marketingForecast: const MarketingWebView(route: '/forecast'),
  RouteConstants.marketingRetention: const MarketingWebView(route: '/retention'),

  // integrations & workdesk
  RouteConstants.marketingWorkdesk: const MarketingWebView(route: '/workdesk'),
  RouteConstants.marketingLeadJournal: const MarketingWebView(route: '/lead-journal'),
  RouteConstants.marketingIntegrations: const MarketingWebView(route: '/integrations'),

  // commercial operations
  RouteConstants.marketingEmailCenter: const MarketingWebView(route: '/email-center'),
  RouteConstants.marketingMediaRegister: const MarketingWebView(route: '/media-register'),
  RouteConstants.marketingHandoff: const MarketingWebView(route: '/handoff'),
  RouteConstants.marketingRealtorPortal: const MarketingWebView(route: '/realtor-portal'),
  RouteConstants.marketingPartnerPortal: const MarketingWebView(route: '/partner-portal'),

  // governance
  RouteConstants.marketingRoleGovernance: const MarketingWebView(route: '/role-governance'),
  RouteConstants.marketingApprovals: const MarketingWebView(route: '/approvals'),
  RouteConstants.marketingAuditLog: const MarketingWebView(route: '/audit-log'),

  // campaign operations & additional tools
  RouteConstants.marketingMeetings: const MarketingWebView(route: '/marketing-meetings'),
  RouteConstants.marketingTurnaround: const MarketingWebView(route: '/turnaround'),
  RouteConstants.marketingCompliance: const MarketingWebView(route: '/compliance'),
  RouteConstants.marketingPartners: const MarketingWebView(route: '/partners'),
  RouteConstants.marketingSupport: const MarketingWebView(route: '/support'),
  RouteConstants.marketingDesign: const MarketingWebView(route: '/design'),
  RouteConstants.marketingWhatsapp: const MarketingWebView(route: '/whatsapp'),

  RouteConstants.marketingLeadDetail: const LeadDetailPage(),
  RouteConstants.marketingCampaignDetail: const CampaignDetailPage(),
  RouteConstants.marketingSiteDetail: const SiteDetailPage(),
  // workspace
  RouteConstants.workspace: const WorkspacePage(),
  RouteConstants.workspaceDashboard: const WorkspaceDashboardPage(),
  // analytics
  RouteConstants.analyticsOverview: const AnalyticsOverviewPage(),
  RouteConstants.analyticsRevenue: const RevenueAnalyticsPage(),
  RouteConstants.analyticsProjects: const ProjectsAnalytics(),
  RouteConstants.analyticsPerformance: const PerformanceAnalytics(),
  RouteConstants.branchPerformanceAnalysis:
      const BranchPerformanceAnalysisPage(),
  // Legals and Compliance
  RouteConstants.legalAudits: const LegalsPage(selectedIndex: 3),
  RouteConstants.legalContracts: const LegalsPage(selectedIndex: 0),
  RouteConstants.legalCompliance: const LegalsPage(selectedIndex: 1),
  RouteConstants.legalCases: const LegalsPage(selectedIndex: 2),
  // Client Portal
  RouteConstants.clientAccess: const ClientsPortal(page: 0),
  RouteConstants.communications: const ClientsPortal(page: 2),
  RouteConstants.portalAnalytics: const ClientsPortal(page: 3),
  RouteConstants.documentSharing: const ClientsPortal(page: 1),
  // Security
  RouteConstants.securityAlerts: const SecurityPage(page: 3),
  RouteConstants.securityCodes: const SecurityPage(page: 1),
  RouteConstants.securityLogs: const SecurityPage(page: 4),
  RouteConstants.securityWorkflow: const SecurityPage(page: 2),
  RouteConstants.securityOverview: const SecurityPage(page: 0),
  // Marketing & CRM (combined)
  RouteConstants.marketingCrm: const MarketingCrmDashboard(),
  // CRM
  RouteConstants.crmClients: const CrmClientsPage(),
  RouteConstants.crmLeads: const CrmLeadsPage(),
  RouteConstants.crmInteractions: const InteractionsPage(),
  RouteConstants.crmAnalytics: const CrmDashboardPage(),
  // Events
  RouteConstants.events: const EventsPage(),
};

// Route permissions are centralised in PermissionService.routePermissions

/// Creates a branch for StatefulShellRoute with a single route
StatefulShellBranch _createBranch(String path, Widget screen) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        builder: (context, state) {
          // Detail routes carry their object via in-memory `extra`; a
          // missing or wrong-typed extra (refresh, deep link) now shows a
          // helpful empty-state instead of a blank pane (audit B12).
          if (path == RouteConstants.estateDetail ||
              path == RouteConstants.estatePerformance) {
            final extra = state.extra;
            if (extra is Estate) {
              return path == RouteConstants.estateDetail
                  ? EstateDetailPage(estate: extra)
                  : EstatePerformancePage(estate: extra);
            }
            return const EstateDetailUnavailable();
          }
          if (path == RouteConstants.roleDetail) {
            final extra = state.extra;
            if (extra is int) {
              return RoleDetailPage(roleId: extra);
            }
            return const RoleDetailUnavailable();
          }
          return screen;
        },
      ),
    ],
  );
}

/// Main router configuration
final AuthController authController = Get.find<AuthController>();
final goRouter = GoRouter(
  initialLocation: RouteConstants.splash,
  debugLogDiagnostics: true,
  refreshListenable: GoRouterRefreshStream(authController.refreshStream),
  redirect: (BuildContext context, GoRouterState state) {
    final bool isLoggedIn = authController.currentUser.value != null;
    final String location = state.matchedLocation;
    log("DEBUG ROUTER: redirect check - location: $location, isLoggedIn: $isLoggedIn, isAuthInitializing: ${authController.isAuthInitializing.value}");

    // 0. Still checking auth state → splash screen
    if (authController.isAuthInitializing.value) {
      return RouteConstants.splash;
    }

    if (location == RouteConstants.splash) {
      if (isLoggedIn) {
        final permissionService = Get.find<PermissionService>();
        return permissionService.getFirstPermittedRoute();
      } else {
        return RouteConstants.login;
      }
    }

    // 1. Define all routes that should be accessible WITHOUT logging in
    final bool isPublicRoute = location == RouteConstants.login ||
        location == RouteConstants.biometric ||
        location == RouteConstants.forgotPassword ||
        location == RouteConstants.resetPassword ||
        location == RouteConstants.twoFactorVerify;

    // 2. If NOT logged in and trying to access a PRIVATE route -> Redirect to Login
    if (!isLoggedIn && !isPublicRoute) {
      return RouteConstants.login;
    }

    // 3. If LOGGED IN and trying to access a PUBLIC AUTH route -> Redirect to first permitted page
    if (isLoggedIn && isPublicRoute) {
      final permissionService = Get.find<PermissionService>();
      return permissionService.getFirstPermittedRoute();
    }

    // 4. Permission Checking (typed, centralised in permissions.dart)
    final permissionService = Get.find<PermissionService>();

    // Super-admin-only redirect: if this user is the super admin and the
    // current route is in superAdminHiddenRoutes (e.g., the employee
    // dashboard), send them to the company admin dashboard instead.
    if (permissionService.isSuperAdmin &&
        superAdminHiddenRoutes.contains(location)) {
      return RouteConstants.company;
    }

    if (!permissionService.canAccessRouteTyped(location)) {
      debugPrint('Access Denied to $location');
      return permissionService.getFirstPermittedRoute();
    }

    // 5. Otherwise, let them go where they want
    return null;
  },
  routes: [
    // Splash route (outside the dashboard shell)
    GoRoute(
      path: RouteConstants.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    // Login route (outside the dashboard shell)
    GoRoute(
      path: RouteConstants.login,
      builder: (context, state) => const LoginScreen(),
    ),

    // Biometric login route (outside the dashboard shell)
    GoRoute(
      path: RouteConstants.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: RouteConstants.resetPassword,
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: RouteConstants.biometric,
      builder: (context, state) => const BiometricLoginScreen(),
    ),
    GoRoute(
      path: RouteConstants.twoFactorVerify,
      builder: (context, state) => const TwoFactorVerifyScreen(),
    ),

    // Dashboard with indexed stack navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => ResponsiveWidget(
        smallScreen: SmallScreenDashboard(navigationShell: navigationShell),
        mediumScreen: SmallScreenDashboard(navigationShell: navigationShell),
        largeScreen: LargeScreenDashboard(navigationShell: navigationShell),
      ),
      branches: _dashboardRoutes.entries
          .map((entry) => _createBranch(entry.key, entry.value))
          .toList(),
    ),
  ],

  // Handle errors and redirects
  errorBuilder: (context, state) => const Center(
    child: MyText('Page not found'),
  ),
);
