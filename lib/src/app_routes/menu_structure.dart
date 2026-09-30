import 'package:bomach_os/src/app_routes/app_route_constants.dart';
import 'package:bomach_os/src/constants/icons.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

// Enums for menu identification
enum MainMenuItem {
  dashboard,
  company,
  hr,
  employee,
  work,
  marketing,
  calendar,
  events,
  services,
  notification,
  settings,
  help,
  financeAccounting,
  workspace,
  analytics,
  legalCompliance,
  clientPortal,
  security,
  crm,
  marketingCrm,
}

enum SubMenuItem {
  dashboardHome,
  myProfile,
  myTasks,
  myReports,
  myTargetReports,
  dashboardRole,
  company,
  branch,
  board,
  broadcast,
  roles,
  orgChart,
  kpiManagement,
  okrBoard,
  approvalWorkflow,
  complianceDashboard,
  knowledgeBase,
  workspaceApprovals,
  auditLog,
  compliance,
  enugu,
  portHarcourt,
  abuja,
  employees,
  employeeDirectory,
  employeePerformance,
  employeeAttendance,
  employeeTraining,
  leaves,
  clients,
  leads,
  department,
  hrDashboad,
  jobPost,
  jobApplicants,
  attendance,
  loans,
  leaveRequest,
  performance,
  benefits,
  trainingProgram,
  associates,
  assets,
  workReport,
  monthlyScorecard,
  awardsRecognition,
  performanceLeaderboard,
  employeeEvaluation,
  disciplinaryProcess,
  performanceEngine,
  marketing,
  marketingDashboard,
  marketingPipeline,
  marketingCampaigns,
  marketingCalendar,
  marketingAnalytics,
  marketingOkrs,
  marketingReports,
  marketingTeamDirectory,
  marketingNewLead,
  marketingMedia,
  marketingRevenueCommand,
  marketingDailyExecution,
  marketingLeadControl,
  marketingFunnelAudit,
  marketingPlaybooks,
  marketingContentStudio,
  marketingCoaching,
  marketingForecast,
  marketingRetention,
  marketingWorkdesk,
  marketingLeadJournal,
  marketingIntegrations,
  marketingEmailCenter,
  marketingMediaRegister,
  marketingHandoff,
  marketingRealtorPortal,
  marketingPartnerPortal,
  marketingRoleGovernance,
  marketingApprovals,
  marketingAuditLog,
  marketingTurnaround,
  marketingCompliance,
  marketingPartners,
  marketingSupport,
  marketingMeetings,
  marketingDesign,
  marketingWhatsapp,
  operations,
  project,
  worksite,
  tasks,
  engineeringSiteReports,
  surveySiteReports,
  contracts,
  meetings,
  servicesDashboard,
  servicesCatalogue,
  servicesCalculators,
  servicesRequestFormBuilder,
  servicesWorkflowDesigner,
  servicesBranchActivation,
  servicesRequests,
  servicesQuotations,
  servicesInvoicesPayments,
  servicesApprovals,
  servicesOrders,
  servicesExecutionTasks,
  servicesDeliverables,
  servicesRealEstateInventory,
  servicesSurveyEngineeringOthers,
  servicesFeedbackQuality,
  servicesReportsAnalytics,
  serviceClients,
  serviceOrder,
  realEstate,
  landSurvey,
  servicesItem,
  propertyManagement,
  estateManagement,
  estatePerformance,
  paymentApproval,
  landSurveyCalculator,
  servicesCalculator,
  generateInvoice,
  serviceLeads,
  serviceInvoices,
  financeDashboard,
  financeInvoices,
  financePayments,
  financeReceivables,
  financeWallets,
  financeCashbook,
  financeServiceOrders,
  financeEstate,
  financeExpenses,
  financeVendors,
  financePettyCash,
  financeApprovals,
  financeCashflow,
  financePayroll,
  financeCommissions,
  financeTax,
  financeJournals,
  financeCoa,
  financeAssets,
  financeReports,
  financeAudit,
  financeSettings,
  invoice,
  payments,
  expenses,
  budget,
  vendorContributor,
  workspace,
  workspaceDashboard,
  overview,
  revenue,
  projects,
  analyticsPerformance,
  branchPerformance,
  legalContracts,
  legalCompliance,
  legalCases,
  legalAudits,
  clientAccess,
  documentSharing,
  communications,
  portalAnalytics,
  securityOverview,
  securityCodes,
  securityWorkflow,
  securityAlerts,
  securityLogs,
  crmClients,
  crmLeads,
  crmAnalytics,
  crmInteractions,
  marketingCrmDashboard,
}

// Data classes for menu structure
class MenuItem {
  final MainMenuItem id;
  final String label;
  final IconData icon;
  final String? route;
  final List<String>? resources;
  final bool isExpandable;
  final List<SubMenuItemData> children;

  const MenuItem({
    required this.id,
    required this.label,
    required this.icon,
    this.route,
    this.resources,
    required this.isExpandable,
    this.children = const [],
  });
}

class SubMenuItemData {
  final SubMenuItem id;
  final String label;
  final IconData icon;
  final String? route;
  final List<String>? resources;

  const SubMenuItemData({
    required this.id,
    required this.label,
    required this.icon,
    this.route,
    this.resources,
  });
}

/// Represents a group of menu items under a header.
class SidebarSection {
  final String label;
  final List<MenuItem> items;

  const SidebarSection({
    required this.label,
    required this.items,
  });
}

/// The master configuration for the Bomach OS Sidebar.
/// Sections are rendered in order, with headers between them.
const List<SidebarSection> sidebarStructure = [
  SidebarSection(
    label: 'Workspace',
    items: [
      MenuItem(
        id: MainMenuItem.dashboard,
        label: 'Dashboard',
        icon: AppIcons.dashboard,
        route: RouteConstants.home,
        isExpandable: true,
        resources: [
          PermissionConstants.resDashboard,
          PermissionConstants.resEmployees,
        ],
        children: [
          SubMenuItemData(
            id: SubMenuItem.dashboardHome,
            icon: Iconsax.home_2,
            label: 'Overview',
            route: RouteConstants.home,
            resources: [
              PermissionConstants.resDashboard,
              PermissionConstants.resEmployees,
            ],
          ),
          SubMenuItemData(
            id: SubMenuItem.myProfile,
            icon: Iconsax.user,
            label: 'Profile',
            route: RouteConstants.employeeMyProfile,
            resources: [PermissionConstants.resEmployees],
          ),
          SubMenuItemData(
            id: SubMenuItem.dashboardRole,
            icon: Icons.shield_outlined,
            label: 'Role',
            route: RouteConstants.employeeRole,
            resources: [PermissionConstants.resRoles],
          ),
          SubMenuItemData(
            id: SubMenuItem.myTasks,
            icon: Iconsax.task_square,
            label: 'Tasks',
            route: RouteConstants.employeeMyTasks,
            resources: [PermissionConstants.resTasks],
          ),
          SubMenuItemData(
            id: SubMenuItem.myReports,
            icon: Iconsax.document_text,
            label: 'Work Reports',
            route: RouteConstants.employeeMyReports,
            resources: [PermissionConstants.resWorkReports],
          ),
          SubMenuItemData(
            id: SubMenuItem.myTargetReports,
            icon: Iconsax.chart_success,
            label: 'Target',
            route: RouteConstants.employeeMyTargetReports,
            resources: [PermissionConstants.resEmployees],
          ),
        ],
      ),
      MenuItem(
        id: MainMenuItem.company,
        label: 'Company',
        icon: AppIcons.company,
        isExpandable: true,
        resources: [PermissionConstants.resCompanySettings],
        children: [
          SubMenuItemData(
            id: SubMenuItem.company,
            icon: Iconsax.building_4,
            label: 'Profile',
            route: RouteConstants.company,
            resources: [PermissionConstants.resCompanySettings],
          ),
          SubMenuItemData(
            id: SubMenuItem.branch,
            icon: Iconsax.buildings_2,
            label: 'Branch',
            route: RouteConstants.branch,
            resources: [PermissionConstants.resBranches],
          ),
          SubMenuItemData(
            id: SubMenuItem.board,
            icon: Iconsax.people,
            label: 'Board',
            route: RouteConstants.board,
            resources: [PermissionConstants.resBoardResolutions],
          ),
          SubMenuItemData(
            id: SubMenuItem.broadcast,
            icon: Iconsax.speaker,
            label: 'Broadcast',
            route: RouteConstants.broadcast,
            resources: [PermissionConstants.resAnnouncements],
          ),
          SubMenuItemData(
            id: SubMenuItem.roles,
            icon: Iconsax.shield_tick,
            label: 'Roles & Permissions',
            route: RouteConstants.roles,
            resources: [PermissionConstants.resRoles],
          ),
          SubMenuItemData(
            id: SubMenuItem.orgChart,
            icon: Iconsax.hierarchy,
            label: 'Org Chart',
            route: RouteConstants.orgChart,
            resources: [PermissionConstants.resRoles],
          ),
          SubMenuItemData(
            id: SubMenuItem.kpiManagement,
            icon: Iconsax.chart_2,
            label: 'KPI Management',
            route: RouteConstants.kpiManagement,
            resources: [PermissionConstants.resRoles],
          ),
          SubMenuItemData(
            id: SubMenuItem.okrBoard,
            icon: Iconsax.flag,
            label: 'OKR Board',
            route: RouteConstants.okrBoard,
            resources: [PermissionConstants.resRoles],
          ),
          SubMenuItemData(
            id: SubMenuItem.complianceDashboard,
            icon: Iconsax.shield_tick,
            label: 'Compliance Dashboard',
            route: RouteConstants.complianceDashboard,
            resources: [PermissionConstants.resRoles],
          ),
          SubMenuItemData(
            id: SubMenuItem.knowledgeBase,
            icon: Iconsax.document,
            label: 'Knowledge Base',
            route: RouteConstants.knowledgeBase,
            resources: [PermissionConstants.resRoles],
          ),
          SubMenuItemData(
            id: SubMenuItem.approvalWorkflow,
            icon: Iconsax.tick_square,
            label: 'Approval Workflows',
            route: RouteConstants.approvalWorkflow,
            resources: [PermissionConstants.resApprovalFlows],
          ),
          SubMenuItemData(
            id: SubMenuItem.workspaceApprovals,
            icon: Iconsax.note_2,
            label: 'Workspace Approvals',
            route: RouteConstants.workspaceApprovals,
            resources: [PermissionConstants.resWorkLocations],
          ),
          SubMenuItemData(
            id: SubMenuItem.department,
            icon: Iconsax.hierarchy,
            label: 'Departments & Units',
            route: RouteConstants.department,
            resources: [PermissionConstants.resDepartments],
          ),
          SubMenuItemData(
            id: SubMenuItem.assets,
            icon: Iconsax.box,
            label: 'Assets',
            route: RouteConstants.assets,
            resources: [PermissionConstants.resAssets],
          ),
          SubMenuItemData(
            id: SubMenuItem.auditLog,
            icon: Iconsax.clipboard_text,
            label: 'Audit Log',
            route: RouteConstants.auditLog,
            resources: [PermissionConstants.resAuditLogs],
          ),
        ],
      ),
    ],
  ),
  SidebarSection(
    label: 'People',
    items: [
      MenuItem(
        id: MainMenuItem.hr,
        label: 'HR/Admin',
        icon: AppIcons.hr,
        isExpandable: true,
        resources: [
          PermissionConstants.resEmployees,
          PermissionConstants.resJobPostings,
          PermissionConstants.resLeaveRequests,
          PermissionConstants.resPayroll,
        ],
        children: [
          SubMenuItemData(
            id: SubMenuItem.employees,
            icon: Iconsax.user_square,
            label: 'Employees',
            route: RouteConstants.employees,
            resources: [PermissionConstants.resEmployees],
          ),
          SubMenuItemData(
            id: SubMenuItem.attendance,
            icon: Iconsax.calendar_tick,
            label: 'Attendance',
            route: RouteConstants.attendance,
            resources: [PermissionConstants.resEmployees],
          ),
          SubMenuItemData(
            id: SubMenuItem.jobPost,
            icon: Iconsax.user_add,
            label: 'Recruitment',
            route: RouteConstants.jobPost,
            resources: [PermissionConstants.resJobPostings],
          ),
          SubMenuItemData(
            id: SubMenuItem.leaves,
            icon: Iconsax.calendar_remove,
            label: 'My Leaves',
            route: RouteConstants.leaves,
            resources: [PermissionConstants.resLeaveRequests],
          ),
          SubMenuItemData(
            id: SubMenuItem.leaveRequest,
            icon: Iconsax.note_remove,
            label: 'Leave Requests',
            route: RouteConstants.leaveRequest,
            resources: [PermissionConstants.resLeaveRequests],
          ),
          SubMenuItemData(
            id: SubMenuItem.trainingProgram,
            icon: Iconsax.teacher,
            label: 'Training',
            route: RouteConstants.trainingProgram,
            resources: [PermissionConstants.resTrainingPrograms],
          ),
          SubMenuItemData(
            id: SubMenuItem.loans,
            icon: Iconsax.money_recive,
            label: 'Loans',
            route: RouteConstants.loans,
            resources: [PermissionConstants.resLoans],
          ),
          SubMenuItemData(
            id: SubMenuItem.benefits,
            icon: Iconsax.gift,
            label: 'Benefits',
            route: RouteConstants.benefits,
            resources: [PermissionConstants.resPayroll],
          ),
          SubMenuItemData(
            id: SubMenuItem.performance,
            icon: Iconsax.chart,
            label: 'Performance',
            route: RouteConstants.performanceReview,
            resources: [PermissionConstants.resPerformanceReviews],
          ),
          SubMenuItemData(
            id: SubMenuItem.workReport,
            icon: Iconsax.note_2,
            label: 'Work Reports',
            route: RouteConstants.workReport,
            resources: [PermissionConstants.resWorkReports],
          ),
          SubMenuItemData(
            id: SubMenuItem.monthlyScorecard,
            icon: Iconsax.chart_2,
            label: 'Monthly Scorecard',
            route: RouteConstants.monthlyScorecard,
            resources: [PermissionConstants.resMonthlyScorecards],
          ),
          SubMenuItemData(
            id: SubMenuItem.awardsRecognition,
            icon: Iconsax.award,
            label: 'Awards & Recognition',
            route: RouteConstants.awardsRecognition,
            resources: [PermissionConstants.resAwards],
          ),
          SubMenuItemData(
            id: SubMenuItem.performanceLeaderboard,
            icon: Iconsax.cup,
            label: 'Performance Leaderboard',
            route: RouteConstants.performanceLeaderboard,
            resources: [PermissionConstants.resKpis],
          ),
          SubMenuItemData(
            id: SubMenuItem.employeeEvaluation,
            icon: Iconsax.clipboard_text,
            label: 'Employee Evaluation',
            route: RouteConstants.employeeEvaluation,
            resources: [PermissionConstants.resEmployeeEvaluations],
          ),
          SubMenuItemData(
            id: SubMenuItem.disciplinaryProcess,
            icon: Iconsax.warning_2,
            label: 'Disciplinary Process',
            route: RouteConstants.disciplinaryProcess,
            resources: [PermissionConstants.resDisciplinaryCases],
          ),
          SubMenuItemData(
            id: SubMenuItem.performanceEngine,
            icon: Iconsax.status_up,
            label: 'Performance Engine',
            route: RouteConstants.performanceEngine,
            resources: [PermissionConstants.resPerformanceReviews],
          ),
        ],
      ),
    ],
  ),
  SidebarSection(
    label: 'Operations',
    items: [
      MenuItem(
        id: MainMenuItem.work,
        label: 'Operations',
        icon: AppIcons.operations,
        isExpandable: true,
        resources: [
          PermissionConstants.resProjects,
          PermissionConstants.resTasks,
          PermissionConstants.resContracts,
          PermissionConstants.resWorksites,
          PermissionConstants.resEngineeringSiteReports,
          PermissionConstants.resSurveySiteReports,
        ],
        children: [
          SubMenuItemData(
            id: SubMenuItem.operations,
            icon: Iconsax.briefcase,
            label: 'Operations',
            route: RouteConstants.operations,
            resources: [PermissionConstants.resProjects],
          ),
          SubMenuItemData(
            id: SubMenuItem.project,
            icon: Iconsax.folder_connection,
            label: 'Project',
            route: RouteConstants.projects,
            resources: [PermissionConstants.resProjects],
          ),
          SubMenuItemData(
            id: SubMenuItem.worksite,
            icon: Iconsax.location_tick,
            label: 'Worksite',
            route: RouteConstants.worksite,
            resources: [PermissionConstants.resWorksites],
          ),
          SubMenuItemData(
            id: SubMenuItem.tasks,
            icon: Iconsax.task_square,
            label: 'Tasks',
            route: RouteConstants.tasks,
            resources: [PermissionConstants.resTasks],
          ),
          SubMenuItemData(
            id: SubMenuItem.engineeringSiteReports,
            icon: Iconsax.document_text,
            label: 'Engineering Site Reports',
            route: RouteConstants.engineeringSiteReports,
            resources: [PermissionConstants.resEngineeringSiteReports],
          ),
          SubMenuItemData(
            id: SubMenuItem.surveySiteReports,
            icon: Iconsax.map,
            label: 'Survey Site Reports',
            route: RouteConstants.surveySiteReports,
            resources: [PermissionConstants.resSurveySiteReports],
          ),
          SubMenuItemData(
            id: SubMenuItem.contracts,
            icon: Iconsax.document_text,
            label: 'Contracts',
            route: RouteConstants.contracts,
            resources: [PermissionConstants.resContracts],
          ),
          SubMenuItemData(
            id: SubMenuItem.meetings,
            icon: Iconsax.calendar_1,
            label: 'Meetings',
            route: RouteConstants.meetings,
            resources: [PermissionConstants.resMeetings],
          ),
        ],
      ),
      MenuItem(
        id: MainMenuItem.services,
        label: 'Services',
        icon: AppIcons.services,
        isExpandable: true,
        resources: [
          PermissionConstants.resServices,
          PermissionConstants.resProperties,
          PermissionConstants.resEstates,
          PermissionConstants.resClients,
        ],
        children: [
          // ── Overview ──
          SubMenuItemData(
            id: SubMenuItem.servicesDashboard,
            icon: Iconsax.element_4,
            label: 'Command center',
            route: RouteConstants.servicesDashboard,
            resources: [PermissionConstants.resServices],
          ),

          // ── Service Administration ──
          SubMenuItemData(
            id: SubMenuItem.servicesCatalogue,
            icon: Iconsax.category_2,
            label: 'Service catalogue',
            route: RouteConstants.servicesCatalogue,
            resources: [PermissionConstants.resServices],
          ),
          SubMenuItemData(
            id: SubMenuItem.servicesCalculators,
            icon: Iconsax.calculator,
            label: 'Calculator library',
            route: RouteConstants.servicesCalculators,
            resources: [PermissionConstants.resServices],
          ),
          SubMenuItemData(
            id: SubMenuItem.servicesRequestFormBuilder,
            icon: Iconsax.document_text,
            label: 'Request form builder',
            route: RouteConstants.servicesRequestFormBuilder,
            resources: [PermissionConstants.resServices],
          ),
          SubMenuItemData(
            id: SubMenuItem.servicesWorkflowDesigner,
            icon: Iconsax.diagram,
            label: 'Workflow designer',
            route: RouteConstants.servicesWorkflowDesigner,
            resources: [PermissionConstants.resServices],
          ),
          SubMenuItemData(
            id: SubMenuItem.servicesBranchActivation,
            icon: Iconsax.buildings,
            label: 'Branch activation',
            route: RouteConstants.servicesBranchActivation,
            resources: [PermissionConstants.resServices],
          ),

          // ── Commercial Flow ──
          SubMenuItemData(
            id: SubMenuItem.servicesRequests,
            icon: Iconsax.clipboard_text,
            label: 'Service requests',
            route: RouteConstants.servicesRequests,
            resources: [
              PermissionConstants.resServices,
              PermissionConstants.resClients
            ],
          ),
          SubMenuItemData(
            id: SubMenuItem.servicesQuotations,
            icon: Iconsax.receipt_item,
            label: 'Quotations',
            route: RouteConstants.servicesQuotations,
            resources: [PermissionConstants.resServices],
          ),
          SubMenuItemData(
            id: SubMenuItem.servicesInvoicesPayments,
            icon: Iconsax.wallet_3,
            label: 'Invoices & payments',
            route: RouteConstants.servicesInvoicesPayments,
            resources: [
              PermissionConstants.resServiceInvoices,
              PermissionConstants.resPayments
            ],
          ),
          SubMenuItemData(
            id: SubMenuItem.servicesApprovals,
            icon: Iconsax.tick_circle,
            label: 'Approvals',
            route: RouteConstants.servicesApprovals,
            resources: [PermissionConstants.resServices],
          ),

          // ── Fulfilment ──
          SubMenuItemData(
            id: SubMenuItem.servicesOrders,
            icon: Iconsax.box,
            label: 'Service orders',
            route: RouteConstants.servicesOrders,
            resources: [PermissionConstants.resServices],
          ),
          SubMenuItemData(
            id: SubMenuItem.servicesExecutionTasks,
            icon: Iconsax.task_square,
            label: 'Execution tasks',
            route: RouteConstants.servicesExecutionTasks,
            resources: [PermissionConstants.resTasks],
          ),
          SubMenuItemData(
            id: SubMenuItem.servicesDeliverables,
            icon: Iconsax.archive_book,
            label: 'Deliverables',
            route: RouteConstants.servicesDeliverables,
            resources: [PermissionConstants.resDocuments],
          ),

          // ── Specialized Services ──
          SubMenuItemData(
            id: SubMenuItem.servicesRealEstateInventory,
            icon: Iconsax.building_4,
            label: 'Real estate inventory',
            route: RouteConstants.servicesRealEstateInventory,
            resources: [
              PermissionConstants.resProperties,
              PermissionConstants.resEstates
            ],
          ),
          SubMenuItemData(
            id: SubMenuItem.servicesSurveyEngineeringOthers,
            icon: Iconsax.ruler,
            label: 'Survey / engineering / others',
            route: RouteConstants.servicesSurveyEngineeringOthers,
            resources: [PermissionConstants.resServices],
          ),

          // ── Experience and Intelligence ──
          SubMenuItemData(
            id: SubMenuItem.servicesFeedbackQuality,
            icon: Iconsax.like_tag,
            label: 'Feedback and quality',
            route: RouteConstants.servicesFeedbackQuality,
            resources: [PermissionConstants.resClients],
          ),
          SubMenuItemData(
            id: SubMenuItem.servicesReportsAnalytics,
            icon: Iconsax.chart_2,
            label: 'Reports and analytics',
            route: RouteConstants.servicesReportsAnalytics,
            resources: [PermissionConstants.resStats],
          ),
        ],
      ),
      MenuItem(
        id: MainMenuItem.events,
        label: 'Events',
        icon: AppIcons.events,
        route: RouteConstants.events,
        isExpandable: false,
        resources: [PermissionConstants.resEvents],
      ),
    ],
  ),
  SidebarSection(
    label: 'Revenue',
    items: [
      MenuItem(
        id: MainMenuItem.marketingCrm,
        label: 'Marketing & Sales',
        icon: AppIcons.marketingCrm,
        isExpandable: true,
        resources: [
          PermissionConstants.resClients,
          PermissionConstants.resLeads,
          PermissionConstants.resMarketingCampaigns,
        ],
        children: [
          // ── Integrated Work ──
          SubMenuItemData(
            id: SubMenuItem.marketingLeadJournal,
            icon: Iconsax.note_21,
            label: 'Lead 360 journal',
            route: RouteConstants.marketingLeadJournal,
            resources: [PermissionConstants.resLeads],
          ),

          // ── Revenue Execution ──
          SubMenuItemData(
            id: SubMenuItem.marketingRevenueCommand,
            icon: Iconsax.money_send,
            label: 'Revenue command',
            route: RouteConstants.marketingRevenueCommand,
            resources: [PermissionConstants.resStats],
          ),
          SubMenuItemData(
            id: SubMenuItem.marketingDailyExecution,
            icon: Iconsax.task,
            label: 'Daily execution',
            route: RouteConstants.marketingDailyExecution,
            resources: [PermissionConstants.resTasks],
          ),
          SubMenuItemData(
            id: SubMenuItem.marketingTurnaround,
            icon: Iconsax.routing,
            label: '13-week turnaround',
            route: RouteConstants.marketingTurnaround,
            resources: [PermissionConstants.resStats],
          ),

          // ── Overview ──
          SubMenuItemData(
            id: SubMenuItem.marketingDashboard,
            icon: Iconsax.element_4,
            label: 'Command centre',
            route: RouteConstants.marketingDashboard,
            resources: [PermissionConstants.resMarketingCampaigns],
          ),
          SubMenuItemData(
            id: SubMenuItem.marketingOkrs,
            icon: Iconsax.flag,
            label: 'OKRs & targets',
            route: RouteConstants.marketingOkrs,
            resources: [PermissionConstants.resKpis],
          ),

          // ── Revenue Controls ──
          SubMenuItemData(
            id: SubMenuItem.marketingLeadControl,
            icon: Iconsax.radar_2,
            label: 'Lead control tower',
            route: RouteConstants.marketingLeadControl,
            resources: [PermissionConstants.resLeads],
          ),
          SubMenuItemData(
            id: SubMenuItem.marketingForecast,
            icon: Iconsax.trend_up,
            label: 'Forecast & coverage',
            route: RouteConstants.marketingForecast,
            resources: [PermissionConstants.resBudgets],
          ),

          // ── Marketing ──
          SubMenuItemData(
            id: SubMenuItem.marketingPipeline,
            icon: Iconsax.kanban,
            label: 'CRM Pipeline',
            route: RouteConstants.marketingPipeline,
            resources: [PermissionConstants.resLeads],
          ),
          SubMenuItemData(
            id: SubMenuItem.marketingCampaigns,
            icon: Iconsax.notification_bing,
            label: 'Campaigns',
            route: RouteConstants.marketingCampaigns,
            resources: [PermissionConstants.resMarketingCampaigns],
          ),
          SubMenuItemData(
            id: SubMenuItem.marketingCalendar,
            icon: Iconsax.calendar_1,
            label: 'Content calendar',
            route: RouteConstants.marketingCalendar,
            resources: [PermissionConstants.resMarketingCampaigns],
          ),
          SubMenuItemData(
            id: SubMenuItem.marketingMedia,
            icon: Iconsax.gallery,
            label: 'Media library',
            route: RouteConstants.marketingMedia,
            resources: [PermissionConstants.resDocuments],
          ),

          // ── Operations ──
          SubMenuItemData(
            id: SubMenuItem.marketingPartners,
            icon: Iconsax.profile_2user,
            label: 'Partners & media',
            route: RouteConstants.marketingPartners,
            resources: [PermissionConstants.resMarketingCampaigns],
          ),
          SubMenuItemData(
            id: SubMenuItem.marketingAnalytics,
            icon: Iconsax.chart_2,
            label: 'Analytics',
            route: RouteConstants.marketingAnalytics,
            resources: [PermissionConstants.resStats],
          ),
          SubMenuItemData(
            id: SubMenuItem.marketingSupport,
            icon: Iconsax.headphone,
            label: 'Support',
            route: RouteConstants.marketingSupport,
            resources: [PermissionConstants.resClients],
          ),

          // ── Team ──
          SubMenuItemData(
            id: SubMenuItem.marketingTeamDirectory,
            icon: Iconsax.people,
            label: 'Team directory',
            route: RouteConstants.marketingTeam,
            resources: [PermissionConstants.resEmployees],
          ),
          SubMenuItemData(
            id: SubMenuItem.marketingNewLead,
            icon: Iconsax.user_add,
            label: 'New lead',
            route: RouteConstants.marketingNewLead,
            resources: [PermissionConstants.resLeads],
          ),

          // ── Enablement & Growth ──
          SubMenuItemData(
            id: SubMenuItem.marketingPlaybooks,
            icon: Iconsax.book_1,
            label: 'Sales playbooks',
            route: RouteConstants.marketingPlaybooks,
            resources: [PermissionConstants.resMarketingCampaigns],
          ),
          SubMenuItemData(
            id: SubMenuItem.marketingCoaching,
            icon: Iconsax.teacher,
            label: 'Coaching',
            route: RouteConstants.marketingCoaching,
            resources: [PermissionConstants.resTrainingPrograms],
          ),
          SubMenuItemData(
            id: SubMenuItem.marketingContentStudio,
            icon: Iconsax.video_play,
            label: 'Content revenue studio',
            route: RouteConstants.marketingContentStudio,
            resources: [PermissionConstants.resMarketingCampaigns],
          ),

          // ── Commercial Operations ──
          SubMenuItemData(
            id: SubMenuItem.marketingEmailCenter,
            icon: Iconsax.sms,
            label: 'Email marketing',
            route: RouteConstants.marketingEmailCenter,
            resources: [PermissionConstants.resMarketingCampaigns],
          ),
          SubMenuItemData(
            id: SubMenuItem.marketingMediaRegister,
            icon: Iconsax.monitor,
            label: 'Traditional media register',
            route: RouteConstants.marketingMediaRegister,
            resources: [PermissionConstants.resMarketingCampaigns],
          ),
          SubMenuItemData(
            id: SubMenuItem.marketingHandoff,
            icon: Iconsax.repeat,
            label: 'Sales handoffs',
            route: RouteConstants.marketingHandoff,
            resources: [PermissionConstants.resClients],
          ),
          SubMenuItemData(
            id: SubMenuItem.marketingRealtorPortal,
            icon: Iconsax.user_tag,
            label: 'External realtors',
            route: RouteConstants.marketingRealtorPortal,
            resources: [PermissionConstants.resMarketingCampaigns],
          ),
          SubMenuItemData(
            id: SubMenuItem.marketingPartnerPortal,
            icon: Iconsax.share,
            label: 'Partner work portal',
            route: RouteConstants.marketingPartnerPortal,
            resources: [PermissionConstants.resMarketingCampaigns],
          ),

          // ── Governance ──
          SubMenuItemData(
            id: SubMenuItem.marketingApprovals,
            icon: Iconsax.tick_circle,
            label: 'Approval center',
            route: RouteConstants.marketingApprovals,
            resources: [PermissionConstants.resApprovalFlows],
          ),

          // ── Campaign Operations ──
          SubMenuItemData(
            id: SubMenuItem.marketingMeetings,
            icon: Iconsax.calendar_2,
            label: 'Marketing meetings',
            route: RouteConstants.marketingMeetings,
            resources: [PermissionConstants.resMarketingCampaigns],
          ),
        ],
      ),
      // Audit B11 fix: CRM pages were registered and route-gated but no
      // sidebar section linked to them — unreachable except by URL.
      MenuItem(
        id: MainMenuItem.crm,
        label: 'CRM',
        icon: Iconsax.people,
        isExpandable: true,
        resources: [
          PermissionConstants.resClients,
          PermissionConstants.resLeads,
        ],
        children: [
          SubMenuItemData(
            id: SubMenuItem.crmClients,
            icon: Iconsax.profile_2user,
            label: 'Client Relationship Management',
            route: RouteConstants.crmClients,
            resources: [PermissionConstants.resClients],
          ),
        ],
      ),
      MenuItem(
        id: MainMenuItem.financeAccounting,
        label: 'Finance & Accounting',
        icon: AppIcons.finance,
        isExpandable: true,
        resources: [
          PermissionConstants.resBudgets,
          PermissionConstants.resExpenses,
          PermissionConstants.resPayments,
          PermissionConstants.resEstateInvoices,
          PermissionConstants.resServiceInvoices,
          PermissionConstants.resOrders,
          PermissionConstants.resPayroll,
          PermissionConstants.resStats,
          PermissionConstants.resAssets,
          PermissionConstants.resComplianceAudits,
          PermissionConstants.resAuditLogs,
          PermissionConstants.resCompanySettings,
        ],
        children: [
          // ── Executive & Strategy ──
          SubMenuItemData(
            id: SubMenuItem.financeDashboard,
            icon: Iconsax.element_4,
            label: 'Command centre',
            route: RouteConstants.financeDashboard,
            resources: [
              PermissionConstants.resStats,
            ],
          ),
          SubMenuItemData(
            id: SubMenuItem.financeCashflow,
            icon: Iconsax.trend_up,
            label: 'Cash flow forecast',
            route: RouteConstants.financeCashflow,
            resources: [PermissionConstants.resBudgets],
          ),
          SubMenuItemData(
            id: SubMenuItem.financeApprovals,
            icon: Iconsax.tick_circle,
            label: 'Approvals queue',
            route: RouteConstants.financeApprovals,
            resources: [
              PermissionConstants.resExpenses,
              PermissionConstants.resBudgets,
              PermissionConstants.resApprovalFlows,
            ],
          ),
          SubMenuItemData(
            id: SubMenuItem.financeReports,
            icon: Iconsax.document_text,
            label: 'Financial statements',
            route: RouteConstants.financeReports,
            resources: [
              PermissionConstants.resStats,
              PermissionConstants.resBudgets,
            ],
          ),
          SubMenuItemData(
            id: SubMenuItem.financeServiceOrders,
            icon: Iconsax.status_up,
            label: 'Order profitability',
            route: RouteConstants.financeServiceOrders,
            resources: [PermissionConstants.resOrders],
          ),

          // ── Treasury & Revenue ──
          SubMenuItemData(
            id: SubMenuItem.financeInvoices,
            icon: Iconsax.receipt_2_1,
            label: 'Invoices & billing',
            route: RouteConstants.financeInvoices,
            resources: [
              PermissionConstants.resEstateInvoices,
              PermissionConstants.resServiceInvoices,
            ],
          ),
          SubMenuItemData(
            id: SubMenuItem.financePayments,
            icon: Iconsax.money_send,
            label: 'Payment submissions',
            route: RouteConstants.financePayments,
            resources: [PermissionConstants.resPayments],
          ),
          SubMenuItemData(
            id: SubMenuItem.financeReceivables,
            icon: Iconsax.card_tick,
            label: 'Receivables & aging',
            route: RouteConstants.financeReceivables,
            resources: [
              PermissionConstants.resEstateInvoices,
              PermissionConstants.resServiceInvoices,
              PermissionConstants.resPayments,
            ],
          ),
          SubMenuItemData(
            id: SubMenuItem.financeWallets,
            icon: Iconsax.wallet_3,
            label: 'Project wallets',
            route: RouteConstants.financeWallets,
            resources: [PermissionConstants.resPayments],
          ),
          SubMenuItemData(
            id: SubMenuItem.financeEstate,
            icon: Iconsax.building,
            label: 'Estate invoices',
            route: RouteConstants.financeEstate,
            resources: [
              PermissionConstants.resEstateInvoices,
              PermissionConstants.resEstates,
            ],
          ),
          SubMenuItemData(
            id: SubMenuItem.financeCashbook,
            icon: Iconsax.book,
            label: 'Cashbook & balances',
            route: RouteConstants.financeCashbook,
            resources: [
              PermissionConstants.resPayments,
              PermissionConstants.resExpenses,
            ],
          ),

          // ── Spend & Payables ──
          SubMenuItemData(
            id: SubMenuItem.financeExpenses,
            icon: Iconsax.receipt_edit,
            label: 'Expense vouchers',
            route: RouteConstants.financeExpenses,
            resources: [PermissionConstants.resExpenses],
          ),
          SubMenuItemData(
            id: SubMenuItem.financeVendors,
            icon: Iconsax.truck,
            label: 'Vendors & bills',
            route: RouteConstants.financeVendors,
            resources: [PermissionConstants.resExpenses],
          ),
          SubMenuItemData(
            id: SubMenuItem.financePettyCash,
            icon: Iconsax.coin,
            label: 'Petty cash',
            route: RouteConstants.financePettyCash,
            resources: [PermissionConstants.resExpenses],
          ),

          // ── Payroll & Compensation ──
          SubMenuItemData(
            id: SubMenuItem.financePayroll,
            icon: Iconsax.people,
            label: 'Payroll runs',
            route: RouteConstants.financePayroll,
            resources: [PermissionConstants.resPayroll],
          ),
          SubMenuItemData(
            id: SubMenuItem.financeCommissions,
            icon: Iconsax.award,
            label: 'Commissions & awards',
            route: RouteConstants.financeCommissions,
            resources: [PermissionConstants.resPayments],
          ),

          // ── Accounting & Governance ──
          SubMenuItemData(
            id: SubMenuItem.financeTax,
            icon: Iconsax.judge,
            label: 'Tax & statutory',
            route: RouteConstants.financeTax,
            resources: [
              PermissionConstants.resExpenses,
              PermissionConstants.resBudgets,
            ],
          ),
          SubMenuItemData(
            id: SubMenuItem.financeJournals,
            icon: Iconsax.edit_2,
            label: 'Journal entries',
            route: RouteConstants.financeJournals,
            resources: [PermissionConstants.resBudgets],
          ),
          SubMenuItemData(
            id: SubMenuItem.financeCoa,
            icon: Iconsax.diagram,
            label: 'Chart of accounts & GL',
            route: RouteConstants.financeCoa,
            resources: [PermissionConstants.resBudgets],
          ),
          SubMenuItemData(
            id: SubMenuItem.financeAssets,
            icon: Iconsax.building_4,
            label: 'Fixed assets',
            route: RouteConstants.financeAssets,
            resources: [PermissionConstants.resAssets],
          ),
          SubMenuItemData(
            id: SubMenuItem.financeAudit,
            icon: Iconsax.shield_tick,
            label: 'Audit & exceptions',
            route: RouteConstants.financeAudit,
            resources: [
              PermissionConstants.resComplianceAudits,
              PermissionConstants.resAuditLogs,
            ],
          ),
          SubMenuItemData(
            id: SubMenuItem.financeSettings,
            icon: Iconsax.setting_2,
            label: 'Finance settings',
            route: RouteConstants.financeSettings,
            resources: [PermissionConstants.resCompanySettings],
          ),
        ],
      ),
    ],
  ),
  SidebarSection(
    label: 'Insights',
    items: [
      MenuItem(
        id: MainMenuItem.analytics,
        label: 'Analytics & Insights',
        icon: AppIcons.analytics,
        isExpandable: true,
        resources: [PermissionConstants.resStats],
        children: [
          SubMenuItemData(
            id: SubMenuItem.overview,
            icon: Iconsax.chart_square,
            label: 'Overview',
            route: RouteConstants.analyticsOverview,
            resources: [PermissionConstants.resStats],
          ),
        ],
      ),
    ],
  ),
  SidebarSection(
    label: 'Compliance',
    items: [
      MenuItem(
        id: MainMenuItem.legalCompliance,
        label: 'Legal & Compliance',
        icon: AppIcons.legal,
        isExpandable: true,
        resources: [
          PermissionConstants.resLegalCases,
          PermissionConstants.resComplianceRecords,
          PermissionConstants.resComplianceAudits,
          PermissionConstants.resContracts,
        ],
        children: [
          SubMenuItemData(
            id: SubMenuItem.legalContracts,
            icon: Iconsax.document_text,
            label: 'Contracts',
            route: RouteConstants.legalContracts,
            resources: [PermissionConstants.resContracts],
          ),
          SubMenuItemData(
            id: SubMenuItem.legalCompliance,
            icon: Iconsax.verify,
            label: 'Compliance',
            route: RouteConstants.legalCompliance,
            resources: [PermissionConstants.resComplianceRecords],
          ),
          SubMenuItemData(
            id: SubMenuItem.legalCases,
            icon: Iconsax.judge,
            label: 'Cases',
            route: RouteConstants.legalCases,
            resources: [PermissionConstants.resLegalCases],
          ),
          SubMenuItemData(
            id: SubMenuItem.legalAudits,
            icon: Iconsax.clipboard_text,
            label: 'Audits',
            route: RouteConstants.legalAudits,
            resources: [PermissionConstants.resComplianceAudits],
          ),
        ],
      ),
      // Audit B11 fix: the Security & Authorization module was registered
      // and gated but absent from navigation — restored for admins.
      MenuItem(
        id: MainMenuItem.security,
        label: 'Security',
        icon: Iconsax.shield_tick,
        isExpandable: true,
        resources: [
          PermissionConstants.resAuditLogs,
          PermissionConstants.resRoles,
          PermissionConstants.resApprovalFlows,
        ],
        children: [
          SubMenuItemData(
            id: SubMenuItem.securityOverview,
            icon: Iconsax.element_4,
            label: 'Overview',
            route: RouteConstants.securityOverview,
            resources: [
              PermissionConstants.resAuditLogs,
              PermissionConstants.resRoles,
            ],
          ),
          SubMenuItemData(
            id: SubMenuItem.securityCodes,
            icon: Iconsax.security_user,
            label: 'Codes & Permissions',
            route: RouteConstants.securityCodes,
            resources: [PermissionConstants.resRoles],
          ),
          SubMenuItemData(
            id: SubMenuItem.securityWorkflow,
            icon: Iconsax.tick_circle,
            label: 'Workflows',
            route: RouteConstants.securityWorkflow,
            resources: [PermissionConstants.resApprovalFlows],
          ),
          SubMenuItemData(
            id: SubMenuItem.securityAlerts,
            icon: Iconsax.warning_2,
            label: 'Alerts',
            route: RouteConstants.securityAlerts,
            resources: [PermissionConstants.resAuditLogs],
          ),
          SubMenuItemData(
            id: SubMenuItem.securityLogs,
            icon: Iconsax.clipboard_text,
            label: 'Audit Logs',
            route: RouteConstants.securityLogs,
            resources: [PermissionConstants.resAuditLogs],
          ),
        ],
      ),
    ],
  ),
];
