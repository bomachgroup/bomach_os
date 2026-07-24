import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/role_success_playbook_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/role_success_playbook_controller.dart';

class CreateEditSuccessPlaybookDialog extends StatefulWidget {
  final RoleSuccessPlaybookController ctrl;
  final int? presetRoleId;
  final RoleSuccessPlaybook? playbook;

  const CreateEditSuccessPlaybookDialog({
    super.key,
    required this.ctrl,
    this.presetRoleId,
    this.playbook,
  });

  @override
  State<CreateEditSuccessPlaybookDialog> createState() =>
      _CreateEditSuccessPlaybookDialogState();
}

class _CreateEditSuccessPlaybookDialogState
    extends State<CreateEditSuccessPlaybookDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late String _kind;
  bool _isActive = true;

  bool get isEditing => widget.playbook != null;

  @override
  void initState() {
    super.initState();
    final p = widget.playbook;
    _titleCtrl = TextEditingController(text: p?.title ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _kind = p?.kind ?? 'best_practice';
    _isActive = p?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
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
      title: isEditing ? 'Edit Playbook Item' : 'Add Success Playbook Item',
      size: DialogSize.sm,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyTextFormField(
                title: 'Title',
                hintText: 'e.g. Always schedule follow-up within 24 hours',
                controller: _titleCtrl,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Text('Playbook Kind',
                  style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _kind,
                decoration: _defaultDropdownDecoration,
                items: RoleSuccessPlaybook.kindOptions
                    .map((k) => DropdownMenuItem(
                        value: k['value']!, child: Text(k['label']!)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _kind = v);
                },
              ),
              const SizedBox(height: 16),
              MyTextFormField(
                title: 'Description (optional)',
                hintText: 'Detailed explanation or context',
                controller: _descCtrl,
                maxLines: 3,
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

    final success = isEditing
        ? await widget.ctrl.updatePlaybook(
            context,
            id: widget.playbook!.id,
            title: _titleCtrl.text.trim(),
            kind: _kind,
            description: _descCtrl.text.trim(),
            isActive: _isActive,
          )
        : await widget.ctrl.createPlaybook(
            context,
            roleId: widget.presetRoleId ?? 0,
            title: _titleCtrl.text.trim(),
            kind: _kind,
            description: _descCtrl.text.trim(),
            isActive: _isActive,
          );

    if (success && context.mounted) navigator.pop();
  }
}
