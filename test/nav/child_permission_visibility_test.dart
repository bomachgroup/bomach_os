import 'package:bomach_os/src/app_routes/menu_structure.dart';
import 'package:bomach_os/src/app_routes/sidebar_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps a section visible when one child is permitted', () {
    const menu = MenuItem(
      id: MainMenuItem.company,
      label: 'Company',
      icon: Icons.business,
      isExpandable: true,
      resources: ['company_settings'],
      children: [
        SubMenuItemData(
          id: SubMenuItem.roles,
          label: 'Roles',
          icon: Icons.badge,
          route: '/company/roles',
          resources: ['roles'],
        ),
      ],
    );

    expect(
      shouldShowMenuItem(
        menu,
        isSuperAdmin: false,
        hasCompanySettings: false,
        canAccess: (route, resources) => resources?.contains('roles') ?? false,
      ),
      isTrue,
    );
  });
}
