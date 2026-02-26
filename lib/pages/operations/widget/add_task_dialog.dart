import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_date_field.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/operations/controllers/milestone_controller.dart';
import 'package:bms_front_end/pages/operations/controllers/project_controller.dart';
import 'package:bms_front_end/pages/operations/models/models.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../controllers/tasks_controler.dart';

// Maps display label → API value
const _statusItems = {
  'Pending': 'pending',
  'In Progress': 'in_progress',
  'Completed': 'completed',
  'Cancelled': 'cancelled',
};

// Maps API value → display label
String _statusLabel(String apiValue) => _statusItems.entries
    .firstWhere((e) => e.value == apiValue,
        orElse: () => const MapEntry('Pending', 'pending'))
    .key;

const _priorityItems = {
  'Low': 'low',
  'Medium': 'medium',
  'High': 'high',
};

String _priorityLabel(String apiValue) => _priorityItems.entries
    .firstWhere((e) => e.value == apiValue,
        orElse: () => const MapEntry('Medium', 'medium'))
    .key;

class AddTaskDialog extends StatefulWidget {
  final Task? task;
  final int projectId;

  const AddTaskDialog({super.key, this.task, this.projectId = 0});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  late final TaskController controller;
  late final MilestoneController milestoneController;
  late final ProjectController projectController;

  late TextEditingController nameCtrl;
  late TextEditingController descCtrl;
  late TextEditingController hoursCtrl;
  late TextEditingController dateCtrl;
  final TextEditingController _employeeSearchCtrl = TextEditingController();

  // Store display labels; convert to API value in _save()
  String selectedPriorityLabel = 'Medium';
  String selectedStatusLabel = 'Pending';
  int? selectedMilestoneId;

  // Selected employee IDs (strings)
  List<String> selectedEmployeeIds = [];
  String _employeeQuery = '';

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<TaskController>()
        ? Get.find<TaskController>()
        : Get.put(TaskController());

    milestoneController = Get.isRegistered<MilestoneController>()
        ? Get.find<MilestoneController>()
        : Get.put(MilestoneController());

    projectController = Get.isRegistered<ProjectController>()
        ? Get.find<ProjectController>()
        : Get.put(ProjectController());

    final t = widget.task;
    nameCtrl = TextEditingController(text: t?.name ?? '');
    descCtrl = TextEditingController(text: t?.description ?? '');
    hoursCtrl = TextEditingController(
        text: t != null && t.estimatedHours > 0
            ? t.estimatedHours.toString()
            : '');
    dateCtrl = TextEditingController(text: t?.dueDate ?? '');
    selectedMilestoneId = t?.milestoneId;
    selectedEmployeeIds = List<String>.from(t?.assignedTo ?? []);

    if (t != null) {
      if (t.priority.isNotEmpty) {
        selectedPriorityLabel = _priorityLabel(t.priority);
      }
      if (t.status.isNotEmpty) {
        selectedStatusLabel = _statusLabel(t.status);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (milestoneController.milestones.isEmpty && widget.projectId != 0) {
        milestoneController.fetchMilestones(context,
            projectId: widget.projectId);
      }
      if (projectController.projectEmployees.isEmpty && widget.projectId != 0) {
        projectController.fetchProjectEmployees(context, widget.projectId);
      }
    });
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    hoursCtrl.dispose();
    dateCtrl.dispose();
    _employeeSearchCtrl.dispose();
    super.dispose();
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

                    // Milestone selector
                    if (widget.projectId != 0) ...[
                      Obx(() {
                        final milestones = milestoneController.milestones;
                        if (milestones.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        final items = milestones.map((m) => m.name).toList();
                        final selectedName = milestones
                            .where((m) => m.id == selectedMilestoneId)
                            .map((m) => m.name)
                            .firstOrNull;

                        return Column(
                          children: [
                            MyDropdown(
                              title: 'Milestone*',
                              hintText: 'Select milestone',
                              items: items,
                              controller: TextEditingController(
                                  text: selectedName ?? ''),
                              onChanged: (val) {
                                final m = milestones
                                    .where((m) => m.name == val)
                                    .firstOrNull;
                                setState(() => selectedMilestoneId = m?.id);
                              },
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      }),
                    ],

                    Row(
                      children: [
                        Expanded(
                          child: MyDropdown(
                            hintText: '',
                            title: 'Priority*',
                            items: _priorityItems.keys.toList(),
                            controller: TextEditingController(
                                text: selectedPriorityLabel),
                            onChanged: (val) =>
                                setState(() => selectedPriorityLabel = val!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MyDropdown(
                            hintText: '',
                            title: 'Status*',
                            items: _statusItems.keys.toList(),
                            controller: TextEditingController(
                                text: selectedStatusLabel),
                            onChanged: (val) =>
                                setState(() => selectedStatusLabel = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: MyDateField(
                            controller: dateCtrl,
                            title: 'Due Date',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MyTextFormField(
                            controller: hoursCtrl,
                            title: 'Estimated Hours',
                            hintText: '0',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Assigned To
                    _AssignedToField(
                      projectController: projectController,
                      selectedIds: selectedEmployeeIds,
                      searchCtrl: _employeeSearchCtrl,
                      query: _employeeQuery,
                      onQueryChanged: (q) => setState(() => _employeeQuery = q),
                      onToggle: (id) => setState(() {
                        if (selectedEmployeeIds.contains(id)) {
                          selectedEmployeeIds.remove(id);
                        } else {
                          selectedEmployeeIds.add(id);
                        }
                      }),
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
      projectId: widget.task?.projectId ?? widget.projectId,
      milestoneId: selectedMilestoneId ?? widget.task?.milestoneId,
      name: nameCtrl.text,
      description: descCtrl.text,
      status: _statusItems[selectedStatusLabel] ?? 'pending',
      priority: _priorityItems[selectedPriorityLabel] ?? 'medium',
      assignedTo: selectedEmployeeIds,
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

class _AssignedToField extends StatelessWidget {
  final ProjectController projectController;
  final List<String> selectedIds;
  final TextEditingController searchCtrl;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onToggle;

  const _AssignedToField({
    required this.projectController,
    required this.selectedIds,
    required this.searchCtrl,
    required this.query,
    required this.onQueryChanged,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = projectController.isLoadingEmployees.value;
      final employees = projectController.projectEmployees;

      final filtered = query.isEmpty
          ? employees
          : employees
              .where((e) =>
                  e.fullName.toLowerCase().contains(query.toLowerCase()) ||
                  e.employeeId.toLowerCase().contains(query.toLowerCase()))
              .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText('Assigned To*', weight: 500),
          const SizedBox(height: 8),

          // Selected chips
          if (selectedIds.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: selectedIds.map((id) {
                final emp = employees.where((e) => e.id == id).firstOrNull;
                final label = emp?.fullName ?? id;
                return Chip(
                  label: Text(label, style: const TextStyle(fontSize: 12)),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () => onToggle(id),
                  backgroundColor: AppColors.blue.withValues(alpha: 0.1),
                  side:
                      BorderSide(color: AppColors.blue.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],

          // Search input
          TextField(
            controller: searchCtrl,
            onChanged: onQueryChanged,
            decoration: InputDecoration(
              hintText: 'Search employees by name or ID...',
              prefixIcon:
                  const Icon(Icons.search, size: 18, color: Colors.grey),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0XFFD5D5D5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0XFFD5D5D5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.blue),
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Employee list
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0XFFD5D5D5)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : employees.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No employees assigned to this project.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : filtered.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No employees match your search.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const Divider(
                                height: 1, color: Color(0XFFD5D5D5)),
                            itemBuilder: (ctx, i) {
                              final emp = filtered[i];
                              final isSelected = selectedIds.contains(emp.id);
                              return InkWell(
                                onTap: () => onToggle(emp.id),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: isSelected,
                                        onChanged: (_) => onToggle(emp.id),
                                        activeColor: AppColors.blue,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              emp.fullName,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              '${emp.employeeId} · ${emp.position}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      );
    });
  }
}
