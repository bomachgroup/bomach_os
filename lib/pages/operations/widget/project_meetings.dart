import 'package:bms_front_end/components/text/my_text.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

class ProjectMeetings extends StatelessWidget {
  const ProjectMeetings({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      decoration: BoxDecoration(
        border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.calendar_1, size: 64, color: AppColors.neutral500),
            SizedBox(height: 16),
            MyText('No Meetings', size: 18, weight: 600),
            SizedBox(height: 8),
            MyText(
              'Meetings scheduled for this project will appear here.',
              size: 14,
              color: AppColors.neutral500,
            ),
          ],
        ),
      ),
    );
  }
}
