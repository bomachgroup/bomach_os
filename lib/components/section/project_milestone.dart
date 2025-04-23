import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/section/project_task.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/helper/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ProjectMilestone extends StatefulWidget {
  const ProjectMilestone({super.key});

  @override
  State<ProjectMilestone> createState() => _ProjectMilestoneState();
}

class _ProjectMilestoneState extends State<ProjectMilestone> {
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
        label: Text(
          "S/N",
        ),
      ),
      const DataColumn(
        label: Text(
          "Milestone Title",
        ),
      ),
      const DataColumn(
        label: Text("Milestone cost"),
      ),
      const DataColumn(
          label: Text(
        "Task count",
      )),
      const DataColumn(
        label: Text(
          "Status",
        ),
      ),
      const DataColumn(
        label: Text(
          "Action",
        ),
      ),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    return List.generate(10, (index) {
      return DataRow(cells: <DataCell>[
        const DataCell(
          Text("1."),
        ),
        DataCell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const MilestoneDetailDialog(),
            );
          },
          const Text("Benji user UI"),
        ),
        const DataCell(
          Text("\$2.00"),
        ),
        const DataCell(
          Text("1"),
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
                            width: 0.6,
                            color: getRandomColorFromList('Incomplete')),
                        color: getRandomColorFromList('Incomplete')
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6)),
                    child: const Center(
                      child: Text("Incomplete"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const DataCell(
          Icon(Icons.more_vert_outlined),
        ),
      ]);
    });
  }
}

class AddMileStoneDialog extends StatefulWidget {
  const AddMileStoneDialog({super.key});

  @override
  State<AddMileStoneDialog> createState() => _AddMileStoneDialogState();
}

class _AddMileStoneDialogState extends State<AddMileStoneDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create Milestones',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Form fields
            const Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      // First row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyTextFormField(
                                  hintText: "Enter Milestone title",
                                  spaceBettwenText: 10,
                                  title: 'Milestone title*',
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyTextFormField(
                                  hintText: "Enter Milestone cost",
                                  spaceBettwenText: 10,
                                  title: 'Milestone Cost*',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Second row
                      Row(
                        children: [
                          // Status
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyDropdown(
                                  hintText: "Marital status",
                                  items: [],
                                  spaceBettwenText: 10,
                                  title: 'Status*',
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          // Leave date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyDropdown(
                                  hintText: 'Milestone title',
                                  spaceBettwenText: 10,
                                  title: 'Milestone title*',
                                  items: [],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Reason for absence
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyTextFormField(
                            maxLines: 4,
                            hintText: '----',
                            spaceBettwenText: 10,
                            title: 'Milestone Summary/Description*',
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Start and End dates
                      Row(
                        children: [
                          // Start date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyTextFormField(
                                  hintText: '----',
                                  spaceBettwenText: 10,
                                  title: 'Start date(optional)*',
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          // End date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyTextFormField(
                                  spaceBettwenText: 10,
                                  title: 'Start date(optional)*',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                    textColor: AppColors.darkGrey1,
                    borderColor: null,
                    child: 'Cancel',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 16),
                  MyElevatedButton(
                    icon: SvgPicture.asset(
                      "assets/svg/check.svg",
                      colorFilter: const ColorFilter.mode(
                          AppColors.whiteColor, BlendMode.srcIn),
                    ),
                    child: 'Save',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MilestoneDetailDialog extends StatelessWidget {
  const MilestoneDetailDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(kDefaultSpace),
        constraints: const BoxConstraints(maxWidth: 846),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            kSizedBox,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Milestone Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            kSizedBox,

            const Divider(height: 1),

            // Form fields
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormField('Milestone title*', 'Benji user UI'),
                          _buildFormField('Milestone Cost*', '\$2.00'),
                          _buildFormField('Status*', 'Incomplete'),
                          _buildFormField(
                            'Milestone smmary*',
                            'gfvdcisvyif viyfgdsykgogl fyifds9yifvy viyfdsykfgovldsg fy9ivsyvog higvysidyobu ihbsfbvyou hivscy9bvxog isziyvkg 8 isvxyiy9ikx y8svicxb8yh9b y8svcyfgz9c7ioh y8vsiby9gox',
                            maxLines: 4,
                          ),
                          _buildFormField('Start date*', '12-01-2024'),
                          _buildFormField('End date*', '13-09-2024'),
                        ],
                      ),
                    ),
                    const MyText("Tasks", size: 20, weight: 400),
                    kSizedBox,
                    const ProjectTask(),
                  ],
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                    textColor: AppColors.darkGrey1,
                    borderColor: null,
                    child: 'Cancel',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 12),
                  MyElevatedButton(
                    icon: SvgPicture.asset(
                      "assets/svg/edit-pencil.svg",
                      colorFilter: const ColorFilter.mode(
                          AppColors.whiteColor, BlendMode.srcIn),
                    ),
                    child: 'Edit',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment:
            maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              maxLines: maxLines,
            ),
          ),
        ],
      ),
    );
  }
}
