import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DocumentsTable extends StatefulWidget {
  const DocumentsTable({super.key});

  @override
  State<DocumentsTable> createState() => _DocumentsTableState();
}

class _DocumentsTableState extends State<DocumentsTable> {
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
          "S/N",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Document Title",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Date of uplaod",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Action",
        ),
      ),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    return List.generate(10, (index) {
      return DataRow(cells: <DataCell>[
        const DataCell(
          MyText("#001"),
        ),
        DataCell(
          onTap: () {},
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
                "CV",
                size: 16,
                weight: 400,
                isSelectable: false,
              ),
            ],
          ),
        ),
        const DataCell(
          MyText("02/02/2025"),
        ),
        DataCell(Row(
          children: [
            SvgPicture.asset("assets/svg/trash-can.svg"),
            kSizedBoxWidthSM,
            SvgPicture.asset("assets/svg/download3.svg"),
          ],
        )),
      ]);
    });
  }
}
