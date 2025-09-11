import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/input/upload_file.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class EditCompanyDialog extends StatefulWidget {
  const EditCompanyDialog({super.key});

  @override
  State<EditCompanyDialog> createState() => _EditCompanyDialogState();
}

class _EditCompanyDialogState extends State<EditCompanyDialog> {
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
                    'Edit Company Profile',
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
                          MyTextFormField(
                            hintText: 'Bomach Group of Companies',
                            spaceBetweenText: 10,
                            title: 'Company Name*',
                          ),
                          SizedBox(height: 24),
                          MyTextFormField(
                            hintText: 'bomachgroups@gmail.com',
                            spaceBetweenText: 10,
                            title: 'Company Email',
                          ),
                          SizedBox(height: 24),
                          MyTextFormField(
                            hintText: '+2341234567890',
                            spaceBetweenText: 10,
                            title: 'Company Phone',
                          ),
                          SizedBox(height: 24),
                          MyTextFormField(
                            hintText: '''
This is a mock representation of the first Branch address
This is a mock representation of the first Branch address
This is a mock representation of the first Branch address''',
                            spaceBetweenText: 10,
                            maxLines: 4,
                            title: 'Company Addresses',
                          ),
                          SizedBox(height: 24),
                          MyText(
                            'Company Logo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          UploadFile(),
                          SizedBox(height: 24),
                          MyTextFormField(
                            hintText: 'JFL488L03LHFR',
                            spaceBetweenText: 10,
                            title: 'RC Number',
                          ),
                          SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyTextFormField(
                                      hintText: '#FE0000',
                                      spaceBetweenText: 10,
                                      title: 'Primary Color Code',
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
                                      spaceBetweenText: 10,
                                      hintText: "#3E4094",
                                      title: 'Secondary Color Code',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          MyTextFormField(
                            hintText: 'Bomach Group of Companies',
                            spaceBetweenText: 10,
                            title: 'Company Slogan',
                          ),
                          SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyDropdown(
                                      hintText: "NGN Naira",
                                      items: [],
                                      spaceBetweenText: 10,
                                      title: 'Default Currency',
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
                                      hintText: "English UK",
                                      items: [],
                                      spaceBetweenText: 10,
                                      title: 'Language Preference',
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
                              MyTextFormField(
                                maxLines: 4,
                                hintText: '''
This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. ''',
                                spaceBetweenText: 10,
                                title: 'Business Rules',
                              ),
                            ],
                          ),
                          SizedBox(height: 40),
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
