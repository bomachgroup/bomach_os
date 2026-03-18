import 'dart:developer';

import 'package:bms_front_end/main.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/permissions.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:bms_front_end/src/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

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
}

enum SubMenuItem {
  // Dashboard sub-items
  dashboardHome,
  myProfile,
  myTasks,
  myReports,

  // Company sub-items
  company,
  branch,
  board,
  broadcast,
  roles,
  approvalWorkflow,
  auditLog,
  compliance,
  enugu,
  portHarcourt,
  abuja,

  // HR sub-items
  employees,

  // Employee sub-items
  employeeDirectory,
  employeePerformance,
  employeeAttendance,
  employeeTraining,
  leaves,
  clients,
  leads,
  department,

  // new
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

  // Warketing sub-items
  marketing,

  // Work sub-items
  operations,
  project,
  worksite,
  tasks,
  contracts,
  meetings,

  // Services sub-items
  servicesDashboard,
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

  // Finance & Accounting sub-items
  financeDashboard,
  invoice,
  payments,
  expenses,
  budget,
  vendorContributor,

  // Workspace
  workspace,
  workspaceDashboard,

  // Analytics
  overview,
  revenue,
  projects,
  analyticsPerformance,
  branchPerformance,

  // Legal & Compliance
  legalContracts,
  legalCompliance,
  legalCases,
  legalAudits,

  // Client Portal
  clientAccess,
  documentSharing,
  communications,
  portalAnalytics,

  // Security
  securityOverview,
  securityCodes,
  securityWorkflow,
  securityAlerts,
  securityLogs,

  // CRM
  crmClients,
  crmLeads,
  crmAnalytics,
  crmInteractions,
}

// Data classes for menu structure
class MenuItem {
  final MainMenuItem id;
  final String label;
  final String iconPath;
  final String? route;
  final List<String>? resources;
  final bool isExpandable;
  final List<SubMenuItemData> children;

  const MenuItem({
    required this.id,
    required this.label,
    required this.iconPath,
    this.route,
    this.resources,
    required this.isExpandable,
    this.children = const [],
  });
}

class SubMenuItemData {
  final SubMenuItem id;
  final String label;
  final String? route;
  final List<String>? resources;

  const SubMenuItemData({
    required this.id,
    required this.label,
    this.route,
    this.resources,
  });
}

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  MainMenuItem? selectedMainMenu;
  SubMenuItem? selectedSubMenu;
  late final List<MenuItem> menuItems;
  late final Map<String, MenuSelection> routeToMenuMapping;

  @override
  void initState() {
    super.initState();
    _initializeMenuItems();
    _initializeRouteMapping();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSelectionBasedOnCurrentRoute();
    });
  }

  void _initializeMenuItems() {
    menuItems = [
      const MenuItem(
        id: MainMenuItem.dashboard,
        label: 'Dashboard',
        iconPath: 'assets/svg/sidebar/home.svg',
        route: RouteConstants.home,
        isExpandable: true,
        resources: [
          PermissionConstants.resDashboard,
          PermissionConstants.resEmployees,
        ],
        children: [
          SubMenuItemData(
            id: SubMenuItem.dashboardHome,
            label: 'Overview',
            route: RouteConstants.home,
            resources: [
              PermissionConstants.resDashboard,
              PermissionConstants.resEmployees,
            ],
          ),
          SubMenuItemData(
            id: SubMenuItem.myProfile,
            label: 'My Profile',
            route: RouteConstants.employeeMyProfile,
            resources: [PermissionConstants.resEmployees],
          ),
          SubMenuItemData(
            id: SubMenuItem.myTasks,
            label: 'My Tasks',
            route: RouteConstants.employeeMyTasks,
            resources: [PermissionConstants.resTasks],
          ),
          SubMenuItemData(
            id: SubMenuItem.myReports,
            label: 'My Work Reports',
            route: RouteConstants.employeeMyReports,
            resources: [PermissionConstants.resWorkReports],
          ),
        ],
      ),
      const MenuItem(
        id: MainMenuItem.company,
        label: 'Company',
        iconPath: 'assets/svg/sidebar/person-plus.svg',
        isExpandable: true,
        resources: [PermissionConstants.resCompanySettings],
        children: [
          SubMenuItemData(
            id: SubMenuItem.company,
            label: 'Profile',
            route: RouteConstants.company,
            resources: [PermissionConstants.resCompanySettings],
          ),
          SubMenuItemData(
            id: SubMenuItem.branch,
            label: 'Branch',
            route: RouteConstants.branch,
            resources: [PermissionConstants.resBranches],
          ),
          SubMenuItemData(
            id: SubMenuItem.board,
            label: 'Board',
            route: RouteConstants.board,
            resources: [PermissionConstants.resBoardResolutions],
          ),
          SubMenuItemData(
            id: SubMenuItem.broadcast,
            label: 'Broadcast',
            route: RouteConstants.broadcast,
            resources: [PermissionConstants.resAnnouncements],
          ),
          SubMenuItemData(
            id: SubMenuItem.roles,
            label: 'Roles & Permissions',
            route: RouteConstants.roles,
            resources: [PermissionConstants.resRoles],
          ),
          SubMenuItemData(
            id: SubMenuItem.approvalWorkflow,
            label: 'Approval Workflows',
            route: RouteConstants.approvalWorkflow,
            resources: [PermissionConstants.resApprovalFlows],
          ),
          SubMenuItemData(
            id: SubMenuItem.department,
            label: 'Departments & Units',
            route: RouteConstants.department,
            resources: [PermissionConstants.resDepartments],
          ),
          SubMenuItemData(
            id: SubMenuItem.assets,
            label: 'Assets',
            route: RouteConstants.assets,
            resources: [PermissionConstants.resAssets],
          ),
          SubMenuItemData(
            id: SubMenuItem.auditLog,
            label: 'Audit Log',
            route: RouteConstants.auditLog,
            resources: [PermissionConstants.resAuditLogs],
          ),
        ],
      ),
      const MenuItem(
        id: MainMenuItem.hr,
        label: 'HR/Admin',
        iconPath: 'assets/svg/sidebar/people.svg',
        isExpandable: true,
        resources: [
          PermissionConstants.resEmployees,
          PermissionConstants.resJobPostings,
          PermissionConstants.resLeaveRequests,
          PermissionConstants.resPayroll,
        ],
        children: [
          SubMenuItemData(
            id: SubMenuItem.hrDashboad,
            label: 'Dashboard',
            route: RouteConstants.hr,
            resources: [PermissionConstants.resDashboard],
          ),
          SubMenuItemData(
            id: SubMenuItem.employees,
            label: 'Employees',
            route: RouteConstants.employees,
            resources: [PermissionConstants.resEmployees],
          ),
          SubMenuItemData(
            id: SubMenuItem.jobPost,
            label: 'Recruitment',
            route: RouteConstants.jobPost,
            resources: [PermissionConstants.resJobPostings],
          ),
          SubMenuItemData(
            id: SubMenuItem.leaveRequest,
            label: 'Leaves',
            route: RouteConstants.leaveRequest,
            resources: [PermissionConstants.resLeaveRequests],
          ),
          SubMenuItemData(
            id: SubMenuItem.trainingProgram,
            label: 'Training',
            route: RouteConstants.trainingProgram,
            resources: [PermissionConstants.resTrainingPrograms],
          ),
          SubMenuItemData(
            id: SubMenuItem.loans,
            label: 'Loans',
            route: RouteConstants.loans,
            resources: [PermissionConstants.resLoans],
          ),
          SubMenuItemData(
            id: SubMenuItem.benefits,
            label: 'Benefits',
            route: RouteConstants.benefits,
            resources: [PermissionConstants.resPayroll],
          ),
          SubMenuItemData(
            id: SubMenuItem.attendance,
            label: 'Attendance',
            route: RouteConstants.attendance,
            resources: [PermissionConstants.resEmployees],
          ),
          SubMenuItemData(
            id: SubMenuItem.performance,
            label: 'Performance',
            route: RouteConstants.performanceReview,
            resources: [PermissionConstants.resPerformanceReviews],
          ),
          SubMenuItemData(
            id: SubMenuItem.workReport,
            label: 'Work Reports',
            route: RouteConstants.workReport,
            resources: [PermissionConstants.resWorkReports],
          ),
          SubMenuItemData(
            id: SubMenuItem.monthlyScorecard,
            label: 'Monthly Scorecard',
            route: RouteConstants.monthlyScorecard,
            resources: [PermissionConstants.resMonthlyScorecards],
          ),
          SubMenuItemData(
            id: SubMenuItem.awardsRecognition,
            label: 'Awards & Recognition',
            route: RouteConstants.awardsRecognition,
            resources: [PermissionConstants.resAwards],
          ),
          SubMenuItemData(
            id: SubMenuItem.performanceLeaderboard,
            label: 'Performance Leaderboard',
            route: RouteConstants.performanceLeaderboard,
            resources: [PermissionConstants.resKpis],
          ),
          SubMenuItemData(
            id: SubMenuItem.employeeEvaluation,
            label: 'Employee Evaluation',
            route: RouteConstants.employeeEvaluation,
            resources: [PermissionConstants.resEmployeeEvaluations],
          ),
          SubMenuItemData(
            id: SubMenuItem.disciplinaryProcess,
            label: 'Disciplinary Process',
            route: RouteConstants.disciplinaryProcess,
            resources: [PermissionConstants.resDisciplinaryCases],
          ),
        ],
      ),
      const MenuItem(
        id: MainMenuItem.work,
        label: 'Operations',
        iconPath: 'assets/svg/sidebar/joined-square.svg',
        isExpandable: true,
        resources: [
          PermissionConstants.resProjects,
          PermissionConstants.resTasks,
          PermissionConstants.resContracts,
          PermissionConstants.resWorksites,
        ],
        children: [
          SubMenuItemData(
            id: SubMenuItem.operations,
            label: 'Operations',
            route: RouteConstants.operations,
            resources: [PermissionConstants.resProjects],
          ),
          SubMenuItemData(
            id: SubMenuItem.project,
            label: 'Project',
            route: RouteConstants.projects,
            resources: [PermissionConstants.resProjects],
          ),
          SubMenuItemData(
            id: SubMenuItem.worksite,
            label: 'Worksite',
            route: RouteConstants.worksite,
            resources: [PermissionConstants.resWorksites],
          ),
          SubMenuItemData(
            id: SubMenuItem.tasks,
            label: 'Tasks',
            route: RouteConstants.tasks,
            resources: [PermissionConstants.resTasks],
          ),
          SubMenuItemData(
            id: SubMenuItem.contracts,
            label: 'Contracts',
            route: RouteConstants.contracts,
            resources: [PermissionConstants.resContracts],
          ),
          SubMenuItemData(
            id: SubMenuItem.meetings,
            label: 'Meetings',
            route: RouteConstants.meetings,
            resources: [PermissionConstants.resMeetings],
          ),
        ],
      ),
      const MenuItem(
        id: MainMenuItem.financeAccounting,
        label: 'Finance & Accounting',
        iconPath: 'assets/svg/sidebar/joined-square.svg',
        isExpandable: true,
        resources: [
          PermissionConstants.resBudgets,
          PermissionConstants.resExpenses,
          PermissionConstants.resPayments,
          PermissionConstants.resEstateInvoices,
        ],
        children: [
          SubMenuItemData(
            id: SubMenuItem.financeDashboard,
            label: 'Dashboard',
            route: RouteConstants.finance,
            resources: [
              PermissionConstants.resStats,
              PermissionConstants.resBudgets,
            ],
          ),
          SubMenuItemData(
            id: SubMenuItem.invoice,
            label: 'Invoice',
            route: RouteConstants.invoice,
            resources: [
              PermissionConstants.resEstateInvoices,
              PermissionConstants.resServiceInvoices,
            ],
          ),
          SubMenuItemData(
            id: SubMenuItem.payments,
            label: 'Payments',
            route: RouteConstants.payment,
            resources: [PermissionConstants.resPayments],
          ),
          SubMenuItemData(
            id: SubMenuItem.expenses,
            label: 'Expenses',
            route: RouteConstants.expense,
            resources: [PermissionConstants.resExpenses],
          ),
          SubMenuItemData(
            id: SubMenuItem.budget,
            label: 'Budget',
            route: RouteConstants.budget,
            resources: [PermissionConstants.resBudgets],
          ),
          SubMenuItemData(
            id: SubMenuItem.vendorContributor,
            label: 'Vendor/Contributor',
            route: RouteConstants.contractPayment,
            resources: [
              PermissionConstants.resContracts,
              PermissionConstants.resPayments,
            ],
          ),
        ],
      ),
      const MenuItem(
        id: MainMenuItem.events,
        label: 'Events',
        iconPath: 'assets/svg/sidebar/calendar.svg',
        route: RouteConstants.events,
        isExpandable: false,
        resources: [PermissionConstants.resEvents],
      ),
      const MenuItem(
        id: MainMenuItem.services,
        label: 'Services',
        iconPath: 'assets/svg/sidebar/calendar.svg',
        isExpandable: true,
        resources: [
          PermissionConstants.resServices,
          PermissionConstants.resProperties,
          PermissionConstants.resEstates,
          PermissionConstants.resClients,
        ],
        children: [
          SubMenuItemData(
            id: SubMenuItem.servicesDashboard,
            label: 'Dashboard',
            route: RouteConstants.services,
            resources: [PermissionConstants.resServices],
          ),
          SubMenuItemData(
            id: SubMenuItem.serviceClients,
            label: 'Clients',
            route: RouteConstants.serviceClients,
            resources: [PermissionConstants.resClients],
          ),
          SubMenuItemData(
            id: SubMenuItem.propertyManagement,
            label: 'Property Management',
            route: RouteConstants.propertyList,
            resources: [PermissionConstants.resProperties],
          ),
        ],
      ),
      const MenuItem(
        id: MainMenuItem.workspace,
        label: 'Workspace',
        iconPath: 'assets/svg/sidebar/joined-square.svg',
        isExpandable: true,
        resources: [
          PermissionConstants.resDocuments,
          PermissionConstants.resContent,
        ],
        children: [
          SubMenuItemData(
            id: SubMenuItem.workspace,
            label: 'Overview',
            route: RouteConstants.workspace,
            resources: [
              PermissionConstants.resDocuments,
              PermissionConstants.resContent,
            ],
          ),
          SubMenuItemData(
            id: SubMenuItem.workspaceDashboard,
            label: 'Dashboard',
            route: RouteConstants.workspaceDashboard,
            resources: [
              PermissionConstants.resDocuments,
              PermissionConstants.resContent,
            ],
          ),
        ],
      ),
      const MenuItem(
        id: MainMenuItem.analytics,
        label: 'Analytics & Insights',
        iconPath: 'assets/svg/sidebar/joined-square.svg',
        isExpandable: true,
        resources: [PermissionConstants.resStats],
        children: [
          SubMenuItemData(
            id: SubMenuItem.overview,
            label: 'Overview',
            route: RouteConstants.analyticsOverview,
            resources: [PermissionConstants.resStats],
          ),
          SubMenuItemData(
            id: SubMenuItem.revenue,
            label: 'Revenue',
            route: RouteConstants.analyticsRevenue,
            resources: [PermissionConstants.resStats],
          ),
          SubMenuItemData(
            id: SubMenuItem.projects,
            label: 'Projects',
            route: RouteConstants.analyticsProjects,
            resources: [
              PermissionConstants.resProjects,
              PermissionConstants.resStats,
            ],
          ),
          SubMenuItemData(
            id: SubMenuItem.analyticsPerformance,
            label: 'Performance',
            route: RouteConstants.analyticsPerformance,
            resources: [PermissionConstants.resStats],
          ),
          SubMenuItemData(
            id: SubMenuItem.branchPerformance,
            label: 'Branch Performance',
            route: RouteConstants.branchPerformanceAnalysis,
            resources: [
              PermissionConstants.resBranches,
              PermissionConstants.resStats,
            ],
          ),
        ],
      ),
      const MenuItem(
        id: MainMenuItem.legalCompliance,
        label: 'Legal & Compliance',
        iconPath: 'assets/svg/sidebar/joined-square.svg',
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
            label: 'Contracts',
            route: RouteConstants.legalContracts,
            resources: [PermissionConstants.resContracts],
          ),
          SubMenuItemData(
            id: SubMenuItem.legalCompliance,
            label: 'Compliance',
            route: RouteConstants.legalCompliance,
            resources: [PermissionConstants.resComplianceRecords],
          ),
          SubMenuItemData(
            id: SubMenuItem.legalCases,
            label: 'Cases',
            route: RouteConstants.legalCases,
            resources: [PermissionConstants.resLegalCases],
          ),
          SubMenuItemData(
            id: SubMenuItem.legalAudits,
            label: 'Audits',
            route: RouteConstants.legalAudits,
            resources: [PermissionConstants.resComplianceAudits],
          ),
        ],
      ),
      const MenuItem(
        id: MainMenuItem.clientPortal,
        label: 'Client Portal',
        iconPath: 'assets/svg/sidebar/joined-square.svg',
        isExpandable: true,
        resources: [
          PermissionConstants.resClients,
          PermissionConstants.resDocuments,
        ],
        children: [
          SubMenuItemData(
            id: SubMenuItem.clientAccess,
            label: 'Client Access',
            route: RouteConstants.clientAccess,
            resources: [PermissionConstants.resClients],
          ),
          SubMenuItemData(
            id: SubMenuItem.documentSharing,
            label: 'Document Sharing',
            route: RouteConstants.documentSharing,
            resources: [PermissionConstants.resDocuments],
          ),
          SubMenuItemData(
            id: SubMenuItem.communications,
            label: 'Communications',
            route: RouteConstants.communications,
            resources: [PermissionConstants.resClients],
          ),
          SubMenuItemData(
            id: SubMenuItem.portalAnalytics,
            label: 'Portal Analytics',
            route: RouteConstants.portalAnalytics,
            resources: [
              PermissionConstants.resStats,
              PermissionConstants.resClients,
            ],
          ),
        ],
      ),
      // const MenuItem(
      //   id: MainMenuItem.security,
      //   label: 'Security & Authorization',
      //   iconPath: 'assets/svg/sidebar/joined-square.svg',
      //   isExpandable: true,
      //   resources: [
      //     PermissionConstants.resAuditLogs,
      //     PermissionConstants.resRoles,
      //     PermissionConstants.resApprovalFlows,
      //   ],
      //   children: [
      //     SubMenuItemData(
      //       id: SubMenuItem.securityOverview,
      //       label: 'Overview',
      //       route: RouteConstants.securityOverview,
      //       resources: [PermissionConstants.resAuditLogs],
      //     ),
      //     SubMenuItemData(
      //       id: SubMenuItem.securityCodes,
      //       label: 'Security Codes',
      //       route: RouteConstants.securityCodes,
      //       resources: [PermissionConstants.resRoles],
      //     ),
      //     SubMenuItemData(
      //       id: SubMenuItem.securityWorkflow,
      //       label: 'Workflows',
      //       route: RouteConstants.securityWorkflow,
      //       resources: [PermissionConstants.resApprovalFlows],
      //     ),
      //     SubMenuItemData(
      //       id: SubMenuItem.securityAlerts,
      //       label: 'Security Alerts',
      //       route: RouteConstants.securityAlerts,
      //       resources: [PermissionConstants.resAuditLogs],
      //     ),
      //     SubMenuItemData(
      //       id: SubMenuItem.securityLogs,
      //       label: 'Audit Logs',
      //       route: RouteConstants.securityLogs,
      //       resources: [PermissionConstants.resAuditLogs],
      //     ),
      //   ],
      // ),
      const MenuItem(
        id: MainMenuItem.crm,
        label: 'CRM',
        iconPath: 'assets/svg/sidebar/joined-square.svg',
        isExpandable: true,
        resources: [
          PermissionConstants.resClients,
          PermissionConstants.resLeads,
          PermissionConstants.resMarketingCampaigns,
        ],
        children: [
          SubMenuItemData(
            id: SubMenuItem.crmClients,
            label: 'Clients',
            route: RouteConstants.crmClients,
            resources: [PermissionConstants.resClients],
          ),
          SubMenuItemData(
            id: SubMenuItem.crmLeads,
            label: 'Leads',
            route: RouteConstants.crmLeads,
            resources: [PermissionConstants.resLeads],
          ),
          SubMenuItemData(
            id: SubMenuItem.crmInteractions,
            label: 'Interactions',
            route: RouteConstants.crmInteractions,
            resources: [
              PermissionConstants.resClients,
              PermissionConstants.resLeads,
            ],
          ),
          SubMenuItemData(
            id: SubMenuItem.crmAnalytics,
            label: 'Analytics',
            route: RouteConstants.crmAnalytics,
            resources: [
              PermissionConstants.resStats,
              PermissionConstants.resClients,
            ],
          ),
          SubMenuItemData(
            id: SubMenuItem.marketing,
            label: 'Marketing',
            route: RouteConstants.marketing,
            resources: [PermissionConstants.resMarketingCampaigns],
          ),
        ],
      ),
    ];
  }

  void _initializeRouteMapping() {
    routeToMenuMapping = {};

    // Process top-level routes
    for (var menuItem in menuItems) {
      if (!menuItem.isExpandable && menuItem.route != null) {
        routeToMenuMapping[menuItem.route!] = MenuSelection(
          mainMenuItem: menuItem.id,
          subMenuItem: null,
        );
      }

      // Process sub-menu routes
      if (menuItem.isExpandable) {
        for (var subMenuItem in menuItem.children) {
          if (subMenuItem.route != null) {
            routeToMenuMapping[subMenuItem.route!] = MenuSelection(
              mainMenuItem: menuItem.id,
              subMenuItem: subMenuItem.id,
            );
          }
        }
      }
    }

    // log('Route Mapping Initialized: $routeToMenuMapping');
  }

  void _updateSelectionBasedOnCurrentRoute() {
    final currentRoute = GoRouterState.of(context).uri.toString();
    log('Current Route: $currentRoute');

    // Find menu item for current route
    if (routeToMenuMapping.containsKey(currentRoute)) {
      final selection = routeToMenuMapping[currentRoute]!;
      setState(() {
        selectedMainMenu = selection.mainMenuItem;
        selectedSubMenu = selection.subMenuItem;
      });
      _saveMenuState(selection.mainMenuItem, selection.subMenuItem);
      log('Menu selection updated based on route: main=$selectedMainMenu, sub=$selectedSubMenu');
    } else {
      // If route is not found in mapping, load from preferences as fallback
      _loadMenuState();
    }
  }

  void _loadMenuState() {
    final mainMenuIndex = prefs.getInt('selectedMenu');
    final subMenuIndex = prefs.getInt('selectedSubMenu');

    setState(() {
      selectedMainMenu = mainMenuIndex != null
          ? MainMenuItem.values[mainMenuIndex]
          : MainMenuItem.dashboard;
      selectedSubMenu = subMenuIndex != null && subMenuIndex >= 0
          ? SubMenuItem.values[subMenuIndex]
          : null;
    });
    log('Menu state loaded from preferences: main=$selectedMainMenu, sub=$selectedSubMenu');
  }

  Future<void> _saveMenuState(
      MainMenuItem mainMenu, SubMenuItem? subMenu) async {
    await prefs.setInt('selectedMenu', mainMenu.index);
    await prefs.setInt('selectedSubMenu', subMenu?.index ?? -1);
    log('Menu state saved to preferences: main=$mainMenu, sub=$subMenu');
  }

  void _navigate(
      String? route, MainMenuItem mainMenuItem, SubMenuItem? subMenuItem) {
    if (route != null) {
      context.go(route);
    }

    setState(() {
      selectedMainMenu = mainMenuItem;
      selectedSubMenu = subMenuItem;
    });

    _saveMenuState(mainMenuItem, subMenuItem);

    if (!isLargeScreen(context)) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildMenuItem(MenuItem menuItem) {
    final permissionService = Get.find<PermissionService>();

    // Dynamic resource-based permission check
    bool isAuthorized =
        permissionService.canAccessResources(menuItem.resources);

    // MUTUAL EXCLUSIVITY LOGIC:
    // 1. If this is the Dashboard, hide it if user also has Company Settings access (CEO view)
    if (menuItem.id == MainMenuItem.dashboard &&
        permissionService.hasAnyPermissionForResource(
            PermissionConstants.resCompanySettings)) {
      isAuthorized = false;
    }

    // 2. If this is Company, it is already gated by company_settings resource
    // (Which employees lack, so it will be hidden naturally)

    // Hide if not authorized
    if (!isAuthorized) {
      return const SizedBox.shrink();
    }

    // Filter sub-items based on resource permissions
    final authorizedSubItems = menuItem.children
        .where(
            (subItem) => permissionService.canAccessResources(subItem.resources))
        .toList();

    // Hide if expandable and no authorized children
    if (menuItem.isExpandable && authorizedSubItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool isSelected = selectedMainMenu == menuItem.id;

    final icon = SvgPicture.asset(
      menuItem.iconPath,
      colorFilter: ColorFilter.mode(
          isSelected ? AppColors.white : AppColors.black, BlendMode.srcIn),
    );

    final title = Text(
      menuItem.label,
      style: isSelected ? AppText.sideMWhite_400_14 : AppText.black_400_14,
    );

    if (!menuItem.isExpandable) {
      return NonExpandableSideBarItem(
        titleColor: isSelected ? AppColors.blue : Colors.transparent,
        icon: icon,
        title: title,
        onTap: () => _navigate(menuItem.route, menuItem.id, null),
      );
    }

    return ExpandableSideBarItem(
      expandedTileController: ExpandedTileController(isExpanded: isSelected),
      titleColor: isSelected ? AppColors.blue : Colors.transparent,
      icon: icon,
      title: title,
      onTap: () {
        setState(() {
          selectedMainMenu = menuItem.id;
        });
        _saveMenuState(menuItem.id, selectedSubMenu);
      },
      children: authorizedSubItems.map<Widget>((subMenuItem) {
        return _buildSubItem(subMenuItem, menuItem.id);
      }).toList(),
    );
  }

  Widget _buildSubItem(
      SubMenuItemData subMenuItem, MainMenuItem parentMenuItem) {
    final isSelected = selectedSubMenu == subMenuItem.id;

    return SubSideBarItems(
      title: Text(
        subMenuItem.label,
        style: isSelected
            ? AppText.sideMBlueText_400_14
            : AppText.sideMText_300_14,
      ),
      isSelected: isSelected,
      onTap: () => _navigate(subMenuItem.route, parentMenuItem, subMenuItem.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sideMenu,
      padding: const EdgeInsets.only(right: 16, left: 16),
      height: MediaQuery.sizeOf(context).height,
      child: Obx(() => ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              kSizedBoxBG,
              const Row(
                children: [
                  Text('BOMACH', style: AppText.black_500_20),
                  Text('OS', style: AppText.black_500_32),
                ],
              ),
              const SizedBox(height: 24),
              ...menuItems.map((menuItem) => _buildMenuItem(menuItem)),
              kSizedBox,
            ],
          )),
    );
  }
}

// Helper class for menu selection
class MenuSelection {
  final MainMenuItem mainMenuItem;
  final SubMenuItem? subMenuItem;

  const MenuSelection({
    required this.mainMenuItem,
    this.subMenuItem,
  });

  @override
  String toString() {
    return 'MenuSelection(main: $mainMenuItem, sub: $subMenuItem)';
  }
}

class SubSideBarItems extends StatelessWidget {
  final Text title;
  final VoidCallback onTap;
  final bool isSelected;
  const SubSideBarItems({
    super.key,
    required this.title,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      onTap: onTap,
      leading: Visibility(
          visible: isSelected,
          child: const CircleAvatar(
            backgroundColor: AppColors.blue,
            radius: 5,
          )),
      title: title,
    );
  }
}

class ExpandableSideBarItem extends StatelessWidget {
  final ExpandedTileController expandedTileController;
  final Widget title;
  final Color titleColor;
  final VoidCallback onTap;
  final Widget icon;
  final List<Widget> children;
  const ExpandableSideBarItem({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    required this.onTap,
    required this.titleColor,
    required this.expandedTileController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpandedTile(
        onTap: onTap,
        theme: ExpandedTileThemeData(
          footerBackgroundColor: Colors.transparent,
          headerPadding: const EdgeInsets.all(12),
          contentPadding: const EdgeInsets.only(top: 0),
          contentBackgroundColor: Colors.transparent,
          headerBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10)),
          headerColor: titleColor,
          headerSplashColor: Colors.transparent,
          contentSeparatorColor: Colors.transparent,
        ),
        title: title,
        leading: icon,
        content: Column(children: children),
        controller: expandedTileController,
        trailing: SvgPicture.asset(
          "assets/svg/arrow-ios-down.svg",
          colorFilter: ColorFilter.mode(
              expandedTileController.isExpanded
                  ? AppColors.white
                  : AppColors.black,
              BlendMode.srcIn),
        ),
        trailingRotation: 180,
      ),
    );
  }
}

class NonExpandableSideBarItem extends StatelessWidget {
  final Widget title;
  final VoidCallback onTap;
  final Color titleColor;
  final Widget icon;
  const NonExpandableSideBarItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: titleColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        tileColor: titleColor,
        leading: icon,
        onTap: onTap,
        title: title,
      ),
    );
  }
}
