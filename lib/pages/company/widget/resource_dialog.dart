import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/role_resource_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/role_resource_controller.dart';

class CreateResourceDialog extends StatefulWidget {
  final RoleResourceController ctrl;
  final int? presetRoleId;

  const CreateResourceDialog({super.key, required this.ctrl, this.presetRoleId});

  @override
  State<CreateResourceDialog> createState() => _CreateResourceDialogState();
}

class _CreateResourceDialogState extends State<CreateResourceDialog> {
  ResourceType _selectedType = ResourceType.physicalResource;

  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _extraCtrl1 = TextEditingController();
  final _extraCtrl2 = TextEditingController();

  bool _isMandatory = false;
  bool _isAssigned = false;
  int _quantity = 1;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _extraCtrl1.dispose();
    _extraCtrl2.dispose();
    super.dispose();
  }

  static const _dropdownDecor = InputDecoration(
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
      title: 'Add ${_typeLabel(_selectedType)}',
      size: DialogSize.sm,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type',
                style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            DropdownButtonFormField<ResourceType>(
              initialValue: _selectedType,
              decoration: _dropdownDecor,
              items: ResourceType.values.map((t) => DropdownMenuItem(
                  value: t, child: Text(_typeLabel(t)))).toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _selectedType = v;
                    _nameCtrl.clear();
                    _descCtrl.clear();
                    _extraCtrl1.clear();
                    _extraCtrl2.clear();
                    _isMandatory = false;
                    _isAssigned = false;
                    _quantity = 1;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            MyTextFormField(
              title: _nameLabel(),
              hintText: _nameHint(),
              controller: _nameCtrl,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            if (_showDescription) ...[
              const SizedBox(height: 16),
              MyTextFormField(
                title: 'Description',
                hintText: 'Details about this item',
                controller: _descCtrl,
                maxLines: 3,
              ),
            ],
            if (_showExtra1) ...[
              const SizedBox(height: 16),
              MyTextFormField(title: _extra1Label(), hintText: _extra1Hint(), controller: _extraCtrl1),
            ],
            if (_showExtra2) ...[
              const SizedBox(height: 16),
              MyTextFormField(title: _extra2Label(), hintText: _extra2Hint(), controller: _extraCtrl2),
            ],
            if (_selectedType == ResourceType.physicalResource) ...[
              const SizedBox(height: 16),
              MyTextFormField(
                title: 'Quantity',
                hintText: '1',
                controller: TextEditingController(text: _quantity.toString()),
                keyboardType: TextInputType.number,
                onChanged: (v) => _quantity = int.tryParse(v) ?? 1,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    height: 24, width: 24,
                    child: Checkbox(
                      value: _isAssigned,
                      onChanged: (v) => setState(() => _isAssigned = v ?? false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Currently assigned', style: AppTextStyles.bodySm),
                ],
              ),
            ],
            if (_selectedType == ResourceType.certification) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    height: 24, width: 24,
                    child: Checkbox(
                      value: _isMandatory,
                      onChanged: (v) => setState(() => _isMandatory = v ?? false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Mandatory certification', style: AppTextStyles.bodySm),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        MyOutlinedButton(height: 40, child: 'Cancel', onTap: () => Navigator.pop(context)),
        const SizedBox(width: 12),
        Obx(() => MyElevatedButton(
              height: 40,
              isLoading: widget.ctrl.isSaving.value,
              child: 'Create',
              onTap: _submit,
            )),
      ],
    );
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    final navigator = Navigator.of(context);

    final payload = <String, dynamic>{};
    switch (_selectedType) {
      case ResourceType.physicalResource:
        payload['name'] = _nameCtrl.text.trim();
        payload['description'] = _descCtrl.text.trim();
        payload['quantity'] = _quantity;
        payload['is_assigned'] = _isAssigned;
      case ResourceType.softwareTool:
        payload['name'] = _nameCtrl.text.trim();
        payload['vendor'] = _extraCtrl1.text.trim();
        payload['license_type'] = _extraCtrl2.text.trim();
      case ResourceType.referenceDocument:
        payload['title'] = _nameCtrl.text.trim();
        payload['document_type'] = _extraCtrl1.text.trim();
        payload['file_path'] = _extraCtrl2.text.trim();
      case ResourceType.technicalSkill:
        payload['name'] = _nameCtrl.text.trim();
        payload['category'] = _extraCtrl1.text.trim();
        payload['proficiency_level'] = _extraCtrl2.text.trim();
      case ResourceType.softSkill:
        payload['name'] = _nameCtrl.text.trim();
        payload['description'] = _descCtrl.text.trim();
      case ResourceType.experienceRequirement:
        payload['description'] = _nameCtrl.text.trim();
        payload['min_years'] = int.tryParse(_extraCtrl1.text.trim()) ?? 0;
        payload['experience_type'] = _extraCtrl2.text.trim();
      case ResourceType.certification:
        payload['name'] = _nameCtrl.text.trim();
        payload['issuing_body'] = _extraCtrl1.text.trim();
        payload['is_mandatory'] = _isMandatory;
    }

    final success = await widget.ctrl.create(context, _selectedType, payload);
    if (success && context.mounted) navigator.pop();
  }

  String _typeLabel(ResourceType t) => switch (t) {
    ResourceType.physicalResource => 'Physical Resource',
    ResourceType.softwareTool => 'Software Tool',
    ResourceType.referenceDocument => 'Reference Document',
    ResourceType.technicalSkill => 'Technical Skill',
    ResourceType.softSkill => 'Soft Skill',
    ResourceType.experienceRequirement => 'Experience Requirement',
    ResourceType.certification => 'Certification',
  };

  String _nameLabel() => switch (_selectedType) {
    ResourceType.physicalResource => 'Resource Name',
    ResourceType.softwareTool => 'Tool Name',
    ResourceType.referenceDocument => 'Document Title',
    ResourceType.technicalSkill => 'Skill Name',
    ResourceType.softSkill => 'Skill Name',
    ResourceType.experienceRequirement => 'Experience Description',
    ResourceType.certification => 'Certification Name',
  };

  String _nameHint() => switch (_selectedType) {
    ResourceType.physicalResource => 'e.g. Laptop, Vehicle',
    ResourceType.softwareTool => 'e.g. AutoCAD, QGIS',
    ResourceType.referenceDocument => 'e.g. Company Policy Manual',
    ResourceType.technicalSkill => 'e.g. Survey Calculations',
    ResourceType.softSkill => 'e.g. Leadership',
    ResourceType.experienceRequirement => 'e.g. Minimum 3 years in surveying',
    ResourceType.certification => 'e.g. PMP, COREN',
  };

  bool get _showDescription => switch (_selectedType) {
    ResourceType.softSkill => true,
    ResourceType.physicalResource => true,
    _ => false,
  };

  bool get _showExtra1 => switch (_selectedType) {
    ResourceType.softwareTool || ResourceType.referenceDocument || ResourceType.technicalSkill || ResourceType.experienceRequirement || ResourceType.certification => true,
    _ => false,
  };

  bool get _showExtra2 => switch (_selectedType) {
    ResourceType.softwareTool || ResourceType.referenceDocument || ResourceType.technicalSkill || ResourceType.experienceRequirement => true,
    _ => false,
  };

  String _extra1Label() => switch (_selectedType) {
    ResourceType.softwareTool => 'Vendor',
    ResourceType.referenceDocument => 'Document Type',
    ResourceType.technicalSkill => 'Category',
    ResourceType.experienceRequirement => 'Min Years',
    ResourceType.certification => 'Issuing Body',
    _ => '',
  };

  String _extra1Hint() => switch (_selectedType) {
    ResourceType.softwareTool => 'e.g. Autodesk, Google',
    ResourceType.referenceDocument => 'e.g. Policy, Manual, Contract',
    ResourceType.technicalSkill => 'e.g. Engineering, Design',
    ResourceType.experienceRequirement => '3',
    ResourceType.certification => 'e.g. COREN, PMI',
    _ => '',
  };

  String _extra2Label() => switch (_selectedType) {
    ResourceType.softwareTool => 'License Type',
    ResourceType.referenceDocument => 'File Path',
    ResourceType.technicalSkill => 'Proficiency Level',
    ResourceType.experienceRequirement => 'Experience Type',
    _ => '',
  };

  String _extra2Hint() => switch (_selectedType) {
    ResourceType.softwareTool => 'e.g. Enterprise, Free',
    ResourceType.referenceDocument => 'URL or file path',
    ResourceType.technicalSkill => 'e.g. Beginner, Advanced',
    ResourceType.experienceRequirement => 'e.g. Industry, Leadership',
    _ => '',
  };
}
