import 'package:bomach_os/components/backend_capability_unavailable.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:flutter/material.dart';

class OkrBoardPage extends StatelessWidget {
  const OkrBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      header: PageHeader(
        title: 'OKR Board',
        subtitle: 'Track objectives and key results across the company.',
      ),
      children: [
        BackendCapabilityUnavailable(
          featureName: 'OKR Board',
          explanation:
              'The published API does not currently expose company or role OKR endpoints.',
          contractRequirement:
              'Backend contract needed: objective, key result, owner, period, progress, status, and approval/review actions.',
        ),
      ],
    );
  }
}
