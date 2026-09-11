import 'package:bomach_os/components/cards/module_shortcut_card.dart';
import 'package:bomach_os/components/section/module_dashboard.dart';
import 'package:bomach_os/src/app_routes/app_route_constants.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

/// Combined landing page for the merged Marketing & Sales module. Surfaces
/// every sub-route as a shortcut card so the dashboard matches the
/// sidebar 1:1. Cards the current user cannot access are rendered locked.
class MarketingCrmDashboard extends StatelessWidget {
  const MarketingCrmDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final perms = Get.find<PermissionService>();

    ModuleShortcutCard card({
      required IconData icon,
      required String title,
      required String subtitle,
      required String route,
      required List<String> resources,
    }) {
      final enabled = perms.canAccessRoute(route, resources);
      return ModuleShortcutCard(
        icon: icon,
        title: title,
        subtitle: subtitle,
        route: route,
        enabled: enabled,
      );
    }

    return ModuleDashboard(
      title: 'Marketing & Sales',
      subtitle:
          'Client relationships, sales pipelines, and marketing activity in one place.',
      shortcuts: [
        card(
          icon: Iconsax.user_octagon,
          title: 'Client Relationship Management',
          subtitle: 'Manage your customer list',
          route: RouteConstants.crmClients,
          resources: const [PermissionConstants.resClients],
        ),
        card(
          icon: Iconsax.chart_2,
          title: 'Marketing',
          subtitle: 'Campaigns, content, and events',
          route: RouteConstants.marketing,
          resources: const [PermissionConstants.resMarketingCampaigns],
        ),
      ],
    );
  }
}
