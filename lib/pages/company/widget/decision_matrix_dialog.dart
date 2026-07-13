import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/decision_matrix_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/decision_matrix_controller.dart';

class CreateEditDecisionMatrixEntryDialog extends StatefulWidget {
  final DecisionMatrixController ctrl;
  final int roleId;
  final DecisionMatrixEntry? entry;

  const CreateEditDecisionMatrixEntryDialog({
    super.key,
    required this.ctrl,
    required this.roleId,
    this.entry,
  });

  @override
  State<CreateEditDecisionMatrixEntryDialog> createState() =>
      _CreateEditDecisionMatrixEntryDialogState();
}

class _CreateEditDecisionMatrixEntryDialogState
    extends State<CreateEditDecisionMatrixEntryDialog> {
  late final TextEditingController _typeCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _approvalCtrl;
  late final TextEditingController _escalationCtrl;
  late final TextEditingController _conditionsCtrl;

  bool _canDecideAlone = true;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _typeCtrl = TextEditingController(text: e?.decisionType ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _approvalCtrl = TextEditingController(text: e?.requiresApprovalFrom ?? '');
    _escalationCtrl = TextEditingController(text: e?.escalationPath ?? '');
    _conditionsCtrl = TextEditingController(text: e?.conditions ?? '');
    _canDecideAlone = e?.canDecideAlone ?? true;
    _isActive = e?.isActive ?? true;
  }

  @override
  void dispose() {
    _typeCtrl.dispose();
    _descCtrl.dispose();
    _approvalCtrl.dispose();
    _escalationCtrl.dispose();
    _conditionsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.entry != null;
    return DialogScaffold(
      title: isEdit ? 'Edit Decision Entry' : 'Add Decision Entry',
      subtitle: 'Define what decisions this role can make and when.',
      size: DialogSize.md,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Decision Type', style: AppTextStyles.label),
            const SizedBox(height: 8),
            MyTextFormField(
              controller: _typeCtrl,
              hintText: r'e.g. Approve purchase order < $50k',
              height: 48,
            ),
            const SizedBox(height: 20),
            const Text('Description', style: AppTextStyles.label),
            const SizedBox(height: 8),
            MyTextFormField(
              controller: _descCtrl,
              hintText: 'Context or details about this decision',
              height: 72,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Can Decide Alone', style: AppTextStyles.label),
                const SizedBox(width: 12),
                Switch(
                  activeThumbColor: AppColors.primary,
                  value: _canDecideAlone,
                  onChanged: (v) => setState(() => _canDecideAlone = v),
                ),
              ],
            ),
            if (!_canDecideAlone) ...[
              const SizedBox(height: 20),
              const Text('Requires Approval From', style: AppTextStyles.label),
              const SizedBox(height: 8),
              MyTextFormField(
                controller: _approvalCtrl,
                hintText: 'e.g. Line Manager, CFO',
                height: 48,
              ),
            ],
            const SizedBox(height: 20),
            const Text('Escalation Path', style: AppTextStyles.label),
            const SizedBox(height: 8),
            MyTextFormField(
              controller: _escalationCtrl,
              hintText: 'e.g. Manager → HOD → Director',
              height: 48,
            ),
            const SizedBox(height: 20),
            const Text('Conditions', style: AppTextStyles.label),
            const SizedBox(height: 8),
            MyTextFormField(
              controller: _conditionsCtrl,
              hintText: 'Any special conditions or limits',
              height: 72,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Active', style: AppTextStyles.label),
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
                  : (isEdit ? 'Save Changes' : 'Add Entry'),
            )),
      ],
    );
  }

  void _onSave() async {
    if (_typeCtrl.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Decision type is required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final body = <String, dynamic>{
      'role_id': widget.roleId,
      'decision_type': _typeCtrl.text.trim(),
      'can_decide_alone': _canDecideAlone,
      'is_active': _isActive,
      'sort_order': widget.entry?.sortOrder ?? widget.ctrl.entries.length,
    };
    if (_descCtrl.text.trim().isNotEmpty) body['description'] = _descCtrl.text.trim();
    if (_approvalCtrl.text.trim().isNotEmpty) {
      body['requires_approval_from'] = _approvalCtrl.text.trim();
    }
    if (_escalationCtrl.text.trim().isNotEmpty) {
      body['escalation_path'] = _escalationCtrl.text.trim();
    }
    if (_conditionsCtrl.text.trim().isNotEmpty) {
      body['conditions'] = _conditionsCtrl.text.trim();
    }

    bool success;
    if (widget.entry != null) {
      success = await widget.ctrl.updateEntry(widget.entry!.id, body);
    } else {
      success = await widget.ctrl.addEntry(body);
    }
    if (success && mounted) Navigator.pop(context);
  }
}
