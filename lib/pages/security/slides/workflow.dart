import 'package:bomach_os/components/backend_capability_unavailable.dart';
import 'package:flutter/material.dart';

class Workflows extends StatelessWidget {
  final bool isMobile;

  const Workflows({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return const BackendCapabilityUnavailable(
      featureName: 'Security Workflows',
      explanation:
          'Use the supported Approval Workflow page for approval-flow management. This legacy security tab no longer renders local workflow records.',
      contractRequirement:
          'Supported API: approval flows, approval requests, queue, approve, and reject actions.',
    );
  }
}
