import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../src/constants/permissions.dart';
import '../../src/services/permission_service.dart';

/// How the gate reacts when the user lacks permission.
enum PermissionGateMode {
  /// Widget is removed from the tree entirely.
  hide,

  /// Widget is rendered but wrapped in an [IgnorePointer] at 40% opacity.
  /// Useful when a button should still visually indicate a feature exists.
  disable,
}

/// Conditionally renders its [child] based on one or more permissions.
/// Reacts to permission changes via `Obx`, so granting/revoking a role
/// updates the UI without a page reload.
///
/// Typical usage:
///
/// ```dart
/// PermissionGate(
///   require: Perms.employeesCreate,
///   child: MyElevatedButton(child: 'Add Employee', onTap: _add),
/// )
/// ```
///
/// Multiple permissions (OR):
///
/// ```dart
/// PermissionGate(
///   anyOf: [Perms.estateInvoicesApprove, Perms.estateInvoicesReject],
///   child: ApproveButton(),
/// )
/// ```
class PermissionGate extends StatelessWidget {
  /// Single required permission. Shorthand for `anyOf: [require]`.
  final Permission? require;

  /// User must have AT LEAST ONE of these permissions.
  final List<Permission>? anyOf;

  /// User must have ALL of these permissions.
  final List<Permission>? allOf;

  final Widget child;
  final PermissionGateMode mode;

  /// Optional fallback when permission is denied. If null and [mode] is
  /// [PermissionGateMode.hide], nothing is rendered.
  final Widget? fallback;

  const PermissionGate({
    super.key,
    this.require,
    this.anyOf,
    this.allOf,
    required this.child,
    this.mode = PermissionGateMode.hide,
    this.fallback,
  }) : assert(require != null || anyOf != null || allOf != null,
            'PermissionGate needs at least one of: require, anyOf, allOf');

  @override
  Widget build(BuildContext context) {
    final perms = Get.find<PermissionService>();

    return Obx(() {
      // Subscribe to permission mutations so the gate re-evaluates on
      // grant/revoke.
      // ignore: unused_local_variable
      final _ = perms.version;

      bool allowed;
      if (allOf != null && allOf!.isNotEmpty) {
        allowed = perms.hasAll(allOf!);
      } else {
        final checks = <Permission>[
          if (require != null) require!,
          if (anyOf != null) ...anyOf!,
        ];
        allowed = checks.isEmpty ? true : perms.hasAny(checks);
      }

      if (allowed) return child;

      switch (mode) {
        case PermissionGateMode.hide:
          return fallback ?? const SizedBox.shrink();
        case PermissionGateMode.disable:
          return IgnorePointer(
            ignoring: true,
            child: Opacity(opacity: 0.4, child: child),
          );
      }
    });
  }
}
