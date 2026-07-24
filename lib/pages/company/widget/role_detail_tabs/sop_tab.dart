import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/role_sop_controller.dart';
import '../sop_dialog.dart';

class SopTab extends StatelessWidget {
  final int roleId;

  const SopTab({super.key, required this.roleId});

  @override
  Widget build(BuildContext context) {
    final tag = 'role_detail_$roleId';
    if (!Get.isRegistered<RoleSopController>(tag: tag)) {
      Get.put(RoleSopController(), tag: tag)
        ..scopedRoleId = roleId
        ..fetchSops(roleId: roleId);
    }

    return GetBuilder<RoleSopController>(
      tag: tag,
      builder: (ctrl) {
        return Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ctrl.sops.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.document_text, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text('No standard operating procedures linked to this role.',
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 16),
                    MyElevatedButton(
                      height: 40,
                      child: 'Link SOP',
                      icon: const Icon(Iconsax.add, size: 16, color: AppColors.textOnPrimary),
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => CreateEditSopDialog(ctrl: ctrl, presetRoleId: roleId),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: ctrl.sops.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == ctrl.sops.length) {
                return Center(
                  child: TextButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => CreateEditSopDialog(ctrl: ctrl, presetRoleId: roleId),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Link SOP'),
                  ),
                );
              }

              final s = ctrl.sops[index];
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
                          child: const Icon(Iconsax.document_text, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      s.title.isNotEmpty ? s.title : 'SOP #${s.sopId}',
                                      style: AppTextStyles.bodyMd
                                          .copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (s.isActive ? AppColors.success : AppColors.textMuted)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(s.isActive ? 'Active' : 'Inactive',
                                        style: AppTextStyles.caption.copyWith(
                                            color: s.isActive ? AppColors.success : AppColors.textMuted,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                              if (s.description.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(s.description,
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
                                builder: (_) => CreateEditSopDialog(ctrl: ctrl, sop: s),
                              );
                            } else if (action == 'delete') {
                              ctrl.deleteSop(context, s.id);
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit Link')),
                            const PopupMenuItem(
                                value: 'delete',
                                child: Text('Remove Link',
                                    style: TextStyle(color: AppColors.danger))),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _chip(Iconsax.info_circle, 'Version: ${s.version}', AppColors.info),
                        _chip(Iconsax.flag, 'Priority: ${s.priority}', AppColors.warning),
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
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
