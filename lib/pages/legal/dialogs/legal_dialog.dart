import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/legal_case_controller.dart';
import '../models/legal_case_model.dart';

import 'package:bomach_os/src/utils/app_date_format.dart';
class CreateNewLegalCaseDialog extends StatefulWidget {
  final LegalCase? caseToEdit;

  const CreateNewLegalCaseDialog({super.key, this.caseToEdit});

  static void show(BuildContext context, {LegalCase? caseToEdit}) {
    showDialog(
      context: context,
      builder: (context) => CreateNewLegalCaseDialog(caseToEdit: caseToEdit),
    );
  }

  @override
  State<CreateNewLegalCaseDialog> createState() =>
      _CreateNewLegalCaseDialogState();
}

class _CreateNewLegalCaseDialogState
    extends State<CreateNewLegalCaseDialog> {
  final controller = Get.find<LegalCaseController>();

  late TextEditingController nameCtrl;
  late TextEditingController exposureCtrl;
  late TextEditingController hearingCtrl;
  late TextEditingController numberCtrl;
  late TextEditingController descriptionCtrl;
  late TextEditingController dateFiledCtrl;
  late TextEditingController dateClosedCtrl;

  String selectedCaseType = 'Legal';
  String selectedStatus = 'Open';
  bool _isSaving = false;

  bool get isEdit => widget.caseToEdit != null;

  @override
  void initState() {
    super.initState();
    final c = widget.caseToEdit;
    nameCtrl = TextEditingController(text: c?.caseName ?? '');
    exposureCtrl = TextEditingController(text: c?.exposure ?? '');
    hearingCtrl = TextEditingController(
        text: formatAppDateValue(c?.nextHearing,
            fallback: c?.nextHearing ?? ''));
    numberCtrl = TextEditingController(text: c?.caseNumber ?? '');
    descriptionCtrl = TextEditingController(text: c?.description ?? '');
    dateFiledCtrl = TextEditingController(
        text: formatAppDateValue(c?.dateFiled, fallback: c?.dateFiled ?? ''));
    dateClosedCtrl = TextEditingController(
        text: formatAppDateValue(c?.dateClosed, fallback: c?.dateClosed ?? ''));
    if (c != null) {
      if (c.caseType.isNotEmpty) selectedCaseType = c.caseType;
      if (c.status.isNotEmpty) selectedStatus = c.status;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    exposureCtrl.dispose();
    hearingCtrl.dispose();
    numberCtrl.dispose();
    descriptionCtrl.dispose();
    dateFiledCtrl.dispose();
    dateClosedCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildPayload() {
    return {
      'case_name': nameCtrl.text.trim(),
      'case_type': selectedCaseType,
      'status': selectedStatus,
      if (exposureCtrl.text.trim().isNotEmpty)
        'exposure': exposureCtrl.text.trim(),
      if (hearingCtrl.text.trim().isNotEmpty)
        'next_hearing': appDateToApiDate(hearingCtrl.text.trim()) ??
            hearingCtrl.text.trim(),
      if (numberCtrl.text.trim().isNotEmpty)
        'case_number': numberCtrl.text.trim(),
      if (descriptionCtrl.text.trim().isNotEmpty)
        'description': descriptionCtrl.text.trim(),
      if (dateFiledCtrl.text.trim().isNotEmpty)
        'date_filed': appDateToApiDate(dateFiledCtrl.text.trim()) ??
            dateFiledCtrl.text.trim(),
      if (dateClosedCtrl.text.trim().isNotEmpty)
        'date_closed': appDateToApiDate(dateClosedCtrl.text.trim()) ??
            dateClosedCtrl.text.trim(),
    };
  }

  Future<void> _save() async {
    if (nameCtrl.text.trim().isEmpty) return;

    setState(() => _isSaving = true);

    try {
      if (isEdit) {
        await controller.updateCase(
          context,
          widget.caseToEdit!.id,
          _buildPayload(),
        );
      } else {
        await controller.createCase(context, _buildPayload());
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: isEdit ? 'Edit Legal Case' : 'Create New Legal Case',
      subtitle:
          isEdit ? 'Update case details' : 'Add a new legal case to the register',
      size: DialogSize.md,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyTextFormField(
              controller: nameCtrl,
              title: 'Case Name',
              hintText: 'e.g Land Survey Dispute',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: MyDropdown(
                    title: 'Case Type',
                    hintText: selectedCaseType,
                    items: const ['Legal', 'Civil', 'Criminal', 'Regulatory'],
                    initialSelection: selectedCaseType,
                    onChanged: (v) =>
                        setState(() => selectedCaseType = v ?? 'Legal'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MyDropdown(
                    title: 'Status',
                    hintText: selectedStatus,
                    items: const ['Open', 'Pending', 'Closed', 'Archived'],
                    initialSelection: selectedStatus,
                    onChanged: (v) =>
                        setState(() => selectedStatus = v ?? 'Open'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: MyTextFormField(
                    controller: numberCtrl,
                    title: 'Case Number',
                    hintText: 'e.g CASE-2024-001',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MyTextFormField(
                    controller: exposureCtrl,
                    title: 'Exposure',
                    hintText: 'e.g ₦5,000,000',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: MyTextFormField(
                    controller: dateFiledCtrl,
                    title: 'Date Filed',
                    hintText: 'DD-MM-YYYY',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MyTextFormField(
                    controller: dateClosedCtrl,
                    title: 'Date Closed',
                    hintText: 'DD-MM-YYYY',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            MyTextFormField(
              controller: hearingCtrl,
              title: 'Next Hearing',
              hintText: 'DD-MM-YYYY',
            ),
            const SizedBox(height: 16),
            MyTextFormField(
              controller: descriptionCtrl,
              title: 'Case Description',
              hintText: 'Enter case details',
              maxLines: 4,
            ),
          ],
        ),
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          onTap: () => Navigator.pop(context),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        MyElevatedButton(
          child: _isSaving
              ? 'Saving...'
              : (isEdit ? 'Update Case' : 'Create Case'),
          onTap: _isSaving ? null : _save,
        ),
      ],
    );
  }
}
