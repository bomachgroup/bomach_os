import 'package:bms_front_end/components/text/my_text.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

class EmployeeAttendancePage extends StatefulWidget {
  const EmployeeAttendancePage({super.key});

  @override
  State<EmployeeAttendancePage> createState() => _EmployeeAttendancePageState();
}

class _EmployeeAttendancePageState extends State<EmployeeAttendancePage> {
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
                  'Attendance Management',
                  style: AppText.displayLg,
                ),
                SizedBox(height: 8),
                MyText(
                  'Monitor and manage employee attendance records',
                  style: AppText.h4,
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
                      Iconsax.calendar_1,
                      size: 48,
                      color: AppColors.neutral300,
                    ),
                    SizedBox(height: 16),
                    MyText(
                      'No attendance records found',
                      style: AppText.bodyMd,
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
