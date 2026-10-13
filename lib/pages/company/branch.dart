import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/paginate/my_paginator.dart';
import 'package:bomach_os/components/permission/permission_gate.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/pages/company/widget/add_branch_dialog.dart';
import 'package:bomach_os/pages/company/widget/view_branch_dialog.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/branch_model.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controllers/branch_controller.dart';

class BranchListPage extends StatefulWidget {
  const BranchListPage({super.key});

  @override
  State<BranchListPage> createState() => _BranchListPageState();
}

class _BranchListPageState extends State<BranchListPage> {
  final BranchController controller = Get.put(BranchController());
  final TextEditingController searchCtrl = TextEditingController();

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Branches',
        subtitle:
            'Manage branch details and configure each office attendance geofence.',
        trailing: PermissionGate(
          require: Perms.branchesCreate,
          child: MyElevatedButton(
            height: 48,
            icon: const Icon(Iconsax.add_circle,
                color: AppColors.textOnPrimary, size: 18),
            child: 'New Branch',
            onTap: _openAddDialog,
          ),
        ),
      ),
      children: [
        _buildToolbar(),
        _buildBranchTable(),
      ],
    );
  }

  void _openAddDialog() {
    controller.loadFilterResources();
    showDialog(
      context: context,
      builder: (_) => const AddBranchDialog(),
    );
  }

  void _openEditDialog(Branch branch) {
    controller.loadFilterResources();
    showDialog(
      context: context,
      builder: (_) => AddBranchDialog(branchToEdit: branch),
    );
  }

  void _openViewDialog(Branch branch) {
    controller.fetchBranchDetails(branch.id);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BranchDetailPage()),
    );
  }

  Widget _buildToolbar() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 1080;

          final search = MyTextFormField(
            controller: searchCtrl,
            hintText: 'Search branches by name, role, city, or address',
            height: 48,
            onChanged: controller.onSearchChanged,
            leading: const Icon(Iconsax.search_normal,
                size: 18, color: AppColors.textMuted),
          );

          final filters = Obx(() {
            final roleValue = _selectedRoleLabel();
            final statusValue = _selectedStatusLabel();
            final hasFilters = controller.searchQuery.value.isNotEmpty ||
                controller.filterState.value != null ||
                controller.filterBranchRole.value != null ||
                controller.filterStatus.value != null;

            final children = <Widget>[
              SizedBox(
                width: 170,
                child: _buildToolbarDropdown(
                  currentValue: roleValue,
                  fallback: 'All Types',
                  items: [
                    'All Types',
                    ...?controller.fieldChoices.value?.branchRole
                        .map((option) => option.label),
                  ],
                  onChanged: controller.onTypeFilterChanged,
                ),
              ),
              SizedBox(
                width: 150,
                child: MyTextFormField(
                  hintText: 'State',
                  height: 48,
                  onChanged: controller.onStateFilterChanged,
                ),
              ),
              SizedBox(
                width: 170,
                child: _buildToolbarDropdown(
                  currentValue: statusValue,
                  fallback: 'All Status',
                  items: [
                    'All Status',
                    ...?controller.fieldChoices.value?.operationalStatus
                        .map((option) => option.label),
                  ],
                  onChanged: controller.onStatusFilterChanged,
                ),
              ),
              if (hasFilters)
                OutlinedButton.icon(
                  onPressed: () {
                    searchCtrl.clear();
                    controller.resetFilters();
                  },
                  icon: const Icon(Iconsax.refresh, size: 16),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.borderStrong),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadii.brMd,
                    ),
                  ),
                ),
            ];

            if (compact) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: children,
              );
            }

            return Row(
              children: [
                ...children
                    .expand((child) => [child, const SizedBox(width: 12)]),
              ]..removeLast(),
            );
          });

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                search,
                const SizedBox(height: 12),
                filters,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: search),
              const SizedBox(width: 16),
              Expanded(flex: 4, child: filters),
            ],
          );
        },
      ),
    );
  }

  Widget _buildToolbarDropdown({
    required String? currentValue,
    required String fallback,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final safeItems = items.isEmpty ? [fallback] : items;
    final selected = safeItems.contains(currentValue) ? currentValue : fallback;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brMd,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          isExpanded: true,
          borderRadius: AppRadii.brMd,
          dropdownColor: AppColors.surface,
          icon: const Icon(Iconsax.arrow_down_1,
              size: 16, color: AppColors.textMuted),
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
          items: safeItems
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildBranchTable() {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Branch register', style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                            '${controller.totalItems.value} records available',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          )),
                    ],
                  ),
                ),
                const StatusChip(
                  label: 'Operational directory',
                  tone: StatusTone.primary,
                  icon: Iconsax.folder_open,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Obx(() {
            if (controller.isLoadingList.value &&
                controller.branchList.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: LoadingSkeleton.listRows(count: 5),
              );
            }

            if (controller.branchList.isEmpty) {
              final filtered = controller.searchQuery.value.isNotEmpty ||
                  controller.filterState.value != null ||
                  controller.filterBranchRole.value != null ||
                  controller.filterStatus.value != null;

              return Padding(
                padding: const EdgeInsets.all(24),
                child: EmptyState(
                  icon: Iconsax.building_4,
                  title: filtered
                      ? 'No branches match these filters'
                      : 'No branches yet',
                  subtitle: filtered
                      ? 'Try changing the search term or clearing one of the filters.'
                      : 'Create your first branch to start structuring the company footprint.',
                  action: MyElevatedButton(
                    child: filtered ? 'Reset Filters' : 'New Branch',
                    icon: Icon(
                      filtered ? Iconsax.refresh : Iconsax.add_circle,
                      color: AppColors.textOnPrimary,
                      size: 18,
                    ),
                    onTap: () {
                      if (filtered) {
                        searchCtrl.clear();
                        controller.resetFilters();
                      } else {
                        _openAddDialog();
                      }
                    },
                  ),
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 900;
                if (isMobile) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildCardList(controller.branchList),
                  );
                }

                return _buildDesktopTable();
              },
            );
          }),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderSubtle),
              ),
            ),
            child: Obx(() => PaginatorFooter(
                  totalItems: controller.totalItems.value,
                  limit: controller.limit.value,
                  currentPage: controller.currentPage.value,
                  onPageChanged: controller.goToPage,
                  onLimitChanged: controller.setLimit,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: AppColors.surfaceMuted,
          child: const Row(
            children: [
              Expanded(
                  flex: 30, child: Text('Branch', style: AppTextStyles.label)),
              SizedBox(width: 16),
              Expanded(
                  flex: 20, child: Text('Type', style: AppTextStyles.label)),
              SizedBox(width: 16),
              Expanded(
                  flex: 24,
                  child: Text('Location', style: AppTextStyles.label)),
              SizedBox(width: 16),
              Expanded(
                  flex: 16, child: Text('Manager', style: AppTextStyles.label)),
              SizedBox(width: 16),
              Expanded(
                  flex: 12, child: Text('Status', style: AppTextStyles.label)),
              SizedBox(width: 40),
            ],
          ),
        ),
        ...controller.branchList.map(_buildDesktopRow),
      ],
    );
  }

  Widget _buildDesktopRow(Branch branch) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 30, child: _buildBranchIdentity(branch)),
          const SizedBox(width: 16),
          Expanded(flex: 20, child: _buildTypeCell(branch)),
          const SizedBox(width: 16),
          Expanded(flex: 24, child: _buildLocationCell(branch)),
          const SizedBox(width: 16),
          Expanded(flex: 16, child: _buildManagerCell(branch)),
          const SizedBox(width: 16),
          Expanded(
            flex: 12,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip.fromStatus(_statusLabel(branch)),
            ),
          ),
          SizedBox(
            width: 40,
            child: _buildActionMenu(branch),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchIdentity(Branch branch) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          branch.branchName,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          branch.branchId.isNotEmpty ? branch.branchId : '#${branch.id}',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildTypeCell(Branch branch) {
    final type = _branchType(branch);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          type,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Operational role',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildLocationCell(Branch branch) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _branchLocation(branch),
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          branch.officeAddress.isNotEmpty
              ? branch.officeAddress
              : 'No address added',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              branch.latitude != null && branch.longitude != null
                  ? Iconsax.location_tick
                  : Iconsax.location_slash,
              size: 14,
              color: branch.latitude != null && branch.longitude != null
                  ? AppColors.success
                  : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              branch.latitude != null && branch.longitude != null
                  ? 'Attendance geofence · ${branch.attendanceRadiusMeters} m'
                  : 'Attendance point not configured',
              style: AppTextStyles.caption.copyWith(
                color: branch.latitude != null && branch.longitude != null
                    ? AppColors.success
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildManagerCell(Branch branch) {
    return Text(
      branch.managerName.isNotEmpty ? branch.managerName : 'Unassigned',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
    );
  }

  Widget _buildActionMenu(Branch branch) {
    return PopupMenuButton<String>(
      icon: const Icon(Iconsax.more, size: 18, color: AppColors.textSecondary),
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
      onSelected: (value) {
        if (value == 'view') {
          _openViewDialog(branch);
        } else if (value == 'edit') {
          _openEditDialog(branch);
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Iconsax.eye, size: 18, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Text('View details'),
            ],
          ),
        ),
        if (Get.find<PermissionService>().has(Perms.branchesUpdate))
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Iconsax.edit, size: 18, color: AppColors.textSecondary),
                SizedBox(width: 8),
                Text('Edit branch'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCardList(List<Branch> branches) {
    return Column(
      children: branches.map((branch) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(
            padding: const EdgeInsets.all(16),
            elevation: AppCardElevation.sm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildBranchIdentity(branch)),
                    const SizedBox(width: 12),
                    StatusChip.fromStatus(_statusLabel(branch)),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildMiniInfo(Iconsax.building_4, _branchType(branch)),
                    _buildMiniInfo(Iconsax.location, _branchLocation(branch)),
                    _buildMiniInfo(
                        Iconsax.profile_circle,
                        branch.managerName.isNotEmpty
                            ? branch.managerName
                            : 'Unassigned'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _openViewDialog(branch),
                      icon: const Icon(Iconsax.eye, size: 16),
                      label: const Text('View'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.borderStrong),
                        minimumSize: const Size(0, 42),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadii.brMd,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    MyElevatedButton(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      icon: const Icon(Iconsax.edit,
                          size: 16, color: AppColors.textOnPrimary),
                      child: 'Edit',
                      onTap: () => _openEditDialog(branch),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMiniInfo(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brPill,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            value,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _branchLocation(Branch branch) {
    final parts = <String>[
      if (branch.city.trim().isNotEmpty) branch.city.trim(),
      if (branch.state.trim().isNotEmpty) branch.state.trim(),
      if (branch.country.trim().isNotEmpty) branch.country.trim(),
    ];
    if (parts.isEmpty) return 'No location added';
    return parts.join(' • ');
  }

  String _branchType(Branch branch) {
    return branch.branchRoleDisplay.isNotEmpty
        ? branch.branchRoleDisplay
        : branch.branchRole;
  }

  String _statusLabel(Branch branch) {
    if (branch.operationalStatusDisplay.isNotEmpty) {
      return branch.operationalStatusDisplay;
    }
    return branch.isOperational ? 'Operational' : 'Inactive';
  }

  String? _selectedRoleLabel() {
    if (controller.filterBranchRole.value == null) return null;
    final options =
        controller.fieldChoices.value?.branchRole ?? const <FieldOption>[];
    for (final option in options) {
      if (option.value == controller.filterBranchRole.value)
        return option.label;
    }
    return null;
  }

  String? _selectedStatusLabel() {
    if (controller.filterStatus.value == null) return null;
    final options = controller.fieldChoices.value?.operationalStatus ??
        const <FieldOption>[];
    for (final option in options) {
      if (option.value == controller.filterStatus.value) return option.label;
    }
    return null;
  }
}
