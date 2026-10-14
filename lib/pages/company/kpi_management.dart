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
import 'package:bomach_os/src/utils/number_formatting.dart';
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
  String _searchText = '';

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
            onChanged: (value) {
              setState(() => _searchText = value);
              ctrl.fetchAllKpis(search: value, refresh: true);
            },
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
                AppCard(
                  padding: const EdgeInsets.all(24),
                  child: EmptyState(
                    icon: Iconsax.chart,
                    title: _searchText.isEmpty
                        ? 'No role KPIs yet'
                        : 'No matching KPIs',
                    subtitle: _searchText.isEmpty
                        ? 'Set shared performance measures for each role. Assignments can be tailored later in an employee plan.'
                        : 'Try a different KPI name or clear the search.',
                    compact: true,
                    action: _searchText.isEmpty
                        ? PermissionGate(
                            allOf: const [
                              Perms.roleKpisCreate,
                              Perms.kpisList,
                            ],
                            child: MyElevatedButton(
                              height: 42,
                              icon: const Icon(Iconsax.add,
                                  size: 17, color: AppColors.white),
                              child: 'Add KPI',
                              onTap: () =>
                                  showKpiEditorDialog(context, ctrl: ctrl),
                            ),
                          )
                        : null,
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
        final columns = constraints.maxWidth >= 1120
            ? 3
            : constraints.maxWidth >= 680
                ? 2
                : 1;
        final cardWidth = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - (columns - 1) * 12) / columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ctrl.kpis.map((kpi) {
            final role = Get.isRegistered<RolesController>()
                ? Get.find<RolesController>()
                    .roles
                    .firstWhereOrNull((item) => item.id == kpi.roleId)
                : null;
            return SizedBox(
              width: cardWidth,
              child: _KpiCard(
                kpi: kpi,
                roleName: role?.name ?? 'Role #${kpi.roleId}',
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final RoleKpi kpi;
  final String roleName;
  const _KpiCard({required this.kpi, required this.roleName});

  @override
  Widget build(BuildContext context) {
    final name = kpi.metric?.name ?? '';
    final unit = kpi.metric?.unit ?? '';
    final desc = kpi.metric?.description ?? '';
    final target = kpi.targetValue != null
        ? formatValueWithUnit(
            kpi.targetValue!.toStringAsFixed(kpi.targetValue! % 1 == 0 ? 0 : 1),
            unit,
          )
        : '—';
    final weight =
        kpi.weight?.toStringAsFixed(kpi.weight! % 1 == 0 ? 0 : 1) ?? '—';
    final periodLabel =
        _formatLabel(kpi.period == 'yearly' ? 'annual' : kpi.period);
    final trackingLabel = _formatLabel(kpi.trackingMode);

    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: AppRadii.brSm,
                ),
                child: const Icon(Iconsax.chart_2,
                    size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
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
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, constraints) {
            final cellWidth = (constraints.maxWidth - 18) / 2;
            return Wrap(
              spacing: 18,
              runSpacing: 12,
              children: [
                SizedBox(
                    width: cellWidth,
                    child: _InfoCell(label: 'Target', value: target)),
                SizedBox(
                    width: cellWidth,
                    child: _InfoCell(label: 'Period', value: periodLabel)),
                SizedBox(
                    width: cellWidth,
                    child: _InfoCell(label: 'Tracking', value: trackingLabel)),
                SizedBox(
                    width: cellWidth,
                    child: _InfoCell(label: 'Weight', value: weight)),
              ],
            );
          }),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  roleName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
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

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;
  const _InfoCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style:
                AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 3),
        Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600)),
      ],
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
        color: isActive ? AppColors.successSubtle : AppColors.neutral100,
        borderRadius: AppRadii.brSm,
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? AppColors.success : AppColors.textSecondary,
        ),
      ),
    );
  }
}
