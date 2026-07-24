import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/role_okr_controller.dart';
import '../okr_dialogs.dart';

class OkrTab extends StatelessWidget {
  final int roleId;

  const OkrTab({super.key, required this.roleId});

  @override
  Widget build(BuildContext context) {
    final tag = 'role_detail_okr_$roleId';
    if (!Get.isRegistered<RoleOkrController>(tag: tag)) {
      Get.put(RoleOkrController(), tag: tag)
        ..scopedRoleId = roleId
        ..fetchOkrs(roleId: roleId);
    }

    return GetBuilder<RoleOkrController>(
      tag: tag,
      builder: (ctrl) {
        final roleOkrs = ctrl.okrs.where((o) => o.roleId == roleId).toList();

        if (roleOkrs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.activity, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text('No OKRs defined for this role.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: 16),
                  MyElevatedButton(
                    height: 40,
                    child: 'Add OKR',
                    icon: const Icon(Iconsax.add, size: 16, color: AppColors.textOnPrimary),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => CreateEditOkrDialog(ctrl: ctrl, presetRoleId: roleId),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: roleOkrs.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == roleOkrs.length) {
              return Center(
                child: TextButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => CreateEditOkrDialog(ctrl: ctrl, presetRoleId: roleId),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add OKR'),
                ),
              );
            }

            final o = roleOkrs[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: o.overallProgress >= 80
                          ? Colors.green.withValues(alpha: 0.1)
                          : o.overallProgress >= 50
                              ? Colors.amber.withValues(alpha: 0.1)
                              : AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Iconsax.activity, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(o.objective,
                            style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          'Q${o.quarter} ${o.year} · ${o.keyResults.length} KRs · ${o.overallProgress.toStringAsFixed(0)}% complete',
                          style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
