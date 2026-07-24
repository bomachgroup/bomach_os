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
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _minutesCtrl;
  late String _priority;
  bool _isActive = true;

  bool get isEditing => widget.template != null;

  @override
  void initState() {
    super.initState();
    final t = widget.template;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _minutesCtrl = TextEditingController(
        text: (t?.estimatedMinutes ?? 30).toString());
    _priority = t?.defaultPriority ?? 'medium';
    _isActive = t?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _minutesCtrl.dispose();
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
                title: 'Title',
                hintText: 'e.g. Conduct site inspection',
                controller: _titleCtrl,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              MyTextFormField(
                title: 'Description (optional)',
                hintText: 'Describe the task template in detail',
                controller: _descCtrl,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              MyTextFormField(
                title: 'Estimated Minutes',
                hintText: '30',
                controller: _minutesCtrl,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Text('Default Priority',
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Active',
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.textPrimary)),
                  const SizedBox(width: 12),
                  Switch(
                    activeThumbColor: AppColors.primary,
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                ],
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

    final minutes = int.tryParse(_minutesCtrl.text) ?? 30;
    final success = isEditing
        ? await widget.ctrl.updateTemplate(
            context,
            id: widget.template!.id!,
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            estimatedMinutes: minutes,
            defaultPriority: _priority,
            isActive: _isActive,
          )
        : await widget.ctrl.createTemplate(
            context,
            roleId: widget.presetRoleId ?? 0,
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            estimatedMinutes: minutes,
            defaultPriority: _priority,
            isActive: _isActive,
          );

    if (success && context.mounted) navigator.pop();
  }
}
