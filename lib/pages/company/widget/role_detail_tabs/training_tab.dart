import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../controllers/training_controller.dart';

class TrainingTab extends StatelessWidget {
  final int roleId;

  const TrainingTab({super.key, required this.roleId});

  @override
  Widget build(BuildContext context) {
    final tag = 'role_detail_$roleId';
    if (!Get.isRegistered<TrainingController>(tag: tag)) {
      Get.put(TrainingController(), tag: tag)
        ..scopedRoleId = roleId
        ..fetchPrograms(roleId: roleId);
    }

    return GetBuilder<TrainingController>(
      tag: tag,
      builder: (ctrl) {
        return Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

        if (ctrl.programs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.book, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text('No training programs assigned to this role.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: ctrl.programs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final p = ctrl.programs[index];

            final statusColor = switch (p.status) {
              'completed' => AppColors.success,
              'in_progress' || 'ongoing' => AppColors.info,
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
                        child: const Icon(Iconsax.book, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(p.programName,
                                      style: AppTextStyles.bodyMd
                                          .copyWith(fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            if (p.provider.isNotEmpty)
                              Text(p.provider,
                                  style: AppTextStyles.bodySm
                                      .copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      if (p.isMandatory)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('Mandatory',
                              style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.danger, fontSize: 11)),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(p.status[0].toUpperCase() + p.status.substring(1),
                            style: AppTextStyles.bodySm.copyWith(
                                color: statusColor, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  if (p.description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(p.description,
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (p.startDate != null) ...[
                        const Icon(Iconsax.calendar, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(DateFormat('MMM dd').format(p.startDate!),
                            style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(width: 16),
                      ],
                      if (p.durationDays > 0) ...[
                        const Icon(Iconsax.clock, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text('${p.durationDays} days',
                            style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(width: 16),
                      ],
                      if (p.cost > 0) ...[
                        const Icon(Iconsax.money, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text('₦${NumberFormat('#,##0').format(p.cost)}',
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
