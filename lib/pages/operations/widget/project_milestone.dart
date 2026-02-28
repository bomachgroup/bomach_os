import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/nav/three_dot_pop.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/helper/color.dart';
import 'package:flutter/material.dart';

class ProjectMilestone extends StatefulWidget {
  final int projectId;
  const ProjectMilestone({super.key, required this.projectId});

  @override
  State<ProjectMilestone> createState() => _ProjectMilestoneState();
}

class _ProjectMilestoneState extends State<ProjectMilestone> {
  final ScrollController _scrollController = ScrollController();

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
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: bodySpace(context)),
                child: DataTable(
                  columns: _createColumns(),
                  rows: _createRows(context),
                  showBottomBorder: true,
                ),
              ),
            ),
          ),
          // const PaginatorFooter(),
        ],
      ),
    );
  }

  List<DataColumn> _createColumns() {
    return const [
      DataColumn(label: MyText("S/N")),
      DataColumn(label: MyText("Milestone Title")),
      DataColumn(label: MyText("Cost")),
      DataColumn(label: MyText("Status")),
      DataColumn(label: MyText("Action")),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    // Placeholder rows - Connect to API using widget.projectId later
    return List.generate(5, (index) {
      return DataRow(cells: [
        DataCell(MyText("${index + 1}")),
        const DataCell(MyText("Foundation Phase")),
        const DataCell(MyText("\$5,000.00")),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color:
                  getRandomColorFromList('Incomplete').withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6)),
          child: const MyText("Incomplete"),
        )),
        const DataCell(ThreeDotPop()),
      ]);
    });
  }
}

class AddMileStoneDialog extends StatelessWidget {
  const AddMileStoneDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyText('Create Milestone',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(children: [
                      Expanded(
                          child: MyTextFormField(
                              title: 'Milestone Title*',
                              hintText: 'Enter title')),
                      SizedBox(width: 16),
                      Expanded(
                          child: MyTextFormField(
                              title: 'Cost*', hintText: '0.00')),
                    ]),
                    SizedBox(height: 24),
                    Row(children: [
                      Expanded(
                          child: MyDropdown(
                              title: 'Status*',
                              items: ['Pending', 'Completed'],
                              hintText: 'Select')),
                      SizedBox(width: 16),
                      Expanded(
                          child: MyTextFormField(
                              title: 'Deadline', hintText: 'YYYY-MM-DD')),
                    ]),
                    SizedBox(height: 24),
                    MyTextFormField(
                        title: 'Description',
                        maxLines: 3,
                        hintText: 'Milestone details...'),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                      child: 'Cancel', onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 16),
                  MyElevatedButton(child: 'Save', onTap: () {}),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
