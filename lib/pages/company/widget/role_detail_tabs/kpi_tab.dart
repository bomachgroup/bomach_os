import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/src/constants/colors.dart';
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
        final roleKpis = ctrl.kpis.where((k) => k.roleId == roleId).toList();

        if (roleKpis.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.chart, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text('No KPIs defined for this role.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: 16),
                  MyElevatedButton(
                    height: 40,
                    child: 'Add KPI',
                    icon: const Icon(Iconsax.add, size: 16, color: AppColors.textOnPrimary),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => CreateEditKpiDialog(ctrl: ctrl, presetRoleId: roleId),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: roleKpis.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == roleKpis.length) {
              return Center(
                child: TextButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => CreateEditKpiDialog(ctrl: ctrl, presetRoleId: roleId),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add KPI'),
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
                    child: const Icon(Iconsax.chart, color: AppColors.info, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          '${_fmt(k.period)} · ${_fmt(k.trackingMode)}'
                          '${k.targetValue != null ? " · Target: ${k.targetValue!.toStringAsFixed(k.targetValue! % 1 == 0 ? 0 : 1)} $unit" : ""}'
                          '${k.weight != null ? " · Weight: ${k.weight!.toStringAsFixed(k.weight! % 1 == 0 ? 0 : 1)}" : ""}',
                          style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (!k.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Inactive',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
