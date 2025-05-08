import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/button/sort_filter_bar.dart';
import 'package:bms_front_end/components/chart/process_status.dart';
import 'package:bms_front_end/components/input/my_checkbox.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/input/upload_file.dart';
import 'package:bms_front_end/components/nav/three_dot_pop.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText(
          'Projects',
          style: AppText.black_500_32,
        ),
        const MyText(
          'Projects',
          style: AppText.black_400_14,
        ),
        const SizedBox(
          height: 12,
        ),
        Wrap(
          runSpacing: kDefaultSpace,
          spacing: kDefaultSpace,
          children: [
            MyElevatedButton(
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.white,
              ),
              child: 'Add New Project',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddProjectDialog(),
                );
              },
            ),
            SizedBox(
              width: 180,
              child: MyTextFormField(
                hintText: 'Search...',
                leading: Icon(
                  Icons.search,
                  color: AppColors.grey1.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SortFilterBar(),
          ],
        ),
        kSizedBox,
        kSizedBoxSM,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
              border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
              borderRadius: BorderRadius.circular(16)),
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
              const SizedBox(
                height: 8,
              ),
            ],
          ),
        )
      ],
    );
  }

  List<DataColumn> _createColumns() {
    return [
      DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: MyCheckbox(
          isChecked: false,
          onChanged: (value) {},
          backgroundNotCheckedColor: AppColors.transparent,
          borderNotCheckedColor: AppColors.grey4,
        ),
      ),
      const DataColumn(
          headingRowAlignment: MainAxisAlignment.start,
          label: MyText(
            "PJ code",
          )),
      const DataColumn(
          label: MyText(
        "Project Name",
      )),
      const DataColumn(label: MyText("Members")),
      const DataColumn(
          label: MyText(
        "Start date",
      )),
      const DataColumn(
          label: MyText(
        "Deadline",
      )),
      const DataColumn(
          label: MyText(
        "Clients",
      )),
      const DataColumn(
          label: MyText(
        "Status",
      )),
      const DataColumn(
          label: MyText(
        "Action",
      )),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    return List.generate(10, (index) {
      return DataRow(cells: <DataCell>[
        DataCell(
          MyCheckbox(
            isChecked: false,
            onChanged: (value) {},
            backgroundNotCheckedColor: AppColors.transparent,
            borderNotCheckedColor: AppColors.grey4,
          ),
        ),
        const DataCell(
          SizedBox(width: 120, child: MyText("#455653")),
        ),
        DataCell(
          onTap: () {
            context.push(RouteConstants.eachProjects);
          },
          const SizedBox(
              width: 152,
              child: MyText(
                "Benji Express mobile app project",
                isSelectable: false,
              )),
        ),
        DataCell(
          SizedBox(
            width: 80,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const SizedBox(),
                Positioned(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        "assets/image/man-demo.png",
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: (20),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        "assets/icons/profile-icon.png",
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        "assets/image/man-demo.png",
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        "assets/icons/profile-icon.png",
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const DataCell(
          SizedBox(width: 100, child: MyText("27/09/2024")),
        ),
        const DataCell(
          SizedBox(width: 100, child: MyText("27/09/2024")),
        ),
        DataCell(
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
                    "MTN Nigeria",
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
          SizedBox(
            width: 160,
            child: ProgressStatus(),
          ),
        ),
        const DataCell(
          ThreeDotPop(),
        ),
      ]);
    });
  }
}

class AddProjectDialog extends StatefulWidget {
  const AddProjectDialog({super.key});

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyText(
                    'Add Project',
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyTextFormField(
                                      hintText: '---',
                                      spaceBetweenText: 10,
                                      title: 'Project Name',
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
                                      hintText: "PJ short code",
                                      title: 'Short Code',
                                    ),
                                  ],
                                ),
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
                                      hintText: '12-10-2024',
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
                                      hintText: "12-10-2024",
                                      title: 'Deadline(optional)*',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyDropdown(
                                      hintText: "----",
                                      items: [],
                                      spaceBetweenText: 10,
                                      title: 'Project Category*',
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
                                      title: 'Department(optional)*',
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
                                      title: 'Client*',
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
                                      hintText: "----",
                                      items: [],
                                      spaceBetweenText: 10,
                                      title: 'Employee/members*',
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
                                title: 'Project summary/Note*',
                              ),
                            ],
                          ),
                          SizedBox(height: 40),
                        ],
                      ),
                    ),
                    const Divider(
                      color: AppColors.card,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),

                          // File upload and Duration
                          const Row(
                            children: [
                              Expanded(
                                child: MyText(
                                  'Other Details',
                                  size: 32,
                                  weight: 600,
                                ),
                              ),
                              kSizedBoxWidthSM,
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 28,
                              )
                            ],
                          ),
                          const SizedBox(height: 24),

                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // File upload
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText(
                                      'Upload File (optional)',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    UploadFile(),
                                    SizedBox(height: 24),
                                    Row(
                                      children: [
                                        // Start date
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              MyDropdown(
                                                hintText: '----',
                                                spaceBetweenText: 10,
                                                title: 'Currency*',
                                                items: [],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        // End date
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              MyTextFormField(
                                                spaceBetweenText: 10,
                                                hintText: "----",
                                                title: 'Project Budget*',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.start,
                            alignment: WrapAlignment.start,
                            runSpacing: 15,
                            spacing: 25,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  MyCheckbox(
                                    isChecked: false,
                                    onChanged: (value) {},
                                  ),
                                  kSizedBoxWidthSM,
                                  const Expanded(
                                    child: MyText(
                                        "Send task notifications to Employee",
                                        size: 14,
                                        weight: 400),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  MyCheckbox(
                                    isChecked: false,
                                    onChanged: (value) {},
                                  ),
                                  kSizedBoxWidthSM,
                                  const Expanded(
                                    child: MyText(
                                        "Send task notifications to Employee",
                                        size: 14,
                                        weight: 400),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          kSizedBoxBG,
                        ],
                      ),
                    ),
                  ],
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
