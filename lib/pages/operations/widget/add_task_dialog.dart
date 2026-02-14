import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../controllers/tasks_controler.dart';
import '../models/models.dart';

class AddTaskDialog extends StatefulWidget {
  final Task? task;

  const AddTaskDialog({super.key, this.task});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TaskController controller = Get.find<TaskController>();

  late TextEditingController nameCtrl;
  late TextEditingController descCtrl;
  late TextEditingController hoursCtrl;
  late TextEditingController dateCtrl;

  String selectedPriority = 'Medium';
  String selectedStatus = 'Pending';

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    nameCtrl = TextEditingController(text: t?.name ?? '');
    descCtrl = TextEditingController(text: t?.description ?? '');
    hoursCtrl =
        TextEditingController(text: t?.estimatedHours.toString() ?? '0');
    dateCtrl = TextEditingController(text: t?.dueDate ?? '');

    if (t != null) {
      if (t.priority.isNotEmpty) selectedPriority = t.priority;
      if (t.status.isNotEmpty) selectedStatus = t.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;

    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText(
                    isEdit ? 'Edit Task' : 'Create Task',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Form Fields
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyTextFormField(
                      controller: nameCtrl,
                      title: 'Task Name*',
                      hintText: 'e.g. Design Login Page',
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: MyDropdown(
                            hintText: '',
                            title: 'Priority*',
                            items: const ['Low', 'Medium', 'High'],
                            controller:
                                TextEditingController(text: selectedPriority),
                            onChanged: (val) =>
                                setState(() => selectedPriority = val!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MyDropdown(
                            hintText: '',
                            title: 'Status*',
                            items: const [
                              'Pending',
                              'In Progress',
                              'Completed'
                            ],
                            controller:
                                TextEditingController(text: selectedStatus),
                            onChanged: (val) =>
                                setState(() => selectedStatus = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: MyTextFormField(
                            controller: dateCtrl,
                            title: 'Due Date*',
                            hintText: "YYYY-MM-DD",
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MyTextFormField(
                            controller: hoursCtrl,
                            title: 'Estimated Hours',
                            hintText: "0",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    MyTextFormField(
                      controller: descCtrl,
                      title: 'Description',
                      maxLines: 4,
                      hintText: 'Task details...',
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                    child: 'Cancel',
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  Obx(() => controller.isActionLoading.value
                      ? const CircularProgressIndicator()
                      : MyElevatedButton(
                          icon: SvgPicture.asset("assets/svg/check.svg",
                              colorFilter: const ColorFilter.mode(
                                  AppColors.white, BlendMode.srcIn)),
                          child: isEdit ? 'Update' : 'Save',
                          onTap: _save,
                        )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (nameCtrl.text.isEmpty) return;

    final newTask = Task(
      id: widget.task?.id ?? 0,
      projectId: widget.task?.projectId ?? 0,
      name: nameCtrl.text,
      description: descCtrl.text,
      status: selectedStatus,
      priority: selectedPriority,
      assignedTo: widget.task?.assignedTo ??
          [], // Keeping existing assignments as UI for it is not requested in detail
      dueDate: dateCtrl.text,
      estimatedHours: double.tryParse(hoursCtrl.text) ?? 0.0,
      createdAt: widget.task?.createdAt ?? '',
      updatedAt: '',
    );

    if (widget.task == null) {
      controller.createTask(context, newTask);
    } else {
      controller.updateTask(context, newTask.id, newTask);
    }
  }
}
