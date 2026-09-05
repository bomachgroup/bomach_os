import 'package:bomach_os/components/backend_capability_unavailable.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:flutter/material.dart';

class CompanyKnowledgeBasePage extends StatelessWidget {
  const CompanyKnowledgeBasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      header: PageHeader(
        title: 'Knowledge Base',
        subtitle: 'Cross-role documents, templates, and references.',
      ),
      children: [
        BackendCapabilityUnavailable(
          featureName: 'Knowledge Base',
          explanation:
              'No company Knowledge Base endpoint is published in the current API contract.',
          contractRequirement:
              'Use role resources and the Success Playbook when applicable, or publish Knowledge Base endpoints before implementing this screen.',
        ),
      ],
    );
  }
}
