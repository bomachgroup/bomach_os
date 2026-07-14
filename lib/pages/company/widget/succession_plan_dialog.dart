import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/succession_plan_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/succession_plan_controller.dart';

class CreateEditSuccessionPlanDialog extends StatefulWidget {
  final SuccessionPlanController ctrl;
  final int roleId;
  final SuccessionPlan? plan;

  const CreateEditSuccessionPlanDialog({super.key, required this.ctrl, required this.roleId, this.plan});

  @override
  State<CreateEditSuccessionPlanDialog> createState() => _CreateEditSuccessionPlanDialogState();
}

class _CreateEditSuccessionPlanDialogState extends State<CreateEditSuccessionPlanDialog> {
  late final TextEditingController _primaryCtrl;
  late final TextEditingController _primaryEmployeeCtrl;
  late final TextEditingController _backupCtrl;
  late final TextEditingController _backupEmployeeCtrl;
  late final TextEditingController _devPlanCtrl;
  late final TextEditingController _notesCtrl;

  String _readiness = 'pipeline';

  @override
  void initState() {
    super.initState();
    final p = widget.plan;
    _primaryCtrl = TextEditingController(text: p?.primarySuccessorName ?? '');
    _primaryEmployeeCtrl = TextEditingController(text: p?.primarySuccessorEmployeeId ?? '');
    _backupCtrl = TextEditingController(text: p?.backupSuccessorName ?? '');
    _backupEmployeeCtrl = TextEditingController(text: p?.backupSuccessorEmployeeId ?? '');
    _devPlanCtrl = TextEditingController(text: p?.developmentPlan ?? '');
    _notesCtrl = TextEditingController(text: p?.notes ?? '');
    _readiness = p?.readiness ?? 'pipeline';
  }

  @override
  void dispose() {
    _primaryCtrl.dispose(); _primaryEmployeeCtrl.dispose();
    _backupCtrl.dispose(); _backupEmployeeCtrl.dispose();
    _devPlanCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.plan != null;
    return DialogScaffold(
      title: isEdit ? 'Edit Succession Plan' : 'Add Succession Plan',
      subtitle: 'Identify successors and readiness for this role.',
      size: DialogSize.md,
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Primary Successor Name', style: AppTextStyles.label), const SizedBox(height: 8),
          MyTextFormField(controller: _primaryCtrl, hintText: 'e.g. Jane Doe', height: 48),
          const SizedBox(height: 16),
          const Text('Primary Successor Employee ID', style: AppTextStyles.label), const SizedBox(height: 8),
          MyTextFormField(controller: _primaryEmployeeCtrl, hintText: 'e.g. EMP001', height: 48),
          const SizedBox(height: 16),
          const Text('Backup Successor Name', style: AppTextStyles.label), const SizedBox(height: 8),
          MyTextFormField(controller: _backupCtrl, hintText: 'e.g. John Smith', height: 48),
          const SizedBox(height: 16),
          const Text('Backup Successor Employee ID', style: AppTextStyles.label), const SizedBox(height: 8),
          MyTextFormField(controller: _backupEmployeeCtrl, hintText: 'e.g. EMP002', height: 48),
          const SizedBox(height: 20),
          const Text('Readiness', style: AppTextStyles.label), const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(hintText: 'Select readiness', border: OutlineInputBorder(borderRadius: AppRadii.brMd), contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
            initialValue: _readiness,
            items: SuccessionPlan.readinessOptions.map((r) {
              final labels = {'ready_now': 'Ready Now', 'ready_1yr': 'Ready in 1yr', 'pipeline': 'Pipeline'};
              return DropdownMenuItem(value: r, child: Text(labels[r] ?? r));
            }).toList(),
            onChanged: (v) => setState(() => _readiness = v ?? 'pipeline'),
          ),
          const SizedBox(height: 20),
          const Text('Development Plan', style: AppTextStyles.label), const SizedBox(height: 8),
          MyTextFormField(controller: _devPlanCtrl, hintText: 'Outline development steps for the successor', height: 80, maxLines: 3),
          const SizedBox(height: 20),
          const Text('Notes', style: AppTextStyles.label), const SizedBox(height: 8),
          MyTextFormField(controller: _notesCtrl, hintText: 'Additional notes', height: 80, maxLines: 3),
        ]),
      ),
      actions: [
        MyOutlinedButton(child: 'Cancel', height: 44, onTap: () => Navigator.pop(context)),
        Obx(() => MyElevatedButton(width: 140, height: 44, onTap: widget.ctrl.isSaving.value ? null : _onSave,
          child: widget.ctrl.isSaving.value ? 'Saving...' : (isEdit ? 'Save Changes' : 'Add Plan'))),
      ],
    );
  }

  void _onSave() async {
    if (_primaryCtrl.text.trim().isEmpty && _backupCtrl.text.trim().isEmpty) {
      Get.snackbar('Validation', 'At least one successor is required', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final body = <String, dynamic>{'role_id': widget.roleId, 'readiness': _readiness};
    if (_primaryCtrl.text.trim().isNotEmpty) body['primary_successor_name'] = _primaryCtrl.text.trim();
    if (_primaryEmployeeCtrl.text.trim().isNotEmpty) body['primary_successor_employee_id'] = _primaryEmployeeCtrl.text.trim();
    if (_backupCtrl.text.trim().isNotEmpty) body['backup_successor_name'] = _backupCtrl.text.trim();
    if (_backupEmployeeCtrl.text.trim().isNotEmpty) body['backup_successor_employee_id'] = _backupEmployeeCtrl.text.trim();
    if (_devPlanCtrl.text.trim().isNotEmpty) body['development_plan'] = _devPlanCtrl.text.trim();
    if (_notesCtrl.text.trim().isNotEmpty) body['notes'] = _notesCtrl.text.trim();

    final success = widget.plan != null ? await widget.ctrl.updatePlan(widget.plan!.id, body) : await widget.ctrl.addPlan(body);
    if (success && mounted) Navigator.pop(context);
  }
}
