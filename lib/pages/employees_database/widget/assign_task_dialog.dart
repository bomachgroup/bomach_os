import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_checkbox.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/input/upload_file.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AssignTaskDialog extends StatefulWidget {
  const AssignTaskDialog({super.key});

  @override
  State<AssignTaskDialog> createState() => _AssignTaskDialogState();
}

class _AssignTaskDialogState extends State<AssignTaskDialog> {
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
                    'Assign Task',
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
                                    MyDropdown(
                                      hintText: '----',
                                      spaceBettwenText: 10,
                                      title: 'Project*',
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
                                    MyDropdown(
                                      spaceBettwenText: 10,
                                      hintText: "----",
                                      title: 'Task Category*',
                                      items: [],
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
                                    MyTextFormField(
                                      spaceBettwenText: 10,
                                      hintText: "---",
                                      title: 'Task Title',
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
                                      hintText: 'PJ short code',
                                      spaceBettwenText: 10,
                                      title: 'Short Code',
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
                                child: MyTextFormField(
                                  spaceBettwenText: 10,
                                  hintText: '12-10-2024',
                                  title: 'Start date*',
                                ),
                              ),
                              kSizedBoxWidth,
                              Expanded(
                                child: MyTextFormField(
                                  spaceBettwenText: 10,
                                  hintText: "12-10-2024",
                                  title: 'Deadline(optional)*',
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
                                      spaceBettwenText: 10,
                                      title: 'Staus*',
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
                                      spaceBettwenText: 10,
                                      title: 'Priority*',
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
                                      spaceBettwenText: 10,
                                      title: 'Employee/members*',
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              Spacer(),
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
                                title: 'Task Description/Note*',
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
                              MyText(
                                'Other Details',
                                size: 32,
                                weight: 600,
                              ),
                              kSizedBoxWidthSM,
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 28,
                              )
                            ],
                          ),
                          const SizedBox(height: 24),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // File upload
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const MyText(
                                      'Upload File (optional)*',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const UploadFile(),
                                    const SizedBox(height: 24),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        MyCheckbox(
                                          isChecked: false,
                                          onChanged: (value) {},
                                        ),
                                        kSizedBoxWidthSM,
                                        const MyText(
                                            "Task is dependent on another task",
                                            size: 14,
                                            weight: 400),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    const Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              MyDropdown(
                                                spaceBettwenText: 10,
                                                hintText: "----",
                                                title: 'Dependent Task*',
                                                items: [],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Spacer(),
                                      ],
                                    ),
                                  ],
                                ),
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
