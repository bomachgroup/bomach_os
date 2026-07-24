import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/targets_controller.dart';

class TargetsTab extends StatelessWidget {
  final int roleId;

  const TargetsTab({super.key, required this.roleId});

  @override
  Widget build(BuildContext context) {
    final tag = 'role_detail_$roleId';
    if (!Get.isRegistered<TargetsController>(tag: tag)) {
      Get.put(TargetsController(), tag: tag)
        ..scopedRoleId = roleId
        ..fetchTargets(roleId: roleId);
    }

    return GetBuilder<TargetsController>(
      tag: tag,
      builder: (ctrl) {
        return Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

        if (ctrl.targets.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.data, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text('No targets or OKRs defined for this role.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: ctrl.targets.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final t = ctrl.targets[index];
            final isOkr = t.type == TargetType.okr;
            final icon = isOkr ? Iconsax.ranking : Iconsax.chart;
            final color = isOkr ? AppColors.warning : AppColors.info;

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
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.title,
                                style: AppTextStyles.bodyMd
                                    .copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(t.subtitle,
                                style: AppTextStyles.bodySm
                                    .copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOkr
                              ? AppColors.warning.withValues(alpha: 0.1)
                              : AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(isOkr ? 'OKR' : 'KPI',
                            style: AppTextStyles.bodySm.copyWith(
                                color: color, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  if (t.progress != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (t.progress! / 100).clamp(0.0, 1.0),
                        backgroundColor: AppColors.borderSubtle,
                        color: t.progress! >= 80
                            ? AppColors.success
                            : t.progress! >= 50
                                ? AppColors.warning
                                : AppColors.danger,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${t.progress!.toStringAsFixed(0)}% complete',
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                  if (t.frequency != null && !isOkr) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Iconsax.calendar, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(t.frequency![0].toUpperCase() + t.frequency!.substring(1),
                            style: AppTextStyles.bodySm
                                .copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
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
