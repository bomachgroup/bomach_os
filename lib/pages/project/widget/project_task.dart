import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';

class ProjectTask extends StatefulWidget {
  const ProjectTask({super.key});

  @override
  State<ProjectTask> createState() => _ProjectTaskState();
}

class _ProjectTaskState extends State<ProjectTask> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: MyText(
          "Task code",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Task Name",
        ),
      ),
      const DataColumn(
          label: MyText(
        "Assign to",
      )),
      const DataColumn(
        label: MyText(
          "Start date",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Due date",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Status",
        ),
      ),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    return List.generate(10, (index) {
      return DataRow(cells: <DataCell>[
        const DataCell(
          MyText("#1234567"),
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
          MyText("11/02/2024"),
        ),
        const DataCell(
          MyText("11/02/2024"),
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
              const MyText("Undone"),
            ],
          ),
        ),
      ]);
    });
  }
}
