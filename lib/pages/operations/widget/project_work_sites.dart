import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/input/rich_text.dart';
import 'package:bms_front_end/components/input/upload_file.dart';
import 'package:bms_front_end/components/nav/employee_stepper.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/employees_database/widget/employee_table.dart';
import 'package:bms_front_end/pages/operations/widget/project_task_table.dart';
import 'package:bms_front_end/pages/operations/widget/site_equipment_table.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ProjectWorkSite extends StatefulWidget {
  const ProjectWorkSite({super.key});

  @override
  State<ProjectWorkSite> createState() => _ProjectWorkSiteState();
}

class _ProjectWorkSiteState extends State<ProjectWorkSite> {
  int selectionStepperState = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        kSizedBoxBG,
        Row(
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 20,
                runSpacing: 20,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: const MyText(
                      "Agbani Site, behind Orando fuel station, Eke Agbani",
                      size: 28,
                      weight: 500,
                      maxLines: 2,
                    ),
                  ),
                  MyElevatedButton(
                      child: "Add Employee",
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppColors.white,
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return const CreateWorkSiteReport();
                          },
                        );
                      })
                ],
              ),
            ),
          ],
        ),
        kSizedBox,
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EmployeeInfoStepper(
                  isActive: selectionStepperState == 0,
                  icon: SvgPicture.asset(
                    "assets/svg/person.svg",
                  ),
                  activeIcon: SvgPicture.asset(
                    "assets/svg/person-filled.svg",
                  ),
                  title: 'Employees',
                  onTap: () {
                    setState(() {
                      selectionStepperState = 0;
                    });
                  },
                ),
                kSizedBoxWidth,
                EmployeeInfoStepper(
                  isActive: selectionStepperState == 1,
                  icon: SvgPicture.asset(
                    "assets/svg/settings.svg",
                  ),
                  activeIcon: SvgPicture.asset(
                    "assets/svg/settings-filled.svg",
                  ),
                  title: 'Site Equipments',
                  onTap: () {
                    setState(() {
                      selectionStepperState = 1;
                    });
                  },
                ),
                kSizedBoxWidth,
                EmployeeInfoStepper(
                  isActive: selectionStepperState == 2,
                  icon: SvgPicture.asset(
                    "assets/svg/document.svg",
                  ),
                  activeIcon: SvgPicture.asset(
                    "assets/svg/document-filled.svg",
                  ),
                  title: 'Site Task',
                  onTap: () {
                    setState(() {
                      selectionStepperState = 2;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        kSizedBoxBG,
        if (selectionStepperState == 0) const EmployeeTable(),
        if (selectionStepperState == 1) const SiteEquipmentTable(),
        if (selectionStepperState == 2) const ProjectTaskTable(),
      ],
    );
  }
}

class CreateWorkSiteReport extends StatefulWidget {
  const CreateWorkSiteReport({super.key});

  @override
  State<CreateWorkSiteReport> createState() => _CreateWorkSiteReportState();
}

class _CreateWorkSiteReportState extends State<CreateWorkSiteReport> {
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
                    'Worksite Report',
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
                                  title: 'Report Title*',
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
                                  title: 'Location*',
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
                                  title: 'Office*',
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          // Leave date
                          Spacer()
                        ],
                      ),

                      SizedBox(height: 24),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyTextFormField(
                            maxLines: 4,
                            hintText: '----',
                            spaceBetweenText: 10,
                            title: 'Office Address*',
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
                                MyDropdown(
                                  hintText: '----',
                                  spaceBetweenText: 10,
                                  title: 'Report Type*',
                                  items: [],
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
                                  title: 'Awaiting approval',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            'Deeds (Write a note)',
                            weight: 400,
                            size: 16,
                          ),
                          kSizedBoxSM,
                          RichTextEditor(),
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
                                  'Upload  File (optional)',
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
