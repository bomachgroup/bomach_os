import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/company/widget/add_branch_dialog.dart';
import 'package:bms_front_end/pages/company/widget/view_branch_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/model/branch_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/branch_controller.dart';

class BranchListPage extends StatelessWidget {
  const BranchListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BranchController controller = Get.put(BranchController());

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 700;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const MyText('Branches', style: AppText.black_600_32),
              MyElevatedButton(
                height: 40,
                icon: const Icon(Icons.add_circle_outline,
                    color: Colors.white, size: 18),
                child: isMobile ? "New" : "New Branch",
                onTap: () {
                  controller.loadFilterResources();
                  showDialog(
                    context: context,
                    builder: (context) => const AddBranchDialog(),
                  );
                },
              ),
            ],
          ),
          kSizedBox,

          // --- Filter Bar ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: MyTextFormField(
                        hintText: 'Search by name, role, department...',
                        onChanged: controller.onSearchChanged,
                        leading: Icon(Icons.search,
                            color: AppColors.grey1.withValues(alpha: 0.5)),
                      ),
                    ),
                    if (!isMobile) ...[
                      const SizedBox(width: 16),
                      _buildFilters(controller),
                    ],
                  ],
                ),
                if (isMobile) ...[
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _buildFilters(controller),
                  ),
                ]
              ],
            ),
          ),

          kSizedBoxSM,

          // --- Table / Cards ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
            ),
            child: Column(
              children: [
                Obx(() {
                  if (controller.isLoadingList.value) {
                    return const Center(
                        child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator()));
                  }
                  if (controller.branchList.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Column(
                          children: [
                            Icon(Icons.domain_disabled_outlined,
                                size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            const MyText('No branches found',
                                size: 14, color: Colors.grey),
                            const SizedBox(height: 8),
                            const MyText('Create a new branch to get started',
                                size: 12, color: Colors.grey),
                          ],
                        ),
                      ),
                    );
                  }

                  if (isMobile) {
                    return _buildCardList(
                        context, controller.branchList, controller);
                  }

                  return _buildDataTable(context, controller, constraints);
                }),
                const SizedBox(height: 16),
                Obx(() => PaginatorFooter(
                      totalItems: controller.totalItems.value,
                      limit: controller.limit.value,
                      currentPage: controller.currentPage.value,
                      onPageChanged: controller.goToPage,
                      onLimitChanged: controller.setLimit,
                      isMobile: isMobile,
                    )),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildDataTable(BuildContext context, BranchController controller,
      BoxConstraints constraints) {
    return SizedBox(
      width: double.infinity,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
        dataRowMinHeight: 60,
        dataRowMaxHeight: 60,
        columnSpacing: 16,
        horizontalMargin: 12,
        columns: const [
          DataColumn(label: MyText("ID")),
          DataColumn(label: Expanded(child: MyText("Name"))),
          DataColumn(label: MyText("Type")),
          DataColumn(label: MyText("Location")),
          DataColumn(label: MyText("Status")),
          DataColumn(label: MyText("Action")),
        ],
        rows: _buildRows(context, controller.branchList, controller),
      ),
    );
  }

  Widget _buildCardList(BuildContext context, List<Branch> branches,
      BranchController controller) {
    return Column(
      children: branches.map((branch) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: MyText(branch.branchName, weight: 600, size: 14),
                  ),
                  _buildStatusBadge(branch.operationalStatusDisplay),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.tag, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  MyText("#${branch.id}", size: 12, color: Colors.grey),
                  const SizedBox(width: 16),
                  Icon(Icons.business, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: MyText(
                      branch.branchRoleDisplay.isNotEmpty
                          ? branch.branchRoleDisplay
                          : branch.branchRole,
                      size: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: MyText(
                      _branchLocation(branch),
                      size: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildCardAction(
                    icon: Icons.visibility_outlined,
                    label: "View",
                    onTap: () {
                      controller.fetchBranchDetails(branch.id);
                      showDialog(
                        context: context,
                        builder: (_) => const ViewBranchDialog(),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildCardAction(
                    icon: Icons.edit_outlined,
                    label: "Edit",
                    onTap: () {
                      controller.loadFilterResources();
                      showDialog(
                        context: context,
                        builder: (_) => AddBranchDialog(branchToEdit: branch),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCardAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(BranchController controller) {
    return Obx(() => Row(
          children: [
            _buildDropdown(
              hint: "All Types",
              value: controller.filterBranchRole.value != null
                  ? controller.fieldChoices.value?.branchRole
                          .firstWhereOrNull((e) =>
                              e.value == controller.filterBranchRole.value)
                          ?.label ??
                      "All Types"
                  : "All Types",
              items: [
                "All Types",
                ...?controller.fieldChoices.value?.branchRole
                    .map((e) => e.label)
              ],
              onChanged: (val) => controller.onTypeFilterChanged(val),
            ),
            const SizedBox(width: 12),
            _buildStateFilterField(controller),
            const SizedBox(width: 12),
            _buildDropdown(
              hint: "Status",
              value: controller.filterStatus.value != null
                  ? controller.fieldChoices.value?.operationalStatus
                          .firstWhereOrNull(
                              (e) => e.value == controller.filterStatus.value)
                          ?.label ??
                      "All Status"
                  : "All Status",
              items: [
                "All Status",
                ...?controller.fieldChoices.value?.operationalStatus
                    .map((e) => e.label)
              ],
              onChanged: (val) => controller.onStatusFilterChanged(val),
            ),
          ],
        ));
  }

  /// Prefer state > city > country for the list/grid blurb.
  String _branchLocation(Branch branch) {
    if (branch.state.isNotEmpty) return branch.state;
    if (branch.city.isNotEmpty) return branch.city;
    return branch.country;
  }

  /// Free-text state filter. Backend no longer exposes a state table, so we
  /// forward whatever the admin types as a `state` query param.
  Widget _buildStateFilterField(BranchController controller) {
    return SizedBox(
      width: 160,
      child: MyTextFormField(
        hintText: 'State',
        onChanged: (val) => controller.onStateFilterChanged(val),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          icon: const Icon(Icons.keyboard_arrow_down,
              size: 18, color: Colors.grey),
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  List<DataRow> _buildRows(BuildContext context, List<Branch> branches,
      BranchController controller) {
    return branches.map((branch) {
      return DataRow(cells: [
        DataCell(MyText("#${branch.id}", color: Colors.grey, size: 13)),
        DataCell(MyText(branch.branchName, weight: 500, size: 13)),
        DataCell(MyText(
            branch.branchRoleDisplay.isNotEmpty
                ? branch.branchRoleDisplay
                : branch.branchRole,
            size: 13)),
        DataCell(MyText(_branchLocation(branch), size: 13)),
        DataCell(_buildStatusBadge(branch.operationalStatusDisplay)),
        DataCell(
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              switch (value) {
                case 'view':
                  controller.fetchBranchDetails(branch.id);
                  showDialog(
                    context: context,
                    builder: (_) => const ViewBranchDialog(),
                  );
                  break;
                case 'edit':
                  controller.loadFilterResources();
                  showDialog(
                    context: context,
                    builder: (_) => AddBranchDialog(branchToEdit: branch),
                  );
                  break;
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'view',
                child: Row(children: [
                  Icon(Icons.visibility_outlined, size: 18, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('View Details'),
                ]),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Edit'),
                ]),
              ),
            ],
          ),
        ),
      ]);
    }).toList();
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status.toLowerCase().contains('active') ||
        status.toLowerCase().contains('operational')) {
      color = Colors.green;
    } else if (status.toLowerCase().contains('inactive') ||
        status.toLowerCase().contains('closed')) {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(status,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
