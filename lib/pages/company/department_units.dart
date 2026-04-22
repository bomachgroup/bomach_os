import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../src/constants/spaces.dart';
import 'controllers/department_units_controller.dart';
import 'widget/department_units_dialogs.dart';

class DepartmentsUnitsPage extends StatelessWidget {
  const DepartmentsUnitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DepartmentsUnitsController controller =
        Get.put(DepartmentsUnitsController());

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 900;

      return RefreshIndicator(
        onRefresh: controller.fetchData,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. HEADER & TITLE ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyText('Departments & Units',
                      style: AppText.displayLg),
                  if (!isMobile) _buildHeaderBtn(context, controller),
                ],
              ),
              const SizedBox(height: 8),
              const Text("Manage departments & units",
                  style: TextStyle(color: AppColors.neutral500, fontSize: 14)),
              const SizedBox(height: 24),

              // --- 2. STATS CARDS ---
              Obx(() => Row(
                    children: [
                      Expanded(
                          child: _buildStatCard(
                              "Departments",
                              "${controller.totalDepartments}",
                              Iconsax.people)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildStatCard(
                              "Units",
                              "${controller.totalUnits}",
                              Iconsax.hierarchy)),
                    ],
                  )),
              const SizedBox(height: 32),

              // --- 3. BIG TABS ---
              Row(
                children: [
                  Expanded(child: _buildTab(controller, "Departments")),
                  Expanded(child: _buildTab(controller, "Units")),
                ],
              ),
              const SizedBox(height: 32),

              // --- 4. SECTION HEADER (Title + Search + New Btn) ---
              // section header: responsive layout with search and filter
              _buildSectionHeader(context, controller, isMobile),
              const SizedBox(height: 16),

              // --- 6. TABLE & PAGINATION ---
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                      child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator()));
                }

                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: LayoutBuilder(
                        builder: (context, boxConstraints) {
                          // Dynamic spacing calculation for desktop table
                          double availableWidth = boxConstraints.maxWidth;
                          if (availableWidth == double.infinity) {
                            availableWidth = 1000;
                          }

                          // 5 Columns now (Checkbox removed)
                          double minSpacing = 20;
                          // Subtracting roughly 100 for margins/padding
                          double calculatedSpacing = (availableWidth - 100) / 5;

                          double finalSpacing = calculatedSpacing > minSpacing
                              ? calculatedSpacing
                              : minSpacing;

                          return Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.grey.shade100),
                            child: controller.currentTab.value == "Departments"
                                ? _buildDepartmentsTable(
                                    controller, context, finalSpacing,
                                    isMobile: isMobile)
                                : _buildUnitsTable(
                                    controller, context, finalSpacing,
                                    isMobile: isMobile),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Obx(() {
                      final filteredCount =
                          controller.currentTab.value == 'Departments'
                              ? controller.totalDepartmentsFiltered
                              : controller.totalUnitsFiltered;
                      return PaginatorFooter(
                        totalItems: filteredCount,
                        limit: controller.itemsPerPage.value,
                        currentPage: controller.currentPage.value + 1,
                        onPageChanged: (page) => controller.goToPage(page - 1),
                        onLimitChanged: (newLimit) =>
                            controller.setLimit(newLimit),
                      );
                    }),
                  ],
                );
              }),
            ],
          ),
        ),
      );
    });
  }

  // --- WIDGET HELPERS ---

  Widget _buildHeaderBtn(
      BuildContext context, DepartmentsUnitsController controller,
      {bool isCompact = false}) {
    return MyElevatedButton(
      height: 40,
      width: isCompact ? null : 180,
      onTap: () {
        if (controller.currentTab.value == "Departments") {
          showDialog(
              context: context, builder: (_) => const CreateDepartmentDialog());
        } else {
          showDialog(
              context: context, builder: (_) => const CreateUnitDialog());
        }
      },
      child: isCompact
          ? "New"
          : (controller.currentTab.value == "Departments"
              ? "New Department"
              : "New Unit"),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(3),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Text(value,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral800)),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral800)),
        ],
      ),
    );
  }

  Widget _buildTab(DepartmentsUnitsController controller, String label) {
    return GestureDetector(
      onTap: () => controller.switchTab(label),
      child: Obx(() {
        bool isActive = controller.currentTab.value == label;
        return Container(
          height: 50,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : AppColors.neutral500,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(BuildContext context,
      DepartmentsUnitsController controller, bool isMobile) {
    // Builds the top section showing current tab, optional company label,
    // search bar, status filter, and new-item button. Adjusts layout for mobile.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Obx(() => Text(controller.currentTab.value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral800))),
            if (!isMobile) ...[
              const SizedBox(width: 12),
              const Text("Bomach Group",
                  style: TextStyle(fontSize: 13, color: AppColors.neutral500)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: isMobile ? 120 : 250,
              height: 40,
              child: TextField(
                onChanged: (val) => controller.setSearch(val),
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon:
                      const Icon(Iconsax.search_normal, size: 18, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
              ),
            ),
            const Spacer(),
            _buildHeaderBtn(context, controller, isCompact: isMobile),
          ],
        ),
      ],
    );
  }

  // --- REFACTORED TABLES ---

  Widget _buildDepartmentsTable(DepartmentsUnitsController controller,
      BuildContext context, double spacing,
      {bool isMobile = false}) {
    final data = controller.paginatedDepartments;

    if (data.isEmpty) {
      return const Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: Text("No departments found")));
    }

    if (isMobile) {
      // card list for small screens
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: data.map((dept) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              title: Text(dept.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.neutral800)),
              subtitle: Text(dept.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.neutral400)),
              trailing: const Icon(Iconsax.arrow_right_3,
                  size: 20, color: AppColors.neutral400),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (_) =>
                        ViewDepartmentDetailsDialog(department: dept));
              },
            ),
          );
        }).toList(),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: bodySpace(context),
        ),
        child: DataTable(
          showCheckboxColumn: false, // Disables default checkbox

          dataRowMinHeight: 68,
          dataRowMaxHeight: 68,
          horizontalMargin: 12,
          showBottomBorder: true,
          columnSpacing: spacing,
          columns: const [
            DataColumn(
                columnWidth: IntrinsicColumnWidth(flex: 4.0),
                label: Text("Department",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral500))),
            DataColumn(
                columnWidth: IntrinsicColumnWidth(flex: 1.0),
                label: Text("Action",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral500))),
          ],
          rows: data.map((dept) {
            return DataRow(
              // Makes the entire row clickable
              onSelectChanged: (_) {
                showDialog(
                    context: context,
                    builder: (_) =>
                        ViewDepartmentDetailsDialog(department: dept));
              },
              cells: [
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(dept.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral800)),
                    Text(dept.description,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.neutral400)),
                  ],
                )),
                DataCell(PopupMenuButton<String>(
                  icon: const Icon(Iconsax.more,
                      size: 20, color: AppColors.neutral400),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 'view') {
                      showDialog(
                          context: context,
                          builder: (_) =>
                              ViewDepartmentDetailsDialog(department: dept));
                    } else if (value == 'edit') {
                      showDialog(
                          context: context,
                          builder: (_) =>
                              CreateDepartmentDialog(department: dept));
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'view',
                      child: Row(children: [
                        Icon(Iconsax.eye,
                            size: 18, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('View Details'),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Iconsax.edit, size: 18, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ]),
                    ),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildUnitsTable(DepartmentsUnitsController controller,
      BuildContext context, double spacing,
      {bool isMobile = false}) {
    final data = controller.paginatedUnits;

    if (data.isEmpty) {
      return const Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: Text("No units found")));
    }

    if (isMobile) {
      return Column(
        children: data.map((unit) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              title: Text(unit.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.neutral800)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(unit.departmentName ?? "-",
                      style: const TextStyle(color: AppColors.neutral600)),
                  Text(unit.hod ?? "-",
                      style: const TextStyle(color: AppColors.neutral600)),
                ],
              ),
              trailing: _buildStatusBadge(unit.status ?? "Active", controller),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (_) => ViewUnitDetailsDialog(unit: unit));
              },
            ),
          );
        }).toList(),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        showCheckboxColumn: false, // Disables default checkbox
        headingRowHeight: 48,
        dataRowMinHeight: 52, // Compact height
        dataRowMaxHeight: 52,
        horizontalMargin: 24,
        columnSpacing: spacing,
        columns: const [
          DataColumn(
              label: Text("Unit",
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.neutral500))),
          DataColumn(
              label: Text("Department",
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.neutral500))),
          DataColumn(
              label: Text("Head of Unit",
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.neutral500))),
          DataColumn(
              label: Text("Status",
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.neutral500))),
          DataColumn(
              label: Text("Action",
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.neutral500))),
        ],
        rows: data.map((unit) {
          return DataRow(
            // Makes the entire row clickable
            onSelectChanged: (_) {
              showDialog(
                  context: context,
                  builder: (_) => ViewUnitDetailsDialog(unit: unit));
            },
            cells: [
              DataCell(Text(unit.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.neutral800))),
              DataCell(Text(unit.departmentName ?? "-",
                  style: const TextStyle(color: AppColors.neutral600))),
              DataCell(Text(unit.hod ?? "-",
                  style: const TextStyle(color: AppColors.neutral600))),
              DataCell(_buildStatusBadge(unit.status ?? "Active", controller)),
              DataCell(PopupMenuButton<String>(
                icon: const Icon(Iconsax.more,
                    size: 20, color: AppColors.neutral400),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'view') {
                    showDialog(
                        context: context,
                        builder: (_) => ViewUnitDetailsDialog(unit: unit));
                  } else if (value == 'edit') {
                    showDialog(
                        context: context,
                        builder: (_) => CreateUnitDialog(unit: unit));
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'view',
                    child: Row(children: [
                      Icon(Iconsax.eye,
                          size: 18, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Iconsax.edit, size: 18, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ]),
                  ),
                ],
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusBadge(
      String status, DepartmentsUnitsController controller) {
    Color bg = controller.getStatusBg(status);
    Color fg = controller.getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.record_circle, size: 6, color: fg),
          const SizedBox(width: 6),
          Text(status,
              style: TextStyle(
                  color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
