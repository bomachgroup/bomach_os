import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/chart/star_5.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/performance_review_controller.dart';
import '../models/performance_review.dart';
import 'add_performance_review_dialog.dart';

class ViewPerformanceReviewDialog extends StatefulWidget {
  final PerformanceReview review;

  const ViewPerformanceReviewDialog({super.key, required this.review});

  @override
  State<ViewPerformanceReviewDialog> createState() =>
      _ViewPerformanceReviewDialogState();
}

class _ViewPerformanceReviewDialogState
    extends State<ViewPerformanceReviewDialog> {
  final PerformanceReviewController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: 'Performance Review',
      subtitle: 'Review the captured ratings, strengths, and feedback.',
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSection(
            title: 'Review Details',
            child: Column(
              children: [
                _buildDetailRow('Employee ID', widget.review.employeeId),
                _buildDetailRow('Reviewer ID', widget.review.reviewerId),
                _buildDetailRow(
                  'Review Date',
                  widget.review.reviewDate
                          ?.toIso8601String()
                          .split('T')
                          .first ??
                      '—',
                ),
                _buildDetailRow(
                    'Review Period', widget.review.reviewPeriod),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        child: Text(
                          'Overall Rating',
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      const Expanded(child: Star5()),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Feedback',
            child: Column(
              children: [
                _buildDetailRow('Strengths', widget.review.strengths ?? '—'),
                _buildDetailRow('Areas For Improvement',
                    widget.review.areasForImprovement ?? '—'),
                _buildDetailRow('Feedback', widget.review.feedback ?? '—'),
                _buildDetailRow('Employee Comment',
                    widget.review.employeeComments ?? '—'),
              ],
            ),
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textColor: AppColors.danger,
          borderColor: AppColors.danger,
          child: 'Delete',
          onTap: () {
            DialogScaffold.show(
              context,
              title: 'Delete Review',
              size: DialogSize.sm,
              body: Text(
                'Are you sure you want to delete this review? This action cannot be undone.',
                style: AppTextStyles.bodyMd
                    .copyWith(color: AppColors.textSecondary),
              ),
              actions: [
                MyOutlinedButton(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                  textColor: AppColors.textSecondary,
                  borderColor: AppColors.borderStrong,
                  child: 'Cancel',
                  onTap: () => Navigator.of(context).pop(),
                ),
                MyElevatedButton(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                  bgColor: AppColors.danger,
                  child: 'Delete',
                  onTap: () async {
                    await controller.deleteReview(widget.review.id!);
                    if (!mounted) return;
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    AppToast.success(context, 'Review deleted');
                  },
                ),
              ],
            );
          },
        ),
        MyElevatedButton(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: 'Edit',
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (c) => AddPerformanceReviewDialog(
                  reviewToEdit: widget.review),
            );
          },
        ),
      ],
    );
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
          Text(title, style: AppTextStyles.h4),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
