import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/permission/permission_gate.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/loading_skeleton.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/permissions.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/responsive_breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../components/paginate/my_paginator.dart';
import '../../src/model/employees_model.dart';
import 'controller/employees_controller.dart';
import 'employee_profile.dart';
import 'widget/add_new_employee.dart';

const Color _accentGreen = AppColors.success;
const Color _accentBlue = AppColors.primary;

class EmployeeDatabase extends StatefulWidget {
  const EmployeeDatabase({super.key});

  @override
  State<EmployeeDatabase> createState() => _EmployeeDatabaseState();
}

class _EmployeeDatabaseState extends State<EmployeeDatabase>
    with AutomaticKeepAliveClientMixin {
  final EmployeeController controller = Get.put(EmployeeController());
  final ScrollController _scrollController = ScrollController();

  String _selectedTab = 'Active';

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return LayoutBuilder(builder: (context, constraints) {
      final bool isMobile = context.breakpoint.isMobileOrTablet &&
          constraints.maxWidth < 800;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(context, isMobile),
          kSizedBox,
          _buildStatsRow(isMobile),
          kSizedBox,
          if (isMobile) ...[
            _buildSearchBar(),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTabButton('Active'),
                const SizedBox(width: 12),
                _buildTabButton('Past(Alumni)'),
              ],
            ),
          ] else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildTabButton('Active'),
                    const SizedBox(width: 12),
                    _buildTabButton('Past(Alumni)'),
                  ],
                ),
                _buildSearchBar(),
              ],
            ),
          kSizedBox,
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: isMobile ? 900 : constraints.maxWidth - 72,
                      ),
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return LoadingSkeleton.listRows(count: 6);
                        }

                        if (controller.errorMessage.value.isNotEmpty) {
                          return EmptyState(
                            icon: Iconsax.warning_2,
                            title: 'Something went wrong',
                            subtitle: controller.errorMessage.value,
                            action: ElevatedButton(
                              onPressed: () => controller.fetchEmployees(),
                              child: const Text('Retry'),
                            ),
                          );
                        }

                        if (controller.employeeList.isEmpty) {
                          return EmptyState.empty(
                            title: 'No employees found',
                            subtitle:
                                'Add a new employee to populate the directory.',
                          );
                        }

                        return DataTable(
                          headingRowColor: WidgetStateProperty.resolveWith(
                              (states) => AppColors.surfaceMuted),
                          headingRowHeight: 60,
                          dataRowMinHeight: 80,
                          dataRowMaxHeight: 80,
                          columnSpacing: 24,
                          horizontalMargin: 12,
                          dividerThickness: 1.0,
                          headingTextStyle: AppText.label.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          dataTextStyle: AppText.bodyMd.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          columns: _createColumns(),
                          rows: _createRows(context, controller.employeeList),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(height: 1, color: AppColors.borderSubtle),
                const SizedBox(height: 20),
                Obx(() => PaginatorFooter(
                      isMobile: isMobile,
                      totalItems: controller.totalItems.value,
                      limit: controller.limit.value,
                      currentPage: controller.currentPage.value,
                      onPageChanged: (newPage) {
                        controller.changePage(newPage);
                      },
                      onLimitChanged: (newLimit) {
                        controller.changeLimit(newLimit);
                      },
                      limitOptions: const [5, 10, 20, 50],
                    )),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSearchBar() {
    return SizedBox(
      width: 300,
      child: TextField(
        style: AppText.bodyMd,
        onChanged: controller.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search employees...',
          hintStyle: AppText.bodyMd.copyWith(color: AppColors.textMuted),
          prefixIcon: const Icon(Iconsax.search_normal_1,
              size: 18, color: AppColors.textMuted),
          filled: true,
          fillColor: AppColors.surfaceMuted,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: const OutlineInputBorder(
            borderRadius: AppRadii.brPill,
            borderSide: BorderSide.none,
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: AppRadii.brPill,
            borderSide: BorderSide(color: AppColors.borderSubtle),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: AppRadii.brPill,
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, bool isMobile) {
    final Widget trailing = isMobile
        ? PermissionGate(
            require: Perms.employeesCreate,
            child: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const AddEmployeeDialog(),
                );
              },
              icon: const Icon(Iconsax.add_circle,
                  color: AppColors.primary, size: 30),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.borderSubtle),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  shape: const RoundedRectangleBorder(
                      borderRadius: AppRadii.brMd),
                  textStyle:
                      AppText.bodyMd.copyWith(fontWeight: FontWeight.w600),
                ),
                child: const Text('Job Postings'),
              ),
              kSizedBoxWidth,
              PermissionGate(
                require: Perms.employeesCreate,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const AddEmployeeDialog(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    shape: const RoundedRectangleBorder(
                        borderRadius: AppRadii.brMd),
                    textStyle:
                        AppText.bodyMd.copyWith(fontWeight: FontWeight.w600),
                  ),
                  icon: const Icon(Iconsax.user_add, size: 18),
                  label: const Text('Add Employee'),
                ),
              ),
            ],
          );

    return PageHeader(
      title: 'Employee Directory',
      trailing: trailing,
    );
  }

  Widget _buildStatsRow(bool isMobile) {
    return Obx(() {
      final total = controller.totalItems.value;
      final contract = controller.employeeList
          .where((e) =>
              e.employmentType?.toLowerCase().contains('contract') ?? false)
          .length;

      if (isMobile) {
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: _buildStatCard(
                  label: 'Total Employees',
                  value: '$total',
                  icon: Iconsax.people,
                  accent: _accentGreen),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _buildStatCard(
                  label: 'Contract Staff',
                  value: '$contract',
                  icon: Iconsax.briefcase,
                  accent: _accentBlue),
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
                accent: _accentGreen),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _buildStatCard(
                label: 'Contract Staff',
                value: '$contract',
                icon: Iconsax.briefcase,
                accent: _accentBlue),
          ),
        ],
      );
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppText.bodySm.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: AppText.displayMd.copyWith(
                    color: AppColors.textPrimary,
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

  Widget _buildTabButton(String title) {
    final bool isSelected = _selectedTab == title;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = title;
        });
        final bool active = (title == 'Active');
        controller.filterByStatus(active);
      },
      borderRadius: AppRadii.brPill,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: AppRadii.brPill,
          border: Border.all(
            color:
                isSelected ? AppColors.primary : AppColors.borderSubtle,
          ),
        ),
        child: Text(
          title,
          style: AppText.bodyMd.copyWith(
            color: isSelected
                ? AppColors.textOnPrimary
                : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  List<DataColumn> _createColumns() {
    return const [
      DataColumn(label: Text('Name & ID')),
      DataColumn(label: Text('Designation')),
      DataColumn(label: Text('Department')),
      DataColumn(label: Text('Type')),
      DataColumn(label: Text('Status')),
      DataColumn(label: Text('Action')),
    ];
  }

  List<DataRow> _createRows(BuildContext context, List<Employee> employees) {
    return employees.map((emp) {
      final bool isActive = emp.isActive;
      final String statusText = isActive ? 'Active' : 'Inactive';

      return DataRow(
        cells: <DataCell>[
          DataCell(
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.surfaceMuted,
                  backgroundImage: emp.profilePicture != null &&
                          emp.profilePicture!.isNotEmpty &&
                          emp.profilePicture != 'string'
                      ? NetworkImage(emp.profilePicture!)
                      : null,
                  child: (emp.profilePicture == null ||
                          emp.profilePicture!.isEmpty ||
                          emp.profilePicture == 'string')
                      ? Text(
                          emp.firstName.isNotEmpty ? emp.firstName[0] : '?',
                          style: AppText.bodyMd.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${emp.firstName} ${emp.lastName}',
                      style: AppText.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      emp.employeeId ?? emp.id,
                      style: AppText.caption.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          DataCell(Text(
            emp.designation ?? emp.role,
            style: AppText.bodyMd.copyWith(color: AppColors.textSecondary),
          )),
          DataCell(Text(
            emp.departmentName ?? emp.departmentId?.toString() ?? '-',
            style: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
          )),
          DataCell(Text(
            emp.employmentType ?? 'Full-time',
            style: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
          )),
          DataCell(
            StatusChip(
              label: statusText,
              tone: isActive ? StatusTone.success : StatusTone.neutral,
            ),
          ),
          DataCell(
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (c) => EmployeeProfile(e: emp)));
              },
              borderRadius: AppRadii.brMd,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderSubtle),
                  borderRadius: AppRadii.brMd,
                  color: AppColors.surface,
                ),
                child: const Icon(Iconsax.more,
                    size: 18, color: AppColors.textMuted),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }
}
