import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/services/auth_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
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

    return DialogScaffold(
      title: isEdit ? 'Edit Work Report' : 'New Work Report',
      subtitle: isEdit
          ? 'Update your daily work activities, hours, and attachments.'
          : 'Log your daily work activities, hours, and any supporting files.',
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSection(
            title: 'Report Summary',
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildDateField(
                        label: 'Report Date',
                        value: _reportDate,
                        onTap: _selectDate,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MyTextFormField(
                        title: 'Hours Worked',
                        controller: _hoursWorkedController,
                        keyboardType: TextInputType.number,
                        hintText: 'e.g. 8.0',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                MyTextFormField(
                  title: 'Operational Base',
                  controller: _operationalBaseController,
                  hintText: 'e.g. Head Office, Site A',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Activities & Plans',
            child: Column(
              children: [
                MyTextFormField(
                  title: 'Work Activities',
                  controller: _workActivitiesController,
                  maxLines: 3,
                  hintText: 'Describe what you worked on today...',
                ),
                const SizedBox(height: 16),
                MyTextFormField(
                  title: 'Task Details',
                  controller: _taskDetailsController,
                  maxLines: 3,
                  hintText: 'Specific tasks completed...',
                ),
                const SizedBox(height: 16),
                MyTextFormField(
                  title: 'Plan for Next Day',
                  controller: _nextDayPlanController,
                  maxLines: 3,
                  hintText: 'What do you plan to work on tomorrow...',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Attachments',
            subtitle: 'Upload supporting documents',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyElevatedButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  isLoading: _isUploading,
                  icon: const Icon(Iconsax.document_upload,
                      size: 18, color: AppColors.white),
                  child: _isUploading ? 'Uploading...' : 'Choose File',
                  onTap: _isUploading ? () {} : _pickAndUploadFile,
                ),
                if (_attachments.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ..._attachments.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final url = entry.value.fileUrl;
                    final fileName =
                        Uri.tryParse(url)?.pathSegments.lastOrNull ?? url;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadii.brSm,
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          const Icon(Iconsax.attach_circle,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              fileName,
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: AppRadii.brSm,
                              onTap: () => setState(
                                  () => _attachments.removeAt(idx)),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Iconsax.close_circle,
                                    size: 16, color: AppColors.danger),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
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
              child: 'Submit',
              onTap: controller.isSaving.value ? () {} : _handleSubmit,
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

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: AppRadii.brMd,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.brMd,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.calendar_1,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Text(
                  DateFormat('MMM d, yyyy').format(value),
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
