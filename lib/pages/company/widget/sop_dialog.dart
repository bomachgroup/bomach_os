import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/role_sop_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/role_sop_controller.dart';

class CreateEditSopDialog extends StatefulWidget {
  final RoleSopController ctrl;
  final int? presetRoleId;
  final RoleSop? sop;

  const CreateEditSopDialog({
    super.key,
    required this.ctrl,
    this.presetRoleId,
    this.sop,
  });

  @override
  State<CreateEditSopDialog> createState() => _CreateEditSopDialogState();
}

class _CreateEditSopDialogState extends State<CreateEditSopDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late String _category;
  late List<_SopStepInput> _steps;

  bool get isEditing => widget.sop != null;

  @override
  void initState() {
    super.initState();
    final s = widget.sop;
    _titleCtrl = TextEditingController(text: s?.title ?? '');
    _descCtrl = TextEditingController(text: s?.description ?? '');
    _category = s?.category ?? '';
    _steps = (s?.steps ?? []).map((st) => _SopStepInput(st)).toList();
    if (_steps.isEmpty) _steps.add(_SopStepInput(null));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    for (final st in _steps) st.dispose();
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
      title: isEditing ? 'Edit SOP' : 'Add Standard Operating Procedure',
      size: DialogSize.md,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyTextFormField(
                title: 'SOP Title',
                hintText: 'e.g. Client Onboarding Procedure',
                controller: _titleCtrl,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              MyTextFormField(
                title: 'Description (optional)',
                hintText: 'Purpose and scope of this procedure',
                controller: _descCtrl,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Text('Category',
                  style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _category.isNotEmpty ? _category : null,
                decoration: _defaultDropdownDecoration,
                items: RoleSop.categoryOptions
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _category = v);
                },
              ),
              const SizedBox(height: 24),
              Row(children: [
                Text('Steps',
                    style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => setState(() => _steps.add(_SopStepInput(null))),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Step'),
                ),
              ]),
              const SizedBox(height: 8),
              ...List.generate(_steps.length, (i) => _buildStepCard(i)),
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

  Widget _buildStepCard(int index) {
    final st = _steps[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('Step ${index + 1}',
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
          const Spacer(),
          if (_steps.length > 1)
            IconButton(
              icon: const Icon(Icons.close, size: 16, color: AppColors.danger),
              onPressed: () => setState(() => _steps.removeAt(index)),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
        ]),
        const SizedBox(height: 8),
        MyTextFormField(
          hintText: 'Step title',
          controller: st.titleCtrl,
          height: 40,
        ),
        const SizedBox(height: 8),
        MyTextFormField(
          hintText: 'Detailed instructions (optional)',
          controller: st.descCtrl,
          height: 40,
        ),
        const SizedBox(height: 8),
        MyTextFormField(
          hintText: 'Media URL (optional)',
          controller: st.mediaCtrl,
          height: 40,
        ),
      ]),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final navigator = Navigator.of(context);

    final steps = _steps.asMap().entries.map((e) {
      return SopStep(
        stepNumber: e.key + 1,
        title: e.value.titleCtrl.text.trim(),
        description: e.value.descCtrl.text.trim(),
        mediaUrl: e.value.mediaCtrl.text.trim().isNotEmpty
            ? e.value.mediaCtrl.text.trim()
            : null,
      );
    }).toList();

    final success = isEditing
        ? await widget.ctrl.updateSop(
            context,
            id: widget.sop!.id!,
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            steps: steps,
            category: _category.isNotEmpty ? _category : null,
          )
        : await widget.ctrl.createSop(
            context,
            roleId: widget.presetRoleId ?? 0,
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            steps: steps,
            category: _category.isNotEmpty ? _category : null,
          );

    if (success && context.mounted) navigator.pop();
  }
}

class _SopStepInput {
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  final TextEditingController mediaCtrl;

  _SopStepInput(SopStep? step)
      : titleCtrl = TextEditingController(text: step?.title ?? ''),
        descCtrl = TextEditingController(text: step?.description ?? ''),
        mediaCtrl = TextEditingController(text: step?.mediaUrl ?? '');

  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    mediaCtrl.dispose();
  }
}
