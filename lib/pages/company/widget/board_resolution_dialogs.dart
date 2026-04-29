import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/board_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../controllers/board_controller.dart';

// ─── CREATE / EDIT RESOLUTION DIALOG ─────────────────────────────

class NewResolutionDialog extends StatefulWidget {
  final BoardResolution? resolution; // null = create, non-null = edit
  const NewResolutionDialog({super.key, this.resolution});

  @override
  State<NewResolutionDialog> createState() => _NewResolutionDialogState();
}

class _NewResolutionDialogState extends State<NewResolutionDialog> {
  final _formKey = GlobalKey<FormState>();
  final BoardController controller = Get.find<BoardController>();

  late final TextEditingController titleCtrl;
  late final TextEditingController descriptionCtrl;
  late final TextEditingController dateCtrl;
  late final TextEditingController notesCtrl;

  String? selectedType;
  String? selectedStatus;
  bool get isEdit => widget.resolution != null;

  @override
  void initState() {
    super.initState();
    final r = widget.resolution;
    titleCtrl = TextEditingController(text: r?.title ?? '');
    descriptionCtrl = TextEditingController(text: r?.description ?? '');
    notesCtrl = TextEditingController(text: r?.notes ?? '');

    // Format date
    String dateText = '';
    if (r?.resolutionDate != null && r!.resolutionDate.isNotEmpty) {
      try {
        final parsed = DateTime.parse(r.resolutionDate);
        dateText = DateFormat('MMM d, yyyy').format(parsed);
      } catch (_) {
        dateText = r.resolutionDate;
      }
    }
    dateCtrl = TextEditingController(text: dateText);

    // Set type/status from existing resolution
    if (r != null) {
      selectedType =
          r.resolutionTypeDisplay.isNotEmpty ? r.resolutionTypeDisplay : null;
      selectedStatus = r.statusDisplay.isNotEmpty ? r.statusDisplay : null;
    } else {
      selectedStatus = 'Pending';
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    dateCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => DialogScaffold(
          title: isEdit ? 'Edit Resolution' : 'New Resolution',
          subtitle: isEdit
              ? 'Update the resolution title, status, and details.'
              : 'Draft a new board resolution for approval.',
          size: DialogSize.lg,
          body: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  title: 'Resolution details',
                  subtitle:
                      'Identify the resolution and choose its type and status.',
                  child: Column(
                    children: [
                      MyTextFormField(
                        controller: titleCtrl,
                        title: 'Resolution Title',
                        hintText: 'e.g. Approval of FY2026 Budget',
                        validator: (val) => (val == null || val.isEmpty)
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Obx(() {
                        final choices = controller
                                .resolutionChoices.value?.resolutionTypes ??
                            [];
                        final labels = choices.map((e) => e.label).toList();
                        return MyDropdown(
                          title: 'Resolution Type',
                          hintText: selectedType ?? 'Select type',
                          items: labels,
                          initialSelection: selectedType,
                          onChanged: (val) =>
                              setState(() => selectedType = val),
                        );
                      }),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              controller: dateCtrl,
                              title: 'Date',
                              hintText: 'Select date',
                              readOnly: true,
                              trailing: const Icon(Iconsax.calendar_1,
                                  size: 18, color: AppColors.textSecondary),
                              onTap: _pickDate,
                              validator: (val) => (val == null || val.isEmpty)
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Obx(() {
                              final choices =
                                  controller.resolutionChoices.value?.statuses ??
                                      [];
                              final labels =
                                  choices.map((e) => e.label).toList();
                              return MyDropdown(
                                title: 'Status',
                                hintText: selectedStatus ?? 'Pending',
                                items: labels,
                                initialSelection: selectedStatus,
                                onChanged: (val) =>
                                    setState(() => selectedStatus = val),
                              );
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Description & notes',
                  subtitle:
                      'Capture the resolution rationale and any supporting notes.',
                  child: Column(
                    children: [
                      MyTextFormField(
                        controller: descriptionCtrl,
                        title: 'Description',
                        hintText: 'Describe the resolution',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      MyTextFormField(
                        controller: notesCtrl,
                        title: 'Notes',
                        hintText: 'Additional context or comments',
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            MyOutlinedButton(
              child: 'Cancel',
              height: 44,
              onTap: () => Navigator.pop(context),
              textColor: AppColors.textSecondary,
              borderColor: AppColors.borderStrong,
            ),
            MyElevatedButton(
              width: 120,
              height: 44,
              child: controller.isSavingResolution.value ? 'Saving...' : 'Save',
              onTap: controller.isSavingResolution.value ? null : _onSave,
              icon: controller.isSavingResolution.value
                  ? null
                  : const Icon(Iconsax.tick_circle,
                      size: 18, color: AppColors.textOnPrimary),
            ),
          ],
        ));
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        dateCtrl.text = DateFormat('MMM d, yyyy').format(picked);
      });
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    // Validate resolution type is selected
    if (selectedType == null) {
      AppToast.error(context, 'Please select a resolution type');
      return;
    }

    // Convert display date to API format
    String apiDate = '';
    try {
      final parsed = DateFormat('MMM d, yyyy').parse(dateCtrl.text);
      apiDate = DateFormat('yyyy-MM-dd').format(parsed);
    } catch (_) {
      apiDate = dateCtrl.text;
    }

    // Map display labels to API values
    final typeOption = controller.resolutionChoices.value?.resolutionTypes
        .firstWhereOrNull((e) => e.label == selectedType);
    final statusOption = controller.resolutionChoices.value?.statuses
        .firstWhereOrNull((e) => e.label == selectedStatus);

    final data = <String, dynamic>{
      'title': titleCtrl.text.trim(),
      'resolution_type': typeOption?.value ?? selectedType ?? '',
      'resolution_date': apiDate,
      'status': statusOption?.value ?? selectedStatus ?? 'pending',
      'description': descriptionCtrl.text.trim(),
      if (notesCtrl.text.trim().isNotEmpty) 'notes': notesCtrl.text.trim(),
    };

    if (isEdit) {
      controller.updateResolution(context, widget.resolution!.id, data);
    } else {
      controller.createResolution(context, data);
    }
  }
}

// ─── VIEW RESOLUTION DIALOG ──────────────────────────────────────

class ViewResolutionDialog extends StatelessWidget {
  final BoardResolution resolution;
  const ViewResolutionDialog({super.key, required this.resolution});

  @override
  Widget build(BuildContext context) {
    final BoardController controller = Get.find<BoardController>();

    // Format date
    String displayDate = resolution.resolutionDate;
    try {
      final parsed = DateTime.parse(resolution.resolutionDate);
      displayDate = DateFormat('MMMM d, yyyy').format(parsed);
    } catch (_) {}

    return DialogScaffold(
      title: 'Resolution details',
      subtitle: resolution.title,
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryBanner(resolution, displayDate),
          const SizedBox(height: 20),
          _buildDetailSection(
            title: 'Resolution information',
            children: [
              _detailRow('Title', resolution.title),
              _detailRow('Type', resolution.resolutionTypeDisplay),
              _detailRow('Date', displayDate),
              _detailRow('Status', resolution.statusDisplay),
              if (resolution.createdByName.isNotEmpty)
                _detailRow('Created By', resolution.createdByName),
              if (resolution.approvedByName != null &&
                  resolution.approvedByName!.isNotEmpty)
                _detailRow('Approved By', resolution.approvedByName!),
            ],
          ),
          if (resolution.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDetailSection(
              title: 'Description',
              children: [
                Text(
                  resolution.description,
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          ],
          if (resolution.attachmentUrl != null &&
              resolution.attachmentUrl!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDetailSection(
              title: 'Attachment',
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadii.brMd,
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Iconsax.attach_circle,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text('View Attachment',
                          style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (resolution.notes != null && resolution.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDetailSection(
              title: 'Notes',
              children: [
                Text(
                  resolution.notes!,
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Close',
          height: 44,
          onTap: () => Navigator.pop(context),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        MyOutlinedButton(
          child: 'Archive',
          height: 44,
          onTap: () async {
            Navigator.pop(context);
            final confirmed =
                await _showArchiveConfirmation(context, resolution.title);
            if (confirmed == true && context.mounted) {
              controller.archiveResolution(context, resolution.id);
            }
          },
          textColor: AppColors.danger,
          borderColor: AppColors.danger,
        ),
        MyElevatedButton(
          width: 120,
          height: 44,
          child: 'Edit',
          icon: const Icon(Iconsax.edit,
              size: 18, color: AppColors.textOnPrimary),
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (_) => NewResolutionDialog(resolution: resolution),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryBanner(BoardResolution resolution, String displayDate) {
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
            child: const Icon(Iconsax.document_text,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(resolution.title, style: AppTextStyles.h3),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (resolution.statusDisplay.isNotEmpty)
                      StatusChip(
                        label: resolution.statusDisplay,
                        tone: _statusTone(resolution.statusDisplay),
                      ),
                    if (resolution.resolutionTypeDisplay.isNotEmpty)
                      _buildMetaChip(
                        icon: Iconsax.tag,
                        label: resolution.resolutionTypeDisplay,
                      ),
                    _buildMetaChip(
                      icon: Iconsax.calendar,
                      label: displayDate.isEmpty ? 'No date' : displayDate,
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

  Widget _buildMetaChip({
    required IconData icon,
    required String label,
  }) {
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
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection({
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
          Text(title, style: AppTextStyles.h4),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
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

  StatusTone _statusTone(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return StatusTone.success;
      case 'pending':
        return StatusTone.warning;
      case 'rejected':
        return StatusTone.danger;
      case 'archived':
        return StatusTone.neutral;
      default:
        return StatusTone.neutral;
    }
  }

  Future<bool?> _showArchiveConfirmation(
      BuildContext context, String name) async {
    return DialogScaffold.show<bool>(
      context,
      title: 'Archive resolution',
      subtitle: 'Archived resolutions can be restored from the archive tab.',
      size: DialogSize.sm,
      body: Text(
        'Are you sure you want to archive "$name"?',
        style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          onTap: () => Navigator.pop(context, false),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        MyElevatedButton(
          width: 120,
          height: 44,
          child: 'Archive',
          icon: const Icon(Iconsax.archive,
              size: 18, color: AppColors.textOnPrimary),
          onTap: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}
