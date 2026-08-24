import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bomach_os/src/app_routes/menu_structure.dart';
import 'package:bomach_os/src/app_routes/sidebar_prefs.dart';

/// Specs (B13 fix Batch 6, B7 fix Batch 6, B9a/B9b fixes Batch 6):
///
/// All sidebar decision logic lives in `lib/src/app_routes/sidebar_prefs.dart`
/// — a web-free pure-Dart module importable by both `side_menu.dart` and the
/// auth controller's logout cleanup. (`side_menu.dart` itself cannot be
/// imported in VM tests: its transitive graph reaches package:web.)
///
/// T10 — `safeMainIndex` / `safeSubIndex` are pure index resolvers used by
///        `_loadMenuState`. Out-of-range / negative / unparseable input →
///        null instead of RangeError. Valid indices pass through.
///
/// T11 — `resolveRoleLabel`: null/empty employmentType falls back to
///        'Team Member' (was the misleading 'Super Admin').
///
/// T12 — `shouldShowMenuItem` encodes the sidebar visibility decision so
///        pinned rows and regular rows can never drift apart again:
///          - super admin/company_settings users: employee Dashboard menu
///            hidden, Company menu visible
///          - others: Company menu hidden
///          - expandable item visible iff ANY child passes canAccess
///          - leaf item visible iff canAccess(route, resources)
///        The `canAccess` callback receives (route, resources) and returns
///        bool — tests inject deterministic answers.
///
/// T13 — `sidebarPrefsKeys` is exactly the six SharedPreferences keys the
///        sidebar writes, so logout clears precisely those.
void main() {
  group('T10: safeMainIndex', () {
    test('valid indices pass through', () {
      expect(safeMainIndex(0), MainMenuItem.dashboard);
      final last = MainMenuItem.values.length - 1;
      expect(safeMainIndex(last), MainMenuItem.values[last]);
    });

    test('out-of-range and negative return null (no RangeError)', () {
      expect(safeMainIndex(-1), isNull);
      expect(safeMainIndex(MainMenuItem.values.length), isNull);
      expect(safeMainIndex(99999), isNull);
    });

    test('unparseable strings return null', () {
      expect(safeMainIndexFromString('abc'), isNull);
      expect(safeMainIndexFromString(null), isNull);
    });

    test('parses valid stored string', () {
      expect(safeMainIndexFromString('2'), MainMenuItem.values[2]);
    });
  });

  group('T10: safeSubIndex', () {
    test('valid indices pass through', () {
      expect(safeSubIndex(0), SubMenuItem.values[0]);
      final last = SubMenuItem.values.length - 1;
      expect(safeSubIndex(last), SubMenuItem.values[last]);
    });

    test('negative and out-of-range return null', () {
      // -1 is also the persisted "no selection" sentinel.
      expect(safeSubIndex(-1), isNull);
      expect(safeSubIndex(SubMenuItem.values.length), isNull);
    });

    test('string variant handles the -1 sentinel and junk', () {
      expect(safeSubIndexFromString('-1'), isNull);
      expect(safeSubIndexFromString('junk'), isNull);
      expect(safeSubIndexFromString(null), isNull);
      expect(
          safeSubIndexFromString('${SubMenuItem.values.length - 1}'),
          SubMenuItem.values.last);
    });
  });

  group('T11: resolveRoleLabel', () {
    test('null/empty employmentType falls back to Team Member', () {
      expect(resolveRoleLabel(null), 'Team Member');
      expect(resolveRoleLabel(''), 'Team Member');
    });

    test('whitespace-only counts as empty', () {
      expect(resolveRoleLabel('   '), 'Team Member');
    });

    test('real values pass through untouched', () {
      expect(resolveRoleLabel('full-time'), 'full-time');
      expect(resolveRoleLabel('surveyor-associate'), 'surveyor-associate');
    });
  });

  group('T12: shouldShowMenuItem', () {
    const icon = Icons.home;
    MenuItem leaf({String? route, List<String>? resources}) => MenuItem(
          id: MainMenuItem.events,
          label: 'Events',
          icon: icon,
          route: route,
          resources: resources,
          isExpandable: false,
        );

    MenuItem expandable(List<SubMenuItemData> children) => MenuItem(
          id: MainMenuItem.company,
          label: 'Company',
          icon: icon,
          isExpandable: true,
          children: children,
        );

    bool allow(String? route, List<String>? resources) => true;
    bool deny(String? route, List<String>? resources) => false;

    test('super admin does not see the employee Dashboard menu', () {
      final dashboard = MenuItem(
        id: MainMenuItem.dashboard,
        label: 'Dashboard',
        icon: const IconData(0xe800),
        isExpandable: true,
      );
      expect(
        shouldShowMenuItem(dashboard,
            isSuperAdmin: true, hasCompanySettings: false, canAccess: allow),
        isFalse,
      );
    });

    test('company_settings holder does not see Dashboard either', () {
      final dashboard = MenuItem(
        id: MainMenuItem.dashboard,
        label: 'Dashboard',
        icon: const IconData(0xe800),
        isExpandable: true,
      );
      expect(
        shouldShowMenuItem(dashboard,
            isSuperAdmin: false, hasCompanySettings: true, canAccess: allow),
        isFalse,
      );
    });

    test('regular user without company settings cannot see Company menu',
        () {
      final company = expandable([]);
      expect(
        shouldShowMenuItem(company,
            isSuperAdmin: false, hasCompanySettings: false, canAccess: allow),
        isFalse,
      );
    });

    test('expandable menus need at least one accessible child even for '
        'super admin (matches real _buildMenuItem)', () {
      final company = expandable([]);
      // In production a super admin's wildcard makes every child pass, so
      // this branch is unreachable — but the predicate must mirror the
      // widget exactly: no authorized children → hidden.
      expect(
        shouldShowMenuItem(company,
            isSuperAdmin: true, hasCompanySettings: false, canAccess: deny),
        isFalse,
      );
    });

    test('expandable menu visible iff any child is accessible', () {
      final company = MenuItem(
        id: MainMenuItem.company,
        label: 'Company',
        icon: const IconData(0xe800),
        isExpandable: true,
        children: [
          SubMenuItemData(
            id: SubMenuItem.roles,
            label: 'Roles',
            icon: const IconData(0xe800),
            route: '/company/roles',
            resources: ['roles'],
          ),
          SubMenuItemData(
            id: SubMenuItem.branch,
            label: 'Branch',
            icon: const IconData(0xe800),
            route: '/company/branch',
            resources: ['branches'],
          ),
        ],
      );

      var allowedRoute;
      final result = shouldShowMenuItem(company,
          isSuperAdmin: false,
          hasCompanySettings: true,
          canAccess: (route, resources) => route == allowedRoute);

      allowedRoute = '/company/roles';
      expect(
        shouldShowMenuItem(company,
            isSuperAdmin: false,
            hasCompanySettings: true,
            canAccess: (route, resources) => route == allowedRoute),
        isTrue,
        reason: 'one accessible child → visible',
      );

      expect(
        shouldShowMenuItem(company,
            isSuperAdmin: false,
            hasCompanySettings: true,
            canAccess: deny),
        isFalse,
        reason: 'no accessible child → hidden',
      );
    });

    test('leaf menu requires its route/resources to be accessible '
        '(even when pinned)', () {
      final events = leaf(route: '/events', resources: ['events']);
      expect(
        shouldShowMenuItem(events,
            isSuperAdmin: false, hasCompanySettings: false, canAccess: deny),
        isFalse,
        reason:
            'THE AUDITED BUG: pinned rows bypassed this check entirely',
      );
      expect(
        shouldShowMenuItem(events,
            isSuperAdmin: false, hasCompanySettings: false, canAccess: allow),
        isTrue,
      );
    });
  });

  group('T13: sidebarPrefsKeys', () {
    test('is exactly the six keys the sidebar persists', () {
      expect(
        sidebarPrefsKeys.toSet(),
        equals({
          'selectedMenu',
          'selectedSubMenu',
          'sidebarOpenMenu',
          'sidebarPinnedSubs',
          'sidebarPinnedMains',
          'sidebarCollapsed',
        }),
      );
    });
  });
}
