import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/models/work_report_models.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

/// Review result enum for the outcome of review
enum ReviewAction { approve, reject, requestRework }

/// Result class for the review dialog
class WorkReportReviewResult {
  final ReviewAction action;
  final String feedback;
  final String? reworkNotes;
  final int rating; // 1-5 star rating
  final DateTime reviewedAt;

  WorkReportReviewResult({
    required this.action,
    required this.feedback,
    this.reworkNotes,
    required this.rating,
    required this.reviewedAt,
  });
}

/// Dialog for managers/supervisors to review and approve/reject daily work reports
class WorkReportReviewDialog extends StatefulWidget {
  final DailyWorkReport report;
  final String? reviewerName;
  final Function(DailyWorkReport)? onReviewComplete;

  const WorkReportReviewDialog({
    super.key,
    required this.report,
    this.reviewerName,
    this.onReviewComplete,
  });

  @override
  State<WorkReportReviewDialog> createState() => _WorkReportReviewDialogState();
}

class _WorkReportReviewDialogState extends State<WorkReportReviewDialog> {
  late TextEditingController _feedbackController;
  late TextEditingController _reworkNotesController;

  ReviewAction? _selectedAction;
  bool _isLoading = false;
  int _rating = 0; // 0 = not rated, 1-5 = star rating

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

  void _handleReview(ReviewAction action) {
    // Validate rating
    if (_rating == 0) {
      _showErrorMessage('Please provide a rating (1-5 stars)');
      return;
    }

    // Validate feedback
    if (_feedbackController.text.isEmpty) {
      _showErrorMessage('Please provide feedback for this review');
      return;
    }

    // Validate rework notes if requesting rework
    if (action == ReviewAction.requestRework && _reworkNotesController.text.isEmpty) {
      _showErrorMessage('Please provide rework instructions');
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _isLoading = false);

        // Determine new status based on action
        final newStatus = action == ReviewAction.approve
            ? 'Approved'
            : action == ReviewAction.reject
                ? 'Rejected'
                : 'Rework Required';

        // Create updated report
        final updatedReport = widget.report.copyWith(
          status: newStatus,
          approvedBy: action == ReviewAction.approve ? widget.reviewerName : null,
          approvedAt: action == ReviewAction.approve ? DateTime.now() : null,
        );

        widget.onReviewComplete?.call(updatedReport);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: MyText(
              'Work report ${newStatus.toLowerCase()} successfully',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor:
                action == ReviewAction.approve ? AppColors.green : AppColors.orange,
          ),
        );

        Navigator.of(context).pop(WorkReportReviewResult(
          action: action,
          feedback: _feedbackController.text,
          reworkNotes:
              action == ReviewAction.requestRework ? _reworkNotesController.text : null,
          rating: _rating,
          reviewedAt: DateTime.now(),
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Development':
        return AppColors.blue;
      case 'Testing':
        return const Color(0xFF9B59B6);
      case 'Bug Fix':
        return AppColors.red;
      case 'Documentation':
        return const Color(0xFFF39C12);
      case 'Meeting':
        return AppColors.green;
      case 'Research':
        return const Color(0xFF3B82F6);
      case 'Code Review':
        return const Color(0xFF8B5CF6);
      case 'Deployment':
        return const Color(0xFFD97706);
      default:
        return AppColors.grey1;
    }
  }

  String _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'neutral':
        return '😐';
      case 'tired':
        return '😴';
      case 'frustrated':
        return '😞';
      default:
        return '😐';
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
                color: Colors.blue.shade50,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.fact_check_outlined,
                          color: AppColors.blue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const MyText(
                            'Review Work Report',
                            style: AppText.black_500_20,
                          ),
                          const SizedBox(height: 4),
                          MyText(
                            'Review and approve ${widget.report.employeeName}\'s daily report',
                            style: const TextStyle(
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
                      // Employee Info Card
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
                                      widget.report.employeeName,
                                      style: AppText.black_600_16,
                                    ),
                                    const SizedBox(height: 4),
                                    MyText(
                                      widget.report.employeeEmail,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
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
                                    color: AppColors.blue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: MyText(
                                    widget.report.status,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.blue,
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
                                  'Report Date',
                                  DateFormat('dd MMM yyyy')
                                      .format(widget.report.reportDate),
                                ),
                                _buildInfoItem(
                                  'Hours Worked',
                                  '${widget.report.hoursWorked.toStringAsFixed(1)} hrs',
                                ),
                                _buildInfoItem(
                                  'Mood',
                                  _getMoodEmoji(widget.report.mood),
                                ),
                                _buildInfoItem(
                                  'Activities',
                                  '${widget.report.activities.length} items',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Activities Section
                      const MyText(
                        'Activities Summary',
                        style: AppText.black_600_14,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0XFFD5D5D5)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: widget.report.activities.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: MyText(
                                  'No activities recorded',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              )
                            : Column(
                                spacing: 12,
                                children: widget.report.activities
                                    .map((activity) =>
                                        _buildActivityCard(activity))
                                    .toList(),
                              ),
                      ),
                      const SizedBox(height: 24),

                      // Report Details Section
                      const MyText(
                        'Report Details',
                        style: AppText.black_600_14,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailSection('Achievements', widget.report.achievements),
                      kSizedBox,
                      _buildDetailSection('Challenges', widget.report.challenges),
                      kSizedBox,
                      _buildDetailSection(
                          'Plan for Next Day', widget.report.nextDayPlan),
                      const SizedBox(height: 24),

                      // Divider
                      const Divider(height: 32),

                      // Review Actions Section
                      const MyText(
                        'Your Review',
                        style: AppText.black_600_16,
                      ),
                      const SizedBox(height: 16),

                      // Action Selection
                      _buildActionButton(
                        label: 'Approve Report',
                        icon: Icons.check_circle_outline,
                        color: AppColors.green,
                        action: ReviewAction.approve,
                        isSelected: _selectedAction == ReviewAction.approve,
                        onTap: () {
                          setState(() {
                            _selectedAction = ReviewAction.approve;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        label: 'Request Rework',
                        icon: Icons.edit_outlined,
                        color: const Color(0xFFF39C12),
                        action: ReviewAction.requestRework,
                        isSelected: _selectedAction == ReviewAction.requestRework,
                        onTap: () {
                          setState(() {
                            _selectedAction = ReviewAction.requestRework;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        label: 'Reject Report',
                        icon: Icons.cancel_outlined,
                        color: AppColors.red,
                        action: ReviewAction.reject,
                        isSelected: _selectedAction == ReviewAction.reject,
                        onTap: () {
                          setState(() {
                            _selectedAction = ReviewAction.reject;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Rating Section
                      const MyText(
                        'Rate This Report *',
                        style: AppText.black_600_16,
                      ),
                      const SizedBox(height: 12),
                      _buildRatingWidget(),
                      const SizedBox(height: 24),

                      // Feedback Section
                      MyTextFormField(
                        title: 'Feedback *',
                        hintText: 'Provide your feedback or comments on this report...',
                        controller: _feedbackController,
                        spaceBetweenText: 8,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Rework Notes (shown only when Rework is selected)
                      if (_selectedAction == ReviewAction.requestRework)
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
                                    ? 'Select a review action above'
                                    : _selectedAction == ReviewAction.approve
                                        ? 'This report will be marked as approved'
                                        : _selectedAction == ReviewAction.requestRework
                                            ? 'Employee will be notified to rework the report'
                                            : 'This report will be rejected',
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
                    child: _isLoading ? 'Submitting...' : 'Submit Review',
                    onTap: _selectedAction == null || _isLoading
                        ? null
                        : () => _handleReview(_selectedAction!),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required ReviewAction action,
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

  Widget _buildActivityCard(WorkActivity activity) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: MyText(
                  activity.taskTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryColor(activity.taskCategory)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: MyText(
                  activity.taskCategory,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getCategoryColor(activity.taskCategory),
                  ),
                ),
              ),
            ],
          ),
          if (activity.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            MyText(
              activity.description,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText(
                '${activity.hoursSpent.toStringAsFixed(1)} hours',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blue,
                ),
              ),
              if (activity.completed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const MyText(
                    '✓ Completed',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.green,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          title,
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
            content.isEmpty ? 'Not provided' : content,
            style: TextStyle(
              fontSize: 13,
              color: content.isEmpty ? const Color(0xFF64748B) : Colors.black,
            ),
          ),
        ),
      ],
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
