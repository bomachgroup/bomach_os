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

class JobApplicatantsPage extends StatefulWidget {
  const JobApplicatantsPage({super.key});

  @override
  State<JobApplicatantsPage> createState() => JobApplicatantsPageState();
}

class JobApplicatantsPageState extends State<JobApplicatantsPage> {
  final ScrollController _scrollController = ScrollController();
  String? selectedStageFilter;
  String? selectedStatusFilter;

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
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const AddJobApplicantDialog();
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
                    width: isMobile ? double.infinity : 250,
                    child: MyTextFormField(
                      hintText: 'Search for Applicants...',
                      leading: Icon(
                        Icons.search,
                        color: AppColors.grey1.withValues(alpha: 0.5),
                      ),
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
                            setState(() {
                              selectedStageFilter = value;
                            });
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
                            setState(() {
                              selectedStatusFilter = value;
                            });
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
                      dataRowMinHeight: 80,
                      dataRowMaxHeight: 80,
                      columnSpacing: isMobile ? 16 : 24,
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
    return const [
      DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: MyText(
          "Applicant",
          weight: 600,
        ),
      ),
      DataColumn(
        label: MyText(
          "Job Title",
          weight: 600,
        ),
      ),
      DataColumn(
        label: MyText(
          "Phone",
          weight: 600,
        ),
      ),
      DataColumn(
        label: MyText(
          "Rating",
          weight: 600,
        ),
      ),
      DataColumn(
        label: MyText(
          "Stage",
          weight: 600,
        ),
      ),
      DataColumn(
        label: MyText(
          "Status",
          weight: 600,
        ),
      ),
      DataColumn(
        label: MyText(
          "Action",
          weight: 600,
        ),
      ),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    final applicants = _getMockApplicants();

    return applicants.map((applicant) {
      return DataRow(
        cells: <DataCell>[
          DataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyText(
                  applicant['name']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                MyText(
                  applicant['email']!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                MyText(
                  'ID: ${applicant['jobId']!}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          DataCell(
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return const ViewJobPostDialog();
                  },
                );
              },
              child: MyText(
                applicant['jobTitle']!,
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
            MyText(
              applicant['phone']!,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          DataCell(
            _buildRatingWidget(applicant['rating']!),
          ),
          DataCell(
            _buildStageChip(applicant['stage']!),
          ),
          DataCell(
            _buildStatusChip(applicant['status']!),
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
            return const Icon(
              Icons.star,
              size: 16,
              color: Colors.amber,
            );
          } else if (index == fullStars && hasHalfStar) {
            return const Icon(
              Icons.star_half,
              size: 16,
              color: Colors.amber,
            );
          } else {
            return Icon(
              Icons.star_border,
              size: 16,
              color: Colors.grey.shade300,
            );
          }
        }),
        const SizedBox(width: 4),
        MyText(
          rating,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStageChip(String stage) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (stage) {
      case 'Applied':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        icon = Icons.article_outlined;
        break;
      case 'Screening':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        icon = Icons.search;
        break;
      case 'Interview':
        bgColor = Colors.purple.shade50;
        textColor = Colors.purple.shade700;
        icon = Icons.video_call;
        break;
      case 'Offered':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        icon = Icons.workspace_premium;
        break;
      case 'Rejected':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        icon = Icons.cancel_outlined;
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          MyText(
            stage,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'New':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        break;
      case 'In Review':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      case 'Shortlisted':
        bgColor = Colors.purple.shade50;
        textColor = Colors.purple.shade700;
        break;
      case 'Hired':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case 'Rejected':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: MyText(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<Map<String, String>> _getMockApplicants() {
    return [
      {
        'jobId': 'K997KD',
        'name': 'John Michael',
        'email': 'johnmichael@gmail.com',
        'jobTitle': 'Operations Manager',
        'phone': '+234 812 3456 789',
        'rating': '4.5',
        'stage': 'Interview',
        'status': 'In Review',
      },
      {
        'jobId': 'K998LD',
        'name': 'Sarah Williams',
        'email': 'sarah.williams@gmail.com',
        'jobTitle': 'Software Engineer',
        'phone': '+234 813 4567 890',
        'rating': '5.0',
        'stage': 'Offered',
        'status': 'Shortlisted',
      },
      {
        'jobId': 'K999MD',
        'name': 'David Brown',
        'email': 'david.brown@gmail.com',
        'jobTitle': 'Product Manager',
        'phone': '+234 814 5678 901',
        'rating': '3.5',
        'stage': 'Screening',
        'status': 'In Review',
      },
      {
        'jobId': 'K100ND',
        'name': 'Emily Davis',
        'email': 'emily.davis@gmail.com',
        'jobTitle': 'Marketing Specialist',
        'phone': '+234 815 6789 012',
        'rating': '4.0',
        'stage': 'Interview',
        'status': 'Shortlisted',
      },
      {
        'jobId': 'K101OD',
        'name': 'Michael Johnson',
        'email': 'mjohnson@gmail.com',
        'jobTitle': 'Data Analyst',
        'phone': '+234 816 7890 123',
        'rating': '4.5',
        'stage': 'Applied',
        'status': 'New',
      },
      {
        'jobId': 'K102PD',
        'name': 'Lisa Anderson',
        'email': 'lisa.a@gmail.com',
        'jobTitle': 'HR Specialist',
        'phone': '+234 817 8901 234',
        'rating': '2.5',
        'stage': 'Rejected',
        'status': 'Rejected',
      },
      {
        'jobId': 'K103QD',
        'name': 'James Wilson',
        'email': 'james.w@gmail.com',
        'jobTitle': 'Sales Executive',
        'phone': '+234 818 9012 345',
        'rating': '3.0',
        'stage': 'Screening',
        'status': 'In Review',
      },
      {
        'jobId': 'K104RD',
        'name': 'Jennifer Martinez',
        'email': 'jennifer.m@gmail.com',
        'jobTitle': 'UI/UX Designer',
        'phone': '+234 819 0123 456',
        'rating': '4.8',
        'stage': 'Offered',
        'status': 'Hired',
      },
      {
        'jobId': 'K105SD',
        'name': 'Robert Taylor',
        'email': 'robert.t@gmail.com',
        'jobTitle': 'Accountant',
        'phone': '+234 820 1234 567',
        'rating': '3.8',
        'stage': 'Interview',
        'status': 'Shortlisted',
      },
      {
        'jobId': 'K106TD',
        'name': 'Amanda Garcia',
        'email': 'amanda.g@gmail.com',
        'jobTitle': 'Operations Manager',
        'phone': '+234 821 2345 678',
        'rating': '4.2',
        'stage': 'Applied',
        'status': 'New',
      },
    ];
  }
}
