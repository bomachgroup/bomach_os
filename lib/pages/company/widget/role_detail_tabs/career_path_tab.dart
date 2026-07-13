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

    return GetBuilder<CareerPathController>(
      tag: 'career_${role.id}',
      init: CareerPathController()..fetchSteps(role.id),
      builder: (ctrl) {
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
                    'Define possible next roles and their criteria.',
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
          separatorBuilder: (_, __) => const SizedBox(height: 0),
          itemBuilder: (context, index) {
            if (index == ctrl.steps.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
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
                      child: Text(step.nextRoleName,
                          style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
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
                              currentRoleId: step.roleId,
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
                const SizedBox(height: 8),
                _buildCriteriaChips(step),
                const SizedBox(height: 8),
                if (step.requiredCertifications.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: step.requiredCertifications.map((cert) {
                      return Chip(
                        label: Text(cert, style: const TextStyle(fontSize: 11)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriteriaChips(CareerPathStep step) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        if (step.minYearsInRole != null)
          _chip(Iconsax.clock, '${step.minYearsInRole!.toStringAsFixed(0)} yrs', AppColors.warning),
        if (step.minKpiScore != null)
          _chip(Iconsax.chart, 'KPI ${step.minKpiScore!.toStringAsFixed(0)}+', AppColors.info),
        if (step.requiredCertifications.isNotEmpty)
          _chip(Iconsax.tick_circle, '${step.requiredCertifications.length} certs', AppColors.success),
      ],
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
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
        content: Text('Remove "${step.nextRoleName}" from the career path?'),
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
