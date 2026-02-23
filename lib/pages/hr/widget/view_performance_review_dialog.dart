import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/chart/star_5.dart';
import 'package:bms_front_end/src/constants/colors.dart';
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
  final ScrollController _scrollController = ScrollController();
  final PerformanceReviewController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Performance Review',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, size: 24),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E5E5)),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
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
                              ''),
                      _buildDetailRow(
                          'Review Period', widget.review.reviewPeriod),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            SizedBox(
                                width: 200,
                                child: Text("Overall Rating",
                                    style: TextStyle(color: Colors.grey[600]))),
                            const Expanded(child: Star5()),
                          ],
                        ),
                      ),
                      _buildDetailRow(
                          'Strengths', widget.review.strengths ?? ''),
                      _buildDetailRow('Area For Improvement',
                          widget.review.areasForImprovement ?? ''),
                      _buildDetailRow('Feedback', widget.review.feedback ?? ''),
                      _buildDetailRow('Employee Comment',
                          widget.review.employeeComments ?? ''),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 15,
                      alignment: WrapAlignment.end,
                      children: [
                        MyElevatedButton(
                          bgColor: AppColors.red,
                          child: 'Delete',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (dCtx) => AlertDialog(
                                title: const Text('Delete Review'),
                                content: const Text(
                                    'Are you sure you want to delete this review?'),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.of(dCtx).pop(),
                                      child: const Text('Cancel')),
                                  TextButton(
                                      onPressed: () async {
                                        await controller
                                            .deleteReview(widget.review.id!);
                                        Navigator.of(dCtx).pop();
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('Review deleted'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      },
                                      child: const Text('Delete')),
                                ],
                              ),
                            );
                          },
                        ),
                        MyElevatedButton(
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
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBlue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isBlue ? const Color(0xFF007AFF) : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
