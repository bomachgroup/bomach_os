import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/career_path_model.dart';
import 'package:bomach_os/src/model/role_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/career_path_controller.dart';
import '../../controllers/roles_controller.dart';
import '../career_path_step_dialog.dart';

class CareerPathTab extends StatelessWidget {
  final Role role;

  const CareerPathTab({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final rolesCtrl = Get.find<RolesController>();

    final tag = 'career_${role.id}';
    if (!Get.isRegistered<CareerPathController>(tag: tag)) {
      Get.put(CareerPathController(), tag: tag).fetchSteps(role.id);
    }

    return GetBuilder<CareerPathController>(
      tag: tag,
      builder: (ctrl) {
        return Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ctrl.steps.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.map, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text('No career path defined for this role.',
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 8),
                    Text(
                      'Define possible next roles and their transition criteria.',
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),
                    MyElevatedButton(
                      height: 40,
                      child: 'Add Career Step',
                      icon: const Icon(Iconsax.add, size: 16, color: AppColors.textOnPrimary),
                      onTap: () => _openAddDialog(context, ctrl, rolesCtrl),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: ctrl.steps.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == ctrl.steps.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Center(
                    child: TextButton.icon(
                      onPressed: () => _openAddDialog(context, ctrl, rolesCtrl),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Career Step'),
                    ),
                  ),
                );
              }

              final step = ctrl.steps[index];
              return _buildStepCard(context, ctrl, step, rolesCtrl);
            },
          );
        });
      },
    );
  }

  void _openAddDialog(
      BuildContext context, CareerPathController ctrl, RolesController rolesCtrl) {
    showDialog(
      context: context,
      builder: (_) => CreateEditCareerPathStepDialog(
        ctrl: ctrl,
        roles: rolesCtrl.roles,
        currentRoleId: role.id,
      ),
    );
  }

  Widget _buildStepCard(BuildContext context, CareerPathController ctrl,
      CareerPathStep step, RolesController rolesCtrl) {
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
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Iconsax.arrow_right, color: AppColors.success, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        step.toRoleName.isNotEmpty ? step.toRoleName : 'Role #${step.toRoleId}',
                        style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Iconsax.more, size: 18, color: AppColors.textSecondary),
                      onSelected: (value) {
                        if (value == 'edit') {
                          showDialog(
                            context: context,
                            builder: (_) => CreateEditCareerPathStepDialog(
                              ctrl: ctrl,
                              roles: rolesCtrl.roles,
                              currentRoleId: step.fromRoleId,
                              step: step,
                            ),
                          );
                        } else if (value == 'delete') {
                          _confirmDelete(context, ctrl, step);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete', style: TextStyle(color: AppColors.danger))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _buildMetaRow(step),
                if (step.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    step.description,
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (step.requirements.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Iconsax.tick_circle, size: 13, color: AppColors.success),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          step.requirements,
                          style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(CareerPathStep step) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _chip(
          Iconsax.ranking,
          'Step ${step.sequence}',
          AppColors.primary,
        ),
        if (step.estimatedDurationMonths != null)
          _chip(
            Iconsax.clock,
            '~${step.estimatedDurationMonths}mo',
            AppColors.warning,
          ),
        _chip(
          step.isActive ? Iconsax.tick_circle : Iconsax.close_circle,
          step.isActive ? 'Active' : 'Inactive',
          step.isActive ? AppColors.success : AppColors.textMuted,
        ),
      ],
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

  void _confirmDelete(
      BuildContext context, CareerPathController ctrl, CareerPathStep step) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Step'),
        content: Text(
          'Remove "${step.toRoleName.isNotEmpty ? step.toRoleName : 'this career step'}" from the path?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctrl.deleteStep(step.id);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
