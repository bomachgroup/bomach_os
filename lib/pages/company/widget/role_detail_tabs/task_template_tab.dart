import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/role_task_template_controller.dart';
import '../task_template_dialogs.dart';

class TaskTemplateTab extends StatelessWidget {
  final int roleId;

  const TaskTemplateTab({super.key, required this.roleId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RoleTaskTemplateController>(
      tag: 'role_detail_$roleId',
      init: RoleTaskTemplateController()
        ..scopedRoleId = roleId
        ..fetchTemplates(roleId: roleId),
      builder: (ctrl) {
        return Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

        if (ctrl.templates.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.task, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text('No task templates for this role.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: 16),
                  MyElevatedButton(
                    height: 40,
                    child: 'Add Task Template',
                    icon: const Icon(Iconsax.add, size: 16, color: AppColors.textOnPrimary),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => CreateEditTaskTemplateDialog(
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
          itemCount: ctrl.templates.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == ctrl.templates.length) {
              return Center(
                child: TextButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => CreateEditTaskTemplateDialog(
                        ctrl: ctrl, presetRoleId: roleId),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Task Template'),
                ),
              );
            }

            final t = ctrl.templates[index];
            final priorityColor = switch (t.priority) {
              'critical' => AppColors.danger,
              'high' => AppColors.warning,
              'low' => AppColors.textSecondary,
              _ => AppColors.primary,
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
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Iconsax.task, color: AppColors.info, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.taskName,
                                style: AppTextStyles.bodyMd
                                    .copyWith(fontWeight: FontWeight.w600)),
                            if (t.description != null && t.description!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(t.description!,
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
                              builder: (_) => CreateEditTaskTemplateDialog(
                                  ctrl: ctrl, template: t),
                            );
                          } else if (action == 'delete') {
                            ctrl.deleteTemplate(context, t.id!);
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
                          color: priorityColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(t.priority[0].toUpperCase() + t.priority.substring(1),
                            style: AppTextStyles.bodySm.copyWith(
                                color: priorityColor, fontSize: 11)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(t.frequency[0].toUpperCase() + t.frequency.substring(1),
                            style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.primary, fontSize: 11)),
                      ),
                      if (t.estimatedDuration > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('${t.estimatedDuration} min',
                              style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.textSecondary, fontSize: 11)),
                        ),
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
