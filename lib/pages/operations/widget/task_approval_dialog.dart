import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/pages/operations/models/task_approval_models.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Result class for task approval
class TaskApprovalResult {
  final TaskApprovalAction action;
  final String feedback;
  final String? reworkNotes;
  final DateTime approvedAt;

  TaskApprovalResult({
    required this.action,
    required this.feedback,
    this.reworkNotes,
    required this.approvedAt,
  });
}

/// Dialog for managers to approve, reject, or request rework on tasks
class TaskApprovalDialog extends StatefulWidget {
  final Task task;
  final String? reviewerName;
  final Function(Task)? onApprovalComplete;

  const TaskApprovalDialog({
    super.key,
    required this.task,
    this.reviewerName,
    this.onApprovalComplete,
  });

  @override
  State<TaskApprovalDialog> createState() => _TaskApprovalDialogState();
}

class _TaskApprovalDialogState extends State<TaskApprovalDialog> {
  late TextEditingController _feedbackController;
  late TextEditingController _reworkNotesController;

  TaskApprovalAction? _selectedAction;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _feedbackController = TextEditingController();
    _reworkNotesController = TextEditingController();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _reworkNotesController.dispose();
    super.dispose();
  }

  void _handleApproval(TaskApprovalAction action) {
    // Validate feedback
    if (_feedbackController.text.isEmpty) {
      _showErrorMessage('Please provide feedback');
      return;
    }

    // Validate rework notes if requesting rework
    if (action == TaskApprovalAction.requestRework &&
        _reworkNotesController.text.isEmpty) {
      _showErrorMessage('Please provide rework instructions');
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _isLoading = false);

        // Determine new status based on action
        final newStatus = action == TaskApprovalAction.approve
            ? TaskStatus.completed
            : action == TaskApprovalAction.reject
                ? TaskStatus.rejected
                : TaskStatus.onHold;

        // Create updated task
        final updatedTask = widget.task.copyWith(
          status: newStatus,
          approvedBy: action == TaskApprovalAction.approve
              ? widget.reviewerName ?? 'Manager'
              : null,
          approvedAt:
              action == TaskApprovalAction.approve ? DateTime.now() : null,
          rejectionReason: action == TaskApprovalAction.reject
              ? _feedbackController.text
              : null,
          reworkNotes: action == TaskApprovalAction.requestRework
              ? _reworkNotesController.text
              : null,
        );

        widget.onApprovalComplete?.call(updatedTask);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Task ${newStatus.displayName.toLowerCase()} successfully',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: action == TaskApprovalAction.approve
                ? AppColors.success
                : AppColors.warning,
          ),
        );

        Navigator.of(context).pop(TaskApprovalResult(
          action: action,
          feedback: _feedbackController.text,
          reworkNotes: action == TaskApprovalAction.requestRework
              ? _reworkNotesController.text
              : null,
          approvedAt: DateTime.now(),
        ));
      }
    });
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  StatusTone _statusTone(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return StatusTone.success;
      case TaskStatus.inProgress:
        return StatusTone.primary;
      case TaskStatus.pending:
        return StatusTone.warning;
      case TaskStatus.onHold:
        return StatusTone.warning;
      case TaskStatus.rejected:
        return StatusTone.danger;
    }
  }

  StatusTone _priorityTone(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return StatusTone.danger;
      case TaskPriority.medium:
        return StatusTone.warning;
      case TaskPriority.low:
        return StatusTone.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: 'Task review',
      subtitle: 'Review and approve task completion.',
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryBanner(),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Description',
            child: Text(
              widget.task.description.isEmpty
                  ? 'No description provided.'
                  : widget.task.description,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Your review',
            subtitle: 'Choose an action, then add feedback before submitting.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildApprovalButton(
                        'Approve',
                        TaskApprovalAction.approve,
                        AppColors.success,
                        Iconsax.tick_circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildApprovalButton(
                        'Rework',
                        TaskApprovalAction.requestRework,
                        AppColors.warning,
                        Iconsax.refresh,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildApprovalButton(
                        'Reject',
                        TaskApprovalAction.reject,
                        AppColors.danger,
                        Iconsax.close_circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                MyTextFormField(
                  title: 'Feedback *',
                  controller: _feedbackController,
                  hintText: 'Enter your feedback...',
                  maxLines: 4,
                  onChanged: (value) => setState(() {}),
                ),
                if (_selectedAction == TaskApprovalAction.requestRework) ...[
                  const SizedBox(height: 16),
                  MyTextFormField(
                    title: 'Rework Instructions *',
                    controller: _reworkNotesController,
                    hintText: 'Describe what needs to be reworked...',
                    maxLines: 4,
                    onChanged: (value) => setState(() {}),
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.infoSubtle,
                    borderRadius: AppRadii.brMd,
                    border: Border.all(color: AppColors.info),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Iconsax.info_circle,
                          size: 16, color: AppColors.info),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getInfoMessage(),
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          onTap: () => Navigator.of(context).pop(),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        MyElevatedButton(
          width: 170,
          height: 44,
          isLoading: _isLoading,
          icon: _isLoading
              ? null
              : const Icon(Iconsax.tick_circle,
                  size: 18, color: AppColors.textOnPrimary),
          onTap: _isLoading || _selectedAction == null
              ? null
              : () => _handleApproval(_selectedAction!),
          child: 'Submit Approval',
        ),
      ],
    );
  }

  Widget _buildSummaryBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: AppRadii.brLg,
            ),
            child: const Icon(Iconsax.task_square,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.task.code, style: AppTextStyles.h4),
                const SizedBox(height: 2),
                Text(
                  widget.task.title,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusChip(
                      label: widget.task.status.displayName,
                      tone: _statusTone(widget.task.status),
                    ),
                    StatusChip(
                      label: widget.task.priority.displayName,
                      tone: _priorityTone(widget.task.priority),
                    ),
                    _buildMetaChip(
                      icon: Iconsax.profile_2user,
                      label: widget.task.assignedTo,
                    ),
                    _buildMetaChip(
                      icon: Iconsax.calendar,
                      label:
                          '${widget.task.dueDate.day.toString().padLeft(2, '0')}-${widget.task.dueDate.month.toString().padLeft(2, '0')}-${widget.task.dueDate.year}',
                    ),
                    _buildMetaChip(
                      icon: Iconsax.clock,
                      label:
                          '${widget.task.estimatedHours.toStringAsFixed(0)} hrs',
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

  Widget _buildMetaChip({
    required IconData icon,
    required String label,
  }) {
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
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required Widget child,
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
          Text(title, style: AppTextStyles.h4),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildApprovalButton(
    String label,
    TaskApprovalAction action,
    Color color,
    IconData icon,
  ) {
    final isSelected = _selectedAction == action;
    return Material(
      color: isSelected ? color.withValues(alpha: 0.08) : AppColors.surface,
      borderRadius: AppRadii.brMd,
      child: InkWell(
        borderRadius: AppRadii.brMd,
        onTap: () => setState(() {
          _selectedAction = _selectedAction == action ? null : action;
          if (_selectedAction != TaskApprovalAction.requestRework) {
            _reworkNotesController.clear();
          }
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? color : AppColors.borderSubtle,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: AppRadii.brMd,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInfoMessage() {
    switch (_selectedAction) {
      case TaskApprovalAction.approve:
        return 'This task will be marked as Completed. The employee will be notified of the approval.';
      case TaskApprovalAction.reject:
        return 'This task will be marked as Rejected. The employee will be asked to address the issues mentioned in your feedback.';
      case TaskApprovalAction.requestRework:
        return 'This task will be marked as On Hold. The employee will need to revise the task based on your instructions.';
      case null:
        return 'Select an action above (Approve, Reject, or Request Rework) to proceed.';
    }
  }
}
