import 'dart:developer';

import 'package:bms_front_end/main.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  logout,
  financeAccounting,
  workspace,
  analytics,
  legalCompliance,
  clientPortal,
  security,
  crm,
}

enum SubMenuItem {
  // Company sub-items
  company,
  branch,
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
  clockIn,
  leaveRequest,
  performance,
  payroll,
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
  final bool isExpandable;
  final List<SubMenuItemData> children;

  const MenuItem({
    required this.id,
    required this.label,
    required this.iconPath,
    this.route,
    required this.isExpandable,
    this.children = const [],
  });
}

class SubMenuItemData {
  final SubMenuItem id;
  final String label;
  final String? route;

  const SubMenuItemData({
    required this.id,
    required this.label,
    this.route,
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
        isExpandable: false,
      ),
      const MenuItem(
        id: MainMenuItem.company,
        label: 'Company',
        iconPath: 'assets/svg/sidebar/person-plus.svg',
        isExpandable: true,
        children: [
          SubMenuItemData(
            id: SubMenuItem.company,
            label: 'Profile',
            route: RouteConstants.company,
          ),
          SubMenuItemData(
            id: SubMenuItem.branch,
            label: 'Branch',
            route: RouteConstants.branch,
          ),
          SubMenuItemData(
            id: SubMenuItem.auditLog,
            label: 'Audit Log',
            route: RouteConstants.auditLog,
          ),
          SubMenuItemData(
            id: SubMenuItem.compliance,
            label: 'Compliance',
            route: RouteConstants.compliance,
          ),
          SubMenuItemData(
            id: SubMenuItem.branchPerformance,
            label: 'Branch Performance',
            route: RouteConstants.branchPerformanceAnalysis,
          ),
          SubMenuItemData(
            id: SubMenuItem.enugu,
            label: 'Enugu',
            route: RouteConstants.enugu,
          ),
          SubMenuItemData(
            id: SubMenuItem.portHarcourt,
            label: 'Port Harcourt',
          ),
          SubMenuItemData(
            id: SubMenuItem.abuja,
            label: 'Abuja',
          ),
        ],
      ),
      const MenuItem(
        id: MainMenuItem.hr,
        label: 'HR',
        iconPath: 'assets/svg/sidebar/people.svg',
        isExpandable: true,
        children: [
          SubMenuItemData(
            id: SubMenuItem.hrDashboad,
            label: 'Dashboard',
            route: RouteConstants.hr,
          ),
          SubMenuItemData(
            id: SubMenuItem.jobPost,
            label: 'Job Postings',
            route: RouteConstants.jobPost,
          ),
          SubMenuItemData(
            id: SubMenuItem.jobApplicants,
            label: 'Applicants',
            route: RouteConstants.jobApplicants,
          ),
          SubMenuItemData(
            id: SubMenuItem.attendance,
            label: 'Attendance',
            route: RouteConstants.attendance,
          ),
          SubMenuItemData(
            id: SubMenuItem.clockIn,
            label: 'Clock In',
            route: RouteConstants.clockIn,
          ),
          SubMenuItemData(
            id: SubMenuItem.leaveRequest,
            label: 'Leave Request',
            route: RouteConstants.leaveRequest,
          ),
          SubMenuItemData(
            id: SubMenuItem.performance,
            label: 'Performance',
            route: RouteConstants.performanceReview,
          ),
          SubMenuItemData(
            id: SubMenuItem.payroll,
            label: 'Payroll',
            route: RouteConstants.payroll,
          ),
          SubMenuItemData(
            id: SubMenuItem.trainingProgram,
            label: 'Training Program',
            route: RouteConstants.trainingProgram,
          ),
          SubMenuItemData(
            id: SubMenuItem.associates,
            label: 'Associates',
            route: RouteConstants.associates,
          ),
          SubMenuItemData(
            id: SubMenuItem.assets,
            label: 'Assets',
            route: RouteConstants.assets,
          ),
          SubMenuItemData(
            id: SubMenuItem.workReport,
            label: 'Work Reports',
            route: RouteConstants.workReport,
          ),
          SubMenuItemData(
            id: SubMenuItem.monthlyScorecard,
            label: 'Monthly Scorecard',
            route: RouteConstants.monthlyScorecard,
          ),
          SubMenuItemData(
            id: SubMenuItem.awardsRecognition,
            label: 'Awards & Recognition',
            route: RouteConstants.awardsRecognition,
          ),
          SubMenuItemData(
            id: SubMenuItem.performanceLeaderboard,
            label: 'Performance Leaderboard',
            route: RouteConstants.performanceLeaderboard,
          ),
          SubMenuItemData(
            id: SubMenuItem.employeeEvaluation,
            label: 'Employee Evaluation',
            route: RouteConstants.employeeEvaluation,
          ),
          SubMenuItemData(
            id: SubMenuItem.disciplinaryProcess,
            label: 'Disciplinary Process',
            route: RouteConstants.disciplinaryProcess,
          ),
          SubMenuItemData(
            id: SubMenuItem.employees,
            label: 'Employees',
            route: RouteConstants.employees,
          ),
          SubMenuItemData(
            id: SubMenuItem.leaves,
            label: 'Leaves',
            route: RouteConstants.leaves,
          ),
          SubMenuItemData(
            id: SubMenuItem.department,
            label: 'Department',
            route: RouteConstants.department,
          ),
        ],
      ),
      // const MenuItem(
      //   id: MainMenuItem.employee,
      //   label: 'Employee',
      //   iconPath: 'assets/svg/sidebar/people.svg',
      //   route: RouteConstants.employee,
      //   isExpandable: true,
      //   children: [
      //     SubMenuItemData(
      //       id: SubMenuItem.employeeDirectory,
      //       label: 'Directory',
      //       route: RouteConstants.employeeDirectory,
      //     ),
      //     SubMenuItemData(
      //       id: SubMenuItem.employeePerformance,
      //       label: 'Performance Reviews',
      //       route: RouteConstants.employeePerformance,
      //     ),
      //     SubMenuItemData(
      //       id: SubMenuItem.employeeAttendance,
      //       label: 'Attendance',
      //       route: RouteConstants.employeeAttendance,
      //     ),
      //     SubMenuItemData(
      //       id: SubMenuItem.employeeTraining,
      //       label: 'Training Programs',
      //       route: RouteConstants.employeeTraining,
      //     ),
      //   ],
      // ),
      const MenuItem(
        id: MainMenuItem.work,
        label: 'Operations',
        iconPath: 'assets/svg/sidebar/joined-square.svg',
        isExpandable: true,
        children: [
          SubMenuItemData(
            id: SubMenuItem.operations,
            label: 'Operations',
            route: RouteConstants.operations,
          ),
          SubMenuItemData(
            id: SubMenuItem.project,
            label: 'Project',
            route: RouteConstants.projects,
          ),
          SubMenuItemData(
            id: SubMenuItem.worksite,
            label: 'Worksite',
          ),
          SubMenuItemData(
            id: SubMenuItem.tasks,
            label: 'Tasks',
            route: RouteConstants.tasks,
          ),
          SubMenuItemData(
            id: SubMenuItem.contracts,
            label: 'Contracts',
            route: RouteConstants.contracts,
          ),
          SubMenuItemData(
            id: SubMenuItem.meetings,
            label: 'Meetings',
            route: RouteConstants.meetings,
          ),
        ],
      ),
      const MenuItem(
        id: MainMenuItem.marketing,
        label: 'Marketing',
        iconPath: 'assets/svg/sidebar/joined-square.svg',
        isExpandable: true,
        children: [
          SubMenuItemData(
            id: SubMenuItem.marketing,
            label: 'Marketing',
            route: RouteConstants.marketing,
          ),
        ],
      ),
      const MenuItem(
        id: MainMenuItem.financeAccounting,
        label: 'Finance & Accounting',
        iconPath: 'assets/svg/sidebar/joined-square.svg',
        isExpandable: true,
        children: [
          SubMenuItemData(
            id: SubMenuItem.financeDashboard,
            label: 'Dashboard',
            route: RouteConstants.finance,
          ),
          SubMenuItemData(
            id: SubMenuItem.invoice,
            label: 'Invoice',
            route: RouteConstants.invoice,
          ),
          SubMenuItemData(
            id: SubMenuItem.payments,
            label: 'Payments',
            route: RouteConstants.payment,
          ),
          SubMenuItemData(
            id: SubMenuItem.expenses,
            label: 'Expenses',
            route: RouteConstants.expense,
          ),
          SubMenuItemData(
            id: SubMenuItem.budget,
            label: 'Budget',
            route: RouteConstants.budget,
          ),
          SubMenuItemData(
            id: SubMenuItem.vendorContributor,
            label: 'Vendor/Contributor',
            route: RouteConstants.contractPayment,
          ),
        ],
      ),
      const MenuItem(
        id: MainMenuItem.calendar,
        label: 'Calendar',
        iconPath: 'assets/svg/sidebar/calendar.svg',
        isExpandable: true,
      ),
      const MenuItem(
        id: MainMenuItem.events,
        label: 'Events',
        iconPath: 'assets/svg/sidebar/calendar.svg',
        route: RouteConstants.events,
        isExpandable: false,
      ),
      const MenuItem(
        id: MainMenuItem.services,
        label: 'Services',
        iconPath: 'assets/svg/sidebar/calendar.svg',
        isExpandable: true,
        children: [
          SubMenuItemData(
            id: SubMenuItem.servicesDashboard,
            label: 'Dashboard',
            route: RouteConstants.services,
          ),
          SubMenuItemData(
            id: SubMenuItem.serviceClients,
            label: 'Clients',
            route: RouteConstants.serviceClients,
          ),
          SubMenuItemData(
            id: SubMenuItem.serviceOrder,
            label: 'Service Order',
            route: RouteConstants.serviceOrder,
          ),
          SubMenuItemData(
            id: SubMenuItem.realEstate,
            label: 'Real Estate',
            route: RouteConstants.realEstate,
          ),
          SubMenuItemData(
            id: SubMenuItem.landSurvey,
            label: 'Land Survey',
            route: RouteConstants.landSurvey,
          ),
          SubMenuItemData(
            id: SubMenuItem.servicesItem,
            label: 'Services',
            route: RouteConstants.servicesProperty,
          ),
          SubMenuItemData(
            id: SubMenuItem.propertyManagement,
            label: 'Property Management',
            route: RouteConstants.propertyList,
          ),
          SubMenuItemData(
            id: SubMenuItem.estateManagement,
            label: 'Estate Management',
            route: RouteConstants.estateManagement,
          ),
          SubMenuItemData(
            id: SubMenuItem.estatePerformance,
            label: 'Estate Performance',
            route: RouteConstants.estatePerformance,
          ),
          SubMenuItemData(
            id: SubMenuItem.paymentApproval,
            label: 'Payment Approval',
            route: RouteConstants.paymentApproval,
          ),
          SubMenuItemData(
            id: SubMenuItem.landSurveyCalculator,
            label: 'Land Survey Calculator',
            route: RouteConstants.landSurveyCalculator,
          ),
          SubMenuItemData(
            id: SubMenuItem.servicesCalculator,
            label: 'Services Calculator',
            route: RouteConstants.servicesCalculator,
          ),
          SubMenuItemData(
            id: SubMenuItem.generateInvoice,
            label: 'Generate Invoice',
            route: RouteConstants.generateInvoice,
          ),
          SubMenuItemData(
            id: SubMenuItem.serviceLeads,
            label: 'Service Leads',
            route: RouteConstants.serviceLeads,
          ),
          SubMenuItemData(
            id: SubMenuItem.serviceInvoices,
            label: 'Service Invoices',
            route: RouteConstants.serviceInvoices,
          ),
        ],
      ),
      const MenuItem(
        id: MainMenuItem.workspace,
        label: 'Workspace',
        iconPath: 'assets/svg/sidebar/joined-square.svg',
        isExpandable: true,
        children: [
          SubMenuItemData(
            id: SubMenuItem.workspace,
            label: 'Overview',
            route: RouteConstants.workspace,
          ),
          SubMenuItemData(
            id: SubMenuItem.workspaceDashboard,
            label: 'Dashboard',
            route: RouteConstants.workspaceDashboard,
          ),
        ],
      ),
      const MenuItem(
        id: MainMenuItem.analytics,
        label: 'Analytics & Insights',
        iconPath: 'assets/svg/sidebar/joined-square.svg',
        isExpandable: true,
        children: [
          SubMenuItemData(
            id: SubMenuItem.overview,
            label: 'Overview',
            route: RouteConstants.analyticsOverview,
          ),
          SubMenuItemData(
            id: SubMenuItem.revenue,
            label: 'Revenue',
            route: RouteConstants.analyticsRevenue,
          ),
          SubMenuItemData(
            id: SubMenuItem.projects,
            label: 'Projects',
            route: RouteConstants.analyticsProjects,
          ),
          SubMenuItemData(
            id: SubMenuItem.analyticsPerformance,
            label: 'Performance',
            route: RouteConstants.analyticsPerformance,
          ),
          SubMenuItemData(
            id: SubMenuItem.branchPerformance,
            label: 'Branch Performance',
            route: RouteConstants.branchPerformanceAnalysis,
          ),
        ],
      ),
      const MenuItem(
        id: MainMenuItem.legalCompliance,
        label: 'Legal & Compliance',
        iconPath: 'assets/svg/sidebar/joined-square.svg',
        isExpandable: true,
        children: [
          SubMenuItemData(
            id: SubMenuItem.legalContracts,
            label: 'Contracts',
            route: RouteConstants.legalContracts,
          ),
          SubMenuItemData(
            id: SubMenuItem.legalCompliance,
            label: 'Compliance',
            route: RouteConstants.legalCompliance,
          ),
          SubMenuItemData(
            id: SubMenuItem.legalCases,
            label: 'Cases',
            route: RouteConstants.legalCases,
          ),
          SubMenuItemData(
            id: SubMenuItem.legalAudits,
            label: 'Audits',
            route: RouteConstants.legalAudits,
          ),
        ],
      ),
      const MenuItem(
        id: MainMenuItem.clientPortal,
        label: 'Client Portal',
        iconPath: 'assets/svg/sidebar/joined-square.svg',
        isExpandable: true,
        children: [
          SubMenuItemData(
            id: SubMenuItem.clientAccess,
            label: 'Client Access',
            route: RouteConstants.clientAccess,
          ),
          SubMenuItemData(
            id: SubMenuItem.documentSharing,
            label: 'Document Sharing',
            route: RouteConstants.documentSharing,
          ),
          SubMenuItemData(
            id: SubMenuItem.communications,
            label: 'Communications',
            route: RouteConstants.communications,
          ),
          SubMenuItemData(
            id: SubMenuItem.portalAnalytics,
            label: 'Portal Analytics',
            route: RouteConstants.portalAnalytics,
          ),
        ],
      ),
      const MenuItem(
        id: MainMenuItem.security,
        label: 'Security & Authorization',
        iconPath: 'assets/svg/sidebar/joined-square.svg',
        isExpandable: true,
        children: [
          SubMenuItemData(
            id: SubMenuItem.securityOverview,
            label: 'Overview',
            route: RouteConstants.securityOverview,
          ),
          SubMenuItemData(
            id: SubMenuItem.securityCodes,
            label: 'Security Codes',
            route: RouteConstants.securityCodes,
          ),
          SubMenuItemData(
            id: SubMenuItem.securityWorkflow,
            label: 'Workflows',
            route: RouteConstants.securityWorkflow,
          ),
          SubMenuItemData(
            id: SubMenuItem.securityAlerts,
            label: 'Security Alerts',
            route: RouteConstants.securityAlerts,
          ),
          SubMenuItemData(
            id: SubMenuItem.securityLogs,
            label: 'Audit Logs',
            route: RouteConstants.securityLogs,
          ),
        ],
      ),
      const MenuItem(
        id: MainMenuItem.crm,
        label: 'CRM',
        iconPath: 'assets/svg/sidebar/joined-square.svg',
        isExpandable: true,
        children: [
          SubMenuItemData(
            id: SubMenuItem.crmClients,
            label: 'Clients',
            route: RouteConstants.crmClients,
          ),
          SubMenuItemData(
            id: SubMenuItem.crmLeads,
            label: 'Leads',
            route: RouteConstants.crmLeads,
          ),
          SubMenuItemData(
            id: SubMenuItem.crmInteractions,
            label: 'Interactions',
            route: RouteConstants.crmInteractions,
          ),
          SubMenuItemData(
            id: SubMenuItem.crmAnalytics,
            label: 'Analytics',
            route: RouteConstants.crmAnalytics,
          ),
        ],
      ),
      const MenuItem(
        id: MainMenuItem.notification,
        label: 'Notification',
        iconPath: 'assets/svg/sidebar/papar.svg',
        isExpandable: false,
      ),
      const MenuItem(
        id: MainMenuItem.settings,
        label: 'Settings',
        iconPath: 'assets/svg/sidebar/settings.svg',
        isExpandable: false,
      ),
      const MenuItem(
        id: MainMenuItem.help,
        label: 'Help',
        iconPath: 'assets/svg/sidebar/help.svg',
        isExpandable: false,
      ),
      const MenuItem(
        id: MainMenuItem.logout,
        label: 'Logout',
        iconPath: 'assets/svg/sidebar/logout.svg',
        isExpandable: false,
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
      children: menuItem.children.map<Widget>((subMenuItem) {
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
      child: ListView(
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
      ),
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
