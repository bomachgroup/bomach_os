import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/permission/permission_gate.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/role_kpi_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controllers/role_kpi_controller.dart';
import 'controllers/roles_controller.dart';
import 'widget/kpi_dialogs.dart';

class KpiManagementPage extends StatefulWidget {
  const KpiManagementPage({super.key});

  @override
  State<KpiManagementPage> createState() => _KpiManagementPageState();
}

class _KpiManagementPageState extends State<KpiManagementPage> {
  late final RoleKpiController ctrl;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<RoleKpiController>(tag: 'kpi_management')) {
      Get.put(RoleKpiController(), tag: 'kpi_management');
    }
    ctrl = Get.find<RoleKpiController>(tag: 'kpi_management');
    if (!Get.isRegistered<RolesController>()) {
      Get.put(RolesController());
    }
    ctrl.fetchAllKpis();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      header: PageHeader(
        title: 'KPI Management',
        subtitle: 'Define and manage role-level Key Performance Indicators.',
        trailing: PermissionGate(
          allOf: const [Perms.roleKpisCreate, Perms.kpisList],
          child: MyElevatedButton(
            height: 48,
            icon: const Icon(Iconsax.add_circle,
                color: AppColors.white, size: 18),
            child: 'Add KPI',
            onTap: () => showKpiEditorDialog(context, ctrl: ctrl),
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
            onChanged: (value) =>
                ctrl.fetchAllKpis(search: value, refresh: true),
          ),
        ),
        Obx(() {
          if (ctrl.isLoading.value && ctrl.kpis.isEmpty) {
            return AppCard(
              padding: const EdgeInsets.all(24),
              child: LoadingSkeleton.listRows(count: 5),
            );
          }
          if (ctrl.errorMessage.value.isNotEmpty && ctrl.kpis.isEmpty) {
            return AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    ctrl.errorMessage.value,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => ctrl.fetchAllKpis(refresh: true),
                    icon: const Icon(Iconsax.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (ctrl.kpis.isEmpty) {
            return Column(
              children: [
                if (ctrl.isRefreshing.value)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Row(
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
                const AppCard(
                  padding: EdgeInsets.all(48),
                  child: EmptyState(
                    icon: Iconsax.chart,
                    title: 'No KPIs defined yet',
                    subtitle:
                        'Add role-level KPIs to track measurable performance standards.',
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              if (ctrl.isRefreshing.value || ctrl.errorMessage.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
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
                          onPressed: () => ctrl.fetchAllKpis(),
                          icon: const Icon(Iconsax.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ],
                  ),
                ),
              _KpiGrid(ctrl: ctrl),
              if (ctrl.totalCount > ctrl.limit) ...[
                const SizedBox(height: 16),
                _KpiPagination(ctrl: ctrl),
              ],
            ],
          );
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
  final RoleKpi kpi;
  const _KpiCard({required this.kpi});

  @override
  Widget build(BuildContext context) {
    final name = kpi.metric?.name ?? '';
    final unit = kpi.metric?.unit ?? '';
    final desc = kpi.metric?.description ?? '';
    final target = kpi.targetValue != null
        ? '${kpi.targetValue!.toStringAsFixed(kpi.targetValue! % 1 == 0 ? 0 : 1)} $unit'
        : '—';
    final weight =
        kpi.weight?.toStringAsFixed(kpi.weight! % 1 == 0 ? 0 : 1) ?? '—';
    final periodLabel =
        kpi.period == 'yearly' ? 'Annual' : _formatLabel(kpi.period);

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
              _InfoChip(label: 'Period', value: periodLabel),
              _InfoChip(label: 'Tracking', value: kpi.trackingMode),
              _InfoChip(label: 'Weight', value: weight),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _Badge(
                kpi.period == 'yearly' ? 'annual' : kpi.period,
                _periodColors,
              ),
              const SizedBox(width: 6),
              _Badge(kpi.trackingMode, _trackingColors),
              const Spacer(),
              PermissionGate(
                allOf: const [Perms.roleKpisUpdate, Perms.kpisList],
                child: IconButton(
                  icon: const Icon(Iconsax.edit_2,
                      size: 18, color: AppColors.primary),
                  onPressed: () => _editKpi(context, kpi),
                  tooltip: 'Edit KPI',
                  visualDensity: VisualDensity.compact,
                ),
              ),
              PermissionGate(
                require: Perms.roleKpisDelete,
                child: IconButton(
                  icon: const Icon(Iconsax.trash,
                      size: 18, color: AppColors.danger),
                  onPressed: () => _confirmDelete(context, kpi),
                  tooltip: 'Remove from role',
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editKpi(BuildContext context, RoleKpi kpi) {
    final ctrl = Get.find<RoleKpiController>(tag: 'kpi_management');
    showKpiEditorDialog(
      context,
      ctrl: ctrl,
      kpi: kpi,
      presetRoleId: kpi.roleId,
    );
  }

  void _confirmDelete(BuildContext context, RoleKpi kpi) {
    final ctrl = Get.find<RoleKpiController>(tag: 'kpi_management');
    showRemoveKpiConfirmation(
      context,
      ctrl: ctrl,
      roleId: kpi.roleId,
      id: kpi.id!,
      metricName: kpi.metric?.name ?? 'this KPI',
    );
  }

  String _formatLabel(String value) => value
      .split('_')
      .map((part) =>
          part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

class _KpiPagination extends StatelessWidget {
  final RoleKpiController ctrl;
  const _KpiPagination({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final page = ctrl.offset ~/ ctrl.limit + 1;
    final pages = (ctrl.totalCount / ctrl.limit).ceil();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: 'Previous page',
          onPressed: page > 1 ? () => ctrl.setAllKpisPage(page - 2) : null,
          icon: const Icon(Iconsax.arrow_left_2),
        ),
        Text('Page $page of $pages'),
        IconButton(
          tooltip: 'Next page',
          onPressed: page < pages ? () => ctrl.setAllKpisPage(page) : null,
          icon: const Icon(Iconsax.arrow_right_3),
        ),
      ],
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
              style:
                  AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w500)),
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
