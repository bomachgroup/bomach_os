import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/input/upload_file.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LeavesPage extends StatefulWidget {
  const LeavesPage({super.key});

  @override
  State<LeavesPage> createState() => _LeavesPageState();
}

class _LeavesPageState extends State<LeavesPage> {
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
        const Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  'Leaves',
                  style: AppText.black_600_32,
                ),
                MyText(
                  'Leaves',
                  style: AppText.black_600_14,
                ),
              ],
            ),
          ],
        ),
        kSizedBoxBG,
        Wrap(
          spacing: 15, // Horizontal space between items
          runSpacing: 15, // Vertical space when wrapping
          children: [
            MyElevatedButton(
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.white,
              ),
              child: 'New Leave',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const AssignLeaveDialog(),
                );
              },
            ),
            SizedBox(
              width: 220,
              height: 48,
              child: MyTextFormField(
                hintText: 'Search...',
                leading: Icon(
                  Icons.search,
                  color: AppColors.grey1.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SortBar(
              text: 'Sort',
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
        )
      ],
    );
  }

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: MyText(
          "Employee ID",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Employee Name",
        ),
      ),
      const DataColumn(
          label: MyText(
        "Leave date",
      )),
      const DataColumn(
        label: MyText(
          "Duration",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Leave Type",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Paid",
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
          MyText("#23456"),
        ),
        DataCell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const LeaveDetailsDialog(),
            );
          },
          Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                width: 36,
                height: 36,
                child: Image.asset('assets/icons/profile-icon.png'),
              ),
              const SizedBox(
                width: 8,
              ),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    "Darlene Robertson",
                    size: 16,
                    weight: 400,
                    isSelectable: false,
                  ),
                  MyText(
                    "UI/UX Designer",
                    size: 14,
                    weight: 300,
                    isSelectable: false,
                  )
                ],
              ),
            ],
          ),
        ),
        const DataCell(
          MyText("11/02/2024"),
        ),
        const DataCell(
          MyText("5 days"),
        ),
        const DataCell(
          MyText("Yes"),
        ),
        DataCell(
          SizedBox(
            width: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 0.6,
                              color: getRandomColorFromList('Earned👍🏼')),
                          color: getRandomColorFromList('Earned👍🏼')
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6)),
                      child: const Center(
                        child: MyText("Earned👍🏼"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              Container(
                height: 10,
                width: 10,
                decoration: const ShapeDecoration(
                  color: AppColors.green2,
                  shape: OvalBorder(),
                ),
              ),
              kSizedBoxWidthTiny,
              const MyText("Approved"),
            ],
          ),
        ),
      ]);
    });
  }
}

class LeaveDetailsDialog extends StatelessWidget {
  const LeaveDetailsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
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
                  const MyText(
                    'Leave Details',
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
            kSizedBoxTiny,

            // Apply date
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const MyText(
                'Apply date: 12-01-2024, 11:20am',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
            kSizedBox,

            const Divider(height: 1),

            // Form fields
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      _buildFormField('Applicant Name*',
                          'Darlene Robertson (UI/UX Designer)'),
                      _buildFormField('Leave date*', '12-12-2024'),
                      _buildFormField('Leave duration*', '5days'),
                      _buildStatusField('Status*', 'Pending'),
                      _buildTagField('Leave type*', 'Casual'),
                      _buildFormField(
                        'Reason for Absence*',
                        'gfvdcisvyif viyfgdsykgoql fyifds9yifvy viyfdsykfgovldsg fy9ivsyvog higvysidyobu ihbsfbvyou hivscy9bvxog isziyvkg 8 isvxyiy9ikx y8svicxb8yh9b y8svcyfgz9c7ioh y8vsiby9gox',
                        maxLines: 4,
                      ),
                      _buildFormField('Start date*', '12-01-2024'),
                      _buildFormField('End date*', '13-09-2024'),
                      _buildFileField('Files*', 'No file found'),
                    ],
                  ),
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      runSpacing: 20,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        // Left-aligned buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MyElevatedButton(
                              bgColor: AppColors.green2,
                              icon: SvgPicture.asset(
                                "assets/svg/check.svg",
                                colorFilter: const ColorFilter.mode(
                                    AppColors.white, BlendMode.srcIn),
                              ),
                              child: 'Approve',
                              onTap: () {},
                            ),
                            const SizedBox(width: 12),
                            MyElevatedButton(
                              bgColor: AppColors.red,
                              icon: SvgPicture.asset(
                                "assets/svg/x.svg",
                                colorFilter: const ColorFilter.mode(
                                    AppColors.white, BlendMode.srcIn),
                              ),
                              child: 'Cancel',
                              onTap: () {},
                            ),
                          ],
                        ),

                        // Right-aligned buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
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
                                    AppColors.white, BlendMode.srcIn),
                              ),
                              child: 'Edit',
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
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
            child: MyText(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: MyText(
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

  Widget _buildStatusField(String label, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: MyText(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const MyText(
                'Pending',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagField(String label, String tag) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: MyText(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: MyText(
              tag,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 200,
                child: MyText(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              MyText(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Center(
            child: UploadFile(),
          ),
        ],
      ),
    );
  }
}

class AssignLeaveDialog extends StatefulWidget {
  const AssignLeaveDialog({super.key});

  @override
  State<AssignLeaveDialog> createState() => _AssignLeaveDialogState();
}

class _AssignLeaveDialogState extends State<AssignLeaveDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
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
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.grey4),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyText(
                    'Assign leave/Edit',
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
                          // Choose Employee
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyDropdown(
                                  hintText: "----",
                                  items: [],
                                  spaceBetweenText: 10,
                                  title: 'Choose Employee*',
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          // Leave Type
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyDropdown(
                                  hintText: "----",
                                  items: [],
                                  spaceBetweenText: 10,
                                  title: 'Leave Type*',
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
                                  hintText: "----",
                                  items: [],
                                  spaceBetweenText: 10,
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
                                MyTextFormField(
                                  hintText: '----',
                                  spaceBetweenText: 10,
                                  title: 'Leave date*',
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
                            spaceBetweenText: 10,
                            title: 'Reason for absence*',
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
                                  spaceBetweenText: 10,
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
                                  spaceBetweenText: 10,
                                  title: 'Start date(optional)*',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // File upload and Duration
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // File upload
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  'File (optional)*',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                UploadFile(),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          // Duration
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyTextFormField(
                                  spaceBetweenText: 10,
                                  title: 'Start date(optional)*',
                                  hintText: '12-10-2024',
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
                          AppColors.white, BlendMode.srcIn),
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
