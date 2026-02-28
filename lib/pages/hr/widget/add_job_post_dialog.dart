import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
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
              primary: Color(0xFF0055FF), // Blue header
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 850),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText(
                    widget.job == null ? 'Create New Job Posting' : 'Edit Job Posting',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Job Title
                    MyTextFormField(
                      controller: controller.titleController,
                      hintText: 'e.g. Senior Product Designer',
                      title: 'Job Title',
                    ),
                    const SizedBox(height: 16),

                    // Department & Location
                    Row(
                      children: [
                        Expanded(
                          child: MyTextFormField(
                            controller: controller.departmentController,
                            hintText: 'e.g. IT',
                            title: 'Department',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MyTextFormField(
                            controller: controller.branchController,
                            hintText: 'Select', // In real app, make this a dropdown
                            title: 'Location',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Employment Type & Vacancies
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() => MyDropdown(
                                items: const ['Full-Time', 'Part-Time', 'Contract'],
                                hintText: controller.selectedJobType.value,
                                title: 'Employment Type',
                                onChanged: (val) {
                                  if(val != null) controller.selectedJobType.value = val;
                                },
                              )),
                        ),
                        const SizedBox(width: 16),
                        // Using Max Salary controller for vacancies temporarily or add new controller
                        const Expanded(
                          child: MyTextFormField(
                            // controller: controller.vacanciesController, // Add this to controller if needed
                            hintText: '1',
                            title: 'Vacancies',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Salary Min & Max
                    Row(
                      children: [
                        Expanded(
                          child: MyTextFormField(
                            controller: controller.minSalaryController,
                            hintText: 'e.g 200000',
                            title: 'Salary Min',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MyTextFormField(
                            controller: controller.maxSalaryController,
                            hintText: 'e.g 500000',
                            title: 'Salary Max',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Deadline & Status
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectDate(context),
                            child: AbsorbPointer( 
                              child: MyTextFormField(
                                controller: controller.deadlineController,
                                hintText: 'dd/mm/yyyy',
                                title: 'Application Deadline',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Obx(() => MyDropdown(
                                items: const ['Active', 'Draft', 'Closed'],
                                hintText: controller.selectedStatus.value,
                                title: 'Status',
                                onChanged: (val) {
                                  if(val != null) controller.selectedStatus.value = val;
                                },
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    MyTextFormField(
                      controller: controller.descriptionController,
                      hintText: "Type here",
                      maxLines: 4,
                      title: 'Job Description',
                    ),
                    const SizedBox(height: 16),

                    // Responsibilities
                    MyTextFormField(
                      controller: controller.responsibilitiesController,
                      hintText: "Lead backend dev, Code reviews, Architecture",
                      maxLines: 3,
                      title: 'Responsibilities (Comma Separated)',
                    ),
                    const SizedBox(height: 16),

                    // Requirements
                    MyTextFormField(
                      controller: controller.requirementsController,
                      hintText: "5+ years Node.js, AWS, PostgreSQL",
                      maxLines: 3,
                      title: 'Requirements (Comma Separated)',
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                    textColor: Colors.black87,
                    child: 'Cancel',
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  Obx(() => MyElevatedButton(
                        width: 140,
                        bgColor: const Color(0xFF0055FF),
                        child: controller.isSaving.value ? 'Saving...' : 'Save changes',
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