import 'dart:developer';

import 'package:bms_front_end/main.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/icons.dart';
import 'package:bms_front_end/src/constants/permissions.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:bms_front_end/src/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
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
  workspaceApprovals,
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

/// Section groupings for the sidebar. The key is the FIRST menu item of each
/// section; hitting that key during render emits a [_SectionHeader] above it.
/// The first entry renders without a top divider.
const Map<MainMenuItem, String> _sectionBreaks = {
  MainMenuItem.dashboard: 'Workspace',
  MainMenuItem.hr: 'People',
  MainMenuItem.work: 'Operations',
  MainMenuItem.marketingCrm: 'Revenue',
  MainMenuItem.analytics: 'Insights',
  MainMenuItem.legalCompliance: 'Compliance',
};

class SideMenu extends StatefulWidget {
  /// When true, the sidebar renders as a narrow icon-only rail with tooltips;
  /// labels, search, and section headers are hidden.
  final bool isCollapsed;

  /// Toggles between expanded and collapsed modes. Invoked from the in-sidebar
  /// toggle button (and from the \u2318K handler when the user triggers search
  /// on a collapsed rail — the rail expands first so the search field exists).
  final VoidCallback? onToggleCollapse;

  const SideMenu({
    super.key,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  MainMenuItem? selectedMainMenu;
  SubMenuItem? selectedSubMenu;

  /// Accordion state: the single expandable group that is currently open,
  /// or `null` when every group is collapsed. Search mode overrides this
  /// (all groups with matches open) via the build-time `isOpen` calc.
  MainMenuItem? _openMenu;
  late final List<MenuItem> menuItems;
  late final Map<String, MenuSelection> routeToMenuMapping;
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(debugLabel: 'sidebar-search');
  String _searchQuery = '';

  /// Pinned sub-items (e.g. "Employees", "Leave Requests"). Rendered as a
  /// "Pinned" section at the top of the expanded sidebar in addition to
  /// their natural position under the parent group.
  final Set<SubMenuItem> _pinnedSubs = <SubMenuItem>{};

  /// Pinned top-level items (e.g. "Events") — same idea, for non-expandable
  /// entries.
  final Set<MainMenuItem> _pinnedMains = <MainMenuItem>{};

  @override
  void initState() {
    super.initState();
    _initializeMenuItems();
    _initializeRouteMapping();
    _loadPinned();
    // Register a global shortcut so \u2318K / Ctrl+K focuses the sidebar
    // search from anywhere in the app (no matter which page or field is
    // focused). HardwareKeyboard fires before any widget-level handlers.
    HardwareKeyboard.instance.addHandler(_handleGlobalKey);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSelectionBasedOnCurrentRoute();
    });
  }

  void _loadPinned() {
    final subs = prefs.getStringList('sidebarPinnedSubs') ?? const <String>[];
    for (final s in subs) {
      final i = int.tryParse(s);
      if (i != null && i >= 0 && i < SubMenuItem.values.length) {
        _pinnedSubs.add(SubMenuItem.values[i]);
      }
    }
    final mains = prefs.getStringList('sidebarPinnedMains') ?? const <String>[];
    for (final s in mains) {
      final i = int.tryParse(s);
      if (i != null && i >= 0 && i < MainMenuItem.values.length) {
        _pinnedMains.add(MainMenuItem.values[i]);
      }
    }
  }

  Future<void> _savePinned() async {
    await prefs.setStringList(
      'sidebarPinnedSubs',
      _pinnedSubs.map((e) => e.index.toString()).toList(),
    );
    await prefs.setStringList(
      'sidebarPinnedMains',
      _pinnedMains.map((e) => e.index.toString()).toList(),
    );
  }

  void _togglePinSub(SubMenuItem id) {
    setState(() {
      if (_pinnedSubs.contains(id)) {
        _pinnedSubs.remove(id);
      } else {
        _pinnedSubs.add(id);
      }
    });
    _savePinned();
  }

  void _togglePinMain(MainMenuItem id) {
    setState(() {
      if (_pinnedMains.contains(id)) {
        _pinnedMains.remove(id);
      } else {
        _pinnedMains.add(id);
      }
    });
    _savePinned();
  }

  /// Show the pin/unpin context menu at [globalPos] for a row.
  Future<void> _showRowContextMenu({
    required Offset globalPos,
    required bool isPinned,
    required VoidCallback onToggle,
  }) async {
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;
    final position = RelativeRect.fromLTRB(
      globalPos.dx,
      globalPos.dy,
      overlay.size.width - globalPos.dx,
      overlay.size.height - globalPos.dy,
    );
    final result = await showMenu<String>(
      context: context,
      position: position,
      items: [
        PopupMenuItem<String>(
          value: 'toggle',
          height: 36,
          child: Row(
            children: [
              Icon(
                isPinned ? Iconsax.bookmark_2 : Iconsax.bookmark,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
              Text(isPinned ? 'Unpin from top' : 'Pin to top'),
            ],
          ),
        ),
      ],
    );
    if (result == 'toggle') onToggle();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleGlobalKey);
    _searchCtrl.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// Global key filter. Catches \u2318K on macOS, Ctrl+K on Windows/Linux/web
  /// and focuses the sidebar search. Returns `true` to consume the event so
  /// the browser's default "open location" binding doesn't fire.
  bool _handleGlobalKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final isK = event.logicalKey == LogicalKeyboardKey.keyK;
    final hasMod = HardwareKeyboard.instance.isMetaPressed ||
        HardwareKeyboard.instance.isControlPressed;
    if (isK && hasMod) {
      // If the rail is collapsed, expand it first so the search field has
      // somewhere to render. Defer focus until the expansion animation has
      // laid out the new widget.
      if (widget.isCollapsed && widget.onToggleCollapse != null) {
        widget.onToggleCollapse!();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchFocusNode.requestFocus();
          _searchCtrl.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _searchCtrl.text.length,
          );
        });
      } else {
        _searchFocusNode.requestFocus();
        _searchCtrl.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _searchCtrl.text.length,
        );
      }
      return true;
    }
    return false;
  }

  /// Applies [_searchQuery] to the given menu item. Returns null when the
  /// item (and none of its children) match; otherwise returns a menu item
  /// whose children are filtered down to the matches.
  MenuItem? _filterForSearch(MenuItem item) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return item;

    final labelHit = item.label.toLowerCase().contains(q);
    if (!item.isExpandable) {
      return labelHit ? item : null;
    }

    // If the parent label matches, show all children.
    if (labelHit) return item;

    final matchingChildren =
        item.children.where((c) => c.label.toLowerCase().contains(q)).toList();
    if (matchingChildren.isEmpty) return null;

    return MenuItem(
      id: item.id,
      label: item.label,
      icon: item.icon,
      route: item.route,
      resources: item.resources,
      isExpandable: item.isExpandable,
      children: matchingChildren,
    );
  }

  void _initializeMenuItems() {
    menuItems = [
      const MenuItem(
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
            label: 'My Profile',
            route: RouteConstants.employeeMyProfile,
            resources: [PermissionConstants.resEmployees],
          ),
          SubMenuItemData(
            id: SubMenuItem.myTasks,
            icon: Iconsax.task_square,
            label: 'My Tasks',
            route: RouteConstants.employeeMyTasks,
            resources: [PermissionConstants.resTasks],
          ),
          SubMenuItemData(
            id: SubMenuItem.myReports,
            icon: Iconsax.document_text,
            label: 'My Work Reports',
            route: RouteConstants.employeeMyReports,
            resources: [PermissionConstants.resWorkReports],
          ),
        ],
      ),
      const MenuItem(
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
      const MenuItem(
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
        ],
      ),
      const MenuItem(
        id: MainMenuItem.work,
        label: 'Operations',
        icon: AppIcons.operations,
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
      const MenuItem(
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
          SubMenuItemData(
            id: SubMenuItem.servicesDashboard,
            icon: Iconsax.element_4,
            label: 'Dashboard',
            route: RouteConstants.services,
            resources: [PermissionConstants.resServices],
          ),
          SubMenuItemData(
            id: SubMenuItem.serviceClients,
            icon: Iconsax.user_octagon,
            label: 'Clients',
            route: RouteConstants.serviceClients,
            resources: [PermissionConstants.resClients],
          ),
          SubMenuItemData(
            id: SubMenuItem.propertyManagement,
            icon: Iconsax.building_4,
            label: 'Property Management',
            route: RouteConstants.propertyList,
            resources: [PermissionConstants.resProperties],
          ),
          SubMenuItemData(
            id: SubMenuItem.estateManagement,
            icon: Iconsax.buildings,
            label: 'Estate Management',
            route: RouteConstants.estateManagement,
            resources: [PermissionConstants.resEstates],
          ),
        ],
      ),
      const MenuItem(
        id: MainMenuItem.events,
        label: 'Events',
        icon: AppIcons.events,
        route: RouteConstants.events,
        isExpandable: false,
        resources: [PermissionConstants.resEvents],
      ),
      const MenuItem(
        id: MainMenuItem.marketingCrm,
        label: 'Marketing & CRM',
        icon: AppIcons.marketingCrm,
        isExpandable: true,
        resources: [
          PermissionConstants.resClients,
          PermissionConstants.resLeads,
          PermissionConstants.resMarketingCampaigns,
        ],
        children: [
          SubMenuItemData(
            id: SubMenuItem.marketingCrmDashboard,
            icon: Iconsax.element_4,
            label: 'Dashboard',
            route: RouteConstants.marketingCrm,
            resources: [
              PermissionConstants.resClients,
              PermissionConstants.resLeads,
              PermissionConstants.resMarketingCampaigns,
            ],
          ),
          SubMenuItemData(
            id: SubMenuItem.crmClients,
            icon: Iconsax.user_octagon,
            label: 'Clients',
            route: RouteConstants.crmClients,
            resources: [PermissionConstants.resClients],
          ),
          SubMenuItemData(
            id: SubMenuItem.crmLeads,
            icon: Iconsax.flash_1,
            label: 'Leads',
            route: RouteConstants.crmLeads,
            resources: [PermissionConstants.resLeads],
          ),
          SubMenuItemData(
            id: SubMenuItem.crmInteractions,
            icon: Iconsax.messages_2,
            label: 'Interactions',
            route: RouteConstants.crmInteractions,
            resources: [
              PermissionConstants.resClients,
              PermissionConstants.resLeads,
            ],
          ),
          SubMenuItemData(
            id: SubMenuItem.marketing,
            icon: Iconsax.lamp_charge,
            label: 'Marketing',
            route: RouteConstants.marketing,
            resources: [PermissionConstants.resMarketingCampaigns],
          ),
          SubMenuItemData(
            id: SubMenuItem.crmAnalytics,
            icon: Iconsax.chart_square,
            label: 'Analytics',
            route: RouteConstants.crmAnalytics,
            resources: [
              PermissionConstants.resStats,
              PermissionConstants.resClients,
            ],
          ),
        ],
      ),
      const MenuItem(
        id: MainMenuItem.financeAccounting,
        label: 'Finance & Accounting',
        icon: AppIcons.finance,
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
            icon: Iconsax.element_4,
            label: 'Dashboard',
            route: RouteConstants.finance,
            resources: [
              PermissionConstants.resStats,
              PermissionConstants.resBudgets,
            ],
          ),
          SubMenuItemData(
            id: SubMenuItem.invoice,
            icon: Iconsax.receipt_2_1,
            label: 'Invoice',
            route: RouteConstants.invoice,
            resources: [
              PermissionConstants.resEstateInvoices,
              PermissionConstants.resServiceInvoices,
            ],
          ),
          SubMenuItemData(
            id: SubMenuItem.payments,
            icon: Iconsax.money_send,
            label: 'Payments',
            route: RouteConstants.payment,
            resources: [PermissionConstants.resPayments],
          ),
          SubMenuItemData(
            id: SubMenuItem.expenses,
            icon: Iconsax.money_remove,
            label: 'Expenses',
            route: RouteConstants.expense,
            resources: [PermissionConstants.resExpenses],
          ),
          SubMenuItemData(
            id: SubMenuItem.budget,
            icon: Iconsax.wallet_2,
            label: 'Budget',
            route: RouteConstants.budget,
            resources: [PermissionConstants.resBudgets],
          ),
          // Vendor/Contributor — hidden (no dedicated vendor-payments API yet)
        ],
      ),
      // Workspace — temporarily hidden (uses dummy data, no API connection yet)
      // const MenuItem(
      //   id: MainMenuItem.workspace,
      //   label: 'Workspace',
      //   icon: AppIcons.workspace,
      //   isExpandable: true,
      //   resources: [
      //     PermissionConstants.resDocuments,
      //     PermissionConstants.resContent,
      //   ],
      //   children: [
      //     SubMenuItemData(
      //       id: SubMenuItem.workspace,
      //       label: 'Overview',
      //       route: RouteConstants.workspace,
      //       resources: [
      //         PermissionConstants.resDocuments,
      //         PermissionConstants.resContent,
      //       ],
      //     ),
      //     SubMenuItemData(
      //       id: SubMenuItem.workspaceDashboard,
      //       label: 'Dashboard',
      //       route: RouteConstants.workspaceDashboard,
      //       resources: [
      //         PermissionConstants.resDocuments,
      //         PermissionConstants.resContent,
      //       ],
      //     ),
      //   ],
      // ),
      const MenuItem(
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
          // Revenue, Projects, Performance — hidden (dummy data, no dedicated API endpoints)
        ],
      ),
      const MenuItem(
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
      const MenuItem(
        id: MainMenuItem.clientPortal,
        label: 'Client Portal',
        icon: AppIcons.clientsPortal,
        isExpandable: true,
        resources: [
          PermissionConstants.resClients,
          PermissionConstants.resDocuments,
        ],
        children: [
          SubMenuItemData(
            id: SubMenuItem.clientAccess,
            icon: Iconsax.key,
            label: 'Client Access',
            route: RouteConstants.clientAccess,
            resources: [PermissionConstants.resClients],
          ),
          SubMenuItemData(
            id: SubMenuItem.documentSharing,
            icon: Iconsax.document_upload,
            label: 'Document Sharing',
            route: RouteConstants.documentSharing,
            resources: [PermissionConstants.resDocuments],
          ),
          SubMenuItemData(
            id: SubMenuItem.communications,
            icon: Iconsax.messages_2,
            label: 'Communications',
            route: RouteConstants.communications,
            resources: [PermissionConstants.resClients],
          ),
          SubMenuItemData(
            id: SubMenuItem.portalAnalytics,
            icon: Iconsax.chart_square,
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
      //   icon: AppIcons.security,
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
        // Auto-open the group whose child owns the active route, so a deep
        // link or back/forward navigation lands with the right tab expanded.
        if (selection.subMenuItem != null) {
          _openMenu = selection.mainMenuItem;
        }
      });
      _saveMenuState(selection.mainMenuItem, selection.subMenuItem);
      _saveOpenMenu(_openMenu);
      log('Menu selection updated based on route: main=$selectedMainMenu, sub=$selectedSubMenu');
    } else {
      // If route is not found in mapping, load from preferences as fallback
      _loadMenuState();
    }
  }

  void _loadMenuState() {
    final mainMenuIndex = prefs.getInt('selectedMenu');
    final subMenuIndex = prefs.getInt('selectedSubMenu');
    final openMenuIndex = prefs.getInt('sidebarOpenMenu');

    setState(() {
      selectedMainMenu = mainMenuIndex != null
          ? MainMenuItem.values[mainMenuIndex]
          : MainMenuItem.dashboard;
      selectedSubMenu = subMenuIndex != null && subMenuIndex >= 0
          ? SubMenuItem.values[subMenuIndex]
          : null;
      // Restore accordion state: prefer the saved open group; fall back to
      // the parent of the selected sub-item so a first-time user with no
      // saved pref still lands with the right group expanded.
      if (openMenuIndex != null && openMenuIndex >= 0) {
        _openMenu = MainMenuItem.values[openMenuIndex];
      } else if (selectedSubMenu != null) {
        _openMenu = selectedMainMenu;
      }
    });
    log('Menu state loaded from preferences: main=$selectedMainMenu, sub=$selectedSubMenu, open=$_openMenu');
  }

  Future<void> _saveMenuState(
      MainMenuItem mainMenu, SubMenuItem? subMenu) async {
    await prefs.setInt('selectedMenu', mainMenu.index);
    await prefs.setInt('selectedSubMenu', subMenu?.index ?? -1);
    log('Menu state saved to preferences: main=$mainMenu, sub=$subMenu');
  }

  /// Persist the currently-open accordion group (or `null` if everything is
  /// collapsed) so the sidebar reopens with the same group after a restart.
  Future<void> _saveOpenMenu(MainMenuItem? openMenu) async {
    await prefs.setInt('sidebarOpenMenu', openMenu?.index ?? -1);
  }

  void _navigate(
      String? route, MainMenuItem mainMenuItem, SubMenuItem? subMenuItem) {
    if (route != null) {
      context.go(route);
    }

    setState(() {
      selectedMainMenu = mainMenuItem;
      selectedSubMenu = subMenuItem;
      // Tapping a child implies its parent group should stay open (matters
      // when the tap originated from search mode, where _openMenu may still
      // be pointing at a different group).
      if (subMenuItem != null) {
        _openMenu = mainMenuItem;
        _saveOpenMenu(_openMenu);
      }
    });

    _saveMenuState(mainMenuItem, subMenuItem);

    if (!isLargeScreen(context)) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildMenuItem(MenuItem menuItem) {
    final permissionService = Get.find<PermissionService>();

    // Super admin / CEO sees the company dashboard instead of the employee
    // dashboard. Hide the employee Dashboard menu for them.
    if (menuItem.id == MainMenuItem.dashboard &&
        (permissionService.isSuperAdmin ||
            permissionService.hasAnyPermissionForResource(
                PermissionConstants.resCompanySettings))) {
      return const SizedBox.shrink();
    }

    // Filter sub-items via typed route permissions.
    final authorizedSubItems = menuItem.children
        .where((subItem) =>
            permissionService.canAccessRoute(subItem.route, subItem.resources))
        .toList();

    if (menuItem.isExpandable && authorizedSubItems.isEmpty) {
      return const SizedBox.shrink();
    }
    if (!menuItem.isExpandable &&
        !permissionService.canAccessResources(menuItem.resources)) {
      return const SizedBox.shrink();
    }

    final bool isSelected = selectedMainMenu == menuItem.id;

    if (!menuItem.isExpandable) {
      final bool isPinned = _pinnedMains.contains(menuItem.id);
      return _MenuRow(
        icon: menuItem.icon,
        label: menuItem.label,
        isSelected: isSelected,
        isPinned: isPinned,
        onTap: () => _navigate(menuItem.route, menuItem.id, null),
        onContextMenu: (pos) => _showRowContextMenu(
          globalPos: pos,
          isPinned: isPinned,
          onToggle: () => _togglePinMain(menuItem.id),
        ),
      );
    }

    // Search mode overrides accordion: every group with matches stays open
    // so the user can see all hits at once. When search is cleared, the
    // normal single-open accordion rule resumes.
    final bool isOpen =
        _searchQuery.trim().isNotEmpty ? true : _openMenu == menuItem.id;

    return _ExpandableMenuRow(
      key: ValueKey('expandable-${menuItem.id.name}'),
      icon: menuItem.icon,
      label: menuItem.label,
      isSelected: isSelected,
      isOpen: isOpen,
      onHeaderTap: () {
        setState(() {
          selectedMainMenu = menuItem.id;
          // Accordion: tapping the already-open group collapses it,
          // tapping any other group opens it and closes the previous one.
          _openMenu = _openMenu == menuItem.id ? null : menuItem.id;
        });
        _saveMenuState(menuItem.id, selectedSubMenu);
        _saveOpenMenu(_openMenu);
      },
      onExpand: () {
        if (!isOpen) {
          setState(() => _openMenu = menuItem.id);
          _saveOpenMenu(_openMenu);
        } else {
          // If already open, Right arrow moves focus to the first child.
          FocusScope.of(context).nextFocus();
        }
      },
      onCollapse: () {
        if (isOpen) {
          setState(() => _openMenu = null);
          _saveOpenMenu(_openMenu);
        }
      },
      children: authorizedSubItems
          .map<Widget>((subItem) => _buildSubItem(subItem, menuItem.id))
          .toList(),
    );
  }

  /// Render a pinned non-expandable top-level item in the Pinned section.
  /// Always full-size (not the sub-item treatment) and marks itself selected
  /// when its route is active.
  Widget _buildPinnedMainRow(MenuItem menuItem) {
    final isSelected = selectedMainMenu == menuItem.id;
    return _MenuRow(
      key: ValueKey('pinned-main-${menuItem.id.name}'),
      icon: menuItem.icon,
      label: menuItem.label,
      isSelected: isSelected,
      isPinned: true,
      onTap: () => _navigate(menuItem.route, menuItem.id, null),
      onContextMenu: (pos) => _showRowContextMenu(
        globalPos: pos,
        isPinned: true,
        onToggle: () => _togglePinMain(menuItem.id),
      ),
    );
  }

  /// Render a pinned sub-item in the Pinned section. Uses the top-level
  /// visual weight (not `isSub: true`) because the pin appears in its own
  /// section, not nested under a parent group.
  Widget _buildPinnedSubRow(SubMenuItemData sub, MainMenuItem parentId) {
    final isSelected = selectedSubMenu == sub.id;
    return _MenuRow(
      key: ValueKey('pinned-sub-${sub.id.name}'),
      icon: sub.icon,
      label: sub.label,
      isSelected: isSelected,
      isPinned: true,
      onTap: () => _navigate(sub.route, parentId, sub.id),
      onContextMenu: (pos) => _showRowContextMenu(
        globalPos: pos,
        isPinned: true,
        onToggle: () => _togglePinSub(sub.id),
      ),
    );
  }

  Widget _buildSubItem(
      SubMenuItemData subMenuItem, MainMenuItem parentMenuItem) {
    final isSelected = selectedSubMenu == subMenuItem.id;
    final bool isPinned = _pinnedSubs.contains(subMenuItem.id);
    return _MenuRow(
      icon: subMenuItem.icon,
      label: subMenuItem.label,
      isSelected: isSelected,
      isSub: true,
      isPinned: isPinned,
      onTap: () => _navigate(subMenuItem.route, parentMenuItem, subMenuItem.id),
      onContextMenu: (pos) => _showRowContextMenu(
        globalPos: pos,
        isPinned: isPinned,
        onToggle: () => _togglePinSub(subMenuItem.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceMuted,
      // Expanded mode: right padding only, so selected-row accent bars sit
      // flush with the left edge. Collapsed mode: horizontal padding hugs the
      // centered rail buttons.
      padding: widget.isCollapsed
          ? const EdgeInsets.symmetric(horizontal: 8)
          : const EdgeInsets.only(right: 8),
      height: MediaQuery.sizeOf(context).height,
      child: Obx(() {
        // Subscribe to permission changes so the menu rebuilds on role changes.
        // ignore: unused_local_variable
        final _ = Get.find<PermissionService>().version;

        final filtered =
            menuItems.map(_filterForSearch).whereType<MenuItem>().toList();

        return widget.isCollapsed
            ? _buildCollapsedRail(filtered)
            : _buildExpandedSidebar(filtered);
      }),
    );
  }

  Widget _buildExpandedSidebar(List<MenuItem> filtered) {
    final rows = <Widget>[];

    // ── Pinned section ──
    // Skip the pinned section during search so matches only appear once.
    // Build it from `menuItems` (not `filtered`) so pinned rows remain
    // visible when the user has typed a search that happens not to match
    // the pinned label.
    final bool pinnedSectionVisible = _searchQuery.trim().isEmpty &&
        (_pinnedSubs.isNotEmpty || _pinnedMains.isNotEmpty);
    if (pinnedSectionVisible) {
      rows.add(const _SectionHeader(label: 'Pinned', showDivider: false));
      for (final menuItem in menuItems) {
        if (_pinnedMains.contains(menuItem.id) && !menuItem.isExpandable) {
          rows.add(_buildPinnedMainRow(menuItem));
        }
        if (menuItem.isExpandable) {
          for (final sub in menuItem.children) {
            if (_pinnedSubs.contains(sub.id)) {
              rows.add(_buildPinnedSubRow(sub, menuItem.id));
            }
          }
        }
      }
    }

    // ── Regular sections ──
    bool firstSectionSeen = pinnedSectionVisible;
    for (final menuItem in filtered) {
      if (_sectionBreaks.containsKey(menuItem.id)) {
        rows.add(_SectionHeader(
          label: _sectionBreaks[menuItem.id]!,
          showDivider: firstSectionSeen,
        ));
        firstSectionSeen = true;
      }
      rows.add(_buildMenuItem(menuItem));
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        kSizedBoxBG,
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
          child: Row(
            children: [
              const Text('BOMACH', style: AppText.h2),
              const Text('OS', style: AppText.displayLg),
              const Spacer(),
              if (widget.onToggleCollapse != null)
                Tooltip(
                  message: 'Collapse sidebar',
                  child: IconButton(
                    icon: const Icon(Iconsax.sidebar_left,
                        size: 18, color: AppColors.textSecondary),
                    onPressed: widget.onToggleCollapse,
                    splashRadius: 18,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SidebarSearchField(
            controller: _searchCtrl,
            focusNode: _searchFocusNode,
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        const SizedBox(height: 8),
        ...rows,
        if (filtered.isEmpty && _searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'No menu items match "$_searchQuery"',
              style: AppText.bodyMd,
              textAlign: TextAlign.center,
            ),
          ),
        kSizedBox,
      ],
    );
  }

  Widget _buildCollapsedRail(List<MenuItem> filtered) {
    final permissionService = Get.find<PermissionService>();

    final rail = <Widget>[];
    for (final menuItem in filtered) {
      // Apply the same permission filters as the expanded build so the rail
      // only shows icons the user can actually access.
      if (menuItem.id == MainMenuItem.dashboard &&
          (permissionService.isSuperAdmin ||
              permissionService.hasAnyPermissionForResource(
                  PermissionConstants.resCompanySettings))) {
        continue;
      }
      if (menuItem.isExpandable) {
        final authorizedSubItems = menuItem.children
            .where(
                (s) => permissionService.canAccessRoute(s.route, s.resources))
            .toList();
        if (authorizedSubItems.isEmpty) continue;
      } else if (!permissionService.canAccessResources(menuItem.resources)) {
        continue;
      }

      final isSelected = selectedMainMenu == menuItem.id;
      rail.add(_CollapsedMenuButton(
        icon: menuItem.icon,
        label: menuItem.label,
        isSelected: isSelected,
        onTap: () {
          if (menuItem.isExpandable) {
            // Opening a group on the rail: mark it open and expand the rail
            // so the user can see the children that just unfurled.
            setState(() {
              selectedMainMenu = menuItem.id;
              _openMenu = menuItem.id;
            });
            _saveMenuState(menuItem.id, selectedSubMenu);
            _saveOpenMenu(_openMenu);
            widget.onToggleCollapse?.call();
          } else {
            _navigate(menuItem.route, menuItem.id, null);
          }
        },
      ));
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        kSizedBoxBG,
        // Logo tile — small square with a brand mark. Tapping navigates home
        // via the first dashboard-eligible rail button if present.
        Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Text(
              'B',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (widget.onToggleCollapse != null)
          Center(
            child: Tooltip(
              message: 'Expand sidebar  (\u2318K / Ctrl+K)',
              child: IconButton(
                icon: const Icon(Iconsax.sidebar_right,
                    size: 18, color: AppColors.textSecondary),
                onPressed: widget.onToggleCollapse,
                splashRadius: 18,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ),
          ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Divider(
            height: 1,
            thickness: 1,
            color: AppColors.borderSubtle,
          ),
        ),
        const SizedBox(height: 8),
        ...rail,
        kSizedBox,
      ],
    );
  }
}

class _SidebarSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _SidebarSearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Show the platform-appropriate shortcut hint so users discover \u2318K / Ctrl+K.
    final bool isMac = Theme.of(context).platform == TargetPlatform.macOS;
    final String shortcutHint = isMac ? '\u2318K' : 'Ctrl K';

    return CallbackShortcuts(
      // Handle Escape *only* while the search field owns focus. If there's
      // text, clear it; otherwise unfocus so Escape does the expected thing
      // for an empty search field too.
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (controller.text.isNotEmpty) {
            controller.clear();
            onChanged('');
          } else {
            focusNode.unfocus();
          }
        },
      },
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search menu...',
          hintStyle: const TextStyle(
            fontSize: 13,
            color: AppColors.neutral500,
          ),
          prefixIcon: const Icon(Iconsax.search_normal,
              size: 18, color: AppColors.neutral500),
          suffixIcon: controller.text.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Center(
                    widthFactor: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        border: Border.all(color: AppColors.borderSubtle),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        shortcutHint,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Iconsax.close_circle, size: 16),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.borderSubtle),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.borderSubtle),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Sidebar row widgets — Pass 1 visual redesign
//
// One canonical row (`_MenuRow`) drives both top-level and sub-level items.
// Selected state = [primarySubtle] fill + [primary] accent bar flush-left +
// [primary]-colored icon/label. Hover state = [neutral200] fill. Transparent
// when neither — so the row sits quietly against the [surfaceMuted] sidebar
// background.
// ─────────────────────────────────────────────────────────────────────────────

/// A single interactive row in the sidebar. Handles hover + selected states
/// with a flush-left accent bar and rounded-right fill.
class _MenuRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isSub;
  final VoidCallback onTap;
  final Widget? trailing;

  /// Whether this row represents a currently-pinned item. Pinned rows get a
  /// small bookmark indicator in the trailing area (when no custom trailing
  /// is supplied).
  final bool isPinned;

  /// Right-click / long-press callback. Receives the global tap position so
  /// the caller can open a context menu anchored to the cursor.
  final ValueChanged<Offset>? onContextMenu;
  final VoidCallback? onExpand;
  final VoidCallback? onCollapse;

  const _MenuRow({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isSub = false,
    this.trailing,
    this.isPinned = false,
    this.onContextMenu,
    this.onExpand,
    this.onCollapse,
  });

  @override
  State<_MenuRow> createState() => _MenuRowState();
}

class _MenuRowState extends State<_MenuRow> {
  bool _hover = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final bool selected = widget.isSelected;

    final Color bg = selected
        ? AppColors.primarySoft
        : (_hover || _focused ? AppColors.neutral200 : Colors.transparent);

    final Color accent = selected ? AppColors.primary : Colors.transparent;

    // Focus ring color. Always 1 px wide (even when transparent) so the row
    // height never jitters as focus moves between rows.
    // If selected, we use a slightly different color or just keep the ring.
    final Color ringColor = _focused ? AppColors.primary : Colors.transparent;

    final Color iconColor = selected
        ? AppColors.primary
        : (widget.isSub ? AppColors.textSecondary : AppColors.textPrimary);

    final Color labelColor = selected
        ? AppColors.primary
        : (widget.isSub ? AppColors.textSecondary : AppColors.textPrimary);

    final double iconSize = widget.isSub ? 16 : 20;
    final double height = widget.isSub ? 36 : 40;
    final double accentWidth = widget.isSub ? 2 : 3;
    // Sub-rows indent further so the hierarchy reads at a glance.
    final double leadingPad = widget.isSub ? 28 : 12;

    // Trailing widget: caller-supplied trailing takes precedence (used by
    // expandable rows for the chevron). Otherwise, pinned rows get a quiet
    // bookmark glyph so pinned state is visible at a glance.
    final Widget? trailing = widget.trailing ??
        (widget.isPinned
            ? const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Iconsax.bookmark_2,
                  size: 12,
                  color: AppColors.neutral400,
                ),
              )
            : null);

    return Focus(
      onFocusChange: (v) => setState(() => _focused = v),
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;

        // Enter / Space → activate the row, matching tap behaviour.
        if (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.space) {
          widget.onTap();
          return KeyEventResult.handled;
        }

        // Right Arrow → Expand if a callback is provided.
        if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          if (widget.onExpand != null) {
            widget.onExpand!();
            return KeyEventResult.handled;
          }
        }

        // Left Arrow → Collapse if a callback is provided.
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          if (widget.onCollapse != null) {
            widget.onCollapse!();
            return KeyEventResult.handled;
          }
        }

        return KeyEventResult.ignored;
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          // Right-click (desktop / web) and long-press (touch) both surface
          // the same context menu — the caller receives the global position
          // so the menu can anchor to the cursor.
          onSecondaryTapDown: widget.onContextMenu == null
              ? null
              : (d) => widget.onContextMenu!(d.globalPosition),
          onLongPressStart: widget.onContextMenu == null
              ? null
              : (d) => widget.onContextMenu!(d.globalPosition),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            height: height,
            margin: const EdgeInsets.symmetric(vertical: 1),
            padding: EdgeInsets.only(left: leadingPad, right: 12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(8),
              ),
              border: Border(
                left: BorderSide(width: accentWidth, color: accent),
                // Focus ring on the other three sides. Transparent when
                // unfocused so the row height stays constant.
                top: BorderSide(width: 1, color: ringColor),
                right: BorderSide(width: 1, color: ringColor),
                bottom: BorderSide(width: 1, color: ringColor),
              ),
            ),
            child: Row(
              children: [
                Icon(widget.icon, size: iconSize, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: widget.isSub ? 13 : 14,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: labelColor,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A two-level menu group: a [_MenuRow] header with a rotating chevron, plus
/// an [AnimatedCrossFade]-toggled column of child rows.
///
/// Fully controlled — [isOpen] comes from the parent so the sidebar can
/// enforce a single-open accordion across all groups.
class _ExpandableMenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isOpen;
  final VoidCallback onHeaderTap;
  final List<Widget> children;
  final VoidCallback? onExpand;
  final VoidCallback? onCollapse;

  const _ExpandableMenuRow({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isOpen,
    required this.onHeaderTap,
    required this.children,
    this.onExpand,
    this.onCollapse,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MenuRow(
          icon: icon,
          label: label,
          isSelected: isSelected,
          onTap: onHeaderTap,
          onExpand: onExpand,
          onCollapse: onCollapse,
          trailing: AnimatedRotation(
            turns: isOpen ? 0.5 : 0.0,
            duration: const Duration(milliseconds: 180),
            child: Icon(
              Iconsax.arrow_down_1,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 180),
          crossFadeState:
              isOpen ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
          secondChild: const SizedBox(width: double.infinity, height: 0),
        ),
      ],
    );
  }
}

/// Quiet section label between sidebar groups. Renders an optional top
/// divider, then an uppercase caption in [neutral500].
class _SectionHeader extends StatelessWidget {
  final String label;
  final bool showDivider;

  const _SectionHeader({
    required this.label,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDivider)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColors.borderSubtle,
            ),
          )
        else
          const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: AppColors.neutral500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Icon-only button rendered in the collapsed rail. Shows a tooltip with the
/// row's label on hover and handles selection / hover fills consistent with
/// the expanded [_MenuRow] treatment.
class _CollapsedMenuButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CollapsedMenuButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CollapsedMenuButton> createState() => _CollapsedMenuButtonState();
}

class _CollapsedMenuButtonState extends State<_CollapsedMenuButton> {
  bool _hover = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final bool selected = widget.isSelected;

    // Focus ring colour. Always 1 px wide (even when transparent) so the button
    // doesn't jitter during focus changes.
    final Color ringColor = _focused ? AppColors.primary : Colors.transparent;

    final Color bg = selected
        ? AppColors.primarySoft
        : (_hover || _focused ? AppColors.neutral200 : Colors.transparent);

    final Color iconColor =
        selected ? AppColors.primary : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Center(
        child: Tooltip(
          message: widget.label,
          waitDuration: const Duration(milliseconds: 400),
          preferBelow: false,
          child: Focus(
            onFocusChange: (v) => setState(() => _focused = v),
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent &&
                  (event.logicalKey == LogicalKeyboardKey.enter ||
                      event.logicalKey == LogicalKeyboardKey.space)) {
                widget.onTap();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _hover = true),
              onExit: (_) => setState(() => _hover = false),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1,
                      color: selected || _focused
                          ? AppColors.primary
                          : Colors.transparent,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(widget.icon, size: 20, color: iconColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
