import 'package:bomach_os/components/backend_capability_unavailable.dart';
import 'package:flutter/material.dart';

class SecurityCodes extends StatelessWidget {
  final bool isMobile;

  const SecurityCodes({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return const BackendCapabilityUnavailable(
      featureName: 'Security Codes',
      explanation:
          'Security-code registration, assignment, lifecycle, and revocation are not published in the current backend contract. No fabricated codes are shown.',
      contractRequirement:
          'Required contract: code CRUD, assignment, access type, status, expiry, and permission-controlled view/edit/delete actions.',
    );
  }
}
