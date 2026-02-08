import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; 


import '../controller/jobposting_control.dart';
import '../models/job_posting.dart';

class AddJobPostDialog extends StatefulWidget {
  final JobPosting? job; 
  const AddJobPostDialog({super.key, this.job});

  @override
  State<AddJobPostDialog> createState() => _AddJobPostDialogState();
}

class _AddJobPostDialogState extends State<AddJobPostDialog> {
  final JobPostController controller = Get.find<JobPostController>();

  @override
  void initState() {
    super.initState();
    if (widget.job != null) {
      controller.populateForm(widget.job!);
      if (widget.job!.deadline != null) {
        controller.deadlineController.text = 
            DateFormat('yyyy-MM-dd').format(widget.job!.deadline!);
      }
    } else {
      controller.clearForm();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDeadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              onPrimary: Colors.white, 
              onSurface: Colors.black, 
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.selectedDeadline = picked;
        controller.deadlineController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText(
                    widget.job == null ? 'New Job Posting' : 'Edit Job Posting',
                    style: const TextStyle(
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

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              controller: controller.titleController,
                              hintText: 'e.g. Operations Manager',
                              spaceBetweenText: 10,
                              title: 'Job Title*',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MyTextFormField(
                              controller: controller.departmentController,
                              hintText: 'e.g. Dept001',
                              spaceBetweenText: 10,
                              title: 'Department ID*',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              controller: controller.branchController,
                              hintText: 'e.g. Branch02',
                              spaceBetweenText: 10,
                              title: 'Branch ID*',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Obx(() => MyDropdown(
                                  items: const ['Full Time', 'Part Time', 'Contract'],
                                  spaceBetweenText: 10,
                                  hintText: controller.selectedJobType.value,
                                  title: 'Job Type',
                                  onChanged: (val) {
                                    if(val != null) controller.selectedJobType.value = val;
                                  },
                                )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              controller: controller.minSalaryController,
                              hintText: '0.00',
                              spaceBetweenText: 10,
                              title: 'Min Salary',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MyTextFormField(
                              controller: controller.maxSalaryController,
                              hintText: '0.00',
                              spaceBetweenText: 10,
                              title: 'Max Salary',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectDate(context),
                              child: AbsorbPointer( 
                                child: MyTextFormField(
                                  controller: controller.deadlineController,
                                  hintText: 'YYYY-MM-DD',
                                  spaceBetweenText: 10,
                                  title: 'Application Deadline',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Obx(() => MyDropdown(
                                  items: const ['Draft', 'Published', 'Closed'],
                                  spaceBetweenText: 10,
                                  hintText: controller.selectedStatus.value,
                                  title: 'Status',
                                  onChanged: (val) {
                                    if(val != null) controller.selectedStatus.value = val;
                                  },
                                )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      MyTextFormField(
                        controller: controller.descriptionController,
                        hintText: "Enter job description...",
                        spaceBetweenText: 10,
                        maxLines: 4,
                        title: 'Description',
                      ),
                      const SizedBox(height: 24),

                      MyTextFormField(
                        controller: controller.responsibilitiesController,
                        hintText: "Enter key responsibilities...",
                        spaceBetweenText: 10,
                        maxLines: 4,
                        title: 'Responsibilities',
                      ),
                      const SizedBox(height: 24),

                      MyTextFormField(
                        controller: controller.requirementsController,
                        hintText: "Enter requirements...",
                        spaceBetweenText: 10,
                        maxLines: 4,
                        title: 'Requirements',
                      ),
                    ],
                  ),
                ),
              ),
            ),

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
                  Obx(() => MyElevatedButton(
                        icon: controller.isSaving.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : SvgPicture.asset(
                                "assets/svg/check.svg",
                                colorFilter: const ColorFilter.mode(
                                    AppColors.white, BlendMode.srcIn),
                              ),
                        child: controller.isSaving.value ? 'Saving...' : 'Save',
                        onTap: controller.isSaving.value
                            ? () {} 
                            : () => controller.saveJob(context, id: widget.job?.id),
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