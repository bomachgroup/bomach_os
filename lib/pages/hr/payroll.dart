import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/nav/three_dot_pop.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/widget/add_payroll_dialog.dart';
import 'package:bms_front_end/pages/hr/widget/view_payroll_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import 'package:intl/intl.dart';

import 'controller/pay_roll_controller.dart';
import 'models/payroll_model.dart'; 

class PayrollPage extends StatefulWidget {
  const PayrollPage({super.key});

  @override
  State<PayrollPage> createState() => PayrollPageState();
}

class PayrollPageState extends State<PayrollPage> {
  final ScrollController _scrollController = ScrollController();
  final PayrollController controller = Get.put(PayrollController());

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
                        'Payroll',
                        style: AppText.black_500_32,
                      ),
                    ],
                  ),
                  MyElevatedButton(
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.white,
                    ),
                    child: "New Payroll",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const AddPayRollDialog();
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
                      hintText: 'Search...', 
                      leading: Icon(
                        Icons.search,
                        color: AppColors.grey1.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  const Row(
                    spacing: 15,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SortBar(text: "All States", 
                      // onTap: controller.fetchPayrolls
                      ), // Acts as refresh
                      SortBar(text: "Status"),
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
                      if (controller.isLoading.value) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ));
                      }
                      
                      if (controller.errorMessage.isNotEmpty) {
                        return Center(child: Text(controller.errorMessage.value));
                      }

                      if (controller.payrollList.isEmpty) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text("No payroll records found."),
                        ));
                      }

                      return DataTable(
                        dataRowMinHeight: 68,
                        dataRowMaxHeight: 68,
                        columnSpacing: 24,
                        horizontalMargin: 12,
                        columns: _createColumns(),
                        rows: _createRows(context, controller.payrollList),
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
      const DataColumn(label: MyText("Employee ID")),
      const DataColumn(label: MyText("Period")),
      const DataColumn(label: MyText("Disbursement Date")),
      const DataColumn(label: MyText("Gross Salary")),
      const DataColumn(label: MyText("Net Salary")),
      const DataColumn(label: MyText("Status")),
      const DataColumn(label: MyText("Action")),
    ];
  }

  List<DataRow> _createRows(BuildContext context, List<Payroll> items) {
    return items.map((payroll) {
      return DataRow(cells: <DataCell>[
        DataCell(
          MyText(
            payroll.employeeId,
            size: 16,
            weight: 400,
            isSelectable: false,
          ),
          onTap: () {
             showDialog(
              context: context,
              builder: (context) => ViewPayrollDialog(payroll: payroll),
            );
          },
        ),
        DataCell(MyText(payroll.payrollPeriod)),
        DataCell(MyText(payroll.disbursementDate != null 
          ? DateFormat('yyyy-MM-dd').format(payroll.disbursementDate!) 
          : '-')),
        DataCell(MyText(payroll.grossSalary.toStringAsFixed(2))),
        DataCell(MyText(payroll.netSalary.toStringAsFixed(2))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: payroll.status == 'paid' ? Colors.green.shade100 : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              payroll.status, 
              style: TextStyle(
                color: payroll.status == 'paid' ? Colors.green : Colors.orange
              )
            ),
          )
        ),
        const DataCell(
          ThreeDotPop(
          ),
        ),
      ]);
    }).toList();
  }
}