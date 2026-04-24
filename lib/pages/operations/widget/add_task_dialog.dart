import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/input/my_date_field.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/pages/operations/controllers/milestone_controller.dart';
import 'package:bms_front_end/pages/operations/controllers/project_controller.dart';
import 'package:bms_front_end/pages/operations/models/models.dart';
import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/model/employees_model.dart';
import 'package:bms_front_end/src/services/employees_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

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

    return DialogScaffold(
      title: isEdit ? 'Edit task' : 'Create task',
      subtitle: isEdit
          ? 'Update task details, assignment, and schedule.'
          : 'Set up a new task with priority, due date, and assignees.',
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'Basic information',
            subtitle: 'Name the task and describe what needs to be done.',
            child: Column(
              children: [
                MyTextFormField(
                  controller: nameCtrl,
                  title: 'Task Name*',
                  hintText: 'e.g. Design Login Page',
                ),
                const SizedBox(height: 16),
                MyTextFormField(
                  controller: descCtrl,
                  title: 'Description',
                  maxLines: 4,
                  hintText: 'Task details...',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Priority & status',
            subtitle: 'Set urgency and current progress for this task.',
            child: Column(
              children: [
                if (widget.projectId != 0)
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

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: MyDropdown(
                        title: 'Milestone*',
                        hintText: 'Select milestone',
                        items: items,
                        controller:
                            TextEditingController(text: selectedName ?? ''),
                        onChanged: (val) {
                          final m = milestones
                              .where((m) => m.name == val)
                              .firstOrNull;
                          setState(() => selectedMilestoneId = m?.id);
                        },
                      ),
                    );
                  }),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: MyDropdown(
                        hintText: selectedPriorityLabel,
                        title: 'Priority*',
                        items: _priorityItems.keys.toList(),
                        controller:
                            TextEditingController(text: selectedPriorityLabel),
                        onChanged: (val) =>
                            setState(() => selectedPriorityLabel = val!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MyDropdown(
                        hintText: selectedStatusLabel,
                        title: 'Status*',
                        items: _statusItems.keys.toList(),
                        controller:
                            TextEditingController(text: selectedStatusLabel),
                        onChanged: (val) =>
                            setState(() => selectedStatusLabel = val!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Schedule',
            subtitle: 'Set due date and estimated effort.',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Assignees',
            subtitle: 'Pick the people responsible for this task.',
            child: _AssignedToField(
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
              width: 120,
              height: 44,
              isLoading: controller.isActionLoading.value,
              icon: controller.isActionLoading.value
                  ? null
                  : const Icon(Iconsax.tick_circle,
                      size: 18, color: AppColors.textOnPrimary),
              child: isEdit ? 'Update' : 'Save',
              onTap: controller.isActionLoading.value ? null : _save,
            )),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required Widget child,
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
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.bodySm
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
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

class _AssignedToField extends StatefulWidget {
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
  State<_AssignedToField> createState() => _AssignedToFieldState();
}

class _AssignedToFieldState extends State<_AssignedToField> {
  final EmployeeService _employeeService = EmployeeService();
  final _storage = const FlutterSecureStorage();

  List<Employee> _allEmployees = [];
  bool _isLoadingAll = false;
  String? _filterDepartmentId;
  String? _filterBranchId;

  // Dropdown data
  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _branches = [];

  @override
  void initState() {
    super.initState();
    _fetchAllEmployees();
    _fetchDepartments();
    _fetchBranches();
  }

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) {
      token = token.replaceFirst("Bearer ", "");
    }
    return token.replaceAll('"', '').trim();
  }

  Future<void> _fetchDepartments() async {
    try {
      final token = await _getToken();
      if (token == null) return;
      final dio = Dio();
      final response = await dio.get(
        '${ApiConstants.baseUrl}/api/v1/employees/department',
        queryParameters: {'limit': 100},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data;
      final List items = data is Map ? (data['items'] ?? []) : (data ?? []);
      setState(() {
        _departments = items.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      debugPrint("Error fetching departments: $e");
    }
  }

  Future<void> _fetchBranches() async {
    try {
      final token = await _getToken();
      if (token == null) return;
      final dio = Dio();
      final response = await dio.get(
        '${ApiConstants.baseUrl}/api/v1/branch/branches',
        queryParameters: {'limit': 100},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data;
      final List items = data is Map ? (data['items'] ?? []) : (data ?? []);
      setState(() {
        _branches = items.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      debugPrint("Error fetching branches: $e");
    }
  }

  Future<void> _fetchAllEmployees() async {
    setState(() => _isLoadingAll = true);
    try {
      final token = await _getToken();
      if (token == null) return;

      final result = await _employeeService.getEmployees(
        token,
        isActive: true,
        departmentId: _filterDepartmentId,
        branchId: _filterBranchId,
        limit: 200,
      );
      setState(() => _allEmployees = result.list);
    } catch (e) {
      debugPrint("Error fetching employees: $e");
    } finally {
      setState(() => _isLoadingAll = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final projectEmployees = widget.projectController.projectEmployees;
      final isProjectLoading =
          widget.projectController.isLoadingEmployees.value;

      // Use all employees if available, fallback to project employees
      final employees = _allEmployees.isNotEmpty ? _allEmployees : <Employee>[];
      final isLoading = _isLoadingAll || isProjectLoading;

      final filtered = widget.query.isEmpty
          ? employees
          : employees
              .where((e) =>
                  e.fullName
                      .toLowerCase()
                      .contains(widget.query.toLowerCase()) ||
                  (e.employeeId ?? '')
                      .toLowerCase()
                      .contains(widget.query.toLowerCase()))
              .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Department & Branch filters
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: MyDropdown(
                  title: 'Filter by Department',
                  hintText: 'All Departments',
                  items: _departments
                      .map((d) => d['name']?.toString() ?? '')
                      .toList(),
                  onChanged: (val) {
                    final dept = _departments
                        .where((d) => d['name'] == val)
                        .firstOrNull;
                    _filterDepartmentId = dept?['id']?.toString();
                    _fetchAllEmployees();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MyDropdown(
                  title: 'Filter by Branch',
                  hintText: 'All Branches',
                  items: _branches
                      .map((b) =>
                          b['branch_name']?.toString() ??
                          b['name']?.toString() ??
                          '')
                      .toList(),
                  onChanged: (val) {
                    final branch = _branches
                        .where((b) => (b['branch_name'] ?? b['name']) == val)
                        .firstOrNull;
                    _filterBranchId = branch?['id']?.toString();
                    _fetchAllEmployees();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Selected chips
          if (widget.selectedIds.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.selectedIds.map((id) {
                final emp = employees
                    .where((e) =>
                        e.tableId.toString() == id || e.id.toString() == id)
                    .firstOrNull;
                final projEmp =
                    projectEmployees.where((e) => e.id == id).firstOrNull;
                final label = emp?.fullName ?? projEmp?.fullName ?? id;
                return Chip(
                  label: Text(
                    label,
                    style: AppTextStyles.bodySm
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                  deleteIcon: const Icon(Iconsax.close_circle, size: 16),
                  onDeleted: () => widget.onToggle(id),
                  backgroundColor: AppColors.primarySubtle,
                  side: const BorderSide(color: AppColors.primarySubtle),
                  shape: const RoundedRectangleBorder(
                      borderRadius: AppRadii.brPill),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Search input
          MyTextFormField(
            controller: widget.searchCtrl,
            onChanged: widget.onQueryChanged,
            hintText: 'Search employees by name or ID...',
            leading: const Icon(
              Iconsax.search_normal,
              size: 18,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),

          // Employee list
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.borderSubtle),
              borderRadius: AppRadii.brMd,
            ),
            child: isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : employees.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No employees found. Try adjusting filters.',
                          style: AppTextStyles.bodySm
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      )
                    : filtered.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'No employees match your search.',
                              style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.textSecondary),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const Divider(
                                height: 1, color: AppColors.borderSubtle),
                            itemBuilder: (ctx, i) {
                              final emp = filtered[i];
                              final empId = emp.tableId.toString();
                              final isSelected =
                                  widget.selectedIds.contains(empId);
                              return InkWell(
                                onTap: () => widget.onToggle(empId),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: isSelected,
                                        onChanged: (_) =>
                                            widget.onToggle(empId),
                                        activeColor: AppColors.primary,
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
                                              style: AppTextStyles.bodyMd
                                                  .copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${emp.employeeId ?? ''} · ${emp.designation ?? ''} · ${emp.departmentName ?? ''} · ${emp.branchName ?? ''}',
                                              style: AppTextStyles.caption
                                                  .copyWith(
                                                color:
                                                    AppColors.textSecondary,
                                              ),
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
