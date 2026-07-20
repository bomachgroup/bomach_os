import 'package:bomach_os/components/coming_soon.dart';
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
        subtitle: 'Cross-role documents, templates, and references',
      ),
      children: [
        ComingSoonTab(featureName: 'Knowledge Base'),
      ],
    );
  }
}
