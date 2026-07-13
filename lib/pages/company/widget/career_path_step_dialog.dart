import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/career_path_model.dart';
import 'package:bomach_os/src/model/role_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/career_path_controller.dart';

class CreateEditCareerPathStepDialog extends StatefulWidget {
  final CareerPathController ctrl;
  final List<Role> roles;
  final int currentRoleId;
  final CareerPathStep? step;

  const CreateEditCareerPathStepDialog({
    super.key,
    required this.ctrl,
    required this.roles,
    required this.currentRoleId,
    this.step,
  });

  @override
  State<CreateEditCareerPathStepDialog> createState() =>
      _CreateEditCareerPathStepDialogState();
}

class _CreateEditCareerPathStepDialogState
    extends State<CreateEditCareerPathStepDialog> {
  late final TextEditingController _yearsCtrl;
  late final TextEditingController _kpiCtrl;
  late final TextEditingController _certsCtrl;

  int? _nextRoleId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final s = widget.step;
    _nextRoleId = s?.nextRoleId;
    _yearsCtrl = TextEditingController(
        text: s?.minYearsInRole?.toStringAsFixed(1) ?? '');
    _kpiCtrl = TextEditingController(
        text: s?.minKpiScore?.toStringAsFixed(1) ?? '');
    _certsCtrl = TextEditingController(
        text: s?.requiredCertifications.join('\n') ?? '');
    _isActive = s?.isActive ?? true;
  }

  @override
  void dispose() {
    _yearsCtrl.dispose();
    _kpiCtrl.dispose();
    _certsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.step != null;
    return DialogScaffold(
      title: isEdit ? 'Edit Career Step' : 'Add Career Step',
      subtitle: 'Define the next role in the career ladder and its criteria.',
      size: DialogSize.md,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Next Role', style: AppTextStyles.label),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              hintText: 'Select next role',
              border: OutlineInputBorder(borderRadius: AppRadii.brMd),
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            initialValue: _nextRoleId,
            items: widget.roles
                .where((r) => r.id != widget.currentRoleId)
                .map((r) => DropdownMenuItem(
                      value: r.id,
                      child: Text(r.name),
                    ))
                .toList(),
            onChanged: (val) => setState(() => _nextRoleId = val),
          ),
          const SizedBox(height: 20),
          const Text('Minimum Years in Role', style: AppTextStyles.label),
          const SizedBox(height: 8),
          MyTextFormField(
            controller: _yearsCtrl,
            hintText: 'e.g. 2.0',
            height: 48,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          const Text('Minimum KPI Score', style: AppTextStyles.label),
          const SizedBox(height: 8),
          MyTextFormField(
            controller: _kpiCtrl,
            hintText: 'e.g. 80.0',
            height: 48,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          const Text('Required Certifications', style: AppTextStyles.label),
          const SizedBox(height: 8),
          MyTextFormField(
            controller: _certsCtrl,
            hintText: 'One per line\ne.g. PMP\nSix Sigma Black Belt\nFirst Aid',
            height: 100,
            maxLines: 5,
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
                  : (isEdit ? 'Save Changes' : 'Add Step'),
            )),
      ],
    );
  }

  void _onSave() async {
    if (_nextRoleId == null) {
      Get.snackbar('Validation', 'Please select a next role',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final body = <String, dynamic>{
      'next_role_id': _nextRoleId,
      'is_active': _isActive,
      'sort_order': widget.step?.sortOrder ?? widget.ctrl.steps.length,
    };

    final years = double.tryParse(_yearsCtrl.text);
    final kpi = double.tryParse(_kpiCtrl.text);
    if (years != null) body['min_years_in_role'] = years;
    if (kpi != null) body['min_kpi_score'] = kpi;

    final certs = _certsCtrl.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (certs.isNotEmpty) body['required_certifications'] = certs;

    bool success;
    if (widget.step != null) {
      success = await widget.ctrl.updateStep(widget.step!.id, body);
    } else {
      body['role_id'] = widget.currentRoleId;
      success = await widget.ctrl.addStep(body);
    }

    if (success && mounted) Navigator.pop(context);
  }
}
