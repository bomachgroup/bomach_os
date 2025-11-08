// Component imports
import 'package:bms_front_end/components/section/responsive_widget.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/analytics/overview.dart';
// Page imports
import 'package:bms_front_end/pages/auth/biometric.dart';
import 'package:bms_front_end/pages/auth/login.dart';
import 'package:bms_front_end/pages/branch/branch.dart';
import 'package:bms_front_end/pages/client/clients_database.dart';
import 'package:bms_front_end/pages/clients_portal/portal.dart';
import 'package:bms_front_end/pages/company/audit_log.dart';
import 'package:bms_front_end/pages/company/branch.dart';
import 'package:bms_front_end/pages/company/company.dart';
import 'package:bms_front_end/pages/company/compliance.dart';
import 'package:bms_front_end/pages/crm/crm.dart';
import 'package:bms_front_end/pages/dashboad/dashboard.dart';
import 'package:bms_front_end/pages/employee/employee.dart';
import 'package:bms_front_end/pages/employee/employee_attendance.dart';
import 'package:bms_front_end/pages/employee/employee_directory.dart';
import 'package:bms_front_end/pages/employee/employee_performance.dart';
import 'package:bms_front_end/pages/employee/employee_training.dart';
import 'package:bms_front_end/pages/employees_database/add_new_employee.dart';
import 'package:bms_front_end/pages/employees_database/employee_database.dart';
import 'package:bms_front_end/pages/employees_database/employee_profile.dart';
import 'package:bms_front_end/pages/finance/budget.dart';
import 'package:bms_front_end/pages/finance/contract_payment.dart';
import 'package:bms_front_end/pages/finance/expenses.dart';
import 'package:bms_front_end/pages/finance/finance.dart';
import 'package:bms_front_end/pages/finance/invoice.dart';
import 'package:bms_front_end/pages/finance/payments.dart';
import 'package:bms_front_end/pages/hr/assets.dart';
import 'package:bms_front_end/pages/hr/associates.dart';
import 'package:bms_front_end/pages/hr/attendance.dart';
import 'package:bms_front_end/pages/hr/clock_in.dart';
import 'package:bms_front_end/pages/hr/department.dart';
import 'package:bms_front_end/pages/hr/hr.dart';
import 'package:bms_front_end/pages/hr/job_applicants.dart';
import 'package:bms_front_end/pages/hr/job_post.dart';
import 'package:bms_front_end/pages/hr/leads.dart';
import 'package:bms_front_end/pages/hr/leave_request.dart';
import 'package:bms_front_end/pages/hr/leaves.dart';
import 'package:bms_front_end/pages/hr/meetings.dart';
import 'package:bms_front_end/pages/hr/payroll.dart';
import 'package:bms_front_end/pages/hr/performance_review.dart';
import 'package:bms_front_end/pages/hr/training_program.dart';
import 'package:bms_front_end/pages/hr/work_report.dart';
import 'package:bms_front_end/pages/large_screen.dart';
import 'package:bms_front_end/pages/legal/legal.dart';
import 'package:bms_front_end/pages/marketing/campaign_detail.dart';
import 'package:bms_front_end/pages/marketing/lead_detail.dart';
import 'package:bms_front_end/pages/marketing/marketing.dart';
import 'package:bms_front_end/pages/marketing/site_detail.dart';
import 'package:bms_front_end/pages/operations/contract.dart';
import 'package:bms_front_end/pages/operations/contract_detail.dart';
import 'package:bms_front_end/pages/operations/each_project.dart';
import 'package:bms_front_end/pages/operations/operation_task_detail.dart';
import 'package:bms_front_end/pages/operations/operations.dart';
import 'package:bms_front_end/pages/operations/project_detail.dart';
import 'package:bms_front_end/pages/operations/projects.dart';
import 'package:bms_front_end/pages/operations/task.dart';
import 'package:bms_front_end/pages/operations/task_detail.dart';
import 'package:bms_front_end/pages/operations/timeline_detail.dart';
import 'package:bms_front_end/pages/operations/worksite_detail.dart';
import 'package:bms_front_end/pages/services/clients.dart';
import 'package:bms_front_end/pages/services/estate_detail_page.dart';
import 'package:bms_front_end/pages/services/estate_management.dart';
import 'package:bms_front_end/pages/services/estate_performance_page.dart';
import 'package:bms_front_end/pages/services/generate_invoice_page.dart';
import 'package:bms_front_end/pages/services/land_survey.dart';
import 'package:bms_front_end/pages/services/land_survey_calculator.dart';
import 'package:bms_front_end/pages/services/land_survey_detail.dart';
import 'package:bms_front_end/pages/services/land_survey_property_detail.dart';
import 'package:bms_front_end/pages/services/models/estate_models.dart';
import 'package:bms_front_end/pages/services/payment_approval.dart';
import 'package:bms_front_end/pages/services/property_detail.dart';
import 'package:bms_front_end/pages/services/property_document_upload.dart';
import 'package:bms_front_end/pages/services/property_list.dart';
import 'package:bms_front_end/pages/services/real_estate.dart';
import 'package:bms_front_end/pages/services/real_estate_detail.dart';
import 'package:bms_front_end/pages/services/service_order.dart';
import 'package:bms_front_end/pages/services/service_leads.dart';
import 'package:bms_front_end/pages/services/service_invoices.dart';
import 'package:bms_front_end/pages/services/services.dart';
import 'package:bms_front_end/pages/services/services_calculator.dart';
import 'package:bms_front_end/pages/services/services_property.dart';
import 'package:bms_front_end/pages/small_screen.dart';
import 'package:bms_front_end/pages/workspace/workspace.dart';
import 'package:bms_front_end/pages/workspace/workspace_dashboard.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../pages/analytics/performance.dart';
import '../../pages/analytics/projects.dart';
import '../../pages/analytics/revenue.dart';
import '../../pages/crm/clients.dart';
import '../../pages/crm/interactions.dart';
import '../../pages/crm/lead.dart';
import '../../pages/events/events.dart';
import '../../pages/security/security.dart';

/// Map of all dashboard screens to their routes for better maintainability
final Map<String, Widget> _dashboardRoutes = {
  RouteConstants.home: const DashboardScreen(),
  // hr
  RouteConstants.hr: const HRPage(),
  RouteConstants.employees: const EmployeeDatabase(),
  RouteConstants.addEmployees: const AddEmployesScreen(),
  RouteConstants.employeeProfile: const EmployeeProfile(),
  // Employee module
  RouteConstants.employee: const EmployeePage(),
  RouteConstants.employeeDirectory: const EmployeeDirectoryPage(),
  RouteConstants.employeePerformance: const EmployeePerformancePage(),
  RouteConstants.employeeAttendance: const EmployeeAttendancePage(),
  RouteConstants.employeeTraining: const EmployeeTrainingPage(),

  RouteConstants.clients: const ClientsDatabasePage(),
  RouteConstants.projects: const ProjectsPage(),
  RouteConstants.eachProjects: const EachProjects(),
  RouteConstants.worksite: const EmployeeProfile(),
  RouteConstants.tasks: const TaskPage(),
  RouteConstants.realEstate: const RealEstateScreen(),
  RouteConstants.leads: const LeadsPage(),
  RouteConstants.leaves: const LeavesPage(),
  RouteConstants.meetings: const Meetings(),
  RouteConstants.department: const DepartmentPage(),
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
  RouteConstants.compliance: const CompliancePage(),
  RouteConstants.enugu: const BranchPage(),
  RouteConstants.finance: const FinancePage(),
  RouteConstants.invoice: const InvoicePage(),
  RouteConstants.payment: const PaymentsPage(),
  RouteConstants.expense: const ExpensesPage(),
  RouteConstants.contractPayment: const ContractPaymentPage(),
  RouteConstants.budget: const BudgetPage(),
  RouteConstants.jobPost: const JobPostPage(),
  RouteConstants.jobApplicants: const JobApplicatantsPage(),
  RouteConstants.attendance: const AttendancePage(),
  RouteConstants.clockIn: const ClockInScreen(),
  RouteConstants.leaveRequest: const LeaveRequestPage(),
  RouteConstants.payroll: const PayrollPage(),
  RouteConstants.trainingProgram: const TrainingProgramPage(),
  RouteConstants.performanceReview: const PerformanceReviewPage(),
  RouteConstants.associates: const AssociatesPage(),
  RouteConstants.assets: const AssetsPage(),
  RouteConstants.workReport: const WorkReportPage(),
  RouteConstants.services: const ServicesPage(),
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
  RouteConstants.operationsTaskDetail: const TaskDetailPage(),
  RouteConstants.operationsWorksiteDetail: const WorksiteDetailPage(),
  RouteConstants.operationsContractDetail: const ContractDetailPage(),
  RouteConstants.operationsTimelineDetail: const TimelineDetailPage(),
  // marketing
  RouteConstants.marketing: const MarketingPage(),
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
  // CRM
  RouteConstants.crmClients: const CrmClientsPage(),
  RouteConstants.crmLeads: const CrmLeadsPage(),
  RouteConstants.crmInteractions: const InteractionsPage(),
  RouteConstants.crmAnalytics: const CrmDashboardPage(),
  // Events
  RouteConstants.events: const EventsPage(),
};

/// Creates a branch for StatefulShellRoute with a single route
StatefulShellBranch _createBranch(String path, Widget screen) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        builder: (context, state) {
          // Handle estate detail route with extra parameter
          if (path == RouteConstants.estateDetail && state.extra != null) {
            return EstateDetailPage(estate: state.extra as Estate);
          }
          // Handle estate performance route with extra parameter
          if (path == RouteConstants.estatePerformance && state.extra != null) {
            return EstatePerformancePage(estate: state.extra as Estate);
          }
          return screen;
        },
      ),
    ],
  );
}

/// Main router configuration
final goRouter = GoRouter(
  initialLocation: RouteConstants.home,
  routes: [
    // Login route (outside the dashboard shell)
    GoRoute(
      path: RouteConstants.login,
      builder: (context, state) => const LoginScreen(),
    ),

    // Biometric login route (outside the dashboard shell)
    GoRoute(
      path: RouteConstants.biometric,
      builder: (context, state) => const BiometricLoginScreen(),
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
