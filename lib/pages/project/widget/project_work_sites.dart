import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';

class ProjectWorkSite extends StatelessWidget {
  const ProjectWorkSite({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      width: 319,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText("Swissgarden plaza", size: 24, weight: 500),
          MyText("Enugu", size: 16, weight: 400),
          kSizedBox,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText("10", size: 32, weight: 500),
                  MyText("Employees", size: 18, weight: 300),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText("10", size: 32, weight: 500),
                  MyText("Work materials", size: 18, weight: 300),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
