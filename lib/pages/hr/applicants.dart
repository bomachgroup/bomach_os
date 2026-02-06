import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/nav/three_dot_pop.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/widget/add_job_applicant_dialog.dart';
import 'package:bms_front_end/pages/hr/widget/view_job_applicant_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/applicant_controller.dart';
import 'models/applicant_model.dart';


class JobApplicatantsPage extends StatefulWidget {
  const JobApplicatantsPage({super.key});

  @override
  State<JobApplicatantsPage> createState() => JobApplicatantsPageState();
}

class JobApplicatantsPageState extends State<JobApplicatantsPage> {
  final ScrollController _scrollController = ScrollController();
  
  final ApplicantController controller = Get.put(ApplicantController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchApplicants(context);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = !isLargeScreen(context);

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
                        'Applicants',
                        style: AppText.black_500_32,
                      ),
                      SizedBox(height: 4),
                      MyText(
                        'Track and manage job applicants',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  MyElevatedButton(
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.white,
                    ),
                    child: "New Applicant",
                    onTap: () {
                      controller.clearForm();
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const AddJobApplicantDialog(); // Create Mode
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

        // --- FILTERS ---
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 15,
                runSpacing: 15,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: isMobile ? double.infinity : 250,
                    child: MyTextFormField(
                      hintText: 'Search for Applicants...',
                      leading: Icon(
                        Icons.search,
                        color: AppColors.grey1.withOpacity(0.5),
                      ),
                      // Optional: Bind search to controller logic
                    ),
                  ),
                  Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    children: [
                      SizedBox(
                        width: isMobile ? double.infinity : 150,
                        child: MyDropdown(
                          hintText: 'All Stages',
                          items: const [
                            'All Stages',
                            'Applied',
                            'Screening',
                            'Interview',
                            'Offered',
                            'Rejected'
                          ],
                          onChanged: (value) {
                             controller.selectedStageFilter.value = value;
                             controller.fetchApplicants(context); // Refresh
                          },
                          height: 45,
                        ),
                      ),
                      SizedBox(
                        width: isMobile ? double.infinity : 150,
                        child: MyDropdown(
                          hintText: 'All Status',
                          items: const [
                            'All Status',
                            'New',
                            'In Review',
                            'Shortlisted',
                            'Hired',
                            'Rejected'
                          ],
                          onChanged: (value) {
                             controller.selectedStatusFilter.value = value;
                             controller.fetchApplicants(context); // Refresh
                          },
                          height: 45,
                        ),
                      ),
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
                      minWidth: bodySpace(context),
                    ),
                    // Use Obx to listen to controller data
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (controller.applicantList.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(child: MyText("No applicants found.")),
                        );
                      }

                      return DataTable(
                        dataRowMinHeight: 80,
                        dataRowMaxHeight: 80,
                        columnSpacing: isMobile ? 16 : 24,
                        horizontalMargin: 12,
                        columns: _createColumns(),
                        rows: _createRows(context, controller.applicantList),
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
    return const [
      DataColumn(label: MyText("Applicant", weight: 600)),
      DataColumn(label: MyText("Job ID", weight: 600)), // Changed Title to ID for table width
      DataColumn(label: MyText("Phone", weight: 600)),
      DataColumn(label: MyText("Rating", weight: 600)),
      DataColumn(label: MyText("Stage", weight: 600)),
      DataColumn(label: MyText("Status", weight: 600)),
      DataColumn(label: MyText("Action", weight: 600)),
    ];
  }

  List<DataRow> _createRows(BuildContext context, List<Applicant> applicants) {
    return applicants.map((applicant) {
      return DataRow(
        cells: <DataCell>[
          DataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyText(
                  "${applicant.firstName} ${applicant.lastName}",
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 2),
                MyText(
                  applicant.email,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          DataCell(
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => ViewJobApplicantDialog(applicant: applicant),
                );
              },
              child: MyText(
                applicant.jobPostingId,
                isSelectable: false,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          DataCell(
            MyText(applicant.phone, style: const TextStyle(fontSize: 13)),
          ),
          DataCell(
            _buildRatingWidget(applicant.rating.toString()),
          ),
          DataCell(
            _buildStageChip(applicant.stage),
          ),
          DataCell(
            _buildStatusChip(applicant.status),
          ),
          const DataCell(
            ThreeDotPop(),
          ),
        ],
      );
    }).toList();
  }
  
    Widget _buildRatingWidget(String rating) {
    final ratingValue = double.tryParse(rating) ?? 0;
    final fullStars = ratingValue.floor();
    final hasHalfStar = (ratingValue - fullStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          if (index < fullStars) {
            return const Icon(Icons.star, size: 16, color: Colors.amber);
          } else if (index == fullStars && hasHalfStar) {
            return const Icon(Icons.star_half, size: 16, color: Colors.amber);
          } else {
            return Icon(Icons.star_border, size: 16, color: Colors.grey.shade300);
          }
        }),
        const SizedBox(width: 4),
        MyText(rating, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildStageChip(String stage) {
    Color bgColor = Colors.grey.shade100;
    Color textColor = Colors.grey.shade700;
    IconData icon = Icons.help_outline;

    switch (stage) {
      case 'Applied':
        bgColor = Colors.blue.shade50; textColor = Colors.blue.shade700; icon = Icons.article_outlined; break;
      case 'Screening':
        bgColor = Colors.orange.shade50; textColor = Colors.orange.shade700; icon = Icons.search; break;
      case 'Interview':
        bgColor = Colors.purple.shade50; textColor = Colors.purple.shade700; icon = Icons.video_call; break;
      case 'Offered':
        bgColor = Colors.green.shade50; textColor = Colors.green.shade700; icon = Icons.workspace_premium; break;
      case 'Rejected':
        bgColor = Colors.red.shade50; textColor = Colors.red.shade700; icon = Icons.cancel_outlined; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          MyText(stage, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
     Color bgColor = Colors.grey.shade100;
    Color textColor = Colors.grey.shade700;

    switch (status) {
      case 'New': bgColor = Colors.blue.shade50; textColor = Colors.blue.shade700; break;
      case 'In Review': bgColor = Colors.orange.shade50; textColor = Colors.orange.shade700; break;
      case 'Shortlisted': bgColor = Colors.purple.shade50; textColor = Colors.purple.shade700; break;
      case 'Hired': bgColor = Colors.green.shade50; textColor = Colors.green.shade700; break;
      case 'Rejected': bgColor = Colors.red.shade50; textColor = Colors.red.shade700; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: MyText(status, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }
}