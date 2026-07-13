import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/role_kpi_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/role_kpi_controller.dart';

class CreateEditKpiDialog extends StatefulWidget {
  final RoleKpiController ctrl;
  final RoleKpi? kpi;
  final int? presetRoleId;

  const CreateEditKpiDialog({
    super.key,
    required this.ctrl,
    this.kpi,
    this.presetRoleId,
  });

  @override
  State<CreateEditKpiDialog> createState() => _CreateEditKpiDialogState();
}

class _CreateEditKpiDialogState extends State<CreateEditKpiDialog> {
  late final TextEditingController _metricCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _targetCtrl;
  late final TextEditingController _categoryCtrl;

  late String _selectedUnit;
  late String _selectedFrequency;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final kpi = widget.kpi;
    _metricCtrl = TextEditingController(text: kpi?.metricName ?? '');
    _descCtrl = TextEditingController(text: kpi?.description ?? '');
    _targetCtrl = TextEditingController(
        text: kpi?.target.toStringAsFixed(kpi.target % 1 == 0 ? 0 : 2) ?? '');
    _categoryCtrl = TextEditingController(text: kpi?.category ?? '');
    _selectedUnit = kpi?.unit ?? '%';
    _selectedFrequency = kpi?.frequency ?? 'monthly';
    _isActive = kpi?.isActive ?? true;
  }

  @override
  void dispose() {
    _metricCtrl.dispose();
    _descCtrl.dispose();
    _targetCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (_metricCtrl.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Metric name is required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final target = double.tryParse(_targetCtrl.text.trim());
    if (target == null) {
      Get.snackbar('Validation', 'Target must be a valid number',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final isEdit = widget.kpi != null;
    bool success;

    if (isEdit) {
      success = await widget.ctrl.updateKpi(
        context,
        id: widget.kpi!.id!,
        metricName: _metricCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        unit: _selectedUnit,
        target: target,
        frequency: _selectedFrequency,
        category: _categoryCtrl.text.trim().isNotEmpty
            ? _categoryCtrl.text.trim()
            : null,
        isActive: _isActive,
      );
    } else {
      success = await widget.ctrl.createKpi(
        context,
        roleId: widget.presetRoleId ?? 0,
        metricName: _metricCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        unit: _selectedUnit,
        target: target,
        frequency: _selectedFrequency,
        category: _categoryCtrl.text.trim().isNotEmpty
            ? _categoryCtrl.text.trim()
            : null,
        isActive: _isActive,
      );
    }

    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.kpi != null;

    return DialogScaffold(
      title: isEdit ? 'Edit KPI' : 'Add KPI',
      subtitle: isEdit
          ? 'Update the KPI definition for this role.'
          : 'Define a new Key Performance Indicator for a role template.',
      size: DialogSize.md,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Metric Name ─────────────────────────────────────────────
          const Text('Metric Name', style: AppTextStyles.label),
          const SizedBox(height: 8),
          MyTextFormField(
            controller: _metricCtrl,
            hintText: 'e.g. Revenue Generated, Task Completion Rate',
            height: 48,
          ),
          const SizedBox(height: 16),

          // ── Description ─────────────────────────────────────────────
          const Text('Description', style: AppTextStyles.label),
          const SizedBox(height: 8),
          MyTextFormField(
            controller: _descCtrl,
            hintText: 'Brief explanation of how this KPI is measured',
            height: 72,
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // ── Target + Unit row ────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Target Value', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    MyTextFormField(
                      controller: _targetCtrl,
                      hintText: 'e.g. 95',
                      height: 48,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Unit', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: AppRadii.brMd),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                      initialValue: _selectedUnit,
                      items: RoleKpi.unitOptions
                          .map((u) => DropdownMenuItem(
                              value: u, child: Text(u)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedUnit = v!),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Frequency ────────────────────────────────────────────────
          const Text('Measurement Frequency', style: AppTextStyles.label),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(borderRadius: AppRadii.brMd),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            initialValue: _selectedFrequency,
            items: RoleKpi.frequencyOptions
                .map((f) => DropdownMenuItem(
                      value: f,
                      child: Text(f[0].toUpperCase() + f.substring(1)),
                    ))
                .toList(),
            onChanged: (v) =>
                setState(() => _selectedFrequency = v!),
          ),
          const SizedBox(height: 16),

          // ── Category ─────────────────────────────────────────────────
          const Text('Category (optional)', style: AppTextStyles.label),
          const SizedBox(height: 8),
          MyTextFormField(
            controller: _categoryCtrl,
            hintText: 'e.g. Revenue, Attendance, Quality',
            height: 48,
          ),
          const SizedBox(height: 16),

          // ── Active toggle ─────────────────────────────────────────────
          Row(
            children: [
              Switch(
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                activeThumbColor: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Text('Active', style: AppTextStyles.bodyMd),
              const SizedBox(width: 4),
              Text(
                '(inactive KPIs are hidden from dashboards)',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
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
                  : (isEdit ? 'Save Changes' : 'Add KPI'),
            )),
      ],
    );
  }
}
