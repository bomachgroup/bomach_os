import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/role_okr_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/role_okr_controller.dart';

class CreateEditOkrDialog extends StatefulWidget {
  final RoleOkrController ctrl;
  final RoleOkr? okr;
  final int? presetRoleId;

  const CreateEditOkrDialog({
    super.key,
    required this.ctrl,
    this.okr,
    this.presetRoleId,
  });

  @override
  State<CreateEditOkrDialog> createState() => _CreateEditOkrDialogState();
}

class _CreateEditOkrDialogState extends State<CreateEditOkrDialog> {
  late final TextEditingController _objectiveCtrl;
  late final TextEditingController _descCtrl;
  late int _quarter;
  late int _year;
  late String _status;

  /// In-progress key results for new OKR creation
  final List<TextEditingController> _krControllers = [];

  @override
  void initState() {
    super.initState();
    final okr = widget.okr;
    final now = DateTime.now();
    _objectiveCtrl = TextEditingController(text: okr?.objective ?? '');
    _descCtrl = TextEditingController(text: okr?.description ?? '');
    _quarter = okr?.quarter ?? ((now.month - 1) ~/ 3 + 1);
    _year = okr?.year ?? now.year;
    _status = okr?.status ?? 'active';

    // Pre-fill KR text controllers if editing
    if (okr != null) {
      for (final kr in okr.keyResults) {
        _krControllers.add(TextEditingController(text: kr.title));
      }
    }
    if (_krControllers.isEmpty) {
      _krControllers.add(TextEditingController()); // start with one blank
    }
  }

  @override
  void dispose() {
    _objectiveCtrl.dispose();
    _descCtrl.dispose();
    for (final c in _krControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addKrField() {
    setState(() => _krControllers.add(TextEditingController()));
  }

  void _removeKrField(int index) {
    if (_krControllers.length <= 1) return;
    setState(() {
      _krControllers[index].dispose();
      _krControllers.removeAt(index);
    });
  }

  void _onSave() async {
    if (_objectiveCtrl.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Objective is required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final isEdit = widget.okr != null;
    final keyResults = _krControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .map((title) => {'title': title, 'progress_percent': 0})
        .toList();

    bool success;

    if (isEdit) {
      success = await widget.ctrl.updateOkr(
        context,
        id: widget.okr!.id!,
        objective: _objectiveCtrl.text.trim(),
        description:
            _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
        quarter: _quarter,
        year: _year,
        status: _status,
      );
    } else {
      success = await widget.ctrl.createOkr(
        context,
        roleId: widget.presetRoleId ?? 0,
        objective: _objectiveCtrl.text.trim(),
        description:
            _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
        quarter: _quarter,
        year: _year,
        status: _status,
        keyResults: keyResults,
      );
    }

    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.okr != null;

    return DialogScaffold(
      title: isEdit ? 'Edit OKR' : 'New OKR',
      subtitle: isEdit
          ? 'Update this objective and its key results.'
          : 'Define an Objective and Key Results for a role template.',
      size: DialogSize.md,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Objective ───────────────────────────────────────────────
          const Text('Objective', style: AppTextStyles.label),
          const SizedBox(height: 8),
          MyTextFormField(
            controller: _objectiveCtrl,
            hintText: 'e.g. Deliver outstanding customer experience this quarter',
            height: 72,
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // ── Description ─────────────────────────────────────────────
          const Text('Description (optional)', style: AppTextStyles.label),
          const SizedBox(height: 8),
          MyTextFormField(
            controller: _descCtrl,
            hintText: 'Provide additional context for this objective',
            height: 56,
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // ── Quarter + Year ───────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quarter', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: AppRadii.brMd),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                      value: _quarter,
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Q1 (Jan–Mar)')),
                        DropdownMenuItem(value: 2, child: Text('Q2 (Apr–Jun)')),
                        DropdownMenuItem(value: 3, child: Text('Q3 (Jul–Sep)')),
                        DropdownMenuItem(value: 4, child: Text('Q4 (Oct–Dec)')),
                      ],
                      onChanged: (v) => setState(() => _quarter = v!),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Year', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: AppRadii.brMd),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                      value: _year,
                      items: List.generate(5, (i) => DateTime.now().year - 1 + i)
                          .map((y) => DropdownMenuItem(
                              value: y, child: Text('$y')))
                          .toList(),
                      onChanged: (v) => setState(() => _year = v!),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Status ───────────────────────────────────────────────────
          const Text('Status', style: AppTextStyles.label),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(borderRadius: AppRadii.brMd),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            value: _status,
            items: RoleOkr.statusOptions
                .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s[0].toUpperCase() + s.substring(1)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _status = v!),
          ),
          const SizedBox(height: 20),

          // ── Key Results ─────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Key Results', style: AppTextStyles.label),
              TextButton.icon(
                onPressed: _addKrField,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add KR'),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(_krControllers.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: MyTextFormField(
                      controller: _krControllers[i],
                      hintText: 'Key Result ${i + 1}',
                      height: 44,
                    ),
                  ),
                  if (_krControllers.length > 1) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline,
                          color: AppColors.danger, size: 20),
                      onPressed: () => _removeKrField(i),
                      tooltip: 'Remove',
                    ),
                  ],
                ],
              ),
            );
          }),
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
                  : (isEdit ? 'Save Changes' : 'Create OKR'),
            )),
      ],
    );
  }
}
