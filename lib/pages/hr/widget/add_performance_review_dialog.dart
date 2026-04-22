import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
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
    employeeIdCtrl = TextEditingController(text: r?.employeeId ?? '');
    reviewerIdCtrl = TextEditingController(text: r?.reviewerId ?? '');
    reviewDateCtrl = TextEditingController(
        text: r?.reviewDate?.toIso8601String().split('T').first ?? '');
    reviewPeriodCtrl = TextEditingController(text: r?.reviewPeriod ?? '');
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

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _save() async {
    // Validation
    if (employeeIdCtrl.text.isEmpty || reviewerIdCtrl.text.isEmpty) {
      _showErrorDialog(
          'Validation Error', 'Employee ID and Reviewer ID are required');
      return;
    }

    final reviewDate = DateTime.tryParse(reviewDateCtrl.text);
    if (reviewDateCtrl.text.isNotEmpty && reviewDate == null) {
      _showErrorDialog('Validation Error', 'Invalid review date format');
      return;
    }

    final rating = int.tryParse(ratingCtrl.text);
    if (ratingCtrl.text.isNotEmpty &&
        (rating == null || rating < 1 || rating > 5)) {
      _showErrorDialog('Validation Error', 'Rating must be between 1 and 5');
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText(
                    widget.reviewToEdit != null
                        ? 'Edit Review'
                        : 'New Performance Review',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    Row(children: [
                      Expanded(
                          child: MyTextFormField(
                              title: 'Employee ID',
                              controller: employeeIdCtrl)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: MyTextFormField(
                              title: 'Reviewer ID',
                              controller: reviewerIdCtrl)),
                    ]),
                    const SizedBox(height: 24),
                    Row(children: [
                      Expanded(
                          child: MyTextFormField(
                              title: 'Review Date',
                              controller: reviewDateCtrl)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: MyTextFormField(
                              title: 'Review Period',
                              controller: reviewPeriodCtrl)),
                    ]),
                    const SizedBox(height: 24),
                    MyTextFormField(
                        title: 'Overall Rating (1-5)', controller: ratingCtrl),
                    const SizedBox(height: 24),
                    MyTextFormField(
                        title: 'Strengths',
                        controller: strengthsCtrl,
                        maxLines: 3),
                    const SizedBox(height: 24),
                    MyTextFormField(
                        title: 'Area For Improvement',
                        controller: areasCtrl,
                        maxLines: 3),
                    const SizedBox(height: 24),
                    MyTextFormField(
                        title: 'Feedback',
                        controller: feedbackCtrl,
                        maxLines: 3),
                    const SizedBox(height: 24),
                    MyTextFormField(
                        title: 'Employee Comment',
                        controller: commentCtrl,
                        maxLines: 3),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                    textColor: AppColors.neutral500,
                    child: 'Cancel',
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  Obx(() => MyElevatedButton(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
