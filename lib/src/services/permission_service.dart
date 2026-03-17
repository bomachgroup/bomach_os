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
    return actions.contains(action) || actions.contains('*') || actions.contains('all');
  }

  void clearPermissions() {
    _userPermissions.clear();
  }
}
