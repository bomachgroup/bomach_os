import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../app_routes/app_route_constants.dart';
import '../app_routes/menu_structure.dart';
import '../constants/permissions.dart';
import '../model/role_model.dart';

/// Central permission checker. Backed by a reactive map so UI widgets can
/// `Obx(() => ...)` and update when permissions load/refresh.
///
/// Permissions are stored as `resource → Set<action>`. Wildcards:
///
///   - `{'*': {'*'}}` or `{'*': {'all'}}` → full admin access.
///   - A specific resource can also have wildcard actions, e.g.
///     `{'employees': {'*'}}` grants every action on employees.
class PermissionService extends GetxService {
  static const Set<String> _disabledMarketingRoutes = {
    '/marketing/funnel-audit',
    '/marketing/compliance',
    '/marketing/retention',
    '/marketing/whatsapp',
    '/marketing/design',
    '/marketing/role-governance',
    '/marketing/audit-log',
  };

  final RxMap<String, Set<String>> _userPermissions =
      <String, Set<String>>{}.obs;

  bool _isSuperAdmin = false;

  /// Monotonically increasing counter bumped on every load/clear. UI widgets
  /// that read this inside an `Obx` automatically rebuild when permissions
  /// change (granted, revoked, super-admin toggled, etc).
  final RxInt _version = 0.obs;

  /// True when the user has the global wildcard (all resources, all actions).
  bool get isSuperAdmin => _isSuperAdmin;

  /// Read inside `Obx(() => ...)` to subscribe to permission changes.
  int get version => _version.value;

  void _bump() => _version.value++;

  // ── Loading ────────────────────────────────────────────────────────────

  /// Load permissions from one or more backend-provided roles.
  void loadPermissions(List<Role> roles) {
    final newPermissions = <String, Set<String>>{};
    for (var role in roles) {
      role.permissions.forEach((resource, actions) {
        newPermissions.putIfAbsent(resource, () => <String>{});
        newPermissions[resource]!.addAll(actions);
      });
    }
    _userPermissions
      ..clear()
      ..addAll(newPermissions)
      ..refresh();
    _isSuperAdmin = _detectSuperAdmin(roles);
    _bump();
  }

  /// Grant full access — used for platform super admins (user_id == 1 today;
  /// later the backend will flag this explicitly). All `has()` checks return
  /// true regardless of resource/action.
  void loadSuperAdminPermissions() {
    _userPermissions
      ..clear()
      ..addAll({
        '*': {'*'}
      })
      ..refresh();
    _isSuperAdmin = true;
    _bump();
  }

  /// Minimal self-service permissions for users who haven't been assigned
  /// a role yet. Called when `/roles/employees/{id}` returns 403/404.
  void loadDefaultPermissions() {
    if (_userPermissions.isNotEmpty) return;
    _userPermissions
      ..clear()
      ..addAll({
        for (final e in defaultEmployeePermissions.entries)
          e.key: Set<String>.from(e.value),
      })
      ..refresh();
    _isSuperAdmin = false;
    _bump();
  }

  /// Baseline permission set every employee should have regardless of role.
  /// Covers viewing/updating one's own record, submitting self-service
  /// requests (leave, expenses, loans, work reports), and read access to
  /// company-wide broadcast content (dashboard, announcements, policies,
  /// events, meetings).
  ///
  /// Role creation pre-ticks these; admins can still untick or extend.
  static const Map<String, Set<String>> defaultEmployeePermissions = {
    // Self
    'employees': {'view_own', 'update_own'},
    'roles': {'view_own'},
    'wallet': {'view_own'},

    // Self-service submissions
    'work_reports': {'create', 'view_own', 'list_own', 'update_own'},
    'leave_requests': {
      'create',
      'view_own',
      'list_own',
      'update_own',
      'delete_own',
    },
    'loans': {'create', 'list_own'},
    'expenses': {'create', 'list_own', 'update_own'},
    'approval_requests': {'list_own'},
    'work_locations': {'list_own'},

    // Own records (read-only)
    'tasks': {'view_own', 'list_own', 'update_own'},
    'payroll': {'list_own'},
    'monthly_scorecards': {'list_own'},
    'employee_evaluations': {'list_own'},
    'performance_reviews': {'list_own'},
    'awards': {'list_own'},
    'disciplinary_cases': {'list_own'},
    'assets': {'list_own'},
    'estate_invoices': {'list_own'},

    // Company-wide read
    'dashboard': {'view'},
    'announcements': {'list'},
    'meetings': {'list'},
    'events': {'list'},
    'policies': {'list'},
  };

  void clearPermissions() {
    _userPermissions.clear();
    _isSuperAdmin = false;
    _bump();
  }

  /// Test-only seam: inject a permission map directly, bypassing role
  /// parsing. Used by widget/permission tests to simulate role shapes.
  @visibleForTesting
  void testInjectPermissions(Map<String, Set<String>> permissions) {
    _userPermissions
      ..clear()
      ..addAll(permissions.map((k, v) => MapEntry(k, Set<String>.from(v))))
      ..refresh();
    _isSuperAdmin = _detectSuperAdmin();
    _bump();
  }

  bool _detectSuperAdmin([List<Role>? roles]) {
    final wildcard = _userPermissions['*'] ?? _userPermissions['all'];
    if (wildcard != null &&
        (wildcard.contains('*') || wildcard.contains('all'))) {
      return true;
    }
    if (roles != null) {
      for (final role in roles) {
        final lower = role.name.toLowerCase();
        if (lower.contains('ceo') ||
            lower.contains('super admin') ||
            lower.contains('founder') ||
            lower.contains('managing director') ||
            lower.contains('executive director')) {
          return true;
        }
      }
    }
    return false;
  }

  // ── Typed API (preferred) ──────────────────────────────────────────────

  /// Check one typed permission. Honors wildcards transparently.
  bool has(Permission p) {
    if (_isSuperAdmin) return true;
    // Global wildcard fallthrough (in case _isSuperAdmin flag is stale)
    final globalWildcard = _userPermissions['*'];
    if (globalWildcard != null &&
        (globalWildcard.contains('*') || globalWildcard.contains('all'))) {
      return true;
    }
    final actions = _userPermissions[p.resource];
    if (actions == null) return false;
    return actions.contains(p.action) ||
        actions.contains('*') ||
        actions.contains('all');
  }

  /// User satisfies ANY of the listed permissions.
  bool hasAny(Iterable<Permission> perms) {
    for (final p in perms) {
      if (has(p)) return true;
    }
    return false;
  }

  /// User satisfies ALL of the listed permissions.
  bool hasAll(Iterable<Permission> perms) {
    for (final p in perms) {
      if (!has(p)) return false;
    }
    return true;
  }

  /// Typed route access check. Looks up [routeRequirements], returns true
  /// if the user satisfies any of the required permissions, or if the route
  /// is declared public (empty list) or is unmapped.
  bool canAccessRouteTyped(String? route) {
    if (route == null) return true;
    if (_disabledMarketingRoutes.contains(route)) return false;
    final required = routeRequirements[route];
    if (required == null) {
      // Unmapped route → allow any logged-in user. This keeps detail routes
      // and new pages accessible by default rather than silently 403ing.
      return true;
    }
    if (required.isEmpty) return true; // Explicitly public
    return hasAny(required);
  }

  // ── String-based API (backwards compat) ────────────────────────────────

  bool hasPermission(String resource, String action) {
    return has(Permission(resource, action));
  }

  /// Check a `resource:action` string. Null → public (allowed).
  bool canAccess(String? permission) {
    if (permission == null) return true;
    final parts = permission.split(':');
    if (parts.length != 2) return false;
    return hasPermission(parts[0], parts[1]);
  }

  bool hasAnyPermissionForResource(String resource) {
    if (_isSuperAdmin) return true;
    return _userPermissions.containsKey(resource) &&
        _userPermissions[resource]!.isNotEmpty;
  }

  bool canAccessResources(List<String>? resources) {
    if (resources == null || resources.isEmpty) return true;
    return resources.any((r) => hasAnyPermissionForResource(r));
  }

  /// Legacy sidebar entry point. Prefer [canAccessRouteTyped] for new code.
  bool canAccessRoute(String? route, List<String>? resources) {
    if (route != null) {
      if (_disabledMarketingRoutes.contains(route)) return false;
      final required = routeRequirements[route];
      if (required != null) {
        if (required.isEmpty) return true;
        return hasAny(required);
      }
    }
    return canAccessResources(resources);
  }

  // ── First permitted route (post-login redirect) ────────────────────────

  /// Finds a route the user can actually navigate to after login. Super admin
  /// always lands on the Company dashboard; regular employees land on the
  /// employee dashboard. Falls back by walking the main menu order.
  String getFirstPermittedRoute() {
    if (canAccessRoute(RouteConstants.home, [PermissionConstants.resDashboard])) {
      return RouteConstants.home;
    }
    if (canAccessRoute(RouteConstants.company, [PermissionConstants.resCompanySettings])) {
      return RouteConstants.company;
    }

    for (final section in sidebarStructure) {
      for (final item in section.items) {
        if (item.isExpandable) {
          for (final sub in item.children) {
            if (canAccessRoute(sub.route, sub.resources) && sub.route != null) {
              return sub.route!;
            }
          }
        } else if (canAccessRoute(item.route, item.resources) &&
            item.route != null) {
          return item.route!;
        }
      }
    }

    return RouteConstants.home;
  }

  // ── Drift validator (dev only) ─────────────────────────────────────────

  /// Compare a backend `permissions-map` against the constants declared on
  /// [Perms]. Logs warnings for drift — missing resources, missing actions,
  /// or unused backend permissions. Runs only in debug mode.
  void validateAgainstBackendMap(Map<String, List<String>> backendMap) {
    if (!kDebugMode) return;

    final frontendPerms = _collectDeclaredPerms();
    final issues = <String>[];

    for (final p in frontendPerms) {
      final actions = backendMap[p.resource];
      if (actions == null) {
        issues.add('⚠️  Frontend declares $p but backend has no resource '
            '"${p.resource}".');
        continue;
      }
      if (!actions.contains(p.action)) {
        issues.add('⚠️  Frontend declares $p but backend resource '
            '"${p.resource}" has no action "${p.action}". '
            'Backend actions: ${actions.join(", ")}');
      }
    }

    final declaredResources = frontendPerms.map((p) => p.resource).toSet();
    for (final resource in backendMap.keys) {
      if (!declaredResources.contains(resource)) {
        // Not an error — backend may expose more than we use. Log at info level.
        log('ℹ️  Backend resource "$resource" has no frontend permissions '
            'declared on Perms. That\'s fine if the UI does not gate it.');
      }
    }

    if (issues.isEmpty) {
      log('✅ Permission drift check passed '
          '(${frontendPerms.length} declared, ${backendMap.length} backend).');
    } else {
      log('❌ Permission drift check found ${issues.length} issue(s):');
      for (final i in issues) {
        log(i);
      }
    }
  }

  /// Reflective enumeration of every [Permission] instance we declare on
  /// [Perms]. Hardcoded here to avoid `dart:mirrors` (not supported on web).
  /// Add new Perms here when you declare them.
  List<Permission> _collectDeclaredPerms() {
    return const [
      Perms.employeesCreate,
      Perms.employeesView,
      Perms.employeesViewOwn,
      Perms.employeesList,
      Perms.employeesUpdate,
      Perms.employeesUpdateOwn,
      Perms.employeesExit,
      Perms.departmentsCreate,
      Perms.departmentsList,
      Perms.departmentsUpdate,
      Perms.rolesCreate,
      Perms.rolesView,
      Perms.rolesViewOwn,
      Perms.rolesList,
      Perms.rolesUpdate,
      Perms.rolesDelete,
      Perms.branchesCreate,
      Perms.branchesView,
      Perms.branchesList,
      Perms.branchesUpdate,
      Perms.companySettingsView,
      Perms.companySettingsUpdate,
      Perms.dashboardView,
      Perms.statsView,
      Perms.leadsCreate,
      Perms.leadsList,
      Perms.leadsUpdate,
      Perms.leadsDelete,
      Perms.clientsCreate,
      Perms.clientsView,
      Perms.clientsList,
      Perms.clientsUpdate,
      Perms.estatesCreate,
      Perms.estatesView,
      Perms.estatesList,
      Perms.estatesUpdate,
      Perms.estatesDelete,
      Perms.propertiesCreate,
      Perms.propertiesView,
      Perms.propertiesList,
      Perms.propertiesUpdate,
      Perms.propertiesDelete,
      Perms.estateInvoicesCreate,
      Perms.estateInvoicesList,
      Perms.estateInvoicesListOwn,
      Perms.estateInvoicesUpdate,
      Perms.estateInvoicesDelete,
      Perms.estateInvoicesApprove,
      Perms.estateInvoicesReject,
      Perms.announcementsCreate,
      Perms.announcementsList,
      Perms.announcementsUpdate,
      Perms.announcementsDelete,
      Perms.boardResolutionsCreate,
      Perms.boardResolutionsList,
      Perms.boardResolutionsUpdate,
      Perms.boardResolutionsDelete,
      Perms.meetingsCreate,
      Perms.meetingsList,
      Perms.meetingsUpdate,
      Perms.meetingsDelete,
      Perms.approvalFlowsCreate,
      Perms.approvalFlowsList,
      Perms.approvalFlowsUpdate,
      Perms.approvalFlowsDelete,
      Perms.approvalRequestsListOwn,
      Perms.approvalRequestsList,
      Perms.auditLogsList,
      Perms.shareholdersList,
      Perms.shareholdersCreate,
      Perms.shareholdersUpdate,
      Perms.assetsCreate,
      Perms.assetsList,
      Perms.assetsListOwn,
      Perms.assetsUpdate,
      Perms.assetsDelete,
      Perms.projectsCreate,
      Perms.projectsList,
      Perms.projectsUpdate,
      Perms.projectsDelete,
      Perms.tasksCreate,
      Perms.tasksList,
      Perms.tasksListOwn,
      Perms.tasksUpdate,
      Perms.tasksUpdateOwn,
      Perms.tasksDelete,
      Perms.worksitesCreate,
      Perms.worksitesList,
      Perms.worksitesUpdate,
      Perms.worksitesDelete,
      Perms.contractsCreate,
      Perms.contractsList,
      Perms.contractsUpdate,
      Perms.contractsDelete,
      Perms.budgetsCreate,
      Perms.budgetsList,
      Perms.budgetsUpdate,
      Perms.budgetsDelete,
      Perms.expensesCreate,
      Perms.expensesList,
      Perms.expensesListOwn,
      Perms.expensesUpdate,
      Perms.expensesUpdateOwn,
      Perms.expensesDelete,
      Perms.expensesApprove,
      Perms.expensesReject,
      Perms.paymentsCreate,
      Perms.paymentsList,
      Perms.paymentsDelete,
      Perms.serviceInvoicesCreate,
      Perms.serviceInvoicesList,
      Perms.serviceInvoicesUpdate,
      Perms.serviceInvoicesDelete,
      Perms.jobPostingsCreate,
      Perms.jobPostingsList,
      Perms.jobPostingsUpdate,
      Perms.jobPostingsDelete,
      Perms.applicantsCreate,
      Perms.applicantsList,
      Perms.applicantsUpdate,
      Perms.applicantsDelete,
      Perms.interviewsCreate,
      Perms.interviewsList,
      Perms.interviewsUpdate,
      Perms.interviewsDelete,
      Perms.offerLettersCreate,
      Perms.offerLettersList,
      Perms.offerLettersUpdate,
      Perms.leaveRequestsCreate,
      Perms.leaveRequestsList,
      Perms.leaveRequestsListOwn,
      Perms.leaveRequestsUpdate,
      Perms.leaveRequestsUpdateOwn,
      Perms.leaveRequestsDelete,
      Perms.leaveRequestsDeleteOwn,
      Perms.leaveRequestsApprove,
      Perms.leaveRequestsReject,
      Perms.payrollList,
      Perms.payrollListOwn,
      Perms.payrollProcessBatch,
      Perms.payrollMakePayment,
      Perms.payrollAuthorize,
      Perms.performanceReviewsCreate,
      Perms.performanceReviewsList,
      Perms.performanceReviewsListOwn,
      Perms.performanceReviewsUpdate,
      Perms.performanceReviewsDelete,
      Perms.trainingProgramsCreate,
      Perms.trainingProgramsList,
      Perms.trainingProgramsUpdate,
      Perms.trainingProgramsDelete,
      Perms.monthlyScorecardsList,
      Perms.monthlyScorecardsListOwn,
      Perms.employeeEvaluationsList,
      Perms.employeeEvaluationsListOwn,
      Perms.workReportsCreate,
      Perms.workReportsList,
      Perms.workReportsListOwn,
      Perms.workReportsUpdate,
      Perms.workReportsUpdateOwn,
      Perms.workReportsDelete,
      Perms.disciplinaryCasesList,
      Perms.disciplinaryCasesListOwn,
      Perms.awardsList,
      Perms.awardsListOwn,
      Perms.legalCasesCreate,
      Perms.legalCasesList,
      Perms.legalCasesUpdate,
      Perms.legalCasesDelete,
      Perms.complianceRecordsCreate,
      Perms.complianceRecordsList,
      Perms.complianceRecordsUpdate,
      Perms.complianceAuditsCreate,
      Perms.complianceAuditsList,
      Perms.complianceAuditsUpdate,
      Perms.complianceAuditsDelete,
      Perms.eventsCreate,
      Perms.eventsList,
      Perms.eventsUpdate,
      Perms.eventsDelete,
      Perms.loansCreate,
      Perms.loansList,
      Perms.loansListOwn,
      Perms.loansApprove,
      Perms.loansReject,
      Perms.drawingsCreate,
      Perms.drawingsList,
      Perms.drawingsUpdate,
      Perms.drawingsDelete,
      Perms.drawingsApprove,
      Perms.drawingsReject,
      Perms.partnersCreate,
      Perms.partnersList,
      Perms.partnersUpdate,
      Perms.partnersDelete,
      Perms.policiesCreate,
      Perms.policiesList,
      Perms.policiesUpdate,
      Perms.policiesDelete,
      Perms.documentsCreate,
      Perms.documentsList,
      Perms.documentsUpdate,
      Perms.documentsDelete,
      Perms.contentCreate,
      Perms.contentList,
      Perms.contentUpdate,
      Perms.contentDelete,
      Perms.marketingCampaignsCreate,
      Perms.marketingCampaignsList,
      Perms.marketingCampaignsUpdate,
      Perms.servicesList,
      Perms.servicesCreate,
      Perms.servicesUpdate,
      Perms.ordersList,
      Perms.quotesList,
      Perms.kpisList,
      Perms.clientInventoryList,
      Perms.walletView,
      Perms.walletViewOwn,
    ];
  }
}
