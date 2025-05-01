import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/upload_file.dart';
import 'package:bms_front_end/components/nav/employee_stepper.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ViewTaskDialog extends StatefulWidget {
  const ViewTaskDialog({super.key});

  @override
  State<ViewTaskDialog> createState() => _ViewTaskDialogState();
}

class _ViewTaskDialogState extends State<ViewTaskDialog> {
  int employeeProfileSelectionStepperState = 0;
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
                    'Task ID - #SSC23',
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: MyText(
                                  "Project Title*",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "-------------",
                                  weight: 400,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          kSizedBox,
                          const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: MyText(
                                  "Milestone*",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "-------------",
                                  weight: 400,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          kSizedBox,
                          const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: MyText(
                                  "Task Title*",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "splash screen",
                                  weight: 400,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          kSizedBox,
                          const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: MyText(
                                  "Task ID*",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "#SSC23",
                                  weight: 400,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          kSizedBox,
                          const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: MyText(
                                  "Assigned to*",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText(
                                      "Nicholas Chidera Ani",
                                      weight: 400,
                                      size: 16,
                                    ),
                                    MyText(
                                      "MTN Nigeria",
                                      weight: 400,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          kSizedBox,
                          Row(
                            children: [
                              const Expanded(
                                flex: 3,
                                child: MyText(
                                  "Task ID*",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Row(
                                  children: [
                                    Container(
                                      height: 10,
                                      width: 10,
                                      decoration: const ShapeDecoration(
                                        color: AppColors.blue,
                                        shape: OvalBorder(),
                                      ),
                                    ),
                                    kSizedBoxWidthTiny,
                                    const MyText("Undone"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          kSizedBox,
                          Row(
                            children: [
                              const Expanded(
                                flex: 3,
                                child: MyText(
                                  "Priority*",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Row(
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
                                    const MyText("Low"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          kSizedBox,
                          const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: MyText(
                                  "Task summary*",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "gfvdcisvyif viyfgdsykgogl fyifds9yifvy viyfdsykfgovldsg fy9ivsyvog higvysidyobu ihbsfbvyou hivscy9bvxog isziyvkg 8 isvxyiy9ikx y8svicxb8yh9b y8svcyfgz9c7ioh y8vsiby9gox ",
                                  weight: 400,
                                  size: 16,
                                  maxLines: 3,
                                ),
                              ),
                            ],
                          ),
                          kSizedBox,
                          const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: MyText(
                                  "Created on*",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "12-01-2024",
                                  weight: 400,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          kSizedBox,
                          const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: MyText(
                                  "Start date**",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "12-01-2024",
                                  weight: 400,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          kSizedBox,
                          const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: MyText(
                                  "End date**",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "12-01-2024",
                                  weight: 400,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          kSizedBoxBG,
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  EmployeeInfoStepper(
                                    allowInactiveBorder: false,
                                    isActive:
                                        employeeProfileSelectionStepperState ==
                                            0,
                                    title: 'Files',
                                    onTap: () {
                                      setState(
                                        () {
                                          employeeProfileSelectionStepperState =
                                              0;
                                        },
                                      );
                                    },
                                  ),
                                  kSizedBoxWidth,
                                  EmployeeInfoStepper(
                                    allowInactiveBorder: false,
                                    isActive:
                                        employeeProfileSelectionStepperState ==
                                            1,
                                    title: 'Comments',
                                    onTap: () {
                                      setState(
                                        () {
                                          employeeProfileSelectionStepperState =
                                              1;
                                        },
                                      );
                                    },
                                  ),
                                  kSizedBoxWidth,
                                  EmployeeInfoStepper(
                                    allowInactiveBorder: false,
                                    isActive:
                                        employeeProfileSelectionStepperState ==
                                            2,
                                    title: 'Notes',
                                    onTap: () {
                                      setState(
                                        () {
                                          employeeProfileSelectionStepperState =
                                              2;
                                        },
                                      );
                                    },
                                  ),
                                  kSizedBoxWidth,
                                  EmployeeInfoStepper(
                                    allowInactiveBorder: false,
                                    isActive:
                                        employeeProfileSelectionStepperState ==
                                            3,
                                    title: 'History',
                                    onTap: () {
                                      setState(
                                        () {
                                          employeeProfileSelectionStepperState =
                                              3;
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          kSizedBoxBG,
                          const Row(
                            children: [
                              SizedBox(
                                width: 250,
                                child: UploadFile(),
                              ),
                            ],
                          ),
                          kSizedBox,
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
                    child: 'Mark completed',
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
