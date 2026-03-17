import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../src/services/permission_service.dart';

/// A widget that conditionally shows its [child] based on whether the user has
/// the specified [action] permission for the given [resource].
class PermissionGate extends StatelessWidget {
  final String resource;
  final String action;
  final Widget child;
  final Widget? fallback;

  const PermissionGate({
    super.key,
    required this.resource,
    required this.action,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final permissionService = Get.find<PermissionService>();

    return Obx(() {
      if (permissionService.hasPermission(resource, action)) {
        return child;
      }
      return fallback ?? const SizedBox.shrink();
    });
  }
}
