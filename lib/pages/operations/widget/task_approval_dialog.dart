import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/operations/models/task_approval_models.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

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
            content: MyText(
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
        content: MyText(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
                color: Colors.green.shade50,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        'Task Review',
                        style: AppText.h2,
                      ),
                      SizedBox(height: 4),
                      MyText(
                        'Review and approve task completion',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0XFFD5D5D5)),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade50,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText(
                                      widget.task.code,
                                      style: AppText.h4,
                                    ),
                                    const SizedBox(height: 4),
                                    MyText(
                                      widget.task.title,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.neutral500,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: MyText(
                                    widget.task.status.displayName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfoItem(
                                  'Assigned To',
                                  widget.task.assignedTo,
                                ),
                                _buildInfoItem(
                                  'Priority',
                                  widget.task.priority.displayName,
                                ),
                                _buildInfoItem(
                                  'Due Date',
                                  '${widget.task.dueDate.day}/${widget.task.dueDate.month}/${widget.task.dueDate.year}',
                                ),
                                _buildInfoItem(
                                  'Est. Hours',
                                  '${widget.task.estimatedHours.toStringAsFixed(0)} hrs',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Task Description
                      const MyText(
                        'Description',
                        style: AppText.h4,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0XFFD5D5D5)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: MyText(
                          widget.task.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.neutral600,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Divider
                      const Divider(height: 32),

                      // Review Actions Section
                      const MyText(
                        'Your Review',
                        style: AppText.h4,
                      ),
                      const SizedBox(height: 16),

                      // Action Buttons
                      Row(
                        spacing: 12,
                        children: [
                          Expanded(
                            child: _buildApprovalButton(
                              'Approve',
                              TaskApprovalAction.approve,
                              AppColors.success,
                              Iconsax.tick_circle,
                            ),
                          ),
                          Expanded(
                            child: _buildApprovalButton(
                              'Rework',
                              TaskApprovalAction.requestRework,
                              AppColors.warning,
                              Iconsax.refresh,
                            ),
                          ),
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
                      const SizedBox(height: 24),

                      // Feedback Field
                      const MyText(
                        'Feedback *',
                        style: AppText.h4,
                      ),
                      const SizedBox(height: 8),
                      MyTextFormField(
                        controller: _feedbackController,
                        hintText: 'Enter your feedback...',
                        maxLines: 4,
                        onChanged: (value) => setState(() {}),
                      ),
                      const SizedBox(height: 24),

                      // Rework Instructions (conditional)
                      if (_selectedAction == TaskApprovalAction.requestRework)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const MyText(
                              'Rework Instructions *',
                              style: AppText.h4,
                            ),
                            const SizedBox(height: 8),
                            MyTextFormField(
                              controller: _reworkNotesController,
                              hintText: 'Describe what needs to be reworked...',
                              maxLines: 4,
                              onChanged: (value) => setState(() {}),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),

                      // Info Message
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          border: Border.all(
                            color: AppColors.info,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: MyText(
                          _getInfoMessage(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF0369A1),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 12,
                children: [
                  MyOutlinedButton(
                    onTap: () => Navigator.of(context).pop(),
                    child: 'Cancel',
                  ),
                  MyElevatedButton(
                    onTap: _isLoading || _selectedAction == null
                        ? null
                        : () => _handleApproval(_selectedAction!),
                    isLoading: _isLoading,
                    child: 'Submit Approval',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral500,
          ),
        ),
        const SizedBox(height: 4),
        MyText(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral800,
          ),
        ),
      ],
    );
  }

  Widget _buildApprovalButton(
    String label,
    TaskApprovalAction action,
    Color color,
    IconData icon,
  ) {
    final isSelected = _selectedAction == action;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedAction = _selectedAction == action ? null : action;
        if (_selectedAction != TaskApprovalAction.requestRework) {
          _reworkNotesController.clear();
        }
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : AppColors.neutral200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color:
              isSelected ? color.withValues(alpha: 0.08) : Colors.transparent,
        ),
        child: Column(
          spacing: 6,
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.neutral500,
              size: 20,
            ),
            MyText(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : AppColors.neutral500,
              ),
            ),
          ],
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
