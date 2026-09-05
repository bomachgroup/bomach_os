import 'package:bomach_os/components/backend_capability_unavailable.dart';
import 'package:flutter/material.dart';

/// Placeholder for role reports until the backend publishes that contract.
class ReportsTab extends StatelessWidget {
  final int roleId;

  const ReportsTab({super.key, required this.roleId});

  @override
  Widget build(BuildContext context) {
    return const BackendCapabilityUnavailable(
      featureName: 'Role Reports',
      explanation:
          'Role-specific report definitions are not available because the published API does not expose the required role reports contract.',
      contractRequirement:
          'Use Work Reports and Target Reports for supported reporting flows, or publish role report endpoints before implementing this tab.',
    );
  }
}
