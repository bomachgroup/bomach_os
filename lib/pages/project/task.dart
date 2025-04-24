import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => TaskPageState();
}

class TaskPageState extends State<TaskPage> {
  final ScrollController _scrollController = ScrollController();

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
        const Text(
          'Tasks',
          style: AppText.black_500_32,
        ),
        const SizedBox(
          height: 8,
        ),
        const Text(
          'Tasks',
          style: AppText.black_400_14,
        ),
        const SizedBox(
          height: 17,
        ),
        Wrap(
          runSpacing: kDefaultSpace,
          spacing: kDefaultSpace,
          children: [
            SizedBox(
              width: 217,
              height: 48,
              child: MyTextFormField(
                hintText: 'Search...',
                leading: Icon(
                  Icons.search,
                  color: AppColors.grey1.withValues(alpha: 0.5),
                ),
              ),
            ),
            MyElevatedButton(
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppColors.white,
                ),
                child: 'Add Task',
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const AlertDialog(
                          contentPadding: EdgeInsets.all(0),
                          content: null,
                        );
                      });
                })
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
                    child: DataTable(
                      dataRowMinHeight: 68,
                      dataRowMaxHeight: 68,
                      columnSpacing: 24,
                      horizontalMargin: 12,
                      columns: _createColumns(),
                      rows: _createRows(context),
                      showBottomBorder: true,
                    ),
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
        label: Text(
          "Task code",
        ),
      ),
      const DataColumn(
        label: Text(
          "Task Name",
        ),
      ),
      const DataColumn(
          label: Text(
        "Assign to",
      )),
      const DataColumn(
        label: Text(
          "Start date",
        ),
      ),
      const DataColumn(
        label: Text(
          "Due date",
        ),
      ),
      const DataColumn(
        label: Text(
          "Status",
        ),
      ),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    return List.generate(10, (index) {
      return DataRow(cells: <DataCell>[
        const DataCell(
          Text("#1234567"),
        ),
        DataCell(
          onTap: () {},
          const MyText("Benji Express user login Interface",
              size: 16, weight: 400),
        ),
        DataCell(
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            width: 36,
            height: 36,
            child: Image.asset('assets/icons/profile-icon.png'),
          ),
        ),
        const DataCell(
          Text("11/02/2024"),
        ),
        const DataCell(
          Text("11/02/2024"),
        ),
        DataCell(
          Row(
            children: [
              Container(
                height: 10,
                width: 10,
                decoration: const ShapeDecoration(
                  color: AppColors.blue,
                  shape: OvalBorder(),
                ),
              ),
              kSizedBoxWidthTiny,
              const Text("Undone"),
            ],
          ),
        ),
      ]);
    });
  }
}
