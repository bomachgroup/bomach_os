import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
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
                  'Employee Management',
                  style: AppTextStyles.displayLg,
                ),
                SizedBox(height: 8),
                MyText(
                  'Manage and track employee information',
                  style: AppTextStyles.h4,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildModuleCard(
                  context,
                  title: 'Employee Directory',
                  description: 'View and manage all employees',
                  icon: Iconsax.people,
                  onTap: () {
                    context.go(RouteConstants.employeeDirectory);
                  },
                ),
                _buildModuleCard(
                  context,
                  title: 'Performance Reviews',
                  description: 'Track employee performance',
                  icon: Iconsax.chart_21,
                  onTap: () {
                    context.go(RouteConstants.employeePerformance);
                  },
                ),
                _buildModuleCard(
                  context,
                  title: 'Attendance',
                  description: 'Monitor attendance records',
                  icon: Iconsax.calendar_1,
                  onTap: () {
                    context.go(RouteConstants.employeeAttendance);
                  },
                ),
                _buildModuleCard(
                  context,
                  title: 'Training',
                  description: 'Employee training programs',
                  icon: Iconsax.teacher,
                  onTap: () {
                    context.go(RouteConstants.employeeTraining);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 280,
        minWidth: 180,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.primary),
            const SizedBox(height: 16),
            MyText(
              title,
              style: AppTextStyles.h4,
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            MyText(
              description,
              style: AppTextStyles.bodyMd,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: MyElevatedButton(
                child: 'Open',
                onTap: onTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
