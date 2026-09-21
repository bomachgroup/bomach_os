import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/src/app_routes/app_route_constants.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
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
    return PageScaffold(
      children: [
        const Column(
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
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900
                ? 4
                : constraints.maxWidth >= 560
                    ? 2
                    : 1;
            const gap = 16.0;
            final cardWidth = columns == 1
                ? constraints.maxWidth
                : (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _buildModuleCard(
                    context,
                    title: 'Employee Directory',
                    description: 'View and manage all employees',
                    icon: Iconsax.people,
                    onTap: () => context.go(RouteConstants.employeeDirectory),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildModuleCard(
                    context,
                    title: 'Performance Reviews',
                    description: 'Track employee performance',
                    icon: Iconsax.chart_21,
                    onTap: () => context.go(RouteConstants.employeePerformance),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildModuleCard(
                    context,
                    title: 'Attendance',
                    description: 'Monitor attendance records',
                    icon: Iconsax.calendar_1,
                    onTap: () => context.go(RouteConstants.employeeAttendance),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildModuleCard(
                    context,
                    title: 'Training',
                    description: 'Employee training programs',
                    icon: Iconsax.teacher,
                    onTap: () => context.go(RouteConstants.employeeTraining),
                  ),
                ),
              ],
            );
          },
        ),
      ],
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
