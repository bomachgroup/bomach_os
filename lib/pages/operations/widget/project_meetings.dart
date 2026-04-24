import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ProjectMeetings extends StatelessWidget {
  const ProjectMeetings({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Project Meetings', style: AppTextStyles.h3),
        SizedBox(height: 4),
        Text(
          'Track meetings, minutes, and attendees for this project.',
          style: AppTextStyles.bodySm,
        ),
        SizedBox(height: 20),
        EmptyState(
          icon: Iconsax.calendar_1,
          title: 'No meetings scheduled',
          subtitle: 'Meetings scheduled for this project will appear here.',
        ),
      ],
    );
  }
}
