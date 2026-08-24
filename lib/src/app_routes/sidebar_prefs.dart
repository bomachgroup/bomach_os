import 'package:bomach_os/src/app_routes/menu_structure.dart';

/// Pure, web-free sidebar decision helpers.
///
/// Lives outside `side_menu.dart` so tests (and the auth controller's
/// logout cleanup) can import it without dragging the widget graph —
/// `package:web` is unreachable in VM test builds.

/// SharedPreferences keys the sidebar persists. The logout flow clears
/// exactly these so menu state never leaks between accounts on shared
/// machines (audit B9 fix).
const List<String> sidebarPrefsKeys = [
  'selectedMenu',
  'selectedSubMenu',
  'sidebarOpenMenu',
  'sidebarPinnedSubs',
  'sidebarPinnedMains',
  'sidebarCollapsed',
];

/// Restore guard for a persisted MainMenuItem ordinal (audit B13 fix).
/// Out-of-range / negative indices return null instead of throwing
/// RangeError after an enum reorder or removal. Null input → null
/// (caller applies its own default).
MainMenuItem? safeMainIndex(int? index) {
  if (index == null) return null;
  if (index < 0 || index >= MainMenuItem.values.length) return null;
  return MainMenuItem.values[index];
}

/// String-keyed variant for values read straight from SharedPreferences.
MainMenuItem? safeMainIndexFromString(String? raw) {
  if (raw == null) return null;
  return safeMainIndex(int.tryParse(raw));
}

/// Restore guard for a persisted SubMenuItem ordinal. -1 is the persisted
/// "no selection" sentinel and maps to null.
SubMenuItem? safeSubIndex(int? index) {
  if (index == null) return null;
  if (index < 0 || index >= SubMenuItem.values.length) return null;
  return SubMenuItem.values[index];
}

SubMenuItem? safeSubIndexFromString(String? raw) {
  if (raw == null) return null;
  return safeSubIndex(int.tryParse(raw));
}

/// Account-card role label fallback (audit B7 fix). The old literal
/// 'Super Admin' mislabelled every user without an employment type as an
/// admin — alarming and misleading, even though authorization is handled
/// by PermissionService.
String resolveRoleLabel(String? employmentType) {
  if (employmentType == null || employmentType.trim().isEmpty) {
    return 'Team Member';
  }
  return employmentType;
}

/// Single source of truth for whether a sidebar [MenuItem] should be
/// visible (audit B9a fix). Both the regular section loop AND the pinned
/// rows call this, so pinned items can never bypass permission filtering
/// again.
///
/// [canAccess] mirrors PermissionService.canAccessRoute: given a route and
/// resource list, decide whether the current user may use it. The
/// super-admin/company special cases replicate _buildMenuItem exactly:
///   - Dashboard menu hidden from super admins / company-settings holders
///     (they get the company dashboard instead),
///   - Company menu restricted to those same users.
bool shouldShowMenuItem(
  MenuItem menuItem, {
  required bool isSuperAdmin,
  required bool hasCompanySettings,
  required bool Function(String? route, List<String>? resources) canAccess,
}) {
  final privileged = isSuperAdmin || hasCompanySettings;

  if (menuItem.id == MainMenuItem.dashboard && privileged) {
    return false;
  }
  if (menuItem.id == MainMenuItem.company && !privileged) {
    return false;
  }

  if (menuItem.isExpandable) {
    return menuItem.children
        .any((child) => canAccess(child.route, child.resources));
  }
  return canAccess(menuItem.route, menuItem.resources);
}
