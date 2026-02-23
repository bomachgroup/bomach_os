import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/nav/three_dot_pop.dart';
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
    final ScrollController scrollController = ScrollController();

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
              icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 18),
              child: "New Branch",
              onTap: () {
                controller.loadFilterResources(); // Ensure fresh data
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
                  // Search
                  Expanded(
                    flex: 2,
                    child: MyTextFormField(
                      hintText: 'Search by name, role, department...',
                      onChanged: controller.onSearchChanged,
                      leading: Icon(Icons.search, color: AppColors.grey1.withOpacity(0.5)),
                    ),
                  ),
                  if (MediaQuery.of(context).size.width > 900) ...[
                    const SizedBox(width: 16),
                    _buildFilters(controller),
                  ],
                ],
              ),
              // Mobile/Tablet Filter Wrap
              if (MediaQuery.of(context).size.width <= 900) ...[
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

        // --- Table ---
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
          ),
          child: Column(
            children: [
              Scrollbar(
                controller: scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 100),
                    child: Obx(() {
                      if (controller.isLoadingList.value) {
                        return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
                      }
                      if (controller.branchList.isEmpty) {
                        return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("No branches found.")));
                      }

                      return DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
                        dataRowMinHeight: 60,
                        dataRowMaxHeight: 60,
                        columnSpacing: 24,
                        horizontalMargin: 12,
                        columns: const [
                          DataColumn(label: MyText("ID")),
                          DataColumn(label: MyText("Name")),
                          DataColumn(label: MyText("Type")),
                          DataColumn(label: MyText("Location")),
                          DataColumn(label: MyText("Status")),
                          DataColumn(label: MyText("Action")),
                        ],
                        rows: _buildRows(context, controller.branchList, controller),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Pagination
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: controller.currentPage.value > 1 ? controller.prevPage : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: MyText("Page ${controller.currentPage.value}", color: AppColors.blue, weight: 600),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: controller.hasMore.value ? controller.nextPage : null,
                  ),
                ],
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(BranchController controller) {
    return Obx(() => Row(
      children: [
        // State Filter
        _buildDropdown(
          hint: "All States",
          value: controller.stateList.any((s) => s.id == controller.filterStateId.value) 
              ? controller.stateList.firstWhere((s) => s.id == controller.filterStateId.value).name 
              : "All States",
          items: ["All States", ...controller.stateList.map((s) => s.name)],
          onChanged: controller.onStateFilterChanged,
        ),
        const SizedBox(width: 12),
        // Type Filter (Branch Role)
        _buildDropdown(
          hint: "All Types",
          value: controller.filterBranchRole.value ?? "All Types",
          items: ["All Types", ...?controller.fieldChoices.value?.branchRole.map((e) => e.label)],
          onChanged: (val) => controller.onTypeFilterChanged(val == "All Types" ? null : val),
        ),
        const SizedBox(width: 12),
        // Status Filter
        _buildDropdown(
          hint: "Status",
          value: controller.filterStatus.value ?? "All Status",
          items: ["All Status", ...?controller.fieldChoices.value?.operationalStatus.map((e) => e.label)],
          onChanged: (val) => controller.onStatusFilterChanged(val == "All Status" ? null : val),
        ),
      ],
    ));
  }

  Widget _buildDropdown({required String hint, required String? value, required List<String> items, required Function(String?) onChanged}) {
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
          icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  List<DataRow> _buildRows(BuildContext context, List<Branch> branches, BranchController controller) {
    return branches.map((branch) {
      return DataRow(cells: [
        DataCell(MyText("#${branch.id}", color: Colors.grey)),
        DataCell(MyText(branch.branchName, weight: 500)),
        DataCell(MyText(branch.branchRoleDisplay.isNotEmpty ? branch.branchRoleDisplay : branch.branchRole)),
        DataCell(MyText(branch.stateName.isNotEmpty ? branch.stateName : branch.countryName)),
        DataCell(_buildStatusBadge(branch.operationalStatusDisplay)),
        DataCell(ThreeDotPop(
          onTapView: () {
            controller.fetchBranchDetails(branch.id);
            showDialog(context: context, builder: (_) => const ViewBranchDialog());
          },
          onTapEdit: () {
            controller.loadFilterResources();
            showDialog(context: context, builder: (_) => AddBranchDialog(branchToEdit: branch));
          },
        )),
      ]);
    }).toList();
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status.toLowerCase().contains('active') || status.toLowerCase().contains('operational')) color = Colors.green;
    else if (status.toLowerCase().contains('inactive') || status.toLowerCase().contains('closed')) color = Colors.red;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}