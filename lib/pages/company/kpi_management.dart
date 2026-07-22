import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
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
    if (!Get.isRegistered<RoleKpiController>(tag: 'kpi_management')) {
      Get.put(RoleKpiController(), tag: 'kpi_management');
    }
    final ctrl = Get.find<RoleKpiController>(tag: 'kpi_management');
    if (!Get.isRegistered<RolesController>()) {
      Get.put(RolesController());
    }
    ctrl.fetchAllKpis();

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
          ).then((_) => ctrl.fetchAllKpis(refresh: true)),
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
            onChanged: (_) => ctrl.fetchAllKpis(refresh: true),
          ),
        ),
        Obx(() {
          if (ctrl.isLoading.value) {
            return AppCard(
              padding: const EdgeInsets.all(24),
              child: LoadingSkeleton.listRows(count: 5),
            );
          }
          if (ctrl.kpis.isEmpty) {
            return const AppCard(
              padding: EdgeInsets.all(48),
              child: EmptyState(
                icon: Iconsax.chart,
                title: 'No KPIs defined yet',
                subtitle:
                    'Add role-level KPIs to track measurable performance standards.',
              ),
            );
          }
          return _KpiGrid(ctrl: ctrl);
        }),
      ],
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final RoleKpiController ctrl;
  const _KpiGrid({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth > 900
            ? (constraints.maxWidth - 24) / 3
            : constraints.maxWidth > 600
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ctrl.kpis.map((kpi) {
            return SizedBox(
              width: cardWidth,
              child: _KpiCard(kpi: kpi),
            );
          }).toList(),
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final dynamic kpi;
  const _KpiCard({required this.kpi});

  @override
  Widget build(BuildContext context) {
    final name = kpi.metric?.name ?? '';
    final unit = kpi.metric?.unit ?? '';
    final desc = kpi.metric?.description ?? '';
    final target = kpi.targetValue != null
        ? '${kpi.targetValue!.toStringAsFixed(kpi.targetValue! % 1 == 0 ? 0 : 1)} $unit'
        : '—';
    final weight = kpi.weight?.toStringAsFixed(kpi.weight! % 1 == 0 ? 0 : 1) ?? '—';

    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.bodyMd
                          .copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (desc.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          desc,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              _StatusBadge(isActive: kpi.isActive),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _InfoChip(label: 'Target', value: target),
              _InfoChip(label: 'Period', value: kpi.period),
              _InfoChip(label: 'Tracking', value: kpi.trackingMode),
              _InfoChip(label: 'Weight', value: weight),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _Badge(kpi.period, _periodColors),
              const SizedBox(width: 6),
              _Badge(kpi.trackingMode, _trackingColors),
              const Spacer(),
              IconButton(
                icon: const Icon(Iconsax.edit_2, size: 18, color: AppColors.primary),
                onPressed: () => _editKpi(context, kpi),
                tooltip: 'Edit KPI',
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                icon: const Icon(Iconsax.trash, size: 18, color: AppColors.danger),
                onPressed: () => _confirmDelete(context, kpi.id!),
                tooltip: 'Delete KPI',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editKpi(BuildContext context, dynamic kpi) {
    final ctrl = Get.find<RoleKpiController>(tag: 'kpi_management');
    showDialog(
      context: context,
      builder: (_) => CreateEditKpiDialog(
          ctrl: ctrl, kpi: kpi, presetRoleId: kpi.roleId),
    ).then((_) => ctrl.fetchAllKpis(refresh: true));
  }

  void _confirmDelete(BuildContext context, int id) {
    final ctrl = Get.find<RoleKpiController>(tag: 'kpi_management');
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
              await ctrl.deleteKpi(id);
              ctrl.fetchAllKpis(refresh: true);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary, fontSize: 10)),
          const SizedBox(height: 2),
          Text(value,
              style: AppTextStyles.bodySm
                  .copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.green.shade700 : Colors.grey.shade600,
        ),
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
        label
            .split('_')
            .map((w) => w[0].toUpperCase() + w.substring(1))
            .join(' '),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
