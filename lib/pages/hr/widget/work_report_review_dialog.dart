import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
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
    _rating = widget.report.rating ?? 0;
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
      operationalBase: widget.report.operationalBase,
      workActivities: widget.report.workActivities,
      taskDetails: widget.report.taskDetails,
      planNextDay: widget.report.planNextDay,
      status: newStatus,
      rating: _rating,
      feedback: _feedbackController.text,
      attachments: widget.report.attachments,
    );

    final success = await controller.updateReport(
        widget.token, widget.report.id, updatedReport);

    if (success && mounted) {
      Navigator.of(context).pop();
      AppToast.success(context, "Report $newStatus");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: 'Review Work Report',
      subtitle:
          'Review the employee\'s daily report and provide a rating and feedback.',
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSummaryBanner(),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Report Details',
            children: [
              _buildDetail(
                  'Operational Base', widget.report.operationalBase),
              _buildDetail('Work Activities', widget.report.workActivities),
              _buildDetail('Task Details', widget.report.taskDetails),
              _buildDetail('Plan for Next Day', widget.report.planNextDay),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Manager Review',
            children: [
              Text(
                'Rating',
                style: AppText.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                        index < _rating ? Iconsax.star1 : Iconsax.star,
                        color: AppColors.warning,
                        size: 28),
                    onPressed: () => setState(() => _rating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 12),
              MyTextFormField(
                title: 'Feedback',
                controller: _feedbackController,
                maxLines: 3,
                hintText: 'Share your feedback on the report',
              ),
            ],
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textColor: AppColors.danger,
          borderColor: AppColors.danger,
          child: 'Reject',
          onTap: () => _handleReview('rejected'),
        ),
        Obx(() => MyElevatedButton(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              isLoading: controller.isSaving.value,
              child: 'Approve',
              onTap: controller.isSaving.value
                  ? () {}
                  : () => _handleReview('approved'),
            )),
      ],
    );
  }

  Widget _buildSummaryBanner() {
    final dayLabel = widget.report.day != null
        ? DateFormat('MMM d, yyyy').format(widget.report.day!)
        : '—';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
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
                Text('Employee #${widget.report.employeeId}',
                    style: AppText.h3),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusChip(
                      label: _statusLabel(widget.report.status),
                      tone: _statusTone(widget.report.status),
                      icon: Iconsax.record_circle,
                    ),
                    _metaChip(icon: Iconsax.calendar_1, label: dayLabel),
                    _metaChip(
                      icon: Iconsax.clock,
                      label: '${widget.report.hoursWorked} hrs',
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

  Widget _metaChip({required IconData icon, required String label}) {
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
            style: AppText.bodySm.copyWith(
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
    required List<Widget> children,
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
          Text(title, style: AppText.h4),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetail(String title, String? content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppText.bodySm.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            (content == null || content.isEmpty) ? 'N/A' : content,
            style: AppText.bodyMd.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    if (status.isEmpty) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1).replaceAll('_', ' ');
  }

  StatusTone _statusTone(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return StatusTone.info;
      case 'approved':
        return StatusTone.success;
      case 'rejected':
        return StatusTone.danger;
      case 'pending_review':
      case 'revision_requested':
        return StatusTone.warning;
      default:
        return StatusTone.neutral;
    }
  }
}
