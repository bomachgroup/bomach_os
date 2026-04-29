import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ProjectAssociate extends StatelessWidget {
  const ProjectAssociate({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Project Associates', style: AppTextStyles.h3),
        SizedBox(height: 4),
        Text(
          'External partners and associates connected to this project.',
          style: AppTextStyles.bodySm,
        ),
        SizedBox(height: 20),
        EmptyState(
          icon: Iconsax.people,
          title: 'No associates',
          subtitle: 'Associates linked to this project will appear here.',
        ),
      ],
    );
  }
}
