import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/role_success_playbook_controller.dart';
import '../success_playbook_dialog.dart';

class SuccessPlaybookTab extends StatelessWidget {
  final int roleId;

  const SuccessPlaybookTab({super.key, required this.roleId});

  @override
  Widget build(BuildContext context) {
    final tag = 'role_detail_$roleId';
    if (!Get.isRegistered<RoleSuccessPlaybookController>(tag: tag)) {
      Get.put(RoleSuccessPlaybookController(), tag: tag)
        ..scopedRoleId = roleId
        ..fetchPlaybooks(roleId: roleId);
    }

    return GetBuilder<RoleSuccessPlaybookController>(
      tag: tag,
      builder: (ctrl) {
        return Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

        if (ctrl.playbooks.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.book, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text('No success playbooks for this role.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: 16),
                  MyElevatedButton(
                    height: 40,
                    child: 'Add Success Playbook',
                    icon: const Icon(Iconsax.add, size: 16, color: AppColors.textOnPrimary),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => CreateEditSuccessPlaybookDialog(
                          ctrl: ctrl, presetRoleId: roleId),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: ctrl.playbooks.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == ctrl.playbooks.length) {
              return Center(
                child: TextButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => CreateEditSuccessPlaybookDialog(
                        ctrl: ctrl, presetRoleId: roleId),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Success Playbook'),
                ),
              );
            }

            final p = ctrl.playbooks[index];
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
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Iconsax.book, color: AppColors.success, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.title,
                                style: AppTextStyles.bodyMd
                                    .copyWith(fontWeight: FontWeight.w600)),
                            if (p.description != null && p.description!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(p.description!,
                                    style: AppTextStyles.bodySm
                                        .copyWith(color: AppColors.textSecondary)),
                              ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (action) {
                          if (action == 'edit') {
                            showDialog(
                              context: context,
                              builder: (_) => CreateEditSuccessPlaybookDialog(
                                  ctrl: ctrl, playbook: p),
                            );
                          } else if (action == 'delete') {
                            ctrl.deletePlaybook(context, p.id!);
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete',
                                  style: TextStyle(color: AppColors.danger))),
                        ],
                      ),
                    ],
                  ),
                  if (p.phases.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...p.phases.map((phase) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('Phase ${phase.order + 1}',
                                  style: AppTextStyles.caption.copyWith(
                                      color: AppColors.success, fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 8),
                            Text(phase.phaseName,
                                style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600)),
                          ]),
                          if (phase.description != null && phase.description!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(phase.description!,
                                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                            ),
                          if (phase.steps.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            ...phase.steps.map((step) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${step.stepNumber}.',
                                      style: AppTextStyles.caption.copyWith(
                                          color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(step.title,
                                            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500)),
                                        if (step.description != null && step.description!.isNotEmpty)
                                          Text(step.description!,
                                              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ],
                      ),
                    )),
                  ],
                  if (p.metrics.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(spacing: 6, runSpacing: 4, children: [
                      ...p.metrics.map((m) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(m,
                            style: AppTextStyles.bodySm.copyWith(color: AppColors.info, fontSize: 11)),
                      )),
                    ]),
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
