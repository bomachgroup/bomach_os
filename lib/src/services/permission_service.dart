import 'package:get/get.dart';
import '../model/role_model.dart';
import '../app_routes/app_route_constants.dart';
import '../constants/permissions.dart';

class PermissionService extends GetxService {
  final RxMap<String, Set<String>> _userPermissions = <String, Set<String>>{}.obs;

  void loadPermissions(List<Role> roles) {
    _userPermissions.clear();
    for (var role in roles) {
      role.permissions.forEach((resource, actions) {
        if (!_userPermissions.containsKey(resource)) {
          _userPermissions[resource] = <String>{}.obs;
        }
        _userPermissions[resource]!.addAll(actions);
      });
    }
  }

  bool hasPermission(String resource, String action) {
    // Check if the user has the specific action for the resource
    // Or if they have 'all' or '*' permissions if implemented by backend
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
      [PermissionConstants.resEmployees, PermissionConstants.resJobPostings,
       PermissionConstants.resLeaveRequests, PermissionConstants.resPayroll]:
          RouteConstants.hr,
      [PermissionConstants.resProjects, PermissionConstants.resTasks,
       PermissionConstants.resContracts, PermissionConstants.resWorksites]:
          RouteConstants.operations,
      [PermissionConstants.resBudgets, PermissionConstants.resExpenses,
       PermissionConstants.resPayments, PermissionConstants.resEstateInvoices]:
          RouteConstants.finance,
      [PermissionConstants.resEvents]: RouteConstants.events,
      [PermissionConstants.resServices, PermissionConstants.resProperties,
       PermissionConstants.resEstates, PermissionConstants.resClients]:
          RouteConstants.services,
      [PermissionConstants.resDocuments, PermissionConstants.resContent]:
          RouteConstants.workspace,
      [PermissionConstants.resStats]: RouteConstants.analyticsOverview,
      [PermissionConstants.resLegalCases, PermissionConstants.resComplianceRecords,
       PermissionConstants.resComplianceAudits, PermissionConstants.resContracts]:
          RouteConstants.legalCases,
      [PermissionConstants.resClients, PermissionConstants.resDocuments]:
          RouteConstants.clientAccess,
      [PermissionConstants.resAuditLogs, PermissionConstants.resRoles,
       PermissionConstants.resApprovalFlows]: RouteConstants.securityOverview,
      [PermissionConstants.resClients, PermissionConstants.resLeads,
       PermissionConstants.resMarketingCampaigns]: RouteConstants.crmClients,
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
