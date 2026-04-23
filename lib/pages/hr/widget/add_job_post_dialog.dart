import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
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
      initialDate: controller.selectedDeadline ??
          DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.selectedDeadline = picked;
        controller.deadlineController.text =
            DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.job != null;

    return DialogScaffold(
      title: isEditing ? 'Edit Job Posting' : 'Create New Job Posting',
      subtitle: isEditing
          ? 'Update the details of this job posting.'
          : 'Publish a new role to the recruiting pipeline.',
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSection(
            title: 'Role overview',
            children: [
              MyTextFormField(
                controller: controller.titleController,
                hintText: 'e.g. Senior Product Designer',
                title: 'Job Title',
              ),
              const SizedBox(height: 16),
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
                      hintText: 'Select',
                      title: 'Location',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => MyDropdown(
                          items: const ['Full-Time', 'Part-Time', 'Contract'],
                          hintText: controller.selectedJobType.value,
                          title: 'Employment Type',
                          onChanged: (val) {
                            if (val != null) {
                              controller.selectedJobType.value = val;
                            }
                          },
                        )),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: MyTextFormField(
                      hintText: '1',
                      title: 'Vacancies',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Compensation & timing',
            children: [
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
                            if (val != null) {
                              controller.selectedStatus.value = val;
                            }
                          },
                        )),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Job details',
            children: [
              MyTextFormField(
                controller: controller.descriptionController,
                hintText: 'Type here',
                maxLines: 4,
                title: 'Job Description',
              ),
              const SizedBox(height: 16),
              MyTextFormField(
                controller: controller.responsibilitiesController,
                hintText: 'Lead backend dev, Code reviews, Architecture',
                maxLines: 3,
                title: 'Responsibilities (Comma Separated)',
              ),
              const SizedBox(height: 16),
              MyTextFormField(
                controller: controller.requirementsController,
                hintText: '5+ years Node.js, AWS, PostgreSQL',
                maxLines: 3,
                title: 'Requirements (Comma Separated)',
              ),
            ],
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          onTap: () => Navigator.pop(context),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        Obx(() => MyElevatedButton(
              height: 44,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              isLoading: controller.isSaving.value,
              icon: const Icon(Iconsax.tick_circle,
                  size: 18, color: AppColors.textOnPrimary),
              child: controller.isSaving.value ? 'Saving...' : 'Save changes',
              onTap: controller.isSaving.value
                  ? () {}
                  : () => controller.saveJob(context, id: widget.job?.id),
            )),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h4),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
