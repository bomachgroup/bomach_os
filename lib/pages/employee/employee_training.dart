import 'package:bms_front_end/components/text/my_text.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

class EmployeeTrainingPage extends StatefulWidget {
  const EmployeeTrainingPage({super.key});

  @override
  State<EmployeeTrainingPage> createState() => _EmployeeTrainingPageState();
}

class _EmployeeTrainingPageState extends State<EmployeeTrainingPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  'Training Programs',
                  style: AppTextStyles.displayLg,
                ),
                SizedBox(height: 8),
                MyText(
                  'Manage employee training and development programs',
                  style: AppTextStyles.h4,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.neutral200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.teacher,
                      size: 48,
                      color: AppColors.neutral300,
                    ),
                    SizedBox(height: 16),
                    MyText(
                      'No training programs found',
                      style: AppTextStyles.bodyMd,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
