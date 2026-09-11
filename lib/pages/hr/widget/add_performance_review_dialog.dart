import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../controller/performance_review_controller.dart';
import '../models/performance_review.dart';

class AddPerformanceReviewDialog extends StatefulWidget {
  final PerformanceReview? reviewToEdit;

  const AddPerformanceReviewDialog({super.key, this.reviewToEdit});

  @override
  State<AddPerformanceReviewDialog> createState() =>
      _AddPerformanceReviewDialogState();
}

class _AddPerformanceReviewDialogState
    extends State<AddPerformanceReviewDialog> {
  final PerformanceReviewController controller = Get.find();

  late TextEditingController employeeIdCtrl;
  late TextEditingController reviewerIdCtrl;
  late TextEditingController reviewDateCtrl;
  late TextEditingController reviewPeriodCtrl;
  late TextEditingController ratingCtrl;
  late TextEditingController strengthsCtrl;
  late TextEditingController areasCtrl;
  late TextEditingController feedbackCtrl;
  late TextEditingController commentCtrl;

  @override
  void initState() {
    super.initState();
    final r = widget.reviewToEdit;
    final now = DateTime.now();
    final currentQuarter = ((now.month - 1) ~/ 3) + 1;
    employeeIdCtrl = TextEditingController(text: r?.employeeId ?? '');
    reviewerIdCtrl = TextEditingController(text: r?.reviewerId ?? '');
    reviewDateCtrl = TextEditingController(
        text: r?.reviewDate?.toIso8601String().split('T').first ??
            now.toIso8601String().split('T').first);
    reviewPeriodCtrl = TextEditingController(
        text: r?.reviewPeriod ?? 'Q$currentQuarter ${now.year}');
    ratingCtrl = TextEditingController(text: r?.overallRating.toString() ?? '');
    strengthsCtrl = TextEditingController(text: r?.strengths ?? '');
    areasCtrl = TextEditingController(text: r?.areasForImprovement ?? '');
    feedbackCtrl = TextEditingController(text: r?.feedback ?? '');
    commentCtrl = TextEditingController(text: r?.employeeComments ?? '');
  }

  @override
  void dispose() {
    employeeIdCtrl.dispose();
    reviewerIdCtrl.dispose();
    reviewDateCtrl.dispose();
    reviewPeriodCtrl.dispose();
    ratingCtrl.dispose();
    strengthsCtrl.dispose();
    areasCtrl.dispose();
    feedbackCtrl.dispose();
    commentCtrl.dispose();
    super.dispose();
  }

  void _showError(String message) {
    AppToast.error(context, message);
  }

  void _save() async {
    // Validation
    if (employeeIdCtrl.text.isEmpty || reviewerIdCtrl.text.isEmpty) {
      _showError('Employee ID and Reviewer ID are required');
      return;
    }

    final reviewDate = DateTime.tryParse(reviewDateCtrl.text);
    if (reviewDateCtrl.text.isEmpty || reviewDate == null) {
      _showError('Review date is required');
      return;
    }
    if (reviewPeriodCtrl.text.trim().isEmpty) {
      _showError('Review period is required');
      return;
    }
    final rating = int.tryParse(ratingCtrl.text);
    if (rating == null) {
      _showError('Overall rating is required');
      return;
    }
    if (rating < 1 || rating > 5) {
      _showError('Rating must be between 1 and 5');
      return;
    }

    final newReview = PerformanceReview(
      id: widget.reviewToEdit?.id,
      employeeId: employeeIdCtrl.text,
      reviewerId: reviewerIdCtrl.text,
      reviewDate: reviewDate,
      reviewPeriod: reviewPeriodCtrl.text.isEmpty ? '' : reviewPeriodCtrl.text,
      overallRating: rating ?? 0,
      strengths: strengthsCtrl.text.isEmpty ? null : strengthsCtrl.text,
      areasForImprovement: areasCtrl.text.isEmpty ? null : areasCtrl.text,
      feedback: feedbackCtrl.text.isEmpty ? null : feedbackCtrl.text,
      employeeComments: commentCtrl.text.isEmpty ? null : commentCtrl.text,
    );

    bool success;
    if (widget.reviewToEdit != null) {
      success =
          await controller.updateReview(widget.reviewToEdit!.id!, newReview);
    } else {
      success = await controller.createReview(newReview);
    }

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _pickReviewDate() async {
    final current = DateTime.tryParse(reviewDateCtrl.text) ?? DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected != null) {
      reviewDateCtrl.text = selected.toIso8601String().split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.reviewToEdit != null;
    return DialogScaffold(
      title: isEdit ? 'Edit Performance Review' : 'New Performance Review',
      subtitle: isEdit
          ? 'Update the review details, ratings, and feedback.'
          : 'Capture an employee performance review with strengths and feedback.',
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSection(
            title: 'Review Details',
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: MyTextFormField(
                        title: 'Employee ID',
                        controller: employeeIdCtrl,
                        hintText: 'Enter employee ID',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MyTextFormField(
                        title: 'Reviewer ID',
                        controller: reviewerIdCtrl,
                        hintText: 'Enter reviewer ID',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: MyTextFormField(
                        title: 'Review Date',
                        controller: reviewDateCtrl,
                        hintText: 'YYYY-MM-DD',
                        onTap: _pickReviewDate,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MyTextFormField(
                        title: 'Review Period',
                        controller: reviewPeriodCtrl,
                        hintText: 'e.g. Q4 2025',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                MyTextFormField(
                  title: 'Overall Rating (1-5)',
                  controller: ratingCtrl,
                  hintText: 'Enter a rating from 1 to 5',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Feedback',
            child: Column(
              children: [
                MyTextFormField(
                  title: 'Strengths',
                  controller: strengthsCtrl,
                  hintText: 'List the employee\'s key strengths',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                MyTextFormField(
                  title: 'Areas For Improvement',
                  controller: areasCtrl,
                  hintText: 'Note focus areas for improvement',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                MyTextFormField(
                  title: 'Feedback',
                  controller: feedbackCtrl,
                  hintText: 'Share overall feedback',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                MyTextFormField(
                  title: 'Employee Comment',
                  controller: commentCtrl,
                  hintText: 'Optional employee response',
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
          child: 'Cancel',
          onTap: () => Navigator.pop(context),
        ),
        Obx(() => MyElevatedButton(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              isLoading: controller.isSaving.value,
              icon: SvgPicture.asset(
                "assets/svg/check.svg",
                colorFilter: const ColorFilter.mode(
                    AppColors.white, BlendMode.srcIn),
              ),
              child: 'Save',
              onTap: _save,
            )),
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
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
