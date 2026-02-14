import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
  final categoryCtrl = TextEditingController();
  final departmentCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final summaryCtrl = TextEditingController();
  final budgetCtrl = TextEditingController();

  String? selectedStatus;
  String? selectedPriority;
  String?
      selectedClientId; 

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyText('Add Project',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(children: [
                      Expanded(
                          child: MyTextFormField(
                              controller: nameCtrl,
                              title: 'Project Name',
                              hintText: 'Enter name')),
                      const SizedBox(width: 16),
                      Expanded(
                          child: MyTextFormField(
                              controller: shortCodeCtrl,
                              title: 'Short Code',
                              hintText: 'PRJ-001')),
                    ]),
                    const SizedBox(height: 24),

                    Row(children: [
                      Expanded(
                          child: MyTextFormField(
                              controller: startDateCtrl,
                              title: 'Start Date',
                              hintText: 'YYYY-MM-DD')),
                      const SizedBox(width: 16),
                      Expanded(
                          child: MyTextFormField(
                              controller: deadlineCtrl,
                              title: 'Deadline',
                              hintText: 'YYYY-MM-DD')),
                    ]),
                    const SizedBox(height: 24),

                    Row(children: [
                      Expanded(
                          child: MyTextFormField(
                              controller: categoryCtrl,
                              title: 'Category',
                              hintText: 'e.g. Development')),
                      const SizedBox(width: 16),
                      Expanded(
                          child: MyTextFormField(
                              controller: departmentCtrl,
                              title: 'Department',
                              hintText: 'e.g. IT')),
                    ]),
                    const SizedBox(height: 24),

                    Row(children: [
                      Expanded(
                          child: MyTextFormField(
                              controller: locationCtrl,
                              title: 'Location',
                              hintText: 'City, Country')),
                      const SizedBox(width: 16),
                      Expanded(
                          child: MyTextFormField(
                              controller: budgetCtrl,
                              title: 'Budget',
                              hintText: '0.00')),
                    ]),
                    const SizedBox(height: 24),

                    Row(children: [
                      Expanded(
                          child: MyDropdown(
                        title: 'Priority',
                        hintText: 'Select',
                        items: const ['Low', 'Medium', 'High'],
                        onChanged: (val) =>
                            setState(() => selectedPriority = val),
                      )),
                      const SizedBox(width: 16),
                      Expanded(
                          child: MyDropdown(
                        title: 'Status',
                        hintText: 'Select',
                        items: const ['Pending', 'In Progress', 'Completed'],
                        onChanged: (val) =>
                            setState(() => selectedStatus = val),
                      )),
                    ]),
                    const SizedBox(height: 24),

                    MyTextFormField(
                        controller: summaryCtrl,
                        title: 'Summary',
                        maxLines: 3,
                        hintText: 'Project description...'),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                      child: 'Cancel', onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 16),
                  Obx(() => controller.isActionLoading.value
                      ? const CircularProgressIndicator()
                      : MyElevatedButton(
                          icon: SvgPicture.asset("assets/svg/check.svg",
                              colorFilter: const ColorFilter.mode(
                                  AppColors.white, BlendMode.srcIn)),
                          child: 'Save',
                          onTap: _saveProject,
                        )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProject() {
    if (nameCtrl.text.isEmpty) return;

    final newProject = Project(
      id: 0, 
      name: nameCtrl.text,
      shortCode: shortCodeCtrl.text,
      category: categoryCtrl.text,
      department: departmentCtrl.text,
      clientId: 1, 
      location: locationCtrl.text,
      priority: selectedPriority ?? 'Medium',
      status: selectedStatus ?? 'Pending',
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
