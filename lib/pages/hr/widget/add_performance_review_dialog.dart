import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AddPerformanceReviewDialog extends StatefulWidget {
  const AddPerformanceReviewDialog({super.key});

  @override
  State<AddPerformanceReviewDialog> createState() =>
      _AddPerformanceReviewDialogState();
}

class _AddPerformanceReviewDialogState
    extends State<AddPerformanceReviewDialog> {
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
                    'Performance Review',
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
                child: Column(
                  children: [
                    Padding(
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
                                      items: [],
                                      hintText: '---',
                                      spaceBetweenText: 10,
                                      title: 'Employee ID',
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
                                      items: [],
                                      spaceBetweenText: 10,
                                      hintText: "----",
                                      title: 'Employee Name',
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
                                      items: [],
                                      spaceBetweenText: 10,
                                      hintText: "-----",
                                      title: 'Reviewer ID',
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyDropdown(
                                      items: [],
                                      hintText: '----',
                                      spaceBetweenText: 10,
                                      title: 'Reviewer Name',
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
                                      spaceBetweenText: 10,
                                      hintText: "-----",
                                      title: 'Review Date',
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
                                      hintText: '----',
                                      spaceBetweenText: 10,
                                      title: 'Review Period',
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
                                      items: [],
                                      spaceBetweenText: 10,
                                      hintText: "-----",
                                      title: 'Overall Rating',
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
                                  hintText:
                                      "This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. ",
                                  spaceBetweenText: 10,
                                  maxLines: 5,
                                  title: 'Strengths',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: MyTextFormField(
                                  hintText:
                                      "This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. ",
                                  spaceBetweenText: 10,
                                  maxLines: 5,
                                  title: 'Area For Improvement',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: MyTextFormField(
                                  hintText:
                                      "This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. ",
                                  spaceBetweenText: 10,
                                  maxLines: 5,
                                  title: 'Feedback',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: MyTextFormField(
                                  hintText:
                                      "This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. ",
                                  spaceBetweenText: 10,
                                  maxLines: 5,
                                  title: 'Employee Comment',
                                ),
                              ),
                            ],
                          ),
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
