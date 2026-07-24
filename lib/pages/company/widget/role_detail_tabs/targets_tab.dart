import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/targets_controller.dart';
import '../target_template_dialog.dart';

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
                    Text('No target templates defined for this role.',
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 8),
                    Text(
                      'Target templates define measurable goals assigned to role holders.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),
                    MyElevatedButton(
                      height: 40,
                      child: 'Add Target',
                      icon: const Icon(Iconsax.add, size: 16, color: AppColors.textOnPrimary),
                      onTap: () => _showDialog(context, ctrl),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: ctrl.targets.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == ctrl.targets.length) {
                return Center(
                  child: TextButton.icon(
                    onPressed: () => _showDialog(context, ctrl),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Target'),
                  ),
                );
              }

              final t = ctrl.targets[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Iconsax.data, color: AppColors.info, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(t.title,
                                    style: AppTextStyles.bodyMd
                                        .copyWith(fontWeight: FontWeight.w600)),
                              ),
                              if (!t.isActive)
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.textMuted.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('Inactive',
                                      style: TextStyle(
                                          fontSize: 10, color: AppColors.textMuted)),
                                ),
                              PopupMenuButton<String>(
                                icon: const Icon(Iconsax.more,
                                    size: 18, color: AppColors.textSecondary),
                                onSelected: (val) {
                                  if (val == 'edit') {
                                    _showDialog(context, ctrl, template: t);
                                  } else if (val == 'delete') {
                                    _confirmDelete(context, ctrl, t.id);
                                  }
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete',
                                        style: TextStyle(color: AppColors.danger)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (t.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(t.description,
                                style: AppTextStyles.bodySm
                                    .copyWith(color: AppColors.textSecondary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                          ],
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              _chip(Iconsax.arrow_up, t.targetDisplay, AppColors.success),
                              _chip(Iconsax.calendar, t.periodDisplay, AppColors.primary),
                            ],
                          ),
                        ],
                      ),
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

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showDialog(BuildContext context, TargetsController ctrl,
      {dynamic template}) {
    showDialog(
      context: context,
      builder: (_) => CreateEditTargetTemplateDialog(
        ctrl: ctrl,
        roleId: roleId,
        template: template,
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, TargetsController ctrl, int templateId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Target'),
        content: const Text('Remove this target template from the role?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctrl.deleteTarget(context, roleId, templateId);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
