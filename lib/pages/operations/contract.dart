import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'controllers/contract_controller.dart';
import 'models/models.dart';
import 'widget/add_contract_dialog.dart';

class ContractPage extends StatefulWidget {
  final int? projectId; // Optional: to filter by project
  const ContractPage({super.key, this.projectId});

  @override
  State<ContractPage> createState() => ContractPageState();
}

class ContractPageState extends State<ContractPage> {
  final ScrollController _scrollController = ScrollController();
  final ContractController controller = Get.put(ContractController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchContracts(context, projectId: widget.projectId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Header ---
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
                      MyText('Contracts', style: AppText.black_500_32),
                      SizedBox(height: 8),
                      MyText('Manage your contracts', style: AppText.black_400_14),
                    ],
                  ),
                  Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    children: [
                      SizedBox(
                        width: 150,
                        child: MyTextFormField(
                          hintText: 'Search...',
                          leading: Icon(Icons.search, color: AppColors.grey1.withValues(alpha: 0.5)),
                          onChanged: (val) => controller.fetchContracts(context, projectId: widget.projectId, search: val),
                        ),
                      ),
                      const SortBar(text: "Sort"),
                      MyElevatedButton(
                        icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.white),
                        child: "Create Contract",
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => const AddContractDialog(),
                          );
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        kSizedBox,
        kSizedBoxSM,
        
        // --- Table ---
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.contracts.isEmpty) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(20),
                child: Text("No contracts found."),
              ));
            }

            return Column(
              children: [
                Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: bodySpace(context)),
                      child: DataTable(
                        dataRowMinHeight: 68,
                        dataRowMaxHeight: 68,
                        columnSpacing: 24,
                        horizontalMargin: 12,
                        columns: _createColumns(),
                        rows: _createRows(context, controller.contracts),
                        showBottomBorder: true,
                      ),
                    ),
                  ),
                ),
                const MyPaginator(),
              ],
            );
          }),
        ),
      ],
    );
  }

  List<DataColumn> _createColumns() {
    return const [
      DataColumn(label: MyText("Name")),
      DataColumn(label: MyText("Contract No.")),
      DataColumn(label: MyText("Type")),
      DataColumn(label: MyText("Value")),
      DataColumn(label: MyText("Start Date")),
      DataColumn(label: MyText("End Date")),
      DataColumn(label: MyText("Status")),
    ];
  }

  List<DataRow> _createRows(BuildContext context, List<Contract> contracts) {
    return contracts.map((contract) {
      return DataRow(cells: <DataCell>[
        DataCell(
          onTap: () {
            context.push(RouteConstants.operationsContractDetail, extra: contract);
          },
          MyText(contract.name.isEmpty ? '-' : contract.name, size: 16, weight: 500),
        ),
        DataCell(
          MyText(contract.contractNumber),
        ),
        DataCell(MyText(contract.contractType)),
        DataCell(MyText("₦${contract.value.toStringAsFixed(2)}")),
        DataCell(MyText(contract.startDate)),
        DataCell(MyText(contract.endDate)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: _getStatusColor(contract.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _getStatusColor(contract.status).withValues(alpha: 0.5))
            ),
            child: MyText(contract.status, color: _getStatusColor(contract.status)),
          ),
        ),
      ]);
    }).toList();
  }
  
  Color _getStatusColor(String status) {
    switch(status.toLowerCase()) {
      case 'active': return AppColors.green;
      case 'pending': return Colors.orange;
      case 'terminated': return AppColors.red;
      default: return AppColors.grey1;
    }
  }
}