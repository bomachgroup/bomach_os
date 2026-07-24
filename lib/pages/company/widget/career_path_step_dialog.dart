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
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _requirementsCtrl;
  late final TextEditingController _durationCtrl;

  int? _toRoleId;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final s = widget.step;
    _toRoleId = s?.toRoleId;
    _descriptionCtrl = TextEditingController(text: s?.description ?? '');
    _requirementsCtrl = TextEditingController(text: s?.requirements ?? '');
    _durationCtrl = TextEditingController(
        text: s?.estimatedDurationMonths?.toString() ?? '');
    _isActive = s?.isActive ?? true;
  }

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    _requirementsCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.step != null;
    return DialogScaffold(
      title: isEdit ? 'Edit Career Path Step' : 'Add Career Path Step',
      subtitle: 'Define a career progression target role and transition details.',
      size: DialogSize.md,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Target Role (To)', style: AppTextStyles.label),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              hintText: 'Select target role',
              border: OutlineInputBorder(borderRadius: AppRadii.brMd),
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            initialValue: _toRoleId,
            items: widget.roles
                .where((r) => r.id != widget.currentRoleId)
                .map((r) => DropdownMenuItem(
                      value: r.id,
                      child: Text(r.name),
                    ))
                .toList(),
            onChanged: (val) => setState(() => _toRoleId = val),
          ),
          const SizedBox(height: 20),
          const Text('Description', style: AppTextStyles.label),
          const SizedBox(height: 8),
          MyTextFormField(
            controller: _descriptionCtrl,
            hintText: 'Brief description of this career step…',
            height: 80,
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          const Text('Requirements', style: AppTextStyles.label),
          const SizedBox(height: 8),
          MyTextFormField(
            controller: _requirementsCtrl,
            hintText: 'Skills, certifications, or experience needed…',
            height: 100,
            maxLines: 4,
          ),
          const SizedBox(height: 20),
          const Text('Estimated Duration (months)', style: AppTextStyles.label),
          const SizedBox(height: 8),
          MyTextFormField(
            controller: _durationCtrl,
            hintText: 'e.g. 12',
            height: 48,
            keyboardType: TextInputType.number,
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
    if (_toRoleId == null) {
      Get.snackbar('Validation', 'Please select a target role.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final duration = int.tryParse(_durationCtrl.text.trim());
    final sequence = widget.step?.sequence ?? (widget.ctrl.steps.length + 1);

    final body = <String, dynamic>{
      'to_role_id': _toRoleId!,
      'description': _descriptionCtrl.text.trim(),
      'requirements': _requirementsCtrl.text.trim(),
      if (duration != null) 'estimated_duration_months': duration,
      'sequence': sequence,
      'is_active': _isActive,
    };

    bool success;
    if (widget.step != null) {
      success = await widget.ctrl.updateStep(widget.step!.id, body);
    } else {
      success = await widget.ctrl.addStep(body);
    }

    if (success && mounted) Navigator.pop(context);
  }
}
