import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/role_risk_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/role_risk_controller.dart';

class CreateEditRiskProfileDialog extends StatefulWidget {
  final RoleRiskController ctrl;
  final int roleId;
  final RoleRiskProfile? profile;

  const CreateEditRiskProfileDialog({
    super.key,
    required this.ctrl,
    required this.roleId,
    this.profile,
  });

  @override
  State<CreateEditRiskProfileDialog> createState() =>
      _CreateEditRiskProfileDialogState();
}

class _CreateEditRiskProfileDialogState
    extends State<CreateEditRiskProfileDialog> {
  late final TextEditingController _obligationCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _deadlineCtrl;
  late final TextEditingController _assignedToCtrl;

  String _category = 'Regulatory';
  String _priority = 'Medium';
  String _status = 'pending';

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _obligationCtrl = TextEditingController(text: p?.obligation ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _deadlineCtrl = TextEditingController(text: p?.deadline ?? '');
    _assignedToCtrl = TextEditingController(text: p?.assignedTo ?? '');
    _category = p?.category ?? 'Regulatory';
    _priority = p?.priority ?? 'Medium';
    _status = p?.status ?? 'pending';
  }

  @override
  void dispose() {
    _obligationCtrl.dispose();
    _descCtrl.dispose();
    _deadlineCtrl.dispose();
    _assignedToCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.profile != null;
    return DialogScaffold(
      title: isEdit ? 'Edit Risk Obligation' : 'Add Risk Obligation',
      subtitle: 'Define compliance or risk obligations tied to this role.',
      size: DialogSize.md,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Obligation', style: AppTextStyles.label),
          const SizedBox(height: 8),
          MyTextFormField(
            controller: _obligationCtrl,
            hintText: 'e.g. Submit quarterly compliance report',
            height: 48,
          ),
          const SizedBox(height: 20),
          const Text('Category', style: AppTextStyles.label),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              hintText: 'Select category',
              border: OutlineInputBorder(borderRadius: AppRadii.brMd),
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            initialValue: _category,
            items: RoleRiskProfile.categoryOptions
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _category = v ?? 'Regulatory'),
          ),
          const SizedBox(height: 20),
          const Text('Priority', style: AppTextStyles.label),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              hintText: 'Select priority',
              border: OutlineInputBorder(borderRadius: AppRadii.brMd),
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            initialValue: _priority,
            items: RoleRiskProfile.priorityOptions
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (v) => setState(() => _priority = v ?? 'Medium'),
          ),
          const SizedBox(height: 20),
          const Text('Status', style: AppTextStyles.label),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              hintText: 'Select status',
              border: OutlineInputBorder(borderRadius: AppRadii.brMd),
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            initialValue: _status,
            items: RoleRiskProfile.statusOptions
                .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.replaceAll('_', ' ').capitalizeFirst ?? s)))
                .toList(),
            onChanged: (v) => setState(() => _status = v ?? 'pending'),
          ),
          const SizedBox(height: 20),
          const Text('Description', style: AppTextStyles.label),
          const SizedBox(height: 8),
          MyTextFormField(
            controller: _descCtrl,
            hintText: 'Details about this obligation',
            height: 80,
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          const Text('Deadline', style: AppTextStyles.label),
          const SizedBox(height: 8),
          MyTextFormField(
            controller: _deadlineCtrl,
            hintText: 'e.g. 2026-12-31',
            height: 48,
          ),
          const SizedBox(height: 20),
          const Text('Assigned To', style: AppTextStyles.label),
          const SizedBox(height: 8),
          MyTextFormField(
            controller: _assignedToCtrl,
            hintText: 'Person or team responsible',
            height: 48,
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
                  : (isEdit ? 'Save Changes' : 'Add Obligation'),
            )),
      ],
    );
  }

  void _onSave() async {
    if (_obligationCtrl.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Obligation is required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final body = <String, dynamic>{
      'role_id': widget.roleId,
      'obligation': _obligationCtrl.text.trim(),
      'category': _category,
      'priority': _priority,
      'status': _status,
    };
    if (_descCtrl.text.trim().isNotEmpty) body['description'] = _descCtrl.text.trim();
    if (_deadlineCtrl.text.trim().isNotEmpty) body['deadline'] = _deadlineCtrl.text.trim();
    if (_assignedToCtrl.text.trim().isNotEmpty) body['assigned_to'] = _assignedToCtrl.text.trim();

    bool success;
    if (widget.profile != null) {
      success = await widget.ctrl.updateRiskProfile(widget.profile!.id, body);
    } else {
      success = await widget.ctrl.addRiskProfile(body);
    }
    if (success && mounted) Navigator.pop(context);
  }
}
