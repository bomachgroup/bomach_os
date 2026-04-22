import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/model/approval_model.dart';
import 'package:bms_front_end/src/model/board_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../controllers/approval_controller.dart';

// ═══════════════════════════════════════════════════════════════════════
//  CREATE / EDIT WORKFLOW DIALOG
// ═══════════════════════════════════════════════════════════════════════

class CreateEditWorkflowDialog extends StatefulWidget {
  final ApprovalFlow? flow;
  const CreateEditWorkflowDialog({super.key, this.flow});

  @override
  State<CreateEditWorkflowDialog> createState() =>
      _CreateEditWorkflowDialogState();
}

class _CreateEditWorkflowDialogState extends State<CreateEditWorkflowDialog> {
  final _formKey = GlobalKey<FormState>();
  final ApprovalController controller = Get.find<ApprovalController>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _notesCtrl;
  String? _selectedAction;
  String? _selectedLevels;
  String? _selectedStatus;
  final List<String> _selectedApprovers = [];

  bool get isEdit => widget.flow != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.flow?.name ?? '');
    _notesCtrl = TextEditingController(text: widget.flow?.notes ?? '');
    _selectedAction =
        widget.flow?.action.isNotEmpty == true ? widget.flow!.action : null;
    _selectedLevels = widget.flow != null && widget.flow!.levels > 0
        ? widget.flow!.levels.toString()
        : null;
    _selectedStatus =
        widget.flow?.status.isNotEmpty == true ? widget.flow!.status : 'active';
    if (widget.flow != null) {
      _selectedApprovers.addAll(widget.flow!.approvers);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_nameCtrl.text.trim().isEmpty) return;

    final steps = _selectedApprovers.isEmpty
        ? [
            {
              'step_order': 1,
              'step_name': 'Approval Step',
              'required_level': _selectedLevels ?? '',
            }
          ]
        : _selectedApprovers.asMap().entries.map((entry) {
            return {
              'step_order': entry.key + 1,
              'step_name': 'Step ${entry.key + 1}',
              'required_level': entry.value,
            };
          }).toList();

    final data = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'action_type': _selectedAction ?? '',
      'description': _notesCtrl.text.trim(),
      'is_active': (_selectedStatus ?? 'active') == 'active',
      'steps': steps,
    };

    if (isEdit) {
      controller.updateFlow(context, widget.flow!.id, data);
    } else {
      controller.createFlow(context, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final choices = controller.flowChoices.value;
      final actionOptions = choices?.actions ?? <BoardFieldOption>[];
      final levelOptions = choices?.levels ?? <BoardFieldOption>[];
      final statusOptions = choices?.statuses ??
          [
            BoardFieldOption(value: 'active', label: 'Active'),
            BoardFieldOption(value: 'inactive', label: 'Inactive'),
          ];
      final approverOptions =
          choices?.approverTypes ?? <BoardFieldOption>[];

      String? selectedActionLabel = actionOptions
          .firstWhereOrNull((o) => o.value == _selectedAction)
          ?.label;
      String? selectedLevelLabel = levelOptions
          .firstWhereOrNull((o) => o.value == _selectedLevels)
          ?.label;
      String? selectedStatusLabel = statusOptions
          .firstWhereOrNull((o) => o.value == _selectedStatus)
          ?.label;

      return DialogScaffold(
        title: isEdit ? 'Edit Approval Workflow' : 'New Approval Workflow',
        subtitle: isEdit
            ? 'Update the workflow rules, approvers, and activation.'
            : 'Configure a multi-level approval workflow for specific actions.',
        size: DialogSize.lg,
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                title: 'Basics',
                subtitle: 'Give this workflow a name and a short description.',
                child: Column(
                  children: [
                    MyTextFormField(
                      controller: _nameCtrl,
                      title: 'Workflow name',
                      hintText: 'e.g. Expense Approval',
                      validator: (val) => (val == null || val.trim().isEmpty)
                          ? 'Workflow name is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    MyTextFormField(
                      controller: _notesCtrl,
                      title: 'Description',
                      hintText: 'What does this workflow govern?',
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSection(
                title: 'Scope',
                subtitle:
                    'Pick the action that triggers this workflow and how many levels of review it requires.',
                child: Column(
                  children: [
                    MyDropdown(
                      title: 'Action type',
                      hintText: selectedActionLabel ?? 'Select an action',
                      items: actionOptions.map((o) => o.label).toList(),
                      initialSelection: selectedActionLabel,
                      onChanged: (val) {
                        final match = actionOptions
                            .firstWhereOrNull((o) => o.label == val);
                        setState(() => _selectedAction = match?.value);
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: MyDropdown(
                            title: 'Levels',
                            hintText: selectedLevelLabel ?? 'Select',
                            items: levelOptions.map((o) => o.label).toList(),
                            initialSelection: selectedLevelLabel,
                            onChanged: (val) {
                              final match = levelOptions
                                  .firstWhereOrNull((o) => o.label == val);
                              setState(() => _selectedLevels = match?.value);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MyDropdown(
                            title: 'Status',
                            hintText: selectedStatusLabel ?? 'Select',
                            items: statusOptions.map((o) => o.label).toList(),
                            initialSelection: selectedStatusLabel,
                            onChanged: (val) {
                              final match = statusOptions
                                  .firstWhereOrNull((o) => o.label == val);
                              setState(() => _selectedStatus = match?.value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSection(
                title: 'Approvers',
                subtitle:
                    'Select the approver types who must sign off, in order.',
                child: _buildApproversEditor(approverOptions),
              ),
            ],
          ),
        ),
        actions: [
          MyOutlinedButton(
            child: 'Cancel',
            height: 44,
            onTap: () => Navigator.pop(context),
            textColor: AppColors.textSecondary,
            borderColor: AppColors.borderStrong,
          ),
          MyElevatedButton(
            width: 140,
            height: 44,
            child: controller.isSavingFlow.value
                ? 'Saving...'
                : (isEdit ? 'Save changes' : 'Create workflow'),
            onTap: controller.isSavingFlow.value ? null : _onSave,
            icon: controller.isSavingFlow.value
                ? null
                : const Icon(Iconsax.tick_circle,
                    size: 18, color: AppColors.textOnPrimary),
          ),
        ],
      );
    });
  }

  Widget _buildApproversEditor(List<BoardFieldOption> options) {
    final remaining = options
        .where((o) => !_selectedApprovers.contains(o.value))
        .toList();
    String? stagedValue;

    return StatefulBuilder(builder: (ctx, setInner) {
      String? stagedLabel = remaining
          .firstWhereOrNull((o) => o.value == stagedValue)
          ?.label;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedApprovers.isNotEmpty) ...[
            Column(
              children: _selectedApprovers.asMap().entries.map((entry) {
                final value = entry.value;
                final label = options
                        .firstWhereOrNull((o) => o.value == value)
                        ?.label ??
                    value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadii.brMd,
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.primarySubtle,
                          borderRadius: AppRadii.brSm,
                        ),
                        child: Text(
                          '${entry.key + 1}',
                          style: AppText.bodySm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: AppText.bodyMd.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove',
                        onPressed: () {
                          setState(() =>
                              _selectedApprovers.removeAt(entry.key));
                        },
                        icon: const Icon(Iconsax.close_circle,
                            size: 18, color: AppColors.danger),
                        splashRadius: 18,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          if (remaining.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: MyDropdown(
                    title: 'Add approver',
                    hintText: 'Select an approver type',
                    items: remaining.map((o) => o.label).toList(),
                    initialSelection: stagedLabel,
                    onChanged: (val) {
                      final match =
                          remaining.firstWhereOrNull((o) => o.label == val);
                      setInner(() => stagedValue = match?.value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: Material(
                    color: AppColors.primary,
                    borderRadius: AppRadii.brMd,
                    child: InkWell(
                      borderRadius: AppRadii.brMd,
                      onTap: () {
                        if (stagedValue == null) return;
                        setState(() => _selectedApprovers.add(stagedValue!));
                        setInner(() => stagedValue = null);
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        child: const Icon(Iconsax.add,
                            color: AppColors.textOnPrimary, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else if (options.isEmpty)
            Text(
              'Approver types will appear once available.',
              style: AppText.bodySm
                  .copyWith(color: AppColors.textSecondary),
            )
          else
            Text(
              'All available approver types have been added.',
              style: AppText.bodySm
                  .copyWith(color: AppColors.textSecondary),
            ),
        ],
      );
    });
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.h4),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppText.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  VIEW WORKFLOW DIALOG
// ═══════════════════════════════════════════════════════════════════════

class ViewWorkflowDialog extends StatelessWidget {
  final ApprovalFlow flow;
  const ViewWorkflowDialog({super.key, required this.flow});

  @override
  Widget build(BuildContext context) {
    final statusLabel =
        flow.statusDisplay.isNotEmpty ? flow.statusDisplay : flow.status;
    final actionLabel =
        flow.actionDisplay.isNotEmpty ? flow.actionDisplay : flow.action;

    String displayCreated = flow.createdAt;
    try {
      final parsed = DateTime.parse(flow.createdAt);
      displayCreated = DateFormat('MMMM d, yyyy').format(parsed);
    } catch (_) {}

    final approvers = flow.approverDisplays.isNotEmpty
        ? flow.approverDisplays
        : flow.approvers;

    return DialogScaffold(
      title: 'Workflow details',
      subtitle: flow.name,
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryBanner(flow, statusLabel, actionLabel),
          const SizedBox(height: 20),
          _buildDetailSection(
            title: 'Workflow information',
            children: [
              _detailRow('Name', flow.name),
              _detailRow('Action', actionLabel.isEmpty ? '—' : actionLabel),
              _detailRow(
                'Levels',
                '${flow.levels} level${flow.levels == 1 ? '' : 's'}',
              ),
              _detailRow('Created', displayCreated),
              if (flow.notes.isNotEmpty) _detailRow('Description', flow.notes),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailSection(
            title: 'Approver chain',
            children: [
              if (approvers.isEmpty)
                Text(
                  'No approvers configured for this workflow.',
                  style:
                      AppText.bodySm.copyWith(color: AppColors.textSecondary),
                )
              else
                Column(
                  children: approvers.asMap().entries.map((entry) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadii.brMd,
                        border:
                            Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.primarySubtle,
                              borderRadius: AppRadii.brSm,
                            ),
                            child: Text(
                              '${entry.key + 1}',
                              style: AppText.bodySm.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: AppText.bodyMd.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Close',
          height: 44,
          onTap: () => Navigator.pop(context),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        MyElevatedButton(
          width: 120,
          height: 44,
          child: 'Edit',
          icon: const Icon(Iconsax.edit,
              size: 18, color: AppColors.textOnPrimary),
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (_) => CreateEditWorkflowDialog(flow: flow),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryBanner(
      ApprovalFlow flow, String statusLabel, String actionLabel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: AppRadii.brLg,
            ),
            child: const Icon(Iconsax.tick_square,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(flow.name, style: AppText.h3),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusChip(
                      label: statusLabel.isEmpty ? 'Unknown' : statusLabel,
                      tone: _statusTone(statusLabel),
                    ),
                    if (actionLabel.isNotEmpty)
                      _buildMetaChip(
                          icon: Iconsax.flash_1, label: actionLabel),
                    _buildMetaChip(
                      icon: Iconsax.hierarchy,
                      label:
                          '${flow.levels} level${flow.levels == 1 ? '' : 's'}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brPill,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppText.bodySm.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.h4),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: AppText.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: AppText.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  StatusTone _statusTone(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return StatusTone.success;
      case 'inactive':
        return StatusTone.neutral;
      default:
        return StatusTone.neutral;
    }
  }
}
