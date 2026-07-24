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
  late final TextEditingController _sopIdCtrl;
  int? _selectedSopId;
  bool _isActive = true;

  bool get isEditing => widget.sop != null;

  @override
  void initState() {
    super.initState();
    final s = widget.sop;
    _selectedSopId = s?.sopId;
    _sopIdCtrl = TextEditingController(
        text: s?.sopId != null && s!.sopId > 0 ? s.sopId.toString() : '');
    _isActive = s?.isActive ?? true;

    widget.ctrl.fetchAvailableSops();
  }

  @override
  void dispose() {
    _sopIdCtrl.dispose();
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
      title: isEditing ? 'Edit Role SOP Link' : 'Link Standard Operating Procedure',
      size: DialogSize.sm,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                final list = widget.ctrl.availableSops;
                if (list.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Select SOP',
                          style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedSopId,
                        decoration: _defaultDropdownDecoration,
                        items: list.map((item) {
                          final id = item['id'] as int? ?? 0;
                          final title = item['title']?.toString() ?? 'SOP #$id';
                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text(title, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              _selectedSopId = v;
                              _sopIdCtrl.text = v.toString();
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
              MyTextFormField(
                title: 'SOP ID',
                hintText: 'e.g. 1',
                controller: _sopIdCtrl,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'SOP ID is required';
                  if (int.tryParse(v.trim()) == null) return 'Must be a valid integer ID';
                  return null;
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
              child: isEditing ? 'Update' : 'Link SOP',
              onTap: _submit,
            )),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final navigator = Navigator.of(context);

    final sopId = int.parse(_sopIdCtrl.text.trim());

    final success = isEditing
        ? await widget.ctrl.updateRoleSop(
            context,
            roleSopId: widget.sop!.id,
            sopId: sopId,
            isActive: _isActive,
          )
        : await widget.ctrl.attachSop(
            context,
            roleId: widget.presetRoleId ?? 0,
            sopId: sopId,
            isActive: _isActive,
          );

    if (success && context.mounted) navigator.pop();
  }
}
