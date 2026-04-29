import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_date_field.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../controllers/timeline_controller.dart';
import '../models/models.dart';

class AddTimelineDialog extends StatefulWidget {
  final TimelineModel? timeline;

  const AddTimelineDialog({
    super.key,
    this.timeline,
  });

  @override
  State<AddTimelineDialog> createState() => _AddTimelineDialogState();
}

class _AddTimelineDialogState extends State<AddTimelineDialog> {
  final TimelineController controller = Get.find<TimelineController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameCtrl;
  late TextEditingController descCtrl;
  late TextEditingController startCtrl;
  late TextEditingController endCtrl;

  String selectedStatus = 'Pending';

  @override
  void initState() {
    super.initState();
    final t = widget.timeline;
    nameCtrl = TextEditingController(text: t?.name ?? '');
    descCtrl = TextEditingController(text: t?.description ?? '');
    startCtrl = TextEditingController(text: t?.startDate ?? '');
    endCtrl = TextEditingController(text: t?.endDate ?? '');

    if (t != null && t.status.isNotEmpty) {
      selectedStatus = t.status;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    startCtrl.dispose();
    endCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (nameCtrl.text.isEmpty) return;

    final timeline = TimelineModel(
      id: widget.timeline?.id ?? 0,
      projectId: widget.timeline?.projectId ?? 0,
      name: nameCtrl.text,
      description: descCtrl.text,
      status: selectedStatus,
      startDate: startCtrl.text,
      endDate: endCtrl.text,
      createdAt: widget.timeline?.createdAt ?? '',
      updatedAt: '',
    );

    if (widget.timeline == null) {
      controller.createTimeline(context, timeline);
    } else {
      controller.updateTimeline(context, timeline.id, timeline);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.timeline != null;

    return Obx(() => DialogScaffold(
          title: isEdit ? 'Edit Timeline Phase' : 'New Timeline Phase',
          subtitle: isEdit
              ? 'Update phase details, status, and schedule.'
              : 'Define a new project phase with its status and schedule.',
          size: DialogSize.md,
          body: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  title: 'Phase information',
                  subtitle: 'Name and classify the project phase.',
                  child: Column(
                    children: [
                      MyTextFormField(
                        controller: nameCtrl,
                        title: 'Phase Name',
                        hintText: 'e.g. Planning',
                        validator: (val) =>
                            (val == null || val.trim().isEmpty)
                                ? 'Required'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      MyDropdown(
                        title: 'Status',
                        hintText: 'Select status',
                        items: const [
                          'Pending',
                          'In Progress',
                          'Completed',
                          'On Hold',
                        ],
                        initialSelection: selectedStatus,
                        onChanged: (val) => setState(
                            () => selectedStatus = val ?? selectedStatus),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Schedule',
                  subtitle: 'Define the phase duration.',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: MyDateField(
                          controller: startCtrl,
                          title: 'Start Date',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MyDateField(
                          controller: endCtrl,
                          title: 'End Date',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Notes',
                  child: MyTextFormField(
                    controller: descCtrl,
                    title: 'Description',
                    hintText: 'Phase details...',
                    maxLines: 4,
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
              width: 140,
              height: 44,
              child: controller.isActionLoading.value
                  ? 'Saving...'
                  : (isEdit ? 'Update' : 'Save'),
              onTap: controller.isActionLoading.value ? null : _save,
              icon: controller.isActionLoading.value
                  ? null
                  : const Icon(
                      Iconsax.tick_circle,
                      size: 18,
                      color: AppColors.textOnPrimary,
                    ),
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
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
