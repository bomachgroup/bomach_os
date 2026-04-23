import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
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
        AppToast.success(context, 'Case saved');
      } else {
        AppToast.error(context, 'Failed to save');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.caseToEdit != null;
    return DialogScaffold(
      title: isEdit ? 'Edit Disciplinary Case' : 'New Disciplinary Case',
      subtitle: isEdit
          ? 'Update the violation details, action, and supporting notes.'
          : 'Capture an employee disciplinary case with action and details.',
      size: DialogSize.lg,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection(
              title: 'Employee & Action',
              child: Column(
                children: [
                  MyTextFormField(
                    title: 'Employee ID',
                    controller: _employeeIdController,
                    hintText: 'Enter Employee ID',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: MyDropdown(
                          title: 'Action Type',
                          items: _actionTypes,
                          initialSelection: _selectedActionType,
                          hintText:
                              _selectedActionType ?? 'Select Action',
                          onChanged: (val) =>
                              setState(() => _selectedActionType = val),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MyDropdown(
                          title: 'Category',
                          items: _categories,
                          initialSelection: _selectedViolationCategory,
                          hintText: _selectedViolationCategory ??
                              'Select Category',
                          onChanged: (val) => setState(
                              () => _selectedViolationCategory = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDateField(
                    label: 'Action Date',
                    value: _actionDate,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _actionDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _actionDate = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Violation Details',
              child: Column(
                children: [
                  MyTextFormField(
                    title: 'Violation Title',
                    controller: _violationTitleController,
                    hintText: 'Short title of the violation',
                  ),
                  const SizedBox(height: 16),
                  MyTextFormField(
                    title: 'Violation Type',
                    controller: _violationTypeController,
                    hintText: 'e.g. Lateness',
                  ),
                  const SizedBox(height: 16),
                  MyTextFormField(
                    title: 'Description',
                    controller: _violationDescController,
                    maxLines: 3,
                    hintText: 'Describe the violation in detail',
                  ),
                  const SizedBox(height: 16),
                  MyTextFormField(
                    title: 'Investigation Details',
                    controller: _investigationController,
                    maxLines: 3,
                    hintText: 'Notes from the investigation',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Severance',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _severancePaymentDue,
                        activeColor: AppColors.primary,
                        onChanged: (val) => setState(
                            () => _severancePaymentDue = val ?? false),
                      ),
                      const Text(
                        'Severance Payment Due?',
                        style: AppText.bodyMd,
                      ),
                    ],
                  ),
                  if (_severancePaymentDue) ...[
                    const SizedBox(height: 12),
                    MyTextFormField(
                      title: 'Severance Amount',
                      controller: _severanceController,
                      hintText: 'Enter amount',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        MyOutlinedButton(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
          child: 'Cancel',
          onTap: () => Navigator.pop(context),
        ),
        Obx(() => MyElevatedButton(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              isLoading: controller.isSaving.value,
              child: 'Save Case',
              onTap: controller.isSaving.value ? () {} : _submitForm,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.h4),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppText.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppText.bodyMd.copyWith(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: AppRadii.brMd,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.brMd,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.calendar_1,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Text(
                  value != null
                      ? DateFormat('MMM d, yyyy').format(value)
                      : 'Select date',
                  style: AppText.bodyMd.copyWith(
                    color: value != null
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
