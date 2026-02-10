import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/input/upload_file.dart'; 
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../controller/applicant_controller.dart';
import '../models/applicant_model.dart';



class AddJobApplicantDialog extends StatefulWidget {
  final Applicant? applicant; 
  const AddJobApplicantDialog({super.key, this.applicant});

  @override
  State<AddJobApplicantDialog> createState() => _AddJobApplicantDialogState();
}

class _AddJobApplicantDialogState extends State<AddJobApplicantDialog> {
  final ApplicantController controller = Get.find<ApplicantController>();

  @override
  void initState() {
    super.initState();
    if (widget.applicant != null) {
      controller.populateForm(widget.applicant!);
    } else {
      controller.clearForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText(
                    widget.applicant == null ? 'New Applicant' : 'Edit Applicant',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: MyTextFormField(
                            controller: controller.jobIdController,
                            hintText: 'e.g. 101',
                            spaceBetweenText: 10,
                            title: 'Job Posting ID*', 
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    Row(
                      children: [
                        Expanded(
                          child: MyTextFormField(
                            controller: controller.firstNameController,
                            hintText: 'John',
                            spaceBetweenText: 10,
                            title: 'First Name',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MyTextFormField(
                            controller: controller.lastNameController,
                            hintText: 'Doe',
                            spaceBetweenText: 10,
                            title: 'Last Name',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: MyTextFormField(
                            controller: controller.emailController,
                            hintText: 'john@example.com',
                            spaceBetweenText: 10,
                            title: 'Email',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MyTextFormField(
                            controller: controller.phoneController,
                            hintText: '+1234567890',
                            spaceBetweenText: 10,
                            title: 'Phone',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: MyText("Upload Resume*", style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 8),
                    const UploadFile(), 
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: MyTextFormField(
                            controller: controller.linkedinController,
                            hintText: 'https://linkedin.com/in/...',
                            spaceBetweenText: 10,
                            title: 'LinkedIn Profile URL',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MyTextFormField(
                            controller: controller.portfolioController,
                            hintText: 'https://portfolio.com',
                            spaceBetweenText: 10,
                            title: 'Portfolio URL',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: Obx(() => MyDropdown(
                            items: const ['Applied', 'Screening', 'Interview', 'Offered', 'Rejected'],
                            spaceBetweenText: 10,
                            hintText: controller.selectedStage.value,
                            title: 'Stage',
                            onChanged: (val) {
                              if (val != null) controller.selectedStage.value = val;
                            },
                          )),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Obx(() => MyDropdown(
                            items: const ['New', 'In Review', 'Shortlisted', 'Hired', 'Rejected'],
                            spaceBetweenText: 10,
                            hintText: controller.selectedStatus.value,
                            title: 'Status',
                            onChanged: (val) {
                              if (val != null) controller.selectedStatus.value = val;
                            },
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    MyTextFormField(
                      controller: controller.notesController,
                      hintText: "Add any internal notes...",
                      spaceBetweenText: 10,
                      maxLines: 3,
                      title: 'Notes',
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade300))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                    textColor: AppColors.darkGrey1,
                    borderColor: null,
                    child: 'Cancel',
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  Obx(() => MyElevatedButton(
                    icon: controller.isSaving.value 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : SvgPicture.asset("assets/svg/check.svg", colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn)),
                    child: controller.isSaving.value ? 'Saving...' : 'Save',
                    onTap: controller.isSaving.value 
                        ? () {} 
                        : () => controller.saveApplicant(context, id: widget.applicant?.id),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}