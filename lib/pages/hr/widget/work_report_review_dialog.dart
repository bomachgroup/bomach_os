import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/work_report_controller.dart';
import '../models/work_report_model.dart';

class WorkReportReviewDialog extends StatefulWidget {
  final WorkReport report;
  final String token;

  const WorkReportReviewDialog({
    super.key,
    required this.report,
    required this.token,
  });

  @override
  State<WorkReportReviewDialog> createState() => _WorkReportReviewDialogState();
}

class _WorkReportReviewDialogState extends State<WorkReportReviewDialog> {
  final WorkReportController controller = Get.find();

  late TextEditingController _feedbackController;
  int _rating = 0;

  @override
  void initState() {
    super.initState();
    _feedbackController =
        TextEditingController(text: widget.report.feedback ?? '');
    _rating = widget.report.rating;
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _handleReview(String newStatus) async {
    final updatedReport = WorkReport(
      id: widget.report.id,
      employeeId: widget.report.employeeId,
      day: widget.report.day,
      hoursWorked: widget.report.hoursWorked,
      mood: widget.report.mood,
      challenges: widget.report.challenges,
      achievements: widget.report.achievements,
      planNextDay: widget.report.planNextDay,
      status: newStatus,
      rating: _rating,
      feedback: _feedbackController.text,
    );

    final success = await controller.updateReport(
        widget.token, widget.report.id, updatedReport);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Report $newStatus"),
          backgroundColor: AppColors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: Colors.blue.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyText('Review Work Report',
                      style: AppText.black_500_20),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText('Employee: ${widget.report.employeeId}',
                                  style: AppText.black_600_16),
                              const SizedBox(height: 4),
                              MyText(
                                  'Date: ${widget.report.day != null ? DateFormat('yyyy-MM-dd').format(widget.report.day!) : '-'}'),
                            ],
                          ),
                          MyText('${widget.report.hoursWorked} hrs',
                              style: AppText.black_600_16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDetail('Achievements', widget.report.achievements),
                    _buildDetail('Challenges', widget.report.challenges),
                    _buildDetail('Next Day Plan', widget.report.planNextDay),
                    const Divider(height: 32),
                    const MyText('Manager Review', style: AppText.black_600_16),
                    const SizedBox(height: 16),
                    const MyText('Rating',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                              index < _rating ? Icons.star : Icons.star_border,
                              color: AppColors.orange,
                              size: 32),
                          onPressed: () => setState(() => _rating = index + 1),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    MyTextFormField(
                      title: 'Feedback',
                      controller: _feedbackController,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                      textColor: Colors.red,
                      child: 'Reject',
                      onTap: () => _handleReview('rejected')),
                  const SizedBox(width: 16),
                  Obx(() => MyElevatedButton(
                        child: controller.isSaving.value
                            ? 'Processing...'
                            : 'Approve',
                        onTap: controller.isSaving.value
                            ? () {}
                            : () => _handleReview('approved'),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(String title, String? content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          MyText((content == null || content.isEmpty) ? 'N/A' : content),
        ],
      ),
    );
  }
}
