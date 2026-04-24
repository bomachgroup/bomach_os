import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/input/my_date_field.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/project_controller.dart';
import '../models/models.dart';

class AddProjectDialog extends StatefulWidget {
  const AddProjectDialog({super.key});

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  final ProjectController controller = Get.find<ProjectController>();

  final nameCtrl = TextEditingController();
  final shortCodeCtrl = TextEditingController();
  final startDateCtrl = TextEditingController();
  final deadlineCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final summaryCtrl = TextEditingController();
  final budgetCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final departmentCtrl = TextEditingController();
  final priorityCtrl = TextEditingController();
  final statusCtrl = TextEditingController();

  String? selectedCategory;
  String? selectedDepartmentId;
  String? selectedStatus;
  String? selectedPriority;
  String? selectedClientId;

  @override
  void dispose() {
    nameCtrl.dispose();
    shortCodeCtrl.dispose();
    startDateCtrl.dispose();
    deadlineCtrl.dispose();
    locationCtrl.dispose();
    summaryCtrl.dispose();
    budgetCtrl.dispose();
    categoryCtrl.dispose();
    departmentCtrl.dispose();
    priorityCtrl.dispose();
    statusCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: 'Add Project',
      subtitle: 'Create a new project and assign ownership',
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'Project details',
            child: Column(
              children: [
                Row(children: [
                  Expanded(
                    child: MyTextFormField(
                      controller: nameCtrl,
                      title: 'Project Name',
                      hintText: 'Enter project name',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MyTextFormField(
                      controller: shortCodeCtrl,
                      title: 'Short Code',
                      hintText: 'PRJ-001',
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: MyDropdown(
                      controller: categoryCtrl,
                      title: 'Category',
                      hintText: 'Select category',
                      initialSelection: selectedCategory,
                      items: const [
                        'Development',
                        'Construction',
                        'Consulting',
                        'Real Estate',
                        'Marketing',
                        'Operations',
                        'Other',
                      ],
                      onChanged: (val) =>
                          setState(() => selectedCategory = val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => MyDropdown(
                          controller: departmentCtrl,
                          title: 'Department',
                          hintText: 'Select department',
                          initialSelection: selectedDepartmentId != null
                              ? controller.departments
                                  .firstWhereOrNull((d) =>
                                      d.id.toString() ==
                                      selectedDepartmentId)
                                  ?.name
                              : null,
                          items: controller.departments
                              .map((d) => d.name)
                              .toList(),
                          onChanged: (val) {
                            final dept = controller.departments
                                .firstWhereOrNull((d) => d.name == val);
                            setState(() => selectedDepartmentId =
                                dept?.id.toString());
                          },
                        )),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Schedule & budget',
            child: Column(
              children: [
                Row(children: [
                  Expanded(
                    child: MyDateField(
                      controller: startDateCtrl,
                      title: 'Start Date',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MyDateField(
                      controller: deadlineCtrl,
                      title: 'Deadline',
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: MyTextFormField(
                      controller: locationCtrl,
                      title: 'Location',
                      hintText: 'City, Country',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MyTextFormField(
                      controller: budgetCtrl,
                      title: 'Budget',
                      hintText: '0.00',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Status & description',
            child: Column(
              children: [
                Row(children: [
                  Expanded(
                    child: MyDropdown(
                      controller: priorityCtrl,
                      title: 'Priority',
                      hintText: 'Select priority',
                      initialSelection: selectedPriority,
                      items: const ['Low', 'Medium', 'High'],
                      onChanged: (val) =>
                          setState(() => selectedPriority = val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MyDropdown(
                      controller: statusCtrl,
                      title: 'Status',
                      hintText: 'Select status',
                      initialSelection: selectedStatus,
                      items: const ['Pending', 'In Progress', 'Completed'],
                      onChanged: (val) =>
                          setState(() => selectedStatus = val),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                MyTextFormField(
                  controller: summaryCtrl,
                  title: 'Summary',
                  maxLines: 3,
                  hintText: 'Brief description of the project...',
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          onTap: () => Navigator.pop(context),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        Obx(() => MyElevatedButton(
              width: 140,
              height: 44,
              isLoading: controller.isActionLoading.value,
              child: 'Save Project',
              onTap: _saveProject,
            )),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          child,
        ],
      ),
    );
  }

  void _saveProject() {
    if (nameCtrl.text.isEmpty) return;

    final dept = selectedDepartmentId != null
        ? controller.departments
                .firstWhereOrNull((d) => d.id == selectedDepartmentId)
                ?.name ??
            ''
        : '';

    final newProject = Project(
      id: 0,
      name: nameCtrl.text,
      shortCode: shortCodeCtrl.text,
      category: categoryCtrl.text.isEmpty
          ? (selectedCategory ?? '')
          : categoryCtrl.text,
      department: dept,
      clientId: 1,
      location: locationCtrl.text,
      priority: priorityCtrl.text.isEmpty
          ? (selectedPriority?.toLowerCase() ?? 'medium')
          : priorityCtrl.text.toLowerCase(),
      status: statusCtrl.text.isEmpty
          ? (selectedStatus?.toLowerCase() ?? 'pending')
          : statusCtrl.text.toLowerCase().replaceAll(' ', '_'),
      summary: summaryCtrl.text,
      budget: double.tryParse(budgetCtrl.text) ?? 0.0,
      progress: 0.0,
      startDate: startDateCtrl.text,
      deadline: deadlineCtrl.text,
      fileUrl: '',
    );

    controller.createProject(context, newProject);
  }
}
