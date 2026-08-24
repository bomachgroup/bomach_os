import 'package:bomach_os/src/app_routes/app_route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

/// Graceful fallbacks for detail routes reached without their in-memory
/// router `extra` (browser refresh / direct URL). Audit B12 fix — these
/// routes used to map to a permanently blank `Container()`.
///
/// Lives outside `app_router.dart` so VM tests can import it without
/// dragging the router's package:web transitive graph.

/// Fallback for `/company/roles/detail`.
class RoleDetailUnavailable extends StatelessWidget {
  const RoleDetailUnavailable({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DetailUnavailableScaffold(
      icon: Iconsax.shield_tick,
      message: 'Role details open from the Roles list. '
          'Pick a role to view its details.',
      backLabel: 'Back to Roles',
      backRoute: RouteConstants.roles,
    );
  }
}

/// Fallback for the estate detail routes.
class EstateDetailUnavailable extends StatelessWidget {
  const EstateDetailUnavailable({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DetailUnavailableScaffold(
      icon: Iconsax.building_4,
      message: 'Estate details open from Estate Management. '
          'Pick an estate to view its details.',
      backLabel: 'Back to Estates',
      backRoute: RouteConstants.estateManagement,
    );
  }
}

class _DetailUnavailableScaffold extends StatelessWidget {
  final IconData icon;
  final String message;
  final String backLabel;
  final String backRoute;

  const _DetailUnavailableScaffold({
    required this.icon,
    required this.message,
    required this.backLabel,
    required this.backRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.blueGrey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () => context.go(backRoute),
              icon: const Icon(Icons.arrow_back),
              label: Text(backLabel),
            ),
          ],
        ),
      ),
    );
  }
}
