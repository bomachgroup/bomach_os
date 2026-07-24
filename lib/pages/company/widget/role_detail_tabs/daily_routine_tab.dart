import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../controllers/daily_routine_controller.dart';

class DailyRoutineTab extends StatelessWidget {
  final int roleId;

  const DailyRoutineTab({super.key, required this.roleId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DailyRoutineController>(
      tag: 'role_detail_$roleId',
      init: DailyRoutineController()
        ..scopedRoleId = roleId
        ..fetchData(roleId: roleId),
      builder: (ctrl) {
        return Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

        if (ctrl.employees.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.clock, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text('No employees assigned to this role.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: 16),
                  MyElevatedButton(
                    height: 40,
                    child: 'View HR Module',
                    icon: const Icon(Iconsax.arrow_right, size: 16, color: AppColors.textOnPrimary),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          );
        }

        if (ctrl.workReports.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.document, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text('No work reports found for this role\'s employees.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: ctrl.workReports.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final wr = ctrl.workReports[index];
            final emp = ctrl.employees.firstWhereOrNull(
                (e) => e.id == wr.employeeId.toString());

            final statusColor = switch (wr.status) {
              'approved' => AppColors.success,
              'submitted' => AppColors.info,
              'rejected' => AppColors.danger,
              _ => AppColors.warning,
            };

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Iconsax.profile_2user, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(emp?.fullName ?? 'Employee #${wr.employeeId}',
                                style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                            if (wr.day != null)
                              Text(DateFormat('MMM dd, yyyy').format(wr.day!),
                                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(wr.status[0].toUpperCase() + wr.status.substring(1),
                            style: AppTextStyles.bodySm.copyWith(
                                color: statusColor, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (wr.workActivities != null && wr.workActivities!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Iconsax.activity, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(wr.workActivities!,
                                style: AppTextStyles.bodySm.copyWith(color: AppColors.textPrimary)),
                          ),
                        ],
                      ),
                    ),
                  if (wr.hoursWorked > 0)
                    Row(
                      children: [
                        const Icon(Iconsax.clock, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text('${wr.hoursWorked}h worked',
                            style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
                        if (wr.operationalBase != null) ...[
                          const SizedBox(width: 16),
                          const Icon(Iconsax.location, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(wr.operationalBase!,
                              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
                        ],
                      ],
                    ),
                ],
              ),
            );
          },
        );
      });
    },
  );
}
}
