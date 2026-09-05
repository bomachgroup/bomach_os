import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/permission/permission_gate.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/role_kpi_controller.dart';
import '../kpi_dialogs.dart';

class KpiTab extends StatelessWidget {
  final int roleId;

  const KpiTab({super.key, required this.roleId});

  String _fmt(String s) =>
      s.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');

  @override
  Widget build(BuildContext context) {
    final tag = 'role_detail_$roleId';
    if (!Get.isRegistered<RoleKpiController>(tag: tag)) {
      Get.put(RoleKpiController(), tag: tag)
        ..scopedRoleId = roleId
        ..fetchKpis(roleId: roleId);
    }

    return GetBuilder<RoleKpiController>(
      tag: tag,
      builder: (ctrl) {
        return Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final roleKpis = ctrl.kpis.where((k) => k.roleId == roleId).toList();

          if (roleKpis.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.chart,
                        size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text('No KPIs defined for this role.',
                        style: AppTextStyles.bodyMd
                            .copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 16),
                    PermissionGate(
                      require: Perms.rolesUpdate,
                      child: MyElevatedButton(
                        height: 40,
                        child: 'Add KPI',
                        icon: const Icon(Iconsax.add,
                            size: 16, color: AppColors.textOnPrimary),
                        onTap: () => showDialog(
                          context: context,
                          builder: (_) => CreateEditKpiDialog(
                              ctrl: ctrl, presetRoleId: roleId),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            itemCount: roleKpis.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == roleKpis.length) {
                return Center(
                  child: PermissionGate(
                    require: Perms.rolesUpdate,
                    child: TextButton.icon(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => CreateEditKpiDialog(
                            ctrl: ctrl, presetRoleId: roleId),
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add KPI'),
                    ),
                  ),
                );
              }

              final k = roleKpis[index];
              final name = k.metric?.name ?? '';
              final unit = k.metric?.unit ?? '';
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
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Iconsax.chart,
                          color: AppColors.info, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: AppTextStyles.bodyMd
                                  .copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            '${_fmt(k.period)} · ${_fmt(k.trackingMode)}'
                            '${k.targetValue != null ? " · Target: ${k.targetValue!.toStringAsFixed(k.targetValue! % 1 == 0 ? 0 : 1)} $unit" : ""}'
                            '${k.weight != null ? " · Weight: ${k.weight!.toStringAsFixed(k.weight! % 1 == 0 ? 0 : 1)}" : ""}',
                            style: AppTextStyles.bodySm
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    PermissionGate(
                      require: Perms.rolesUpdate,
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert,
                            size: 18, color: AppColors.textMuted),
                        onSelected: (val) {
                          if (val == 'edit') {
                            showDialog(
                              context: context,
                              builder: (_) => CreateEditKpiDialog(
                                ctrl: ctrl,
                                kpi: k,
                                presetRoleId: roleId,
                              ),
                            );
                          } else if (val == 'delete' && k.id != null) {
                            _showDeleteConfirm(context, ctrl, k.id!);
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Iconsax.edit,
                                    size: 16, color: AppColors.textPrimary),
                                SizedBox(width: 8),
                                Text('Edit KPI'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Iconsax.trash,
                                    size: 16, color: AppColors.danger),
                                SizedBox(width: 8),
                                Text('Delete KPI',
                                    style: TextStyle(color: AppColors.danger)),
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

  void _showDeleteConfirm(
      BuildContext context, RoleKpiController ctrl, int kpiId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete KPI'),
        content: const Text('Are you sure you want to delete this KPI?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              await ctrl.deleteKpi(kpiId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
