import 'package:bomach_os/components/coming_soon.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:flutter/material.dart';

class AuthorityLimitsPage extends StatelessWidget {
  const AuthorityLimitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      maxContentWidth: 1440,
      header: const PageHeader(
        title: 'Authority Limits',
        subtitle: 'Define approval authority limits across roles and resources',
      ),
      children: const [
        ComingSoonTab(featureName: 'Authority Limits'),
      ],
    );
  }
}
