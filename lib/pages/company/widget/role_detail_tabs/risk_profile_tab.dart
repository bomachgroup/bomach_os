import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/role_risk_controller.dart';
import '../risk_profile_dialog.dart';

class RiskProfileTab extends StatelessWidget {
  final int roleId;

  const RiskProfileTab({super.key, required this.roleId});

  @override
  Widget build(BuildContext context) {
    final tag = 'risk_$roleId';
    if (!Get.isRegistered<RoleRiskController>(tag: tag)) {
      Get.put(RoleRiskController(), tag: tag);
      Get.find<RoleRiskController>(tag: tag).fetchRiskProfiles(roleId);
    }

    return GetBuilder<RoleRiskController>(
      tag: tag,
      builder: (ctrl) {
        return Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

        final profiles = ctrl.riskProfiles;

        if (profiles.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.shield_cross, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text('No risk obligations defined for this role.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: 16),
                  MyElevatedButton(
                    height: 40,
                    child: 'Add Obligation',
                    icon: const Icon(Iconsax.add, size: 16, color: AppColors.textOnPrimary),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => CreateEditRiskProfileDialog(
                        ctrl: ctrl,
                        roleId: roleId,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: profiles.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == profiles.length) {
              return Center(
                child: TextButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => CreateEditRiskProfileDialog(
                      ctrl: ctrl,
                      roleId: roleId,
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Obligation'),
                ),
              );
            }

            final p = profiles[index];
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
                      color: _priorityColor(p.priority).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Iconsax.shield,
                        color: _priorityColor(p.priority), size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(p.obligation,
                                  style: AppTextStyles.bodyMd
                                      .copyWith(fontWeight: FontWeight.w600)),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Iconsax.more,
                                  size: 18, color: AppColors.textSecondary),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  showDialog(
                                    context: context,
                                    builder: (_) => CreateEditRiskProfileDialog(
                                      ctrl: ctrl,
                                      roleId: roleId,
                                      profile: p,
                                    ),
                                  );
                                } else if (value == 'delete') {
                                  _confirmDelete(context, ctrl, p);
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
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            _chip(p.category, AppColors.info),
                            _chip(p.priority, _priorityColor(p.priority)),
                            _statusChip(p.status),
                            if (p.deadline != null && p.deadline!.isNotEmpty)
                              _chip('Due: ${p.deadline}', AppColors.warning),
                          ],
                        ),
                        if (p.description != null && p.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(p.description!,
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.textSecondary)),
                          ),
                        if (p.assignedTo != null && p.assignedTo!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                const Icon(Iconsax.user, size: 14, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(p.assignedTo!,
                                    style: AppTextStyles.caption
                                        .copyWith(color: AppColors.textMuted)),
                              ],
                            ),
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

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical':
        return AppColors.danger;
      case 'high':
        return Colors.deepOrange;
      case 'medium':
        return AppColors.warning;
      case 'low':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'compliant':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'expired':
        return AppColors.danger;
      case 'at_risk':
        return Colors.deepOrange;
      case 'overdue':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _statusChip(String status) {
    final label = status.replaceAll('_', ' ').capitalizeFirst ?? status;
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w700)),
    );
  }

  void _confirmDelete(BuildContext context, RoleRiskController ctrl, dynamic profile) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Obligation'),
        content: Text('Remove "${profile.obligation}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctrl.deleteRiskProfile(profile.id);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
