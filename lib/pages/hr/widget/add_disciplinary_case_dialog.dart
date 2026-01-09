import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/models/disciplinary_process_models.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

class AddDisciplinaryCaseDialog extends StatefulWidget {
  final Function(DisciplinaryCaseRecord) onSubmit;

  const AddDisciplinaryCaseDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<AddDisciplinaryCaseDialog> createState() =>
      _AddDisciplinaryCaseDialogState();
}

class _AddDisciplinaryCaseDialogState extends State<AddDisciplinaryCaseDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedEmployeeId;
  String? _selectedActionType;
  String? _selectedViolationCategory;
  final TextEditingController _violationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _investigationController =
      TextEditingController();
  DateTime? _dateOfViolation;
  bool _severancePaymentDue = false;
  final TextEditingController _severanceController = TextEditingController();

  final List<Map<String, dynamic>> _employees = [
    {
      'id': 'E001',
      'name': 'James Smith',
      'email': 'james.smith@company.com',
      'department': 'Operations',
      'position': 'Operations Manager',
      'branch': 'Lagos'
    },
    {
      'id': 'E002',
      'name': 'Patricia Evans',
      'email': 'patricia.evans@company.com',
      'department': 'Finance',
      'position': 'Finance Officer',
      'branch': 'Enugu'
    },
    {
      'id': 'E003',
      'name': 'Robert Johnson',
      'email': 'robert.johnson@company.com',
      'department': 'Sales',
      'position': 'Sales Manager',
      'branch': 'Lagos'
    },
  ];

  @override
  void dispose() {
    _violationController.dispose();
    _descriptionController.dispose();
    _investigationController.dispose();
    _severanceController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        _selectedEmployeeId != null &&
        _selectedActionType != null &&
        _dateOfViolation != null) {
      final employee = _employees.firstWhere(
        (e) => e['id'] == _selectedEmployeeId,
      );

      final actionTypeEnum =
          DisciplinaryActionType.values.firstWhere((t) => t.name == _selectedActionType);

      final newCase = DisciplinaryCaseRecord(
        caseId: 'DC${DateTime.now().millisecond}',
        employeeId: employee['id'],
        employeeName: employee['name'],
        employeeEmail: employee['email'],
        department: employee['department'],
        position: employee['position'],
        branch: employee['branch'],
        actionType: actionTypeEnum,
        violation: _violationController.text,
        description: _descriptionController.text,
        dateOfViolation: _dateOfViolation!,
        dateInitiated: DateTime.now(),
        status: 'Pending',
        severancePaymentDue: _severancePaymentDue,
        severanceAmount: _severancePaymentDue
            ? double.tryParse(_severanceController.text)
            : null,
        investigationDetails: _investigationController.text.isNotEmpty
            ? _investigationController.text
            : null,
        appealFiled: false,
      );

      widget.onSubmit(newCase);
      Navigator.of(context).pop();
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyText(
                    'New Disciplinary Case',
                    style: TextStyle(
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
            // Form fields
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Employee Selection
                        const MyText(
                          'Employee Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const MyText(
                                    'Employee ID',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      hintText: 'Select Employee',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                    value: _selectedEmployeeId,
                                    items: _employees
                                        .map((emp) => DropdownMenuItem<String>(
                                              value: emp['id'] as String,
                                              child: MyText(emp['id'] as String),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() => _selectedEmployeeId = value);
                                    },
                                    validator: (value) => value == null
                                        ? 'Please select an employee'
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const MyText(
                                    'Employee Name',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFFD5D5D5),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: MyText(
                                      _selectedEmployeeId != null
                                          ? _employees
                                              .firstWhere(
                                                (e) =>
                                                    e['id'] ==
                                                    _selectedEmployeeId,
                                              )['name']
                                          : 'Select Employee First',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Violation Information
                        const MyText(
                          'Violation Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const MyText(
                                    'Action Type',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      hintText: 'Select Action',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                    value: _selectedActionType,
                                    items: DisciplinaryActionType.values
                                        .map((action) => DropdownMenuItem(
                                              value: action.name,
                                              child: MyText(action.displayName),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(
                                        () => _selectedActionType = value,
                                      );
                                    },
                                    validator: (value) => value == null
                                        ? 'Please select an action type'
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const MyText(
                                    'Violation Category',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      hintText: 'Select Category',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                    value: _selectedViolationCategory,
                                    items: ViolationCategory.values
                                        .map((category) => DropdownMenuItem(
                                              value: category.name,
                                              child:
                                                  MyText(category.displayName),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(
                                        () => _selectedViolationCategory = value,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const MyText(
                                    'Date of Violation',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () async {
                                      final DateTime? picked =
                                          await showDatePicker(
                                        context: context,
                                        initialDate:
                                            _dateOfViolation ?? DateTime.now(),
                                        firstDate:
                                            DateTime(DateTime.now().year - 1),
                                        lastDate: DateTime.now(),
                                      );
                                      if (picked != null) {
                                        setState(() =>
                                            _dateOfViolation = picked);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xFFD5D5D5),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          MyText(
                                            _dateOfViolation != null
                                                ? '${_dateOfViolation!.day}/${_dateOfViolation!.month}/${_dateOfViolation!.year}'
                                                : 'Select Date',
                                          ),
                                          const Icon(Icons.calendar_today,
                                              size: 18),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Violation Details
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const MyText(
                              'Violation Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            MyTextFormField(
                              hintText: 'Violation Title',
                              controller: _violationController,
                              validator: (value) => value == null ||
                                      value.isEmpty
                                  ? 'Please enter violation title'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            MyTextFormField(
                              hintText: 'Description',
                              controller: _descriptionController,
                              maxLines: 3,
                              validator: (value) => value == null ||
                                      value.isEmpty
                                  ? 'Please enter description'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            MyTextFormField(
                              hintText:
                                  'Investigation Details (Optional)',
                              controller: _investigationController,
                              maxLines: 2,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Severance Payment
                        Row(
                          children: [
                            Checkbox(
                              value: _severancePaymentDue,
                              onChanged: (value) {
                                setState(
                                  () =>
                                      _severancePaymentDue =
                                          value ?? false,
                                );
                              },
                            ),
                            const MyText(
                              'Severance Payment Due',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        if (_severancePaymentDue) ...[
                          const SizedBox(height: 12),
                          MyTextFormField(
                            hintText: 'Severance Amount',
                            controller: _severanceController,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.grey5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 12,
                children: [
                  MyOutlinedButton(
                    child: 'Cancel',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  MyElevatedButton(
                    child: 'Create Case',
                    onTap: _submitForm,
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
