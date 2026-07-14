import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/role_task_template_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/role_task_template_controller.dart';

class CreateEditTaskTemplateDialog extends StatefulWidget {
  final RoleTaskTemplateController ctrl;
  final int? presetRoleId;
  final RoleTaskTemplate? template;

  const CreateEditTaskTemplateDialog({
    super.key,
    required this.ctrl,
    this.presetRoleId,
    this.template,
  });

  @override
  State<CreateEditTaskTemplateDialog> createState() =>
      _CreateEditTaskTemplateDialogState();
}

class _CreateEditTaskTemplateDialogState
    extends State<CreateEditTaskTemplateDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _durationCtrl;
  late String _frequency;
  late String _priority;

  bool get isEditing => widget.template != null;

  @override
  void initState() {
    super.initState();
    final t = widget.template;
    _nameCtrl = TextEditingController(text: t?.taskName ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _durationCtrl =
        TextEditingController(text: (t?.estimatedDuration ?? 30).toString());
    _frequency = t?.frequency ?? 'weekly';
    _priority = t?.priority ?? 'medium';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  static const _defaultDropdownDecoration = InputDecoration(
    filled: true,
    fillColor: AppColors.surfaceMuted,
    border: OutlineInputBorder(
      borderRadius: AppRadii.brMd,
      borderSide: BorderSide.none,
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: isEditing ? 'Edit Task Template' : 'Add Task Template',
      size: DialogSize.sm,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyTextFormField(
                title: 'Task Name',
                hintText: 'e.g. Conduct site inspection',
                controller: _nameCtrl,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              MyTextFormField(
                title: 'Description (optional)',
                hintText: 'Describe the task in detail',
                controller: _descCtrl,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              MyTextFormField(
                title: 'Estimated Duration (minutes)',
                hintText: '30',
                controller: _durationCtrl,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Text('Frequency',
                  style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _frequency,
                decoration: _defaultDropdownDecoration,
                items: RoleTaskTemplate.frequencyOptions
                    .map((f) => DropdownMenuItem(
                        value: f,
                        child: Text(f[0].toUpperCase() + f.substring(1))))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _frequency = v);
                },
              ),
              const SizedBox(height: 16),
              Text('Priority',
                  style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _priority,
                decoration: _defaultDropdownDecoration,
                items: RoleTaskTemplate.priorityOptions
                    .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(p[0].toUpperCase() + p.substring(1))))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _priority = v);
                },
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

    final duration = int.tryParse(_durationCtrl.text) ?? 30;
    final success = isEditing
        ? await widget.ctrl.updateTemplate(
            context,
            id: widget.template!.id!,
            taskName: _nameCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            estimatedDuration: duration,
            frequency: _frequency,
            priority: _priority,
          )
        : await widget.ctrl.createTemplate(
            context,
            roleId: widget.presetRoleId ?? 0,
            taskName: _nameCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            estimatedDuration: duration,
            frequency: _frequency,
            priority: _priority,
          );

    if (success && context.mounted) navigator.pop();
  }
}
