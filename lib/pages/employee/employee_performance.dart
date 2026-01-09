import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

class EmployeePerformancePage extends StatefulWidget {
  const EmployeePerformancePage({super.key});

  @override
  State<EmployeePerformancePage> createState() =>
      _EmployeePerformancePageState();
}

class _EmployeePerformancePageState extends State<EmployeePerformancePage> {
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
                  'Performance Reviews',
                  style: AppText.black_600_32,
                ),
                SizedBox(height: 8),
                MyText(
                  'Track and manage employee performance reviews',
                  style: AppText.black_600_14,
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
                border: Border.all(color: AppColors.grey7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assessment_outlined,
                      size: 48,
                      color: AppColors.grey4,
                    ),
                    SizedBox(height: 16),
                    MyText(
                      'No performance reviews found',
                      style: AppText.black_400_14,
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
