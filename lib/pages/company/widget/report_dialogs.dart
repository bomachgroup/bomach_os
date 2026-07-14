import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/role_report_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/role_report_controller.dart';

class CreateEditReportDialog extends StatefulWidget {
  final RoleReportController ctrl;
  final int? presetRoleId;
  final RoleReport? report;

  const CreateEditReportDialog({
    super.key,
    required this.ctrl,
    this.presetRoleId,
    this.report,
  });

  @override
  State<CreateEditReportDialog> createState() => _CreateEditReportDialogState();
}

class _CreateEditReportDialogState extends State<CreateEditReportDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _freqCtrl;
  late final TextEditingController _recipientsCtrl;
  late String _reportType;
  late String _format;

  bool get isEditing => widget.report != null;

  @override
  void initState() {
    super.initState();
    final r = widget.report;
    _nameCtrl = TextEditingController(text: r?.reportName ?? '');
    _descCtrl = TextEditingController(text: r?.description ?? '');
    _freqCtrl = TextEditingController(text: r?.frequency ?? 'monthly');
    _reportType = r?.reportType ?? 'monthly';
    _format = r?.format ?? 'pdf';
    _recipientsCtrl =
        TextEditingController(text: r?.recipients.join(', ') ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _freqCtrl.dispose();
    _recipientsCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.surfaceMuted,
      border: OutlineInputBorder(
        borderRadius: AppRadii.brMd,
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: isEditing ? 'Edit Report' : 'Add Report',
      size: DialogSize.sm,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyTextFormField(
                title: 'Report Name',
                hintText: 'e.g. Monthly Sales Report',
                controller: _nameCtrl,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              MyTextFormField(
                title: 'Description (optional)',
                hintText: 'Purpose and content of the report',
                controller: _descCtrl,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Text('Report Type',
                  style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _reportType,
                decoration: _dropdownDecoration(),
                items: RoleReport.reportTypeOptions
                    .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t[0].toUpperCase() + t.substring(1))))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _reportType = v);
                },
              ),
              const SizedBox(height: 16),
              Text('Format',
                  style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _format,
                decoration: _dropdownDecoration(),
                items: RoleReport.formatOptions
                    .map((f) => DropdownMenuItem(
                        value: f,
                        child: Text(f[0].toUpperCase() + f.substring(1))))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _format = v);
                },
              ),
              const SizedBox(height: 16),
              MyTextFormField(
                title: 'Frequency',
                hintText: 'e.g. monthly, weekly',
                controller: _freqCtrl,
              ),
              const SizedBox(height: 16),
              MyTextFormField(
                title: 'Recipients (comma-separated emails)',
                hintText: 'hr@bomach.com, ceo@bomach.com',
                controller: _recipientsCtrl,
              ),
            ],
          ),
        ),
      ),
      actions: [
        MyOutlinedButton(
          height: 40,
          child: 'Cancel',
          onTap: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        Obx(() => MyElevatedButton(
              height: 40,
              isLoading: widget.ctrl.isSaving.value,
              child: isEditing ? 'Update' : 'Create',
              onTap: _submit,
            )),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final navigator = Navigator.of(context);

    final recipients = _recipientsCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final success = isEditing
        ? await widget.ctrl.updateReport(
            context,
            id: widget.report!.id!,
            reportName: _nameCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            reportType: _reportType,
            format: _format,
            frequency: _freqCtrl.text.trim(),
            recipients: recipients,
          )
        : await widget.ctrl.createReport(
            context,
            roleId: widget.presetRoleId ?? 0,
            reportName: _nameCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            reportType: _reportType,
            format: _format,
            frequency: _freqCtrl.text.trim(),
            recipients: recipients,
          );

    if (success && context.mounted) navigator.pop();
  }
}
