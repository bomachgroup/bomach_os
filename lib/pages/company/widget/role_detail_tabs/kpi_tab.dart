import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/permission/permission_gate.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/role_kpi_controller.dart';
import '../kpi_dialogs.dart';

class KpiTab extends StatelessWidget {
  final int roleId;
  final bool readOnly;

  const KpiTab({super.key, required this.roleId, this.readOnly = false});

  String _fmt(String s) => s == 'yearly'
      ? 'Annual'
      : s
          .split('_')
          .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
          .join(' ');

  @override
  Widget build(BuildContext context) {
    if (!Get.find<PermissionService>().has(Perms.roleKpisList)) {
      return const Center(child: Text('You do not have access to role KPIs.'));
    }
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
          if (ctrl.isLoading.value && ctrl.kpis.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ctrl.errorMessage.value.isNotEmpty && ctrl.kpis.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(ctrl.errorMessage.value),
                  TextButton.icon(
                    onPressed: () => ctrl.fetchKpis(
                      refresh: true,
                      roleId: roleId,
                    ),
                    icon: const Icon(Iconsax.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          final roleKpis = ctrl.kpis.where((k) => k.roleId == roleId).toList();

          if (roleKpis.isEmpty) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (ctrl.isRefreshing.value)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Updating KPIs...'),
                      ],
                    ),
                  ),
                Center(
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
                        if (!readOnly)
                          PermissionGate(
                            allOf: const [Perms.roleKpisCreate, Perms.kpisList],
                            child: MyElevatedButton(
                              height: 40,
                              child: 'Add KPI',
                              icon: const Icon(Iconsax.add,
                                  size: 16, color: AppColors.textOnPrimary),
                              onTap: () => showKpiEditorDialog(context,
                                  ctrl: ctrl, presetRoleId: roleId),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              if (ctrl.isRefreshing.value || ctrl.errorMessage.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Row(
                    children: [
                      if (ctrl.isRefreshing.value) ...[
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        const Text('Updating KPIs...'),
                      ],
                      if (ctrl.errorMessage.value.isNotEmpty) ...[
                        Expanded(
                          child: Text(
                            ctrl.errorMessage.value,
                            style: const TextStyle(color: AppColors.danger),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => ctrl.fetchKpis(roleId: roleId),
                          icon: const Icon(Iconsax.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ],
                  ),
                ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                itemCount: roleKpis.length + (readOnly ? 0 : 1),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (!readOnly && index == roleKpis.length) {
                    return Center(
                      child: PermissionGate(
                        allOf: const [Perms.roleKpisCreate, Perms.kpisList],
                        child: TextButton.icon(
                          onPressed: () => showKpiEditorDialog(context,
                              ctrl: ctrl, presetRoleId: roleId),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add KPI'),
                        ),
                      ),
                    );
                  }

                  final k = roleKpis[index];
                  final name = k.metric?.name ?? '';
                  final unit = k.metric?.unit ?? '';
                  final permissions = Get.find<PermissionService>();
                  final canEditKpi = permissions.hasAll([
                    Perms.roleKpisUpdate,
                    Perms.kpisList,
                  ]);
                  final canDeleteKpi = permissions.has(Perms.roleKpisDelete);
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
                        if (!readOnly && (canEditKpi || canDeleteKpi))
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert,
                                size: 18, color: AppColors.textMuted),
                            onSelected: (val) {
                              if (val == 'edit') {
                                showKpiEditorDialog(
                                  context,
                                  ctrl: ctrl,
                                  kpi: k,
                                  presetRoleId: roleId,
                                );
                              } else if (val == 'delete' && k.id != null) {
                                _showDeleteConfirm(
                                    context, ctrl, roleId, k.id!);
                              }
                            },
                            itemBuilder: (_) => [
                              if (canEditKpi)
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Iconsax.edit,
                                          size: 16,
                                          color: AppColors.textPrimary),
                                      SizedBox(width: 8),
                                      Text('Edit KPI'),
                                    ],
                                  ),
                                ),
                              if (canDeleteKpi)
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Iconsax.trash,
                                          size: 16, color: AppColors.danger),
                                      SizedBox(width: 8),
                                      Text('Remove from role',
                                          style: TextStyle(
                                              color: AppColors.danger)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        });
      },
    );
  }

  void _showDeleteConfirm(
      BuildContext context, RoleKpiController ctrl, int roleId, int kpiId) {
    final kpi = ctrl.kpis.firstWhereOrNull((item) => item.id == kpiId);
    showRemoveKpiConfirmation(
      context,
      ctrl: ctrl,
      roleId: roleId,
      id: kpiId,
      metricName: kpi?.metric?.name ?? 'this KPI',
    );
  }
}
