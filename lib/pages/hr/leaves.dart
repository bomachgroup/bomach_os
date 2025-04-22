import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/button/sort_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/color.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LeavesPage extends StatelessWidget {
  const LeavesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leaves',
                    style: AppText.black_600_32,
                  ),
                  Text(
                    'Leaves',
                    style: AppText.black_600_14,
                  ),
                ],
              ),
            ],
          ),
          kSizedBoxBG,
          Wrap(
            spacing: 8, // Horizontal space between items
            runSpacing: 8, // Vertical space when wrapping
            children: [
              MyElevatedButton(
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppColors.whiteColor,
                ),
                child: 'New Leave',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const LeaveDetailsDialog(),
                  );
                },
              ),
              kSizedBoxWidth,
              SizedBox(
                width: 220,
                height: 48,
                child: MyTextFormField(
                  hintText: 'Search...',
                  leading: Icon(
                    Icons.search,
                    color: AppColors.grey1.withOpacity(0.5),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Scrollbar(
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: SingleChildScrollView(
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
                      ),
                    ),
                  ),
                ),
                const MyPaginator(),
              ],
            ),
          )
        ],
      ),
    );
  }

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: Text(
          "Employee ID",
        ),
      ),
      const DataColumn(
        label: Text(
          "Employee Name",
        ),
      ),
      const DataColumn(
          label: Text(
        "Leave date",
      )),
      const DataColumn(
        label: Text(
          "Duration",
        ),
      ),
      const DataColumn(
        label: Text(
          "Leave Type",
        ),
      ),
      const DataColumn(
        label: Text(
          "Paid",
        ),
      ),
      const DataColumn(
        label: Text(
          "Status",
        ),
      ),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    return List.generate(10, (index) {
      return DataRow(cells: <DataCell>[
        const DataCell(
          Text("#23456"),
        ),
        DataCell(
          onTap: () {},
          GestureDetector(
            onTap: () {
              // context.go(RouteConstants.employeeProfile);
            },
            child: Row(
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
                    MyText("Darlene Robertson", size: 16, weight: 400),
                    MyText("UI/UX Designer", size: 14, weight: 300)
                  ],
                ),
              ],
            ),
          ),
        ),
        const DataCell(
          Text("11/02/2024"),
        ),
        const DataCell(
          Text("5 days"),
        ),
        const DataCell(
          Text("Yes"),
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
                            color: getRandomColorFromList('Earned👍🏼')),
                        color: getRandomColorFromList('Earned👍🏼')
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6)),
                    child: const Center(
                      child: Text("Earned👍🏼"),
                    ),
                  ),
                ],
              ),
            ],
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
              const Text("Approved"),
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
              child: const Text(
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
                                    AppColors.whiteColor, BlendMode.srcIn),
                              ),
                              child: 'Approve',
                              onTap: () {},
                            ),
                            const SizedBox(width: 12),
                            MyElevatedButton(
                              bgColor: AppColors.redColor,
                              icon: SvgPicture.asset(
                                "assets/svg/x.svg",
                                colorFilter: const ColorFilter.mode(
                                    AppColors.whiteColor, BlendMode.srcIn),
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
                                    AppColors.whiteColor, BlendMode.srcIn),
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

  Widget _buildStatusField(String label, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
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
              const Text(
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
            child: Text(
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
            child: Text(
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
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: DottedBorder(
              color: AppColors.blueColor,
              dashPattern: const [5, 5],
              strokeWidth: 2,
              borderType: BorderType.RRect,
              radius: const Radius.circular(8),
              child: SizedBox(
                width: double.infinity,
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: AppColors.blueColor,
                          borderRadius: BorderRadius.circular(10)),
                      width: 40,
                      height: 40,
                      child: SvgPicture.asset(
                        "assets/svg/upload.svg",
                      ),
                    ),
                    kSizedBoxSM,
                    const Text('Drag & Drop or choose files to upload'),
                    const MyText(
                      'Supported formats : Jpeg, pdf',
                      size: 11,
                      weight: 300,
                      color: AppColors.darkGrey2,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
