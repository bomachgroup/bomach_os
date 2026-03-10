import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

class ProjectAssociate extends StatelessWidget {
  const ProjectAssociate({super.key});

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
            Icon(Icons.people_outline, size: 64, color: AppColors.grey1),
            SizedBox(height: 16),
            MyText('No Associates', size: 18, weight: 600),
            SizedBox(height: 8),
            MyText(
              'Associates linked to this project will appear here.',
              size: 14,
              color: AppColors.grey1,
            ),
          ],
        ),
      ),
    );
  }
}
