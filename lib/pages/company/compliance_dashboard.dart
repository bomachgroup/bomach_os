import 'package:bomach_os/components/coming_soon.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:flutter/material.dart';

class ComplianceDashboardPage extends StatelessWidget {
  const ComplianceDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      maxContentWidth: 1200,
      header: const PageHeader(
        title: 'Compliance Dashboard',
        subtitle: 'Role compliance and risk obligations overview',
      ),
      children: const [
        ComingSoonTab(featureName: 'Compliance Dashboard'),
      ],
    );
  }
}
