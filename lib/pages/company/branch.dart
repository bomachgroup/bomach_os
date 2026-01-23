import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/nav/three_dot_pop.dart';
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

class BranchListPage extends StatefulWidget {
  const BranchListPage({super.key});

  @override
  State<BranchListPage> createState() => BranchListPageState();
}

class BranchListPageState extends State<BranchListPage> {
  final ScrollController _scrollController = ScrollController();

  final BranchController controller = Get.put(BranchController());

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showStateFilterDialog(BuildContext context) {
    if (controller.stateList.isEmpty) {
      controller.fetchStatesForCountry(1);
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Filter by State"),
          content: SizedBox(
            width: 300,
            child: Obx(() {
              if (controller.isFetchingStates.value) {
                return const LinearProgressIndicator();
              }

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text("All States",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () {
                        controller.fetchBranches();
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(),
                    ...controller.stateList.map((state) => ListTile(
                          title: Text(state.name),
                          onTap: () {
                            controller.applyStateFilter(state.id);
                            Navigator.pop(context);
                          },
                        )),
                  ],
                ),
              );
            }),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 10,
                runSpacing: 10,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        'Branch',
                        style: AppText.black_500_32,
                      ),
                    ],
                  ),
                  MyElevatedButton(
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.white,
                    ),
                    child: "New Branch",
                    onTap: () {
                      // Trigger loading resources before showing dialog
                      controller.loadFormResources();

                      showDialog(
                        context: context,
                        builder: (context) {
                          return const AddBranchDialog();
                        },
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
        kSizedBox,
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 15,
                runSpacing: 15,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 250,
                    child: MyTextFormField(
                      hintText: 'Search by name, role, department...',
                      onChanged: (val) {
                        controller.setSearch(val ?? '');
                      },
                      leading: Icon(
                        Icons.search,
                        color: AppColors.grey1.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  Row(
                    spacing: 15,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => _showStateFilterDialog(context),
                        child: const SortBar(text: "Filter State"),
                      ),
                      InkWell(
                        onTap: () => controller.toggleActiveFilter(),
                        child: Obx(() {
                          final isActive = controller.activeFilter.value;
                          return SortBar(
                            text: isActive ? "Active Only" : "All Status",
                          );
                        }),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        kSizedBox,
        kSizedBoxSM,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
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
                      minWidth: bodySpace(context),
                    ),
                    child: Obx(() {
                      if (controller.isLoadingList.value) {
                        return const SizedBox(
                          height: 300,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (controller.branchList.isEmpty) {
                        return const SizedBox(
                          height: 200,
                          child: Center(child: Text("No branches found.")),
                        );
                      }

                      return DataTable(
                        dataRowMinHeight: 68,
                        dataRowMaxHeight: 68,
                        columnSpacing: 24,
                        horizontalMargin: 12,
                        columns: _createColumns(),
                        rows: _createRows(context, controller.branchList),
                        showBottomBorder: true,
                      );
                    }),
                  ),
                ),
              ),
              const MyPaginator(),
            ],
          ),
        ),
      ],
    );
  }

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: MyText("Branch ID"),
      ),
      const DataColumn(label: MyText("Branch name")),
      const DataColumn(label: MyText("Location")),
      const DataColumn(label: MyText("Manager")),
      const DataColumn(label: MyText("Status")),
      const DataColumn(label: MyText("Action")),
    ];
  }

  List<DataRow> _createRows(BuildContext context, List<Branch> branches) {
    return branches.map((branch) {
      return DataRow(cells: <DataCell>[
        DataCell(
          MyText(
            branch.branchId.isNotEmpty ? branch.branchId : "#${branch.id}",
            size: 16,
            weight: 400,
            isSelectable: false,
          ),
        ),
        DataCell(
          onTap: () {
            controller.fetchBranchDetails(branch.id);

            showDialog(
              context: context,
              builder: (context) {
                return const ViewBranchDialog();
              },
            );
          },
          MyText(branch.branchName),
        ),
        DataCell(
          MyText(branch.stateName.isNotEmpty
              ? branch.stateName
              : branch.countryName),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                branch.managerName.isNotEmpty
                    ? branch.managerName
                    : "Unassigned",
                size: 16,
                weight: 400,
                isSelectable: false,
              ),
              MyText(branch.contactEmail, size: 14, weight: 300)
            ],
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: 0.6,
                          color: _getStatusColor(branch.operationalStatus)),
                      color: _getStatusColor(branch.operationalStatus)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: MyText(branch.operationalStatusDisplay.isNotEmpty
                          ? branch.operationalStatusDisplay
                          : "Unknown"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        DataCell(
          ThreeDotPop(
            onTapView: () {
              controller.fetchBranchDetails(branch.id);

              showDialog(
                context: context,
                builder: (context) {
                  return const ViewBranchDialog();
                },
              );
            },
            onTapEdit: () {
              controller.loadFormResources();

              showDialog(
                context: context,
                builder: (context) => AddBranchDialog(
                  branchToEdit: branch,
                ),
              );
            },
          ),
        ),
      ]);
    }).toList();
  }

  Color _getStatusColor(String status) {
    status = status.toLowerCase();
    if (status == 'active' || status == 'operational') {
      return Colors.green;
    } else if (status == 'inactive' || status == 'closed') {
      return Colors.red;
    } else if (status == 'maintenance') {
      return Colors.orange;
    }
    return Colors.grey;
  }
}
