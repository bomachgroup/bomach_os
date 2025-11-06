import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
  final List<String> _statusList = ['Pending', 'In Progress', 'Completed', 'On Hold'];

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
            content: MyText(
              'Task assigned to $_selectedEmployee',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.green,
          ),
        );
      }
    });
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: MyText(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.red,
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return AppColors.red;
      case 'Medium':
        return const Color(0xFFFFA500);
      case 'Low':
        return AppColors.green;
      default:
        return AppColors.grey1;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppColors.green;
      case 'In Progress':
        return AppColors.blue;
      case 'Pending':
        return const Color(0xFFFFA500);
      case 'On Hold':
        return const Color(0xFF9B59B6);
      default:
        return AppColors.grey1;
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
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.assignment_ind,
                          color: AppColors.blue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const MyText(
                        'Assign Task to Employee',
                        style: AppText.black_500_20,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task Information Section
                      const MyText(
                        'Task Information',
                        style: AppText.black_600_16,
                      ),
                      kSizedBox,

                      // Task Title
                      MyTextFormField(
                        title: 'Task Title *',
                        hintText: 'Enter task title',
                        controller: _taskTitleController,
                        spaceBetweenText: 8,
                      ),
                      kSizedBox,

                      // Priority and Status
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyDropdown(
                                  title: 'Priority *',
                                  items: _priorityList,
                                  hintText: _selectedPriority,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPriority = value ?? 'Medium';
                                    });
                                  },
                                  spaceBetweenText: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyDropdown(
                                  title: 'Status *',
                                  items: _statusList,
                                  hintText: _selectedStatus,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedStatus = value ?? 'Pending';
                                    });
                                  },
                                  spaceBetweenText: 8,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      kSizedBox,

                      // Description
                      MyTextFormField(
                        title: 'Description',
                        hintText: 'Enter task description',
                        controller: _descriptionController,
                        spaceBetweenText: 8,
                        maxLines: 3,
                      ),
                      const Divider(height: 32),

                      // Assignment Section
                      const MyText(
                        'Assign Employee',
                        style: AppText.black_600_16,
                      ),
                      kSizedBox,

                      // Employee Selection
                      MyDropdown(
                        title: 'Employee/Member *',
                        items: _employeeList,
                        hintText: _selectedEmployee.isEmpty
                            ? 'Select an employee'
                            : _selectedEmployee,
                        onChanged: (value) {
                          setState(() {
                            _selectedEmployee = value ?? '';
                          });
                        },
                        spaceBetweenText: 8,
                      ),
                      kSizedBox,

                      // Due Date
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const MyText(
                            'Due Date *',
                            style: AppText.black_600_14,
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _selectDueDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0XFFD5D5D5),
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade50,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  MyText(
                                    DateFormat('MMM dd, yyyy').format(_dueDate),
                                    style: AppText.black_400_14,
                                  ),
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: AppColors.blue,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      kSizedBox,

                      // Estimated Hours
                      MyTextFormField(
                        title: 'Estimated Hours *',
                        hintText: 'e.g., 8, 16, 40',
                        controller: _estimatedHoursController,
                        spaceBetweenText: 8,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),

                      // Preview Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const MyText(
                              'Assignment Preview',
                              style: AppText.black_600_14,
                            ),
                            const SizedBox(height: 12),
                            if (_taskTitleController.text.isNotEmpty)
                              MyText(
                                _taskTitleController.text,
                                style: AppText.black_500_16,
                              ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (_selectedEmployee.isNotEmpty) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.blue.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: MyText(
                                      'Assigned to: $_selectedEmployee',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.blue,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                if (_selectedPriority.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getPriorityColor(_selectedPriority)
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: MyText(
                                      _selectedPriority,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: _getPriorityColor(
                                          _selectedPriority,
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                if (_selectedStatus.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(_selectedStatus)
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: MyText(
                                      _selectedStatus,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            _getStatusColor(_selectedStatus),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
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
                    onTap: _isLoading
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                  ),
                  const SizedBox(width: 16),
                  MyElevatedButton(
                    icon: _isLoading
                        ? null
                        : SvgPicture.asset(
                            "assets/svg/check.svg",
                            colorFilter: const ColorFilter.mode(
                                AppColors.white, BlendMode.srcIn),
                          ),
                    child: _isLoading ? 'Assigning...' : 'Assign Task',
                    onTap: _isLoading ? null : _handleAssignTask,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
