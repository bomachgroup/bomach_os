import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/input/my_dropdown2.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/nav/three_dot_pop.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/widget/add_job_post_dialog.dart';
import 'package:bms_front_end/pages/hr/widget/view_job_post_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

class JobPostPage extends StatefulWidget {
  const JobPostPage({super.key});

  @override
  State<JobPostPage> createState() => JobPostPageState();
}

class JobPostPageState extends State<JobPostPage> {
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
                        'Job Postings',
                        style: AppText.black_500_32,
                      ),
                    ],
                  ),
                  MyElevatedButton(
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.white,
                    ),
                    child: "New Job Post",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const AddJobPostDialog();
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
                      hintText: 'Search for Job Postings...',
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
        label: MyText(
          "Job Title",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Department",
        ),
      ),
      const DataColumn(
          label: MyText(
        "Location",
      )),
      const DataColumn(
        label: MyText(
          "Job Type",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Status",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Applicants",
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
          MyText(
            "Operational Manager",
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
                return const ViewJobPostDialog();
              },
            );
          },
          const MyText(
            "Operations",
            isSelectable: false,
          ),
        ),
        const DataCell(
          MyText("Enugu"),
        ),
        const DataCell(
          MyText("Full-Time", size: 14, weight: 300),
        ),
        const DataCell(
          MyDropdown2(),
        ),
        const DataCell(
          MyText("510", size: 14, weight: 300),
        ),
        const DataCell(
          ThreeDotPop(),
        ),
      ]);
    });
  }
}
