import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/loading_skeleton.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/shadows.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/model/departments_units_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controllers/department_units_controller.dart';
import 'widget/department_units_dialogs.dart';

const List<String> _tabs = ['Departments', 'Units'];

class DepartmentsUnitsPage extends StatelessWidget {
  const DepartmentsUnitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DepartmentsUnitsController controller =
        Get.put(DepartmentsUnitsController());

    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Departments & Units',
        subtitle:
            'Organize departments, units, and their heads across Bomach Group.',
        trailing: Obx(() => _buildHeaderAction(context, controller)),
      ),
      children: [
        Obx(() => _buildTabBar(controller)),
        _buildToolbar(controller),
        Obx(() => _buildTableCard(context, controller)),
      ],
    );
  }

  // ─────────── HEADER ACTION ───────────

  Widget _buildHeaderAction(
      BuildContext context, DepartmentsUnitsController controller) {
    final isDepartments = controller.currentTab.value == 'Departments';
    return MyElevatedButton(
      height: 48,
      icon: const Icon(Iconsax.add_circle,
          color: AppColors.textOnPrimary, size: 18),
      child: isDepartments ? 'New Department' : 'New Unit',
      onTap: () => showDialog(
        context: context,
        builder: (_) => isDepartments
            ? const CreateDepartmentDialog()
            : const CreateUnitDialog(),
      ),
    );
  }

  // ─────────── TAB BAR (pill) ───────────

  Widget _buildTabBar(DepartmentsUnitsController controller) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _tabs
              .map((label) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _buildTabButton(controller, label),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTabButton(
      DepartmentsUnitsController controller, String label) {
    final isActive = controller.currentTab.value == label;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadii.brMd,
        onTap: () => controller.switchTab(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.surface : Colors.transparent,
            borderRadius: AppRadii.brMd,
            boxShadow: isActive ? AppShadows.sm : const <BoxShadow>[],
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyMd.copyWith(
              color:
                  isActive ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────── TOOLBAR ───────────

  Widget _buildToolbar(DepartmentsUnitsController controller) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: Obx(() {
        final hint = controller.currentTab.value == 'Departments'
            ? 'Search departments by name'
            : 'Search units by name or head of unit';
        return MyTextFormField(
          hintText: hint,
          height: 48,
          onChanged: controller.setSearch,
          leading: const Icon(Iconsax.search_normal,
              size: 18, color: AppColors.textMuted),
        );
      }),
    );
  }

  // ─────────── TABLE CARD ───────────

  Widget _buildTableCard(
      BuildContext context, DepartmentsUnitsController controller) {
    final isDepartments = controller.currentTab.value == 'Departments';
    final total = isDepartments
        ? controller.totalDepartmentsFiltered
        : controller.totalUnitsFiltered;
    final loading = controller.isLoading.value;

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
                      Text(
                        isDepartments
                            ? 'Department register'
                            : 'Unit register',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loading
                            ? 'Loading ${isDepartments ? 'departments' : 'units'}...'
                            : '$total ${isDepartments ? 'departments' : 'units'} available',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusChip(
                  label: isDepartments
                      ? 'Organizational map'
                      : 'Unit directory',
                  tone: StatusTone.primary,
                  icon: isDepartments ? Iconsax.people : Iconsax.hierarchy,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          _buildTableBody(context, controller, isDepartments, loading),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderSubtle),
              ),
            ),
            child: PaginatorFooter(
              totalItems: total,
              limit: controller.itemsPerPage.value,
              currentPage: controller.currentPage.value + 1,
              onPageChanged: (page) => controller.goToPage(page - 1),
              onLimitChanged: controller.setLimit,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableBody(
    BuildContext context,
    DepartmentsUnitsController controller,
    bool isDepartments,
    bool loading,
  ) {
    if (loading) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: LoadingSkeleton.listRows(count: 5),
      );
    }

    if (isDepartments) {
      final data = controller.paginatedDepartments;
      if (data.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: EmptyState(
            icon: Iconsax.people,
            title: controller.searchString.value.isNotEmpty
                ? 'No departments match this search'
                : 'No departments yet',
            subtitle: controller.searchString.value.isNotEmpty
                ? 'Try a different search term or clear the filter.'
                : 'Create your first department to start organizing your teams.',
            action: MyOutlinedAction(
              label: controller.searchString.value.isNotEmpty
                  ? 'Clear Search'
                  : 'New Department',
              icon: controller.searchString.value.isNotEmpty
                  ? Iconsax.refresh
                  : Iconsax.add_circle,
              onTap: () {
                if (controller.searchString.value.isNotEmpty) {
                  controller.setSearch('');
                } else {
                  showDialog(
                    context: context,
                    builder: (_) => const CreateDepartmentDialog(),
                  );
                }
              },
            ),
          ),
        );
      }
      return _buildDepartmentsTable(context, controller, data);
    }

    final units = controller.paginatedUnits;
    if (units.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: EmptyState(
          icon: Iconsax.hierarchy,
          title: controller.searchString.value.isNotEmpty
              ? 'No units match this search'
              : 'No units yet',
          subtitle: controller.searchString.value.isNotEmpty
              ? 'Try a different search term or clear the filter.'
              : 'Create units under departments to represent smaller teams.',
          action: MyOutlinedAction(
            label: controller.searchString.value.isNotEmpty
                ? 'Clear Search'
                : 'New Unit',
            icon: controller.searchString.value.isNotEmpty
                ? Iconsax.refresh
                : Iconsax.add_circle,
            onTap: () {
              if (controller.searchString.value.isNotEmpty) {
                controller.setSearch('');
              } else {
                showDialog(
                  context: context,
                  builder: (_) => const CreateUnitDialog(),
                );
              }
            },
          ),
        ),
      );
    }

    return _buildUnitsTable(context, controller, units);
  }

  // ─────────── DEPARTMENTS TABLE ───────────

  Widget _buildDepartmentsTable(
    BuildContext context,
    DepartmentsUnitsController controller,
    List<Department> data,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 960,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              color: AppColors.surfaceMuted,
              child: Row(
                children: [
                  _buildHeaderCell('Department', flex: 4),
                  _buildHeaderCell('Code', flex: 2),
                  _buildHeaderCell('', width: 220),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderSubtle),
            ...data.map((dept) => _buildDepartmentRow(context, dept)),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentRow(BuildContext context, Department dept) {
    final code =
        'DEP-${dept.id.length >= 3 ? dept.id.substring(0, 3) : dept.id}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: AppRadii.brMd,
                  ),
                  child: const Icon(
                    Iconsax.people,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dept.name,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (dept.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          dept.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySm
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              code,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
            ),
          ),
          SizedBox(
            width: 220,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) =>
                        ViewDepartmentDetailsDialog(department: dept),
                  ),
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
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => CreateDepartmentDialog(department: dept),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────── UNITS TABLE ───────────

  Widget _buildUnitsTable(
    BuildContext context,
    DepartmentsUnitsController controller,
    List<DepartmentUnit> data,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1080,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              color: AppColors.surfaceMuted,
              child: Row(
                children: [
                  _buildHeaderCell('Unit', flex: 3),
                  _buildHeaderCell('Department', flex: 2),
                  _buildHeaderCell('Head of Unit', flex: 2),
                  _buildHeaderCell('Status', flex: 2),
                  _buildHeaderCell('', width: 220),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderSubtle),
            ...data.map((unit) => _buildUnitRow(context, unit)),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitRow(BuildContext context, DepartmentUnit unit) {
    final status = unit.status ?? 'Active';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: AppRadii.brMd,
                  ),
                  child: const Icon(
                    Iconsax.hierarchy,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unit.name,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (unit.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          unit.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySm
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              unit.departmentName ?? '-',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              unit.hod ?? 'Not Assigned',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip.fromStatus(status),
            ),
          ),
          SizedBox(
            width: 220,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => ViewUnitDetailsDialog(unit: unit),
                  ),
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
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => CreateUnitDialog(unit: unit),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────── HELPERS ───────────

  Widget _buildHeaderCell(String label, {double? width, int? flex}) {
    final content = Text(
      label,
      style: AppTextStyles.bodySm.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
    if (width != null) return SizedBox(width: width, child: content);
    return Expanded(flex: flex ?? 1, child: content);
  }
}

/// Small helper that wraps a MyOutlinedButton-style action for empty states.
/// Kept local to this file to avoid coupling to a specific button variant
/// while still respecting the design-system rule for EmptyState actions.
class MyOutlinedAction extends StatelessWidget {
  const MyOutlinedAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.borderStrong),
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
      ),
    );
  }
}
