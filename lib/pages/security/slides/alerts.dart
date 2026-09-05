import 'package:bomach_os/components/backend_capability_unavailable.dart';
import 'package:flutter/material.dart';

class SecurityAlerts extends StatelessWidget {
  final bool isMobile;

  const SecurityAlerts({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return const BackendCapabilityUnavailable(
      featureName: 'Security Alerts',
      explanation:
          'Security-alert detection, triage, assignment, and resolution are not published in the current backend contract. No fabricated alerts are shown.',
      contractRequirement:
          'Required contract: alert records, priority, type, affected systems, assignee, lifecycle status, timestamps, and review actions.',
    );
  }
}
