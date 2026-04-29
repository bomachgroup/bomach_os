import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class AssignTaskDialog extends StatefulWidget {
  final Map<String, dynamic>? task;
  final Function(Map<String, dynamic>)? onAssign;

  const AssignTaskDialog({
    super.key,
    this.task,
    this.onAssign,
  });

  @override
  State<AssignTaskDialog> createState() => _AssignTaskDialogState();
}

class _AssignTaskDialogState extends State<AssignTaskDialog> {
  late TextEditingController _taskTitleController;
  late TextEditingController _descriptionController;
  late TextEditingController _estimatedHoursController;

  String _selectedEmployee = '';
  String _selectedPriority = 'Medium';
  String _selectedStatus = 'Pending';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _isLoading = false;

  // Sample employee list - in production, this would come from API
  final List<String> _employeeList = [
    'John Michael',
    'Sarah Johnson',
    'Nicholas Chidera Ani',
    'Amara Okafor',
    'David Adeleke',
    'Chioma Nwankwo',
    'Oluwaseun Adeyemi',
    'Fatima Hassan',
  ];

  final List<String> _priorityList = ['Low', 'Medium', 'High'];
  final List<String> _statusList = [
    'Pending',
    'In Progress',
    'Completed',
    'On Hold'
  ];

  @override
  void initState() {
    super.initState();
    _taskTitleController = TextEditingController(
      text: widget.task?['title'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.task?['description'] ?? '',
    );
    _estimatedHoursController = TextEditingController(
      text: widget.task?['estimatedHours'] ?? '',
    );
    _selectedEmployee = widget.task?['assignedTo'] ?? '';
    _selectedPriority = widget.task?['priority'] ?? 'Medium';
    _selectedStatus = widget.task?['status'] ?? 'Pending';
  }

  @override
  void dispose() {
    _taskTitleController.dispose();
    _descriptionController.dispose();
    _estimatedHoursController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null && pickedDate != _dueDate) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  void _handleAssignTask() {
    // Validate inputs
    if (_taskTitleController.text.isEmpty) {
      _showErrorMessage('Task title is required');
      return;
    }

    if (_selectedEmployee.isEmpty) {
      _showErrorMessage('Please select an employee');
      return;
    }

    if (_estimatedHoursController.text.isEmpty) {
      _showErrorMessage('Estimated hours is required');
      return;
    }

    setState(() => _isLoading = true);

    // Create task assignment data
    final taskAssignment = {
      'title': _taskTitleController.text,
      'description': _descriptionController.text,
      'assignedTo': _selectedEmployee,
      'priority': _selectedPriority,
      'status': _selectedStatus,
      'dueDate': DateFormat('dd MMM yyyy').format(_dueDate),
      'estimatedHours': _estimatedHoursController.text,
      'assignedDate': DateFormat('dd MMM yyyy').format(DateTime.now()),
    };

    // Simulate API call
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoading = false);
        widget.onAssign?.call(taskAssignment);
        Navigator.of(context).pop(taskAssignment);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Task assigned to $_selectedEmployee',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  StatusTone _priorityTone(String priority) {
    switch (priority) {
      case 'High':
        return StatusTone.danger;
      case 'Medium':
        return StatusTone.warning;
      case 'Low':
        return StatusTone.neutral;
      default:
        return StatusTone.neutral;
    }
  }

  StatusTone _statusTone(String status) {
    switch (status) {
      case 'Completed':
        return StatusTone.success;
      case 'In Progress':
        return StatusTone.primary;
      case 'Pending':
        return StatusTone.warning;
      case 'On Hold':
        return StatusTone.warning;
      default:
        return StatusTone.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: 'Assign task to employee',
      subtitle: 'Fill in task details and select a team member.',
      size: DialogSize.md,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'Task information',
            subtitle: 'Title, description, and workflow metadata.',
            child: Column(
              children: [
                MyTextFormField(
                  title: 'Task Title *',
                  hintText: 'Enter task title',
                  controller: _taskTitleController,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: MyDropdown(
                        title: 'Priority *',
                        items: _priorityList,
                        hintText: _selectedPriority,
                        initialSelection: _selectedPriority,
                        onChanged: (value) {
                          setState(() {
                            _selectedPriority = value ?? 'Medium';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MyDropdown(
                        title: 'Status *',
                        items: _statusList,
                        hintText: _selectedStatus,
                        initialSelection: _selectedStatus,
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value ?? 'Pending';
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                MyTextFormField(
                  title: 'Description',
                  hintText: 'Enter task description',
                  controller: _descriptionController,
                  maxLines: 3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Assignment',
            subtitle: 'Pick an assignee, due date, and expected effort.',
            child: Column(
              children: [
                MyDropdown(
                  title: 'Employee/Member *',
                  items: _employeeList,
                  hintText: _selectedEmployee.isEmpty
                      ? 'Select an employee'
                      : _selectedEmployee,
                  initialSelection: _selectedEmployee.isEmpty
                      ? null
                      : _selectedEmployee,
                  onChanged: (value) {
                    setState(() {
                      _selectedEmployee = value ?? '';
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: MyTextFormField(
                        title: 'Due Date *',
                        readOnly: true,
                        controller: TextEditingController(
                          text: DateFormat('MMM dd, yyyy').format(_dueDate),
                        ),
                        trailing: const Icon(
                          Iconsax.calendar_1,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        onTap: () => _selectDueDate(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MyTextFormField(
                        title: 'Estimated Hours *',
                        hintText: 'e.g., 8, 16, 40',
                        controller: _estimatedHoursController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Assignment preview',
            subtitle: 'Confirm the details before assigning.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_taskTitleController.text.isNotEmpty) ...[
                  Text(
                    _taskTitleController.text,
                    style: AppTextStyles.bodyLg.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_selectedEmployee.isNotEmpty)
                      StatusChip(
                        label: 'Assigned to: $_selectedEmployee',
                        tone: StatusTone.primary,
                        icon: Iconsax.profile_tick,
                      ),
                    if (_selectedPriority.isNotEmpty)
                      StatusChip(
                        label: _selectedPriority,
                        tone: _priorityTone(_selectedPriority),
                      ),
                    if (_selectedStatus.isNotEmpty)
                      StatusChip(
                        label: _selectedStatus,
                        tone: _statusTone(_selectedStatus),
                      ),
                    StatusChip(
                      label: DateFormat('MMM dd, yyyy').format(_dueDate),
                      tone: StatusTone.neutral,
                      icon: Iconsax.calendar,
                    ),
                    if (_estimatedHoursController.text.isNotEmpty)
                      StatusChip(
                        label: '${_estimatedHoursController.text} hrs',
                        tone: StatusTone.neutral,
                        icon: Iconsax.clock,
                      ),
                  ],
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
          onTap: _isLoading ? null : () => Navigator.pop(context),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        MyElevatedButton(
          width: 150,
          height: 44,
          isLoading: _isLoading,
          icon: _isLoading
              ? null
              : const Icon(Iconsax.tick_circle,
                  size: 18, color: AppColors.textOnPrimary),
          child: _isLoading ? 'Assigning...' : 'Assign Task',
          onTap: _isLoading ? null : _handleAssignTask,
        ),
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
}
