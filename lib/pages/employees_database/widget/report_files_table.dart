import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/helper/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ReportFilesTable extends StatefulWidget {
  const ReportFilesTable({super.key});

  @override
  State<ReportFilesTable> createState() => _ReportFilesTableState();
}

class _ReportFilesTableState extends State<ReportFilesTable> {
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
}

List<DataColumn> _createColumns() {
  return [
    const DataColumn(
      headingRowAlignment: MainAxisAlignment.start,
      label: MyText(
        "Date",
      ),
    ),
    const DataColumn(
      label: MyText(
        "Employee ID",
      ),
    ),
    const DataColumn(
      label: MyText("Report Title"),
    ),
    const DataColumn(
        label: MyText(
      "Report Type",
    )),
    const DataColumn(
      label: MyText(
        "Report status",
      ),
    ),
  ];
}

List<DataRow> _createRows(BuildContext context) {
  return List.generate(10, (index) {
    return DataRow(cells: <DataCell>[
      const DataCell(
        MyText("02/02/2025"),
      ),
      const DataCell(
        MyText("#Emeka@MRK20"),
      ),
      const DataCell(
        MyText("Milestone"),
      ),
      DataCell(
        Row(
          children: [
            SvgPicture.asset(
              "assets/svg/note2.svg",
              colorFilter: const ColorFilter.mode(
                AppColors.black,
                BlendMode.srcIn,
              ),
            ),
            kSizedBoxWidth,
            const MyText(
              "Benji Express user login Interface",
              size: 16,
              weight: 400,
              isSelectable: false,
            ),
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
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 0.6, color: getRandomColorFromList('Decline')),
                      color: getRandomColorFromList('Decline')
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6)),
                  child: const Center(
                    child: MyText("Decline"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ]);
  });
}
