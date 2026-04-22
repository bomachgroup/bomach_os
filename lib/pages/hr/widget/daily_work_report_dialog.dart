import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/services/auth_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/work_report_controller.dart';
import '../models/work_report_model.dart';

class DailyWorkReportDialog extends StatefulWidget {
  final WorkReport? existingReport;
  final String token;

  const DailyWorkReportDialog({
    super.key,
    this.existingReport,
    required this.token,
  });

  @override
  State<DailyWorkReportDialog> createState() => _DailyWorkReportDialogState();
}

class _DailyWorkReportDialogState extends State<DailyWorkReportDialog> {
  final WorkReportController controller = Get.find();

  late TextEditingController _hoursWorkedController;
  late TextEditingController _operationalBaseController;
  late TextEditingController _workActivitiesController;
  late TextEditingController _taskDetailsController;
  late TextEditingController _nextDayPlanController;
  final List<WorkReportAttachment> _attachments = [];
  bool _isUploading = false;

  DateTime _reportDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final r = widget.existingReport;
    _hoursWorkedController =
        TextEditingController(text: r?.hoursWorked.toString() ?? '');
    _operationalBaseController =
        TextEditingController(text: r?.operationalBase ?? '');
    _workActivitiesController =
        TextEditingController(text: r?.workActivities ?? '');
    _taskDetailsController = TextEditingController(text: r?.taskDetails ?? '');
    _nextDayPlanController = TextEditingController(text: r?.planNextDay ?? '');

    _reportDate = r?.day ?? DateTime.now();
    if (r?.attachments != null) {
      _attachments.addAll(r!.attachments);
    }
  }

  @override
  void dispose() {
    _hoursWorkedController.dispose();
    _operationalBaseController.dispose();
    _workActivitiesController.dispose();
    _taskDetailsController.dispose();
    _nextDayPlanController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() => _isUploading = true);
    try {
      final authService = AuthService();
      final url = await authService.uploadFile(
          widget.token, file.bytes!.toList(), file.name);
      setState(() {
        _attachments.add(WorkReportAttachment(fileUrl: url));
      });
    } catch (e) {
      if (mounted) {
        AppToast.error(context, 'Failed to upload file: $e');
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _reportDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _reportDate) {
      setState(() => _reportDate = picked);
    }
  }

  void _handleSubmit() async {
    if (_hoursWorkedController.text.isEmpty) {
      AppToast.error(context, 'Hours worked is required');
      return;
    }

    final report = WorkReport(
      id: widget.existingReport?.id ?? '',
      employeeId: widget.existingReport?.employeeId ?? 0,
      day: _reportDate,
      hoursWorked: double.tryParse(_hoursWorkedController.text) ?? 0.0,
      operationalBase: _operationalBaseController.text.isNotEmpty
          ? _operationalBaseController.text
          : null,
      workActivities: _workActivitiesController.text.isNotEmpty
          ? _workActivitiesController.text
          : null,
      taskDetails: _taskDetailsController.text.isNotEmpty
          ? _taskDetailsController.text
          : null,
      planNextDay: _nextDayPlanController.text.isNotEmpty
          ? _nextDayPlanController.text
          : null,
      status: 'draft',
      rating: widget.existingReport?.rating,
      feedback: widget.existingReport?.feedback,
      attachments: _attachments,
    );

    bool success;
    if (widget.existingReport != null) {
      success = await controller.updateReport(
          widget.token, widget.existingReport!.id, report);
    } else {
      success = await controller.createReport(widget.token, report);
    }

    if (success && mounted) {
      Navigator.of(context).pop();
      AppToast.success(context, 'Report submitted');
    } else if (mounted) {
      AppToast.error(context, 'Failed to submit');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingReport != null;

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
              decoration: BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Colors.grey.shade300))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText(isEdit ? 'Edit Work Report' : 'New Work Report',
                      style: AppText.h2),
                  IconButton(
                      icon: const Icon(Iconsax.close_circle),
                      onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const MyText('Report Date *',
                                  style: AppText.h4),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: _selectDate,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0XFFD5D5D5)),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey.shade50,
                                  ),
                                  child: MyText(
                                      DateFormat('MMM dd, yyyy')
                                          .format(_reportDate),
                                      style: AppText.bodyMd),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                            child: MyTextFormField(
                          title: 'Hours Worked *',
                          controller: _hoursWorkedController,
                          keyboardType: TextInputType.number,
                          hintText: 'e.g. 8.0',
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    MyTextFormField(
                      title: 'Operational Base',
                      controller: _operationalBaseController,
                      hintText: 'e.g. Head Office, Site A',
                    ),
                    kSizedBox,
                    MyTextFormField(
                        title: 'Work Activities',
                        controller: _workActivitiesController,
                        maxLines: 3,
                        hintText: 'Describe what you worked on today...'),
                    kSizedBox,
                    MyTextFormField(
                        title: 'Task Details',
                        controller: _taskDetailsController,
                        maxLines: 3,
                        hintText: 'Specific tasks completed...'),
                    kSizedBox,
                    MyTextFormField(
                        title: 'Plan for Next Day',
                        controller: _nextDayPlanController,
                        maxLines: 3,
                        hintText: 'What do you plan to work on tomorrow...'),
                    kSizedBox,
                    // ─── Attachments Section ───
                    const MyText('Attachments', style: AppText.h4),
                    const SizedBox(height: 4),
                    Text('Upload supporting documents',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : _pickAndUploadFile,
                      icon: _isUploading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Iconsax.document_upload, size: 18),
                      label:
                          Text(_isUploading ? 'Uploading...' : 'Choose File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    if (_attachments.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ..._attachments.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final url = entry.value.fileUrl;
                        final fileName =
                            Uri.tryParse(url)?.pathSegments.lastOrNull ?? url;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Iconsax.attach_circle,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(fileName,
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis),
                              ),
                              InkWell(
                                onTap: () =>
                                    setState(() => _attachments.removeAt(idx)),
                                child: const Icon(Iconsax.close_circle,
                                    size: 16, color: Colors.red),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
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
                    textColor: AppColors.neutral500,
                    child: 'Cancel',
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  Obx(() => MyElevatedButton(
                        child: controller.isSaving.value
                            ? 'Submitting...'
                            : 'Submit',
                        onTap:
                            controller.isSaving.value ? () {} : _handleSubmit,
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
