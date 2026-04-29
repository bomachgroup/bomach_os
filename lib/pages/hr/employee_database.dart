import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/paginate/my_paginator.dart';
import 'package:bomach_os/components/permission/permission_gate.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/shadows.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/helper/responsive_breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../src/model/employees_model.dart';
import 'controller/employees_controller.dart';
import 'employee_profile.dart';
import 'widget/add_new_employee.dart';

class EmployeeDatabase extends StatefulWidget {
  const EmployeeDatabase({super.key});

  @override
  State<EmployeeDatabase> createState() => _EmployeeDatabaseState();
}

class _EmployeeDatabaseState extends State<EmployeeDatabase>
    with AutomaticKeepAliveClientMixin {
  final EmployeeController controller = Get.put(EmployeeController());
  final TextEditingController _searchController = TextEditingController();

  String _selectedTab = 'Active';

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  StatusTone _employmentTypeTone(String? type) {
    final t = (type ?? '').toLowerCase();
    if (t.contains('part')) return StatusTone.info;
    if (t.contains('contract')) return StatusTone.warning;
    if (t.contains('intern')) return StatusTone.neutral;
    return StatusTone.primary; // full-time and default
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Employee Directory',
        subtitle:
            'Manage active team members, alumni, and their employment details.',
        trailing: _buildHeaderActions(context),
      ),
      children: [
        _buildStatsRow(),
        _buildToolbarAndTabs(),
        Obx(() {
          final loading =
              controller.isLoading.value && controller.employeeList.isEmpty;
          final hasError = controller.errorMessage.value.isNotEmpty;
          final isEmpty = !loading && controller.employeeList.isEmpty;

          return _buildTableCard(
            loading: loading,
            isEmpty: isEmpty,
            hasError: hasError,
            body: _buildTable(context, controller.employeeList),
            footer: (!loading && !hasError && controller.employeeList.isNotEmpty)
                ? _tablePaginator(
                    Obx(() => PaginatorFooter(
                          isMobile: context.isMobile,
                          totalItems: controller.totalItems.value,
                          limit: controller.limit.value,
                          currentPage: controller.currentPage.value,
                          onPageChanged: controller.changePage,
                          onLimitChanged: controller.changeLimit,
                          limitOptions: const [5, 10, 20, 50],
                        )),
                  )
                : null,
          );
        }),
      ],
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    final isMobile = context.isMobile;

    if (isMobile) {
      return PermissionGate(
        require: Perms.employeesCreate,
        child: MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.user_add,
              color: AppColors.textOnPrimary, size: 18),
          child: 'Add Employee',
          onTap: () => showDialog(
            context: context,
            builder: (_) => const AddEmployeeDialog(),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MyOutlinedButton(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textColor: AppColors.textPrimary,
          borderColor: AppColors.borderStrong,
          icon: const Icon(Iconsax.briefcase,
              size: 18, color: AppColors.textPrimary),
          child: 'Job Postings',
          onTap: () {},
        ),
        const SizedBox(width: 12),
        PermissionGate(
          require: Perms.employeesCreate,
          child: MyElevatedButton(
            height: 48,
            icon: const Icon(Iconsax.user_add,
                color: AppColors.textOnPrimary, size: 18),
            child: 'Add Employee',
            onTap: () => showDialog(
              context: context,
              builder: (_) => const AddEmployeeDialog(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Obx(() {
      final total = controller.totalItems.value;
      final contract = controller.employeeList
          .where((e) =>
              e.employmentType?.toLowerCase().contains('contract') ?? false)
          .length;

      return LayoutBuilder(builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 700;
        if (isNarrow) {
          return Column(
            children: [
              _buildStatCard(
                label: 'Total Employees',
                value: '$total',
                icon: Iconsax.people,
                accent: AppColors.success,
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                label: 'Contract Staff',
                value: '$contract',
                icon: Iconsax.briefcase,
                accent: AppColors.primary,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'Total Employees',
                value: '$total',
                icon: Iconsax.people,
                accent: AppColors.success,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildStatCard(
                label: 'Contract Staff',
                value: '$contract',
                icon: Iconsax.briefcase,
                accent: AppColors.primary,
              ),
            ),
          ],
        );
      });
    });
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color accent,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.sm,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: AppTextStyles.displayMd.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              borderRadius: AppRadii.brMd,
              color: accent.withValues(alpha: 0.12),
            ),
            child: Icon(icon, size: 22, color: accent),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarAndTabs() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: LayoutBuilder(builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 720;
        final searchField = MyTextFormField(
          controller: _searchController,
          hintText: 'Search employees by name, id or designation',
          height: 48,
          leading: const Icon(Iconsax.search_normal,
              size: 18, color: AppColors.textMuted),
          onChanged: controller.onSearchChanged,
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchField,
              const SizedBox(height: 12),
              _buildPillTabs(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildPillTabs(),
            const SizedBox(width: 16),
            Expanded(child: searchField),
          ],
        );
      }),
    );
  }

  Widget _buildPillTabs() {
    const tabs = ['Active', 'Past(Alumni)'];
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: tabs
            .map((t) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _buildTabButton(t),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildTabButton(String title) {
    final bool isActive = _selectedTab == title;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadii.brMd,
        onTap: () {
          setState(() => _selectedTab = title);
          controller.filterByStatus(title == 'Active');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.surface : Colors.transparent,
            borderRadius: AppRadii.brMd,
            boxShadow: isActive ? AppShadows.sm : const <BoxShadow>[],
          ),
          child: Text(
            title,
            style: AppTextStyles.bodyMd.copyWith(
              color: isActive
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableCard({
    required bool loading,
    required bool isEmpty,
    required bool hasError,
    required Widget body,
    Widget? footer,
  }) {
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
                        _selectedTab == 'Active'
                            ? 'Active employees'
                            : 'Past employees',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                            loading
                                ? 'Loading employees...'
                                : '${controller.totalItems.value} employee${controller.totalItems.value == 1 ? '' : 's'} on record',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          )),
                    ],
                  ),
                ),
                StatusChip(
                  label: _selectedTab == 'Active' ? 'Active roster' : 'Alumni',
                  tone: _selectedTab == 'Active'
                      ? StatusTone.success
                      : StatusTone.neutral,
                  icon: Iconsax.people,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          if (loading)
            Padding(
              padding: const EdgeInsets.all(20),
              child: LoadingSkeleton.listRows(count: 6),
            )
          else if (hasError)
            Padding(
              padding: const EdgeInsets.all(24),
              child: EmptyState(
                icon: Iconsax.warning_2,
                title: 'Something went wrong',
                subtitle: controller.errorMessage.value,
                action: MyOutlinedButton(
                  child: 'Retry',
                  icon: const Icon(Iconsax.refresh,
                      size: 18, color: AppColors.primary),
                  onTap: () => controller.fetchEmployees(),
                ),
              ),
            )
          else if (isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: EmptyState.empty(
                title: 'No employees found',
                subtitle:
                    'Add a new employee to populate the directory or adjust your filters.',
                action: PermissionGate(
                  require: Perms.employeesCreate,
                  child: MyOutlinedButton(
                    child: 'Add Employee',
                    icon: const Icon(Iconsax.user_add,
                        size: 18, color: AppColors.primary),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => const AddEmployeeDialog(),
                    ),
                  ),
                ),
              ),
            )
          else
            body,
          if (footer != null) ...[
            const Divider(height: 1, color: AppColors.borderSubtle),
            footer,
          ],
        ],
      ),
    );
  }

  Widget _tablePaginator(Widget child) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: child,
    );
  }

  Widget _buildTable(BuildContext context, List<Employee> employees) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1080,
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              color: AppColors.surfaceMuted,
              child: Row(
                children: [
                  _buildHeaderCell('Name & ID', flex: 4),
                  _buildHeaderCell('Designation', flex: 3),
                  _buildHeaderCell('Department', flex: 3),
                  _buildHeaderCell('Type', flex: 2),
                  _buildHeaderCell('Status', flex: 2),
                  _buildHeaderCell('', width: 130),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderSubtle),
            ...employees.map((e) => _buildEmployeeRow(context, e)),
          ],
        ),
      ),
    );
  }

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

  Widget _buildEmployeeRow(BuildContext context, Employee emp) {
    final bool isActive = emp.isActive;
    final bool hasPicture = emp.profilePicture != null &&
        emp.profilePicture!.isNotEmpty &&
        emp.profilePicture != 'string';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.surfaceMuted,
                  backgroundImage:
                      hasPicture ? NetworkImage(emp.profilePicture!) : null,
                  child: !hasPicture
                      ? Text(
                          emp.firstName.isNotEmpty
                              ? emp.firstName[0].toUpperCase()
                              : '?',
                          style: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${emp.firstName} ${emp.lastName}',
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        emp.employeeId ?? emp.id,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              emp.designation ?? emp.role,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              emp.departmentName ?? emp.departmentId?.toString() ?? '—',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                label: emp.employmentType ?? 'Full-time',
                tone: _employmentTypeTone(emp.employmentType),
                dense: true,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                label: isActive ? 'Active' : 'Inactive',
                tone:
                    isActive ? StatusTone.success : StatusTone.neutral,
              ),
            ),
          ),
          SizedBox(
            width: 130,
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => EmployeeProfile(e: emp),
                    ),
                  );
                },
                icon: const Icon(Iconsax.eye, size: 16),
                label: const Text('View'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.borderStrong),
                  minimumSize: const Size(0, 42),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: const RoundedRectangleBorder(
                      borderRadius: AppRadii.brMd),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
