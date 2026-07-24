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
                    Text('No success playbook items for this role.',
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 16),
                    MyElevatedButton(
                      height: 40,
                      child: 'Add Playbook Item',
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
                    label: const Text('Add Playbook Item'),
                  ),
                );
              }

              final p = ctrl.playbooks[index];
              final kindColor = switch (p.kind) {
                'common_mistake' => AppColors.danger,
                'winning_strategy' => AppColors.success,
                'lesson_learned' => AppColors.info,
                _ => AppColors.primary,
              };

              final kindLabel = switch (p.kind) {
                'common_mistake' => 'Common Mistake',
                'winning_strategy' => 'Winning Strategy',
                'lesson_learned' => 'Lesson Learned',
                _ => 'Best Practice',
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
                            color: kindColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Iconsax.book, color: kindColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.title,
                                  style: AppTextStyles.bodyMd
                                      .copyWith(fontWeight: FontWeight.w600)),
                              if (p.description.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(p.description,
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
                              ctrl.deletePlaybook(context, p.id);
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: kindColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(kindLabel,
                              style: AppTextStyles.bodySm.copyWith(
                                  color: kindColor, fontSize: 11)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('Seq: ${p.sequence}',
                              style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.primary, fontSize: 11)),
                        ),
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
