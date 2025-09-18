// Component imports
import 'package:bms_front_end/components/section/responsive_widget.dart';
import 'package:bms_front_end/components/text/my_text.dart';
// Page imports
import 'package:bms_front_end/pages/auth/login.dart';
import 'package:bms_front_end/pages/branch/branch.dart';
import 'package:bms_front_end/pages/client/clients_database.dart';
import 'package:bms_front_end/pages/company/branch.dart';
import 'package:bms_front_end/pages/company/company.dart';
import 'package:bms_front_end/pages/dashboad/dashboard.dart';
import 'package:bms_front_end/pages/employees_database/add_new_employee.dart';
import 'package:bms_front_end/pages/employees_database/employee_database.dart';
import 'package:bms_front_end/pages/employees_database/employee_profile.dart';
import 'package:bms_front_end/pages/finance/budget.dart';
import 'package:bms_front_end/pages/finance/contract_payment.dart';
import 'package:bms_front_end/pages/finance/expenses.dart';
import 'package:bms_front_end/pages/finance/finance.dart';
import 'package:bms_front_end/pages/finance/invoice.dart';
import 'package:bms_front_end/pages/finance/payments.dart';
import 'package:bms_front_end/pages/hr/attendance.dart';
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
import 'package:bms_front_end/pages/large_screen.dart';
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
import 'package:bms_front_end/pages/services/land_survey.dart';
import 'package:bms_front_end/pages/services/land_survey_detail.dart';
import 'package:bms_front_end/pages/services/land_survey_property_detail.dart';
import 'package:bms_front_end/pages/services/real_estate.dart';
import 'package:bms_front_end/pages/services/real_estate_detail.dart';
import 'package:bms_front_end/pages/services/service_order.dart';
import 'package:bms_front_end/pages/services/services.dart';
import 'package:bms_front_end/pages/services/services_property.dart';
import 'package:bms_front_end/pages/small_screen.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Map of all dashboard screens to their routes for better maintainability
final Map<String, Widget> _dashboardRoutes = {
  RouteConstants.home: const DashboardScreen(),
  // hr
  RouteConstants.hr: const HRPage(),
  RouteConstants.employees: const EmployeeDatabase(),
  RouteConstants.addEmployees: const AddEmployesScreen(),
  RouteConstants.employeeProfile: const EmployeeProfile(),

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
  RouteConstants.leaveRequest: const LeaveRequestPage(),
  RouteConstants.payroll: const PayrollPage(),
  RouteConstants.trainingProgram: const TrainingProgramPage(),
  RouteConstants.performanceReview: const PerformanceReviewPage(),
  RouteConstants.services: const ServicesPage(),
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
};

/// Creates a branch for StatefulShellRoute with a single route
StatefulShellBranch _createBranch(String path, Widget screen) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        builder: (context, state) => screen,
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
