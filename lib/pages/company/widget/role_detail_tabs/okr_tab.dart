import 'package:bomach_os/components/backend_capability_unavailable.dart';
import 'package:flutter/material.dart';

/// Placeholder for the role OKR tab until the backend publishes its contract.
class OkrTab extends StatelessWidget {
  final int roleId;

  const OkrTab({super.key, required this.roleId});

  @override
  Widget build(BuildContext context) {
    return const BackendCapabilityUnavailable(
      featureName: 'Role OKRs',
      explanation:
          'Role OKRs are not available because the published API does not expose the required role OKR contract.',
      contractRequirement:
          'Backend contract needed: objectives, key results, owners, periods, progress, status, and approval/review actions.',
    );
  }
}
