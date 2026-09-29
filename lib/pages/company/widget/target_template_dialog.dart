import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/role_target_template_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/targets_controller.dart';

const _periods = ['daily', 'weekly', 'monthly', 'quarterly', 'annual'];

class CreateEditTargetTemplateDialog extends StatefulWidget {
  final TargetsController ctrl;
  final int roleId;
  final RoleTargetTemplate? template;

  const CreateEditTargetTemplateDialog({
    super.key,
    required this.ctrl,
    required this.roleId,
    this.template,
  });

  @override
  State<CreateEditTargetTemplateDialog> createState() =>
      _CreateEditTargetTemplateDialogState();
}

class _CreateEditTargetTemplateDialogState
    extends State<CreateEditTargetTemplateDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _targetValueCtrl;
  late final TextEditingController _unitCtrl;

  String _period = 'monthly';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final t = widget.template;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _targetValueCtrl =
        TextEditingController(text: t?.targetValue?.toString() ?? '');
    _unitCtrl = TextEditingController(text: t?.unit ?? '');
    _period = _periods.contains(t?.period) ? t!.period : 'monthly';
    _isActive = t?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _targetValueCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.template != null;
    return DialogScaffold(
      title: isEdit ? 'Edit Target Template' : 'Add Target Template',
      subtitle: 'Define a measurable target for this role.',
      size: DialogSize.md,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Title', style: AppTextStyles.label),
          const SizedBox(height: 8),
          MyTextFormField(
            controller: _titleCtrl,
            hintText: 'e.g. Monthly Revenue Target',
            height: 48,
          ),
          const SizedBox(height: 20),
          const Text('Description', style: AppTextStyles.label),
          const SizedBox(height: 8),
          MyTextFormField(
            controller: _descCtrl,
            hintText: 'Optional description…',
            height: 80,
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Target Value', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    MyTextFormField(
                      controller: _targetValueCtrl,
                      hintText: 'e.g. 100 or "Bronze"',
                      height: 48,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Unit', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    MyTextFormField(
                      controller: _unitCtrl,
                      hintText: 'e.g. %',
                      height: 48,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Period', style: AppTextStyles.label),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(borderRadius: AppRadii.brMd),
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            value: _period,
            items: _periods
                .map((p) => DropdownMenuItem(
                      value: p,
                      child: Text(p[0].toUpperCase() + p.substring(1)),
                    ))
                .toList(),
            onChanged: (val) => setState(() => _period = val ?? _period),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('Active', style: AppTextStyles.label),
              const SizedBox(width: 12),
              Switch(
                activeColor: AppColors.primary,
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
            ],
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          onTap: () => Navigator.pop(context),
        ),
        Obx(() => MyElevatedButton(
              width: 140,
              height: 44,
              onTap: widget.ctrl.isSaving.value ? null : _onSave,
              child: widget.ctrl.isSaving.value
                  ? 'Saving...'
                  : (isEdit ? 'Save Changes' : 'Add Target'),
            )),
      ],
    );
  }

  void _onSave() async {
    final title = _titleCtrl.text.trim();
    final rawValue = _targetValueCtrl.text.trim();

    if (title.isEmpty) {
      Get.snackbar('Validation', 'Title is required.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (rawValue.isEmpty) {
      Get.snackbar('Validation', 'Target value is required.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Try numeric, fall back to string
    final dynamic targetValue = double.tryParse(rawValue) ?? rawValue;

    bool success;
    if (widget.template != null) {
      success = await widget.ctrl.updateTarget(
        context,
        roleId: widget.roleId,
        templateId: widget.template!.id,
        title: title,
        targetValue: targetValue,
        period: _period,
        description: _descCtrl.text.trim(),
        unit: _unitCtrl.text.trim(),
        isActive: _isActive,
      );
    } else {
      success = await widget.ctrl.createTarget(
        context,
        roleId: widget.roleId,
        title: title,
        targetValue: targetValue,
        period: _period,
        description: _descCtrl.text.trim(),
        unit: _unitCtrl.text.trim(),
        isActive: _isActive,
      );
    }

    if (success && mounted) Navigator.pop(context);
  }
}
