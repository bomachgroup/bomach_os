import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/model/approval_model.dart';
import 'package:bms_front_end/src/model/board_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  final ApprovalController controller = Get.find<ApprovalController>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _notesCtrl;
  String? _selectedAction;
  String? _selectedLevels;
  String? _selectedStatus;
  final Set<String> _selectedApprovers = {};

  bool get isEdit => widget.flow != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.flow?.name ?? '');
    _notesCtrl = TextEditingController(text: widget.flow?.notes ?? '');
    _selectedAction = widget.flow?.action.isNotEmpty == true
        ? widget.flow!.action
        : null;
    _selectedLevels = widget.flow != null && widget.flow!.levels > 0
        ? widget.flow!.levels.toString()
        : null;
    _selectedStatus = widget.flow?.status.isNotEmpty == true
        ? widget.flow!.status
        : 'active';
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
    if (_nameCtrl.text.trim().isEmpty) return;

    final steps = _selectedApprovers.isEmpty
        ? [
            {
              'step_order': 1,
              'step_name': 'Approval Step',
              'required_level': _selectedLevels ?? '',
            }
          ]
        : _selectedApprovers.toList().asMap().entries.map((entry) {
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title bar
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isEdit
                          ? 'Edit Approval Workflow'
                          : 'New Approval Workflow',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Obx(() {
                  final choices = controller.flowChoices.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Workflow Name
                      const Text('Workflow Name',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13)),
                      const SizedBox(height: 6),
                      MyTextFormField(
                        controller: _nameCtrl,
                        hintText: 'Type here',
                      ),
                      const SizedBox(height: 16),

                      // Action dropdown
                      const Text('Action',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13)),
                      const SizedBox(height: 6),
                      _buildDropdown(
                        value: _selectedAction,
                        hint: 'Select',
                        items: choices?.actions ?? [],
                        onChanged: (val) =>
                            setState(() => _selectedAction = val),
                      ),
                      const SizedBox(height: 16),

                      // Levels dropdown
                      const Text('Levels',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13)),
                      const SizedBox(height: 6),
                      _buildDropdown(
                        value: _selectedLevels,
                        hint: 'Select',
                        items: choices?.levels ?? [],
                        onChanged: (val) =>
                            setState(() => _selectedLevels = val),
                      ),
                      const SizedBox(height: 16),

                      // Approvers checkboxes
                      const Text('Approvers',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13)),
                      const SizedBox(height: 8),
                      ...(choices?.approverTypes ?? []).map((approver) {
                        final isChecked =
                            _selectedApprovers.contains(approver.value);
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isChecked) {
                                _selectedApprovers.remove(approver.value);
                              } else {
                                _selectedApprovers.add(approver.value);
                              }
                            });
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: isChecked
                                        ? AppColors.blue
                                        : Colors.transparent,
                                    borderRadius:
                                        BorderRadius.circular(4),
                                    border: Border.all(
                                      color: isChecked
                                          ? AppColors.blue
                                          : const Color(0xFFE2E8F0),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: isChecked
                                      ? const Icon(Icons.check,
                                          size: 14,
                                          color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Text(approver.label,
                                    style:
                                        const TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),

                      // Status dropdown
                      const Text('Status',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13)),
                      const SizedBox(height: 6),
                      _buildDropdown(
                        value: _selectedStatus,
                        hint: 'Select',
                        items: choices?.statuses ??
                            [
                              BoardFieldOption(
                                  value: 'active', label: 'Active'),
                              BoardFieldOption(
                                  value: 'inactive', label: 'Inactive'),
                            ],
                        onChanged: (val) =>
                            setState(() => _selectedStatus = val),
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      const Text('Notes',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13)),
                      const SizedBox(height: 6),
                      MyTextFormField(
                        controller: _notesCtrl,
                        hintText: 'Type here',
                        maxLines: 3,
                      ),
                    ],
                  );
                }),
              ),
            ),

            const Divider(height: 1),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  Obx(() => MyElevatedButton(
                        height: 40,
                        icon: controller.isSavingFlow.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.check,
                                size: 16, color: Colors.white),
                        child: isEdit ? 'Save' : 'Create',
                        onTap: controller.isSavingFlow.value
                            ? null
                            : _onSave,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<BoardFieldOption> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: items.any((i) => i.value == value) ? value : null,
          hint: Text(hint,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
          items: items
              .map((opt) => DropdownMenuItem(
                  value: opt.value, child: Text(opt.label)))
              .toList(),
          onChanged: onChanged,
        ),
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title bar
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      flow.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  _buildStatusBadge(flow.statusDisplay.isNotEmpty
                      ? flow.statusDisplay
                      : flow.status),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Body
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Action', flow.actionDisplay.isNotEmpty
                      ? flow.actionDisplay
                      : flow.action),
                  _buildDetailRow('Levels', '${flow.levels}'),
                  if (flow.notes.isNotEmpty)
                    _buildDetailRow('Notes', flow.notes),
                  _buildDetailRow('Created', flow.createdAt),
                  const SizedBox(height: 12),
                  const Text('Approvers',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: flow.approverDisplays.isNotEmpty
                        ? flow.approverDisplays
                            .map((a) => _buildApproverChip(a))
                            .toList()
                        : flow.approvers
                            .map((a) => _buildApproverChip(a))
                            .toList(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildApproverChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: const TextStyle(
            color: AppColors.blue,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          )),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isActive = status.toLowerCase() == 'active';
    final Color color = isActive ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: color),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
