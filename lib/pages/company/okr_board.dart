import 'package:bomach_os/components/coming_soon.dart';
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
        subtitle: 'Track Objectives and Key Results across role templates.',
      ),
      children: [
        ComingSoonTab(featureName: 'OKR Board'),
      ],
    );
  }
}
