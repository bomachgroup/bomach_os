import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/stakeholder_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/stakeholder_controller.dart';

class CreateEditStakeholderDialog extends StatefulWidget {
  final StakeholderController ctrl;
  final int roleId;
  final RoleStakeholder? stakeholder;

  const CreateEditStakeholderDialog({super.key, required this.ctrl, required this.roleId, this.stakeholder});

  @override
  State<CreateEditStakeholderDialog> createState() => _CreateEditStakeholderDialogState();
}

class _CreateEditStakeholderDialogState extends State<CreateEditStakeholderDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _orgCtrl;
  late final TextEditingController _protocolCtrl;
  late final TextEditingController _descCtrl;

  String _type = 'internal';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final s = widget.stakeholder;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _orgCtrl = TextEditingController(text: s?.organization ?? '');
    _protocolCtrl = TextEditingController(text: s?.communicationProtocol ?? '');
    _descCtrl = TextEditingController(text: s?.description ?? '');
    _type = s?.type ?? 'internal';
    _isActive = s?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _orgCtrl.dispose(); _protocolCtrl.dispose(); _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.stakeholder != null;
    return DialogScaffold(
      title: isEdit ? 'Edit Stakeholder' : 'Add Stakeholder',
      subtitle: 'Define who this role interacts with.',
      size: DialogSize.md,
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Name', style: AppTextStyles.label), const SizedBox(height: 8),
          MyTextFormField(controller: _nameCtrl, hintText: 'e.g. HR Director', height: 48),
          const SizedBox(height: 20),
          const Text('Type', style: AppTextStyles.label), const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(hintText: 'Select type', border: OutlineInputBorder(borderRadius: AppRadii.brMd), contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
            initialValue: _type,
            items: RoleStakeholder.typeOptions.map((t) => DropdownMenuItem(value: t, child: Text(t[0].toUpperCase() + t.substring(1)))).toList(),
            onChanged: (v) => setState(() => _type = v ?? 'internal'),
          ),
          const SizedBox(height: 20),
          const Text('Organization', style: AppTextStyles.label), const SizedBox(height: 8),
          MyTextFormField(controller: _orgCtrl, hintText: 'e.g. Bomach Group', height: 48),
          const SizedBox(height: 20),
          const Text('Communication Protocol', style: AppTextStyles.label), const SizedBox(height: 8),
          MyTextFormField(controller: _protocolCtrl, hintText: 'e.g. Weekly email, Slack channel', height: 80, maxLines: 3),
          const SizedBox(height: 20),
          const Text('Description', style: AppTextStyles.label), const SizedBox(height: 8),
          MyTextFormField(controller: _descCtrl, hintText: 'Nature of interaction', height: 80, maxLines: 3),
          const SizedBox(height: 20),
          Row(children: [
            const Text('Active', style: AppTextStyles.label), const SizedBox(width: 12),
            Switch(activeThumbColor: AppColors.primary, value: _isActive, onChanged: (v) => setState(() => _isActive = v)),
          ]),
        ]),
      ),
      actions: [
        MyOutlinedButton(child: 'Cancel', height: 44, onTap: () => Navigator.pop(context)),
        Obx(() => MyElevatedButton(width: 140, height: 44, onTap: widget.ctrl.isSaving.value ? null : _onSave,
          child: widget.ctrl.isSaving.value ? 'Saving...' : (isEdit ? 'Save Changes' : 'Add Stakeholder'))),
      ],
    );
  }

  void _onSave() async {
    if (_nameCtrl.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Name is required', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final body = <String, dynamic>{'role_id': widget.roleId, 'name': _nameCtrl.text.trim(), 'type': _type, 'is_active': _isActive};
    if (_orgCtrl.text.trim().isNotEmpty) body['organization'] = _orgCtrl.text.trim();
    if (_protocolCtrl.text.trim().isNotEmpty) body['communication_protocol'] = _protocolCtrl.text.trim();
    if (_descCtrl.text.trim().isNotEmpty) body['description'] = _descCtrl.text.trim();

    final success = widget.stakeholder != null ? await widget.ctrl.updateStakeholder(widget.stakeholder!.id, body) : await widget.ctrl.addStakeholder(body);
    if (success && mounted) Navigator.pop(context);
  }
}
