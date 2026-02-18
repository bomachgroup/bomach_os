import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/input/my_dropdown2.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/nav/three_dot_pop.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/widget/add_leave_request_dialog.dart';
import 'package:bms_front_end/pages/hr/widget/view_leave_request_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/leave_request_controller.dart';
import 'models/leave_request_model.dart';

class LeaveRequestPage extends StatefulWidget {
  const LeaveRequestPage({super.key});

  @override
  State<LeaveRequestPage> createState() => LeaveRequestPageState();
}

class LeaveRequestPageState extends State<LeaveRequestPage> {
  final ScrollController _scrollController = ScrollController();
  final LeaveRequestController _ctrl = Get.put(LeaveRequestController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.fetchLeaveRequests(context);
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
                        'Leave-request',
                        style: AppText.black_500_32,
                      ),
                    ],
                  ),
                  MyElevatedButton(
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.white,
                    ),
                    child: "New Leave Request",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const AddLeaveRequestDialog();
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
                      hintText: 'Search by name',
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
                      SortBar(text: "All States"),
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
          child: Obx(() {
            if (_ctrl.isLoading.value) {
              return const SizedBox(
                height: 400,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (_ctrl.hasError.value) {
              return SizedBox(
                height: 400,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.red,
                      ),
                      const SizedBox(height: 16),
                      MyText(
                        _ctrl.errorMessage.value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      MyElevatedButton(
                        child: 'Retry',
                        onTap: () {
                          _ctrl.fetchLeaveRequests(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            if (_ctrl.leaveList.isEmpty) {
              return const SizedBox(
                height: 400,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Color(0xFFBDBDBD),
                      ),
                      SizedBox(height: 16),
                      MyText(
                        'No leave requests found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
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
                      constraints: BoxConstraints(
                        minWidth: bodySpace(context),
                      ),
                      child: DataTable(
                        dataRowMinHeight: 68,
                        dataRowMaxHeight: 68,
                        columnSpacing: 24,
                        horizontalMargin: 12,
                        columns: _createColumns(),
                        rows: _createRows(context, _ctrl.leaveList),
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
    return [
      const DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: MyText(
          "Employee ID",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Name & Email",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Start Date",
        ),
      ),
      const DataColumn(
        label: MyText(
          "End Date",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Leave Type",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Status",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Action",
        ),
      ),
    ];
  }

  List<DataRow> _createRows(BuildContext context, List<LeaveRequest> items) {
    return items.map((r) {
      return DataRow(cells: <DataCell>[
        DataCell(
          MyText(
            r.employeeId,
            size: 16,
            weight: 400,
            isSelectable: false,
          ),
        ),
        DataCell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return ViewLeaveRequestDialog(request: r);
              },
            );
          },
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyText(
                r.employeeId,
                style: const TextStyle(fontWeight: FontWeight.bold),
                isSelectable: false,
              ),
              MyText(
                r.createdAt != null
                    ? r.createdAt!.toIso8601String().split('T').first
                    : '',
                isSelectable: false,
              ),
            ],
          ),
        ),
        DataCell(
          MyText(
            r.startDate != null
                ? r.startDate!.toIso8601String().split('T').first
                : '',
          ),
        ),
        DataCell(
          MyText(r.endDate != null
              ? r.endDate!.toIso8601String().split('T').first
              : ''),
        ),
        DataCell(
          MyText(r.leaveType),
        ),
        const DataCell(
          MyDropdown2(),
        ),
        DataCell(
          ThreeDotPop(
            onTapEdit: () {
              _ctrl.populateForm(r);
              showDialog(
                  context: context,
                  builder: (_) => AddLeaveRequestDialog(request: r));
            },
          ),
        ),
      ]);
    }).toList();
  }
}
