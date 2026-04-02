import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/disciplinary_controller.dart';
import '../models/disciplinary_cases_model.dart';

class AddDisciplinaryCaseDialog extends StatefulWidget {
  final String token;
  final DisciplinaryCase? caseToEdit;

  const AddDisciplinaryCaseDialog({
    super.key,
    required this.token,
    this.caseToEdit,
  });

  @override
  State<AddDisciplinaryCaseDialog> createState() =>
      _AddDisciplinaryCaseDialogState();
}

class _AddDisciplinaryCaseDialogState extends State<AddDisciplinaryCaseDialog> {
  final _formKey = GlobalKey<FormState>();
  final DisciplinaryController controller = Get.find();

  late TextEditingController _employeeIdController;
  late TextEditingController _violationTitleController;
  late TextEditingController _violationDescController;
  late TextEditingController _investigationController;
  late TextEditingController _severanceController;
  late TextEditingController _violationTypeController;

  String? _selectedActionType;
  String? _selectedViolationCategory;
  DateTime? _actionDate;
  bool _severancePaymentDue = false;

  final List<String> _actionTypes = [
    'Verbal Warning',
    'Written Warning',
    'Final Warning',
    'Suspension',
    'Termination',
    'Dismissal'
  ];

  final List<String> _categories = [
    'Misconduct',
    'Performance',
    'Attendance',
    'Gross Misconduct',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.caseToEdit;
    _employeeIdController = TextEditingController(text: c?.employeeId ?? '');
    _violationTitleController =
        TextEditingController(text: c?.violationTitle ?? '');
    _violationDescController =
        TextEditingController(text: c?.violationDescription ?? '');
    _investigationController =
        TextEditingController(text: c?.investigationDetails ?? '');
    _severanceController =
        TextEditingController(text: c?.severanceAmount?.toString() ?? '');
    _violationTypeController =
        TextEditingController(text: c?.violationType ?? '');

    _selectedActionType = c?.actionType;
    _selectedViolationCategory = c?.violationCategory;
    _actionDate = c?.actionDate ?? DateTime.now();
    _severancePaymentDue = c?.severancePaymentDue ?? false;
  }

  @override
  void dispose() {
    _employeeIdController.dispose();
    _violationTitleController.dispose();
    _violationDescController.dispose();
    _investigationController.dispose();
    _severanceController.dispose();
    _violationTypeController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final newCase = DisciplinaryCase(
        id: widget.caseToEdit?.id ?? '',
        employeeId: _employeeIdController.text,
        violationType: _violationTypeController.text,
        violationCategory: _selectedViolationCategory ?? 'Other',
        violationTitle: _violationTitleController.text,
        violationDescription: _violationDescController.text,
        actionDate: _actionDate,
        actionType: _selectedActionType ?? 'Verbal Warning',
        investigationDetails: _investigationController.text,
        severancePaymentDue: _severancePaymentDue,
        severanceAmount: double.tryParse(_severanceController.text) ?? 0.0,
      );

      bool success;
      if (widget.caseToEdit != null) {
        success = await controller.updateCase(
            widget.token, widget.caseToEdit!.id, newCase);
      } else {
        success = await controller.createCase(widget.token, newCase);
      }

      if (!mounted) return;
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Case saved"), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Failed to save"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText(
                      widget.caseToEdit == null
                          ? 'New Disciplinary Case'
                          : 'Edit Case',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyTextFormField(
                        title: 'Employee ID',
                        controller: _employeeIdController,
                        hintText: 'Enter Employee ID',
                      ),
                      kSizedBox,
                      Row(
                        children: [
                          Expanded(
                            child: MyDropdown(
                              title: 'Action Type',
                              items: _actionTypes,
                              hintText: _selectedActionType ?? 'Select Action',
                              onChanged: (val) =>
                                  setState(() => _selectedActionType = val),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MyDropdown(
                              title: 'Category',
                              items: _categories,
                              hintText: _selectedViolationCategory ??
                                  'Select Category',
                              onChanged: (val) => setState(
                                  () => _selectedViolationCategory = val),
                            ),
                          ),
                        ],
                      ),
                      kSizedBox,
                      MyTextFormField(
                          title: 'Violation Title',
                          controller: _violationTitleController),
                      kSizedBox,
                      MyTextFormField(
                          title: 'Violation Type',
                          controller: _violationTypeController,
                          hintText: 'e.g. Lateness'),
                      kSizedBox,
                      MyTextFormField(
                          title: 'Description',
                          controller: _violationDescController,
                          maxLines: 3),
                      kSizedBox,
                      MyTextFormField(
                          title: 'Investigation Details',
                          controller: _investigationController,
                          maxLines: 3),
                      kSizedBox,
                      const MyText('Action Date',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                              context: context,
                              initialDate: _actionDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100));
                          if (picked != null)
                            setState(() => _actionDate = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(_actionDate != null
                              ? DateFormat('yyyy-MM-dd').format(_actionDate!)
                              : 'Select Date'),
                        ),
                      ),
                      kSizedBox,
                      Row(
                        children: [
                          Checkbox(
                            value: _severancePaymentDue,
                            onChanged: (val) => setState(
                                () => _severancePaymentDue = val ?? false),
                          ),
                          const MyText('Severance Payment Due?'),
                        ],
                      ),
                      if (_severancePaymentDue)
                        MyTextFormField(
                            title: 'Severance Amount',
                            controller: _severanceController),
                    ],
                  ),
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
                      child: 'Cancel',
                      onTap: () => Navigator.pop(context),
                      textColor: Colors.grey),
                  const SizedBox(width: 16),
                  Obx(() => MyElevatedButton(
                        child: controller.isSaving.value
                            ? 'Saving...'
                            : 'Save Case',
                        onTap: controller.isSaving.value ? () {} : _submitForm,
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
