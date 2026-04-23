import 'package:bms_front_end/components/cards/module_shortcut_card.dart';
import 'package:bms_front_end/components/section/module_dashboard.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/permissions.dart';
import 'package:bms_front_end/src/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

/// Combined landing page for the merged Marketing & CRM module. Surfaces
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
      title: 'Marketing & CRM',
      subtitle:
          'Client relationships, lead pipelines, and marketing activity in one place.',
      shortcuts: [
        card(
          icon: Iconsax.user_octagon,
          title: 'Clients',
          subtitle: 'Manage your customer list',
          route: RouteConstants.crmClients,
          resources: const [PermissionConstants.resClients],
        ),
        card(
          icon: Iconsax.flash_1,
          title: 'Leads',
          subtitle: 'Pipeline and new prospects',
          route: RouteConstants.crmLeads,
          resources: const [PermissionConstants.resLeads],
        ),
        card(
          icon: Iconsax.message_2,
          title: 'Interactions',
          subtitle: 'Conversations and touchpoints',
          route: RouteConstants.crmInteractions,
          resources: const [
            PermissionConstants.resClients,
            PermissionConstants.resLeads,
          ],
        ),
        card(
          icon: Iconsax.chart_2,
          title: 'Marketing',
          subtitle: 'Campaigns, content, and events',
          route: RouteConstants.marketing,
          resources: const [PermissionConstants.resMarketingCampaigns],
        ),
        card(
          icon: Iconsax.chart_square,
          title: 'Analytics',
          subtitle: 'Revenue and performance insights',
          route: RouteConstants.crmAnalytics,
          resources: const [
            PermissionConstants.resStats,
            PermissionConstants.resClients,
          ],
        ),
      ],
    );
  }
}
