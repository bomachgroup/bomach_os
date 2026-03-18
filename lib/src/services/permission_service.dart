import 'package:get/get.dart';
import '../model/role_model.dart';

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

  void clearPermissions() {
    _userPermissions.clear();
  }
}
