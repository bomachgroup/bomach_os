import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controllers/role_kpi_controller.dart';
import 'controllers/roles_controller.dart';
import 'widget/kpi_dialogs.dart';

class KpiManagementPage extends StatelessWidget {
  const KpiManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(RoleKpiController());
    if (!Get.isRegistered<RolesController>()) {
      Get.put(RolesController());
    }

    return PageScaffold(
      header: PageHeader(
        title: 'KPI Management',
        subtitle: 'Define and manage role-level Key Performance Indicators.',
        trailing: MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle, color: AppColors.white, size: 18),
          child: 'Add KPI',
          onTap: () => showDialog(
            context: context,
            builder: (_) => CreateEditKpiDialog(ctrl: ctrl),
          ),
        ),
      ),
      children: [
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          elevation: AppCardElevation.sm,
          child: MyTextFormField(
            hintText: 'Search KPIs...',
            height: 44,
            leading: const Icon(Iconsax.search_normal,
                size: 18, color: AppColors.textMuted),
            onChanged: (_) => ctrl.fetchKpis(refresh: true),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          elevation: AppCardElevation.sm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('KPI Registry', style: AppTextStyles.h3),
                    SizedBox(height: 4),
                    Text(
                      'Standard KPI definitions attached to each role template',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.borderSubtle),
              Obx(() {
                if (ctrl.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (ctrl.kpis.isEmpty) {
                  return const EmptyState(
                    icon: Iconsax.chart,
                    title: 'No KPIs defined yet',
                    subtitle:
                        'Add role-level KPIs to track measurable performance standards.',
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor:
                        WidgetStateProperty.all(AppColors.surfaceMuted),
                    columnSpacing: 24,
                    columns: const [
                      DataColumn(label: Text('Metric', style: AppTextStyles.label)),
                      DataColumn(label: Text('Role', style: AppTextStyles.label)),
                      DataColumn(label: Text('Target', style: AppTextStyles.label)),
                      DataColumn(label: Text('Period', style: AppTextStyles.label)),
                      DataColumn(label: Text('Tracking', style: AppTextStyles.label)),
                      DataColumn(label: Text('Weight', style: AppTextStyles.label)),
                      DataColumn(label: Text('Status', style: AppTextStyles.label)),
                      DataColumn(label: Text('Actions', style: AppTextStyles.label)),
                    ],
                    rows: ctrl.kpis.map((kpi) {
                      final name = kpi.metric?.name ?? '';
                      final unit = kpi.metric?.unit ?? '';
                      return DataRow(cells: [
                        DataCell(
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: AppTextStyles.bodySm.copyWith(
                                      fontWeight: FontWeight.w600)),
                              if (kpi.metric?.description != null &&
                                  kpi.metric!.description.isNotEmpty)
                                Text(kpi.metric!.description,
                                    style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        const DataCell(Text('—', style: AppTextStyles.bodySm)),
                        DataCell(Text(
                            kpi.targetValue != null
                                ? '${kpi.targetValue!.toStringAsFixed(kpi.targetValue! % 1 == 0 ? 0 : 1)} $unit'
                                : '—',
                            style: AppTextStyles.bodySm)),
                        DataCell(_Badge(kpi.period, _periodColors)),
                        DataCell(_Badge(kpi.trackingMode, _trackingColors)),
                        DataCell(Text(
                            kpi.weight?.toStringAsFixed(kpi.weight! % 1 == 0 ? 0 : 1) ?? '—',
                            style: AppTextStyles.bodySm)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: kpi.isActive
                                  ? Colors.green.shade50
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              kpi.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: kpi.isActive
                                    ? Colors.green.shade700
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Iconsax.edit_2,
                                    size: 18, color: AppColors.primary),
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (_) => CreateEditKpiDialog(
                                      ctrl: ctrl, kpi: kpi, presetRoleId: kpi.roleId),
                                ),
                                tooltip: 'Edit KPI',
                              ),
                              IconButton(
                                icon: const Icon(Iconsax.trash,
                                    size: 18, color: AppColors.danger),
                                onPressed: () =>
                                    _confirmDelete(context, ctrl, kpi.id!),
                                tooltip: 'Delete KPI',
                              ),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(
      BuildContext context, RoleKpiController ctrl, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete KPI'),
        content: const Text(
            'Are you sure you want to delete this KPI definition? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ctrl.deleteKpi(context, id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

const _periodColors = {
  'weekly': Color(0xFF8B5CF6),
  'monthly': Color(0xFF059669),
  'quarterly': Color(0xFFD97706),
  'semi_annual': Color(0xFF3B82F6),
  'annual': Color(0xFFDC2626),
};

const _trackingColors = {
  'manual': Color(0xFF6B7280),
  'automatic': Color(0xFF059669),
  'semi_automatic': Color(0xFFD97706),
};

class _Badge extends StatelessWidget {
  final String label;
  final Map<String, Color> colorMap;
  const _Badge(this.label, this.colorMap);

  @override
  Widget build(BuildContext context) {
    final color = colorMap[label.toLowerCase()] ?? AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' '),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
