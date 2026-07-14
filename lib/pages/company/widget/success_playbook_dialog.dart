import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/role_success_playbook_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/role_success_playbook_controller.dart';

class CreateEditSuccessPlaybookDialog extends StatefulWidget {
  final RoleSuccessPlaybookController ctrl;
  final int? presetRoleId;
  final RoleSuccessPlaybook? playbook;

  const CreateEditSuccessPlaybookDialog({
    super.key,
    required this.ctrl,
    this.presetRoleId,
    this.playbook,
  });

  @override
  State<CreateEditSuccessPlaybookDialog> createState() =>
      _CreateEditSuccessPlaybookDialogState();
}

class _CreateEditSuccessPlaybookDialogState
    extends State<CreateEditSuccessPlaybookDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _metricsCtrl;
  late List<_PhaseInput> _phases;

  bool get isEditing => widget.playbook != null;

  @override
  void initState() {
    super.initState();
    final p = widget.playbook;
    _titleCtrl = TextEditingController(text: p?.title ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _metricsCtrl = TextEditingController(
        text: p?.metrics.isNotEmpty == true ? p!.metrics.join(', ') : '');
    _phases = (p?.phases ?? []).map((ph) => _PhaseInput(ph)).toList();
    if (_phases.isEmpty) _phases.add(_PhaseInput(null));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _metricsCtrl.dispose();
    for (final ph in _phases) ph.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: isEditing ? 'Edit Success Playbook' : 'Add Success Playbook',
      size: DialogSize.md,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyTextFormField(
                title: 'Title',
                hintText: 'e.g. First 90 Days as Manager',
                controller: _titleCtrl,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              MyTextFormField(
                title: 'Description (optional)',
                hintText: 'Overview of this success playbook',
                controller: _descCtrl,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              MyTextFormField(
                title: 'Metrics / KPIs (comma-separated)',
                hintText: 'e.g. Revenue target, Customer satisfaction, Time to productivity',
                controller: _metricsCtrl,
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Row(children: [
                Text('Phases & Steps',
                    style: AppTextStyles.label.copyWith(color: AppColors.textPrimary)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => setState(() => _phases.add(_PhaseInput(null))),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Phase'),
                ),
              ]),
              const SizedBox(height: 8),
              ...List.generate(_phases.length, (i) => _buildPhaseCard(i)),
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
              child: isEditing ? 'Update' : 'Create',
              onTap: _submit,
            )),
      ],
    );
  }

  Widget _buildPhaseCard(int index) {
    final ph = _phases[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Phase ${index + 1}',
              style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600)),
          const Spacer(),
          if (_phases.length > 1)
            IconButton(
              icon: const Icon(Icons.close, size: 16, color: AppColors.danger),
              onPressed: () => setState(() => _phases.removeAt(index)),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
        ]),
        const SizedBox(height: 8),
        MyTextFormField(
          hintText: 'Phase name',
          controller: ph.nameCtrl,
          height: 40,
        ),
        const SizedBox(height: 8),
        MyTextFormField(
          hintText: 'Phase description (optional)',
          controller: ph.descCtrl,
          height: 40,
        ),
        const SizedBox(height: 8),
        ...List.generate(ph.steps.length, (si) {
          final step = ph.steps[si];
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(children: [
              Text('${si + 1}.',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              Expanded(
                child: MyTextFormField(
                  hintText: 'Step title',
                  controller: step.titleCtrl,
                  height: 36,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MyTextFormField(
                  hintText: 'Details (optional)',
                  controller: step.descCtrl,
                  height: 36,
                ),
              ),
              if (ph.steps.length > 1)
                IconButton(
                  icon: const Icon(Icons.close, size: 14, color: AppColors.danger),
                  onPressed: () => setState(() => ph.steps.removeAt(si)),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
            ]),
          );
        }),
        TextButton.icon(
          onPressed: () => setState(() => ph.steps.add(_StepInput(null))),
          icon: const Icon(Icons.add, size: 14),
          label: const Text('Add Step', style: TextStyle(fontSize: 13)),
        ),
      ]),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final navigator = Navigator.of(context);

    final phases = _phases.map((ph) {
      return PlaybookPhase(
        phaseName: ph.nameCtrl.text.trim(),
        description: ph.descCtrl.text.trim(),
        order: _phases.indexOf(ph),
        steps: ph.steps.asMap().entries.map((e) {
          return PlaybookStep(
            stepNumber: e.key + 1,
            title: e.value.titleCtrl.text.trim(),
            description: e.value.descCtrl.text.trim(),
          );
        }).toList(),
      );
    }).toList();

    final metrics = _metricsCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final success = isEditing
        ? await widget.ctrl.updatePlaybook(
            context,
            id: widget.playbook!.id!,
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            phases: phases,
            metrics: metrics,
          )
        : await widget.ctrl.createPlaybook(
            context,
            roleId: widget.presetRoleId ?? 0,
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            phases: phases,
            metrics: metrics,
          );

    if (success && context.mounted) navigator.pop();
  }
}

class _PhaseInput {
  final TextEditingController nameCtrl;
  final TextEditingController descCtrl;
  final List<_StepInput> steps;

  _PhaseInput(PlaybookPhase? phase)
      : nameCtrl = TextEditingController(text: phase?.phaseName ?? ''),
        descCtrl = TextEditingController(text: phase?.description ?? ''),
        steps = (phase?.steps ?? []).map((s) => _StepInput(s)).toList();

  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    for (final s in steps) s.dispose();
  }
}

class _StepInput {
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;

  _StepInput(PlaybookStep? step)
      : titleCtrl = TextEditingController(text: step?.title ?? ''),
        descCtrl = TextEditingController(text: step?.description ?? '');

  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
  }
}
