import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/operations/models/task_approval_models.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

/// Dialog for supervisors/managers to approve, reject, or request rework on tasks
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
  int _rating = 0; // 1-5 star rating

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
    // Validate rating
    if (_rating == 0) {
      _showErrorMessage('Please provide a rating (1-5 stars)');
      return;
    }

    // Validate feedback
    if (_feedbackController.text.isEmpty) {
      _showErrorMessage('Please provide feedback for this task');
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
          approvedBy:
              action == TaskApprovalAction.approve ? widget.reviewerName : null,
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
                ? AppColors.green
                : action == TaskApprovalAction.reject
                    ? AppColors.red
                    : AppColors.orange,
          ),
        );

        Navigator.of(context).pop(TaskApprovalResult(
          action: action,
          feedback: _feedbackController.text,
          reworkInstructions: action == TaskApprovalAction.requestRework
              ? _reworkNotesController.text
              : null,
          rating: _rating,
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
        backgroundColor: AppColors.red,
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return const Color(0xFF94A3B8);
      case TaskStatus.inProgress:
        return AppColors.blue;
      case TaskStatus.completed:
        return AppColors.green;
      case TaskStatus.onHold:
        return AppColors.orange;
      case TaskStatus.rejected:
        return AppColors.red;
    }
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.task_alt_outlined,
                          color: AppColors.green,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            'Task Approval',
                            style: AppText.black_500_20,
                          ),
                          SizedBox(height: 4),
                          MyText(
                            'Review and approve task completion',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
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
                          border: Border.all(color: const Color(0xFFD5D5D5)),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade50,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      MyText(
                                        widget.task.code,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      MyText(
                                        widget.task.title,
                                        style: AppText.black_600_16,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(widget.task.status)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: MyText(
                                    widget.task.status.displayName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _getStatusColor(widget.task.status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildTaskInfoItem(
                                  'Assigned To',
                                  widget.task.assignedTo,
                                ),
                                _buildTaskInfoItem(
                                  'Priority',
                                  widget.task.priority.displayName,
                                ),
                                _buildTaskInfoItem(
                                  'Due Date',
                                  DateFormat('dd MMM yyyy')
                                      .format(widget.task.dueDate),
                                ),
                                _buildTaskInfoItem(
                                  'Est. Hours',
                                  '${widget.task.estimatedHours.toStringAsFixed(1)} hrs',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Task Description
                      const MyText(
                        'Task Description',
                        style: AppText.black_600_14,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD5D5D5)),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade50,
                        ),
                        child: MyText(
                          widget.task.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Divider
                      const Divider(height: 32),

                      // Approval Section
                      const MyText(
                        'Task Approval',
                        style: AppText.black_600_16,
                      ),
                      const SizedBox(height: 16),

                      // Action Selection
                      _buildApprovalButton(
                        label: 'Approve Task',
                        icon: Icons.check_circle_outline,
                        color: AppColors.green,
                        action: TaskApprovalAction.approve,
                        isSelected: _selectedAction == TaskApprovalAction.approve,
                        onTap: () {
                          setState(() {
                            _selectedAction = TaskApprovalAction.approve;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildApprovalButton(
                        label: 'Request Rework',
                        icon: Icons.edit_outlined,
                        color: AppColors.orange,
                        action: TaskApprovalAction.requestRework,
                        isSelected:
                            _selectedAction == TaskApprovalAction.requestRework,
                        onTap: () {
                          setState(() {
                            _selectedAction = TaskApprovalAction.requestRework;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildApprovalButton(
                        label: 'Reject Task',
                        icon: Icons.cancel_outlined,
                        color: AppColors.red,
                        action: TaskApprovalAction.reject,
                        isSelected: _selectedAction == TaskApprovalAction.reject,
                        onTap: () {
                          setState(() {
                            _selectedAction = TaskApprovalAction.reject;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Rating Section
                      const MyText(
                        'Rate This Task *',
                        style: AppText.black_600_16,
                      ),
                      const SizedBox(height: 12),
                      _buildRatingWidget(),
                      const SizedBox(height: 24),

                      // Feedback Section
                      MyTextFormField(
                        title: 'Feedback *',
                        hintText:
                            'Provide your feedback or comments on this task...',
                        controller: _feedbackController,
                        spaceBetweenText: 8,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Rework Notes (shown only when Rework is selected)
                      if (_selectedAction == TaskApprovalAction.requestRework)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyTextFormField(
                              title: 'Rework Instructions *',
                              hintText:
                                  'Specify what needs to be reworked and any additional details...',
                              controller: _reworkNotesController,
                              spaceBetweenText: 8,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),

                      // Info Message
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border.all(color: Colors.blue.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: MyText(
                                _selectedAction == null
                                    ? 'Select an approval action above'
                                    : _selectedAction ==
                                            TaskApprovalAction.approve
                                        ? 'This task will be marked as completed'
                                        : _selectedAction ==
                                                TaskApprovalAction.requestRework
                                            ? 'Task will be put on hold for rework'
                                            : 'This task will be rejected',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1E40AF),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                    textColor: AppColors.darkGrey1,
                    borderColor: null,
                    child: 'Cancel',
                    onTap: _isLoading
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                  ),
                  const SizedBox(width: 16),
                  MyElevatedButton(
                    icon: _isLoading
                        ? null
                        : SvgPicture.asset(
                            "assets/svg/check.svg",
                            colorFilter: const ColorFilter.mode(
                                AppColors.white, BlendMode.srcIn),
                          ),
                    child: _isLoading ? 'Submitting...' : 'Submit Approval',
                    onTap: _selectedAction == null || _isLoading
                        ? null
                        : () => _handleApproval(_selectedAction!),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalButton({
    required String label,
    required IconData icon,
    required Color color,
    required TaskApprovalAction action,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : const Color(0xFFD5D5D5),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? color.withValues(alpha: 0.05) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MyText(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? color : const Color(0xFF64748B),
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : const Color(0xFFD5D5D5),
                  width: isSelected ? 2 : 1,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        MyText(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: _rating == 0 ? const Color(0xFFD5D5D5) : AppColors.blue,
          width: _rating == 0 ? 1 : 2,
        ),
        borderRadius: BorderRadius.circular(10),
        color: _rating == 0 ? Colors.transparent : AppColors.blue.withValues(alpha: 0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ...List.generate(
            5,
            (index) {
              final starNumber = index + 1;
              final isFilled = starNumber <= _rating;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = starNumber;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    isFilled ? Icons.star : Icons.star_outline,
                    color: AppColors.orange,
                    size: 32,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: MyText(
              _rating == 0
                  ? 'Select a rating'
                  : _rating == 1
                      ? '⭐ Poor'
                      : _rating == 2
                          ? '⭐⭐ Fair'
                          : _rating == 3
                              ? '⭐⭐⭐ Good'
                              : _rating == 4
                                  ? '⭐⭐⭐⭐ Very Good'
                                  : '⭐⭐⭐⭐⭐ Excellent',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _rating == 0 ? const Color(0xFF64748B) : AppColors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
