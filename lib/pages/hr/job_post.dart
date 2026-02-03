import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/input/my_dropdown2.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/nav/three_dot_pop.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/controller/jobposting_control.dart';
import 'package:bms_front_end/pages/hr/widget/add_job_post_dialog.dart';
import 'package:bms_front_end/pages/hr/widget/view_job_post_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'models/job_posting.dart';

class JobPostPage extends StatefulWidget {
  const JobPostPage({super.key});

  @override
  State<JobPostPage> createState() => JobPostPageState();
}

class JobPostPageState extends State<JobPostPage> {
  final ScrollController _scrollController = ScrollController();
  
  final JobPostController controller = Get.put(JobPostController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchJobPostings(context);
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
        // --- HEADER ---
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
                      controller.clearForm();
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const AddJobPostDialog(); // No job passed = Create Mode
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

        // --- SEARCH & SORT ---
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
                        color: AppColors.grey1.withOpacity(0.5),
                      ),
                      // TODO: trigger search in controller
                      // onChanged: (val) => controller.fetchJobPostings(context, search: val), 
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

        // --- DATA TABLE ---
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
                      minWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (controller.jobList.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(child: MyText("No job postings found.")),
                        );
                      }

                      return DataTable(
                        dataRowMinHeight: 68,
                        dataRowMaxHeight: 68,
                        columnSpacing: 24,
                        horizontalMargin: 12,
                        columns: _createColumns(),
                        rows: _createRows(context, controller.jobList),
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
      const DataColumn(label: MyText("Job Title")),
      const DataColumn(label: MyText("Department")),
      const DataColumn(label: MyText("Branch")),
      const DataColumn(label: MyText("Job Type")),
      const DataColumn(label: MyText("Status")),
      const DataColumn(label: MyText("Salary")),
      const DataColumn(label: MyText("Action")),
    ];
  }

  List<DataRow> _createRows(BuildContext context, List<JobPosting> jobs) {
    return jobs.map((job) {
      return DataRow(cells: <DataCell>[
        DataCell(
          MyText(
            job.title,
            size: 16,
            weight: 400,
            isSelectable: false,
          ),
        ),
        DataCell(
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return ViewJobPostDialog(job: job);
                },
              );
            },
            child: MyText(
              job.departmentId, 
              isSelectable: false,
            ),
          ),
        ),
        DataCell(
          MyText(job.branchId),
        ),
        DataCell(
          MyText(job.jobType, size: 14, weight: 300),
        ),
        const DataCell(
          MyDropdown2(
            // TODO: modify MyDropdown2 to accept an initial value and onChange
            // initialValue: job.status,
            // onChanged: (val) => controller.updateJobStatus(context, job.id, val),
          ),
        ),
        DataCell(
          MyText(
            "${job.salaryRangeMin} - ${job.salaryRangeMax}", 
            size: 14, 
            weight: 300
          ),
        ),
        const DataCell(
          ThreeDotPop(
            //TODO: Bind actions here if your ThreeDotPop supports callbacks
          ),
        ),
      ]);
    }).toList();
  }
}