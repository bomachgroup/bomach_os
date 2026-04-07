import 'package:get/get.dart';
import '../model/role_model.dart';
import '../app_routes/app_route_constants.dart';
import '../constants/permissions.dart';

class PermissionService extends GetxService {
  final RxMap<String, Set<String>> _userPermissions =
      <String, Set<String>>{}.obs;

  void loadPermissions(List<Role> roles) {
    final newPermissions = <String, Set<String>>{};
    for (var role in roles) {
      role.permissions.forEach((resource, actions) {
        newPermissions.putIfAbsent(resource, () => <String>{});
        newPermissions[resource]!.addAll(actions);
      });
    }
    _userPermissions.clear();
    _userPermissions.addAll(newPermissions);
    _userPermissions.refresh();
  }

  /// Sets minimal default permissions so every logged-in user can at least
  /// see the dashboard and basic self-service pages when the roles endpoint
  /// returns 403 (user lacks roles:view_own permission).
  void loadDefaultPermissions() {
    if (_userPermissions.isNotEmpty)
      return; // Don't overwrite if already loaded
    _userPermissions.clear();
    _userPermissions.addAll({
      'dashboard': {'view'},
      'employees': {'view_own'},
      'work_reports': {'create', 'view_own', 'list_own', 'update_own'},
      'leave_requests': {
        'create',
        'view_own',
        'list_own',
        'update_own',
        'delete_own'
      },
      'tasks': {'view_own', 'list_own', 'update_own'},
    });
    _userPermissions.refresh();
  }



  bool hasPermission(String resource, String action) {
    final actions = _userPermissions[resource];
    if (actions == null) return false;
    return actions.contains(action) ||
        actions.contains('*') ||
        actions.contains('all');
  }

  /// Checks if the user has access based on a permission string in the format "resource:action"
  /// Returns true if permission is null (public access)
  bool canAccess(String? permission) {
    if (permission == null) return true;
    final parts = permission.split(':');
    if (parts.length != 2) return false;
    return hasPermission(parts[0], parts[1]);
  }

  /// Returns true if user has any permission at all for a given resource
  bool hasAnyPermissionForResource(String resource) {
    return _userPermissions.containsKey(resource) &&
        _userPermissions[resource]!.isNotEmpty;
  }

  /// Returns true if resources is null/empty (public access) or user has any
  /// permission for at least one of the listed resources.
  /// This is used by the sidebar to dynamically show/hide menu items based on
  /// the resource names returned by the backend permissions map.
  bool canAccessResources(List<String>? resources) {
    if (resources == null || resources.isEmpty) return true;
    return resources.any((r) => hasAnyPermissionForResource(r));
  }

  /// Checks if the user can access a specific route by verifying against
  /// the route permissions map. If the route has no explicit permission
  /// requirement, falls back to resource-based check.
  bool canAccessRoute(String? route, List<String>? resources) {
    if (route == null) return canAccessResources(resources);

    // Check route permission map first — this is the authoritative check
    final requiredPermission = routePermissions[route];
    if (requiredPermission != null) {
      return canAccess(requiredPermission);
    }

    // No route-level permission defined, fall back to resource check
    return canAccessResources(resources);
  }

  /// Route-to-permission mapping used by both the router guard and sidebar.
  /// Centralised here so the sidebar can hide items the user cannot navigate to.
  static final Map<String, String> routePermissions = {
    RouteConstants.employees: PermissionConstants.perm(
        PermissionConstants.resEmployees, PermissionConstants.actList),
    RouteConstants.attendance: PermissionConstants.perm(
        PermissionConstants.resEmployees, PermissionConstants.actList),
    RouteConstants.roles: PermissionConstants.perm(
        PermissionConstants.resRoles, PermissionConstants.actList),
    RouteConstants.budget: PermissionConstants.perm(
        PermissionConstants.resBudgets, PermissionConstants.actList),
    RouteConstants.expense: PermissionConstants.perm(
        PermissionConstants.resExpenses, PermissionConstants.actList),
    RouteConstants.invoice: PermissionConstants.perm(
        PermissionConstants.resEstateInvoices, PermissionConstants.actList),
    RouteConstants.branch: PermissionConstants.perm(
        PermissionConstants.resBranches, PermissionConstants.actList),
    RouteConstants.department: PermissionConstants.perm(
        PermissionConstants.resDepartments, PermissionConstants.actList),
    RouteConstants.jobPost: PermissionConstants.perm(
        PermissionConstants.resJobPostings, PermissionConstants.actList),
    RouteConstants.leaveRequest: PermissionConstants.perm(
        PermissionConstants.resLeaveRequests, PermissionConstants.actList),
    RouteConstants.performanceReview: PermissionConstants.perm(
        PermissionConstants.resPerformanceReviews, PermissionConstants.actList),
    RouteConstants.assets: PermissionConstants.perm(
        PermissionConstants.resAssets, PermissionConstants.actList),
    RouteConstants.auditLog: PermissionConstants.perm(
        PermissionConstants.resAuditLogs, PermissionConstants.actList),
    RouteConstants.approvalWorkflow: PermissionConstants.perm(
        PermissionConstants.resApprovalFlows, PermissionConstants.actList),
    RouteConstants.board: PermissionConstants.perm(
        PermissionConstants.resBoardResolutions, PermissionConstants.actList),
    RouteConstants.broadcast: PermissionConstants.perm(
        PermissionConstants.resAnnouncements, PermissionConstants.actList),
    RouteConstants.projects: PermissionConstants.perm(
        PermissionConstants.resProjects, PermissionConstants.actList),
    RouteConstants.tasks: PermissionConstants.perm(
        PermissionConstants.resTasks, PermissionConstants.actList),
    RouteConstants.contracts: PermissionConstants.perm(
        PermissionConstants.resContracts, PermissionConstants.actList),
    RouteConstants.realEstate: PermissionConstants.perm(
        PermissionConstants.resProperties, PermissionConstants.actList),
    RouteConstants.landSurvey: PermissionConstants.perm(
        PermissionConstants.resProperties, PermissionConstants.actList),
    RouteConstants.estateManagement: PermissionConstants.perm(
        PermissionConstants.resEstates, PermissionConstants.actList),
    RouteConstants.propertyList: PermissionConstants.perm(
        PermissionConstants.resProperties, PermissionConstants.actList),
  };

  /// Returns the first route the user is permitted to see, following
  /// the same menu order and mutual-exclusivity logic as the sidebar.
  String getFirstPermittedRoute() {
    // CEO / admin with company_settings → Company Profile
    if (hasAnyPermissionForResource(PermissionConstants.resCompanySettings)) {
      return RouteConstants.company;
    }

    // Regular employee → Dashboard (if they have dashboard or employees resource)
    if (hasAnyPermissionForResource(PermissionConstants.resDashboard) ||
        hasAnyPermissionForResource(PermissionConstants.resEmployees)) {
      return RouteConstants.home;
    }

    // Fallback: walk the sidebar menu order and return first match
    // Each entry: [resources that gate the menu] → first child route
    final menuResources = <List<String>, String>{
      [
        PermissionConstants.resEmployees,
        PermissionConstants.resJobPostings,
        PermissionConstants.resLeaveRequests,
        PermissionConstants.resPayroll
      ]: RouteConstants.hr,
      [
        PermissionConstants.resProjects,
        PermissionConstants.resTasks,
        PermissionConstants.resContracts,
        PermissionConstants.resWorksites
      ]: RouteConstants.operations,
      [
        PermissionConstants.resBudgets,
        PermissionConstants.resExpenses,
        PermissionConstants.resPayments,
        PermissionConstants.resEstateInvoices
      ]: RouteConstants.finance,
      [PermissionConstants.resEvents]: RouteConstants.events,
      [
        PermissionConstants.resServices,
        PermissionConstants.resProperties,
        PermissionConstants.resEstates,
        PermissionConstants.resClients
      ]: RouteConstants.services,
      [PermissionConstants.resDocuments, PermissionConstants.resContent]:
          RouteConstants.workspace,
      [PermissionConstants.resStats]: RouteConstants.analyticsOverview,
      [
        PermissionConstants.resLegalCases,
        PermissionConstants.resComplianceRecords,
        PermissionConstants.resComplianceAudits,
        PermissionConstants.resContracts
      ]: RouteConstants.legalCases,
      [PermissionConstants.resClients, PermissionConstants.resDocuments]:
          RouteConstants.clientAccess,
      [
        PermissionConstants.resAuditLogs,
        PermissionConstants.resRoles,
        PermissionConstants.resApprovalFlows
      ]: RouteConstants.securityOverview,
      [
        PermissionConstants.resClients,
        PermissionConstants.resLeads,
        PermissionConstants.resMarketingCampaigns
      ]: RouteConstants.crmClients,
    };

    for (final entry in menuResources.entries) {
      if (entry.key.any((r) => hasAnyPermissionForResource(r))) {
        return entry.value;
      }
    }

    // Absolute fallback
    return RouteConstants.home;
  }

  void clearPermissions() {
    _userPermissions.clear();
  }
}
