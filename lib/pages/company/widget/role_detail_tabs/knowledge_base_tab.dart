import 'package:bomach_os/components/backend_capability_unavailable.dart';
import 'package:flutter/material.dart';

/// The published API has role resources and a Success Playbook, but no
/// Knowledge Base resource. Keep this tab honest until that contract exists.
class KnowledgeBaseTab extends StatelessWidget {
  final int roleId;

  const KnowledgeBaseTab({super.key, required this.roleId});

  @override
  Widget build(BuildContext context) {
    return const BackendCapabilityUnavailable(
      featureName: 'Knowledge Base',
      explanation:
          'A role-specific Knowledge Base endpoint is not published in the current API contract.',
      contractRequirement:
          'Use Resources or Success Playbook for supported content, or publish Knowledge Base endpoints before enabling this tab.',
    );
  }
}
