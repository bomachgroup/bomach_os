import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/model/broadcast_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../controllers/broadcast_controller.dart';

// ─── CREATE / EDIT ANNOUNCEMENT DIALOG ──────────────────────────

class CreateEditAnnouncementDialog extends StatefulWidget {
  final Announcement? announcement; // null = create, non-null = edit
  const CreateEditAnnouncementDialog({super.key, this.announcement});

  @override
  State<CreateEditAnnouncementDialog> createState() =>
      _CreateEditAnnouncementDialogState();
}

class _CreateEditAnnouncementDialogState
    extends State<CreateEditAnnouncementDialog> {
  final _formKey = GlobalKey<FormState>();
  final BroadcastController controller = Get.find<BroadcastController>();

  late final TextEditingController titleCtrl;
  late final TextEditingController contentCtrl;
  late final TextEditingController publishAtCtrl;
  late final TextEditingController expiresAtCtrl;

  String? selectedAnnouncementTypeValue;
  String? selectedPriorityValue;
  bool isActive = true;

  Set<int> selectedBranchIds = {};
  Set<String> selectedDepartmentIds = {};

  bool get isEdit => widget.announcement != null;

  @override
  void initState() {
    super.initState();
    final a = widget.announcement;
    titleCtrl = TextEditingController(text: a?.title ?? '');
    contentCtrl = TextEditingController(text: a?.content ?? '');

    publishAtCtrl =
        TextEditingController(text: _formatDateForDisplay(a?.publishAt ?? ''));
    expiresAtCtrl =
        TextEditingController(text: _formatDateForDisplay(a?.expiresAt ?? ''));

    if (a != null) {
      selectedAnnouncementTypeValue =
          a.announcementType.isNotEmpty ? a.announcementType : null;
      selectedPriorityValue = a.priority.isNotEmpty ? a.priority : null;
      isActive = a.isActive;
      selectedBranchIds = a.branchIds.toSet();
      selectedDepartmentIds =
          a.departmentIds.map((id) => id.toString()).toSet();
    } else {
      selectedAnnouncementTypeValue = 'general';
      selectedPriorityValue = 'normal';
      isActive = true;
    }
  }

  String _formatDateForDisplay(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final parsed = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy').format(parsed);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    contentCtrl.dispose();
    publishAtCtrl.dispose();
    expiresAtCtrl.dispose();
    super.dispose();
  }

  List<_OptionLabelValue> _announcementTypeOptions() {
    final choices =
        controller.announcementChoices.value?.announcementTypes ?? [];
    if (choices.isNotEmpty) {
      return choices
          .map((e) => _OptionLabelValue(value: e.value, label: e.label))
          .toList();
    }
    return const [
      _OptionLabelValue(value: 'general', label: 'General'),
      _OptionLabelValue(value: 'urgent', label: 'Urgent'),
      _OptionLabelValue(value: 'policy', label: 'Policy'),
      _OptionLabelValue(value: 'event', label: 'Event'),
    ];
  }

  List<_OptionLabelValue> _priorityOptions() {
    final choices = controller.announcementChoices.value?.priorities ?? [];
    if (choices.isNotEmpty) {
      return choices
          .map((e) => _OptionLabelValue(value: e.value, label: e.label))
          .toList();
    }
    return const [
      _OptionLabelValue(value: 'low', label: 'Low'),
      _OptionLabelValue(value: 'normal', label: 'Normal'),
      _OptionLabelValue(value: 'high', label: 'High'),
      _OptionLabelValue(value: 'urgent', label: 'Urgent'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => DialogScaffold(
          title: isEdit ? 'Edit Announcement' : 'Create Announcement',
          subtitle: isEdit
              ? 'Update the announcement content, audience, and schedule.'
              : 'Share a new message with your team, branches, or departments.',
          size: DialogSize.lg,
          body: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  title: 'Announcement details',
                  subtitle:
                      'Give the announcement a clear title and message body.',
                  child: Column(
                    children: [
                      MyTextFormField(
                        controller: titleCtrl,
                        title: 'Title',
                        hintText: 'e.g. Office closure on public holiday',
                        validator: (val) => (val == null || val.isEmpty)
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      MyTextFormField(
                        controller: contentCtrl,
                        title: 'Content',
                        hintText: 'Type the full message here',
                        maxLines: 4,
                        validator: (val) => (val == null || val.isEmpty)
                            ? 'Required'
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Classification',
                  subtitle:
                      'Pick the announcement type and priority for routing.',
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildTypeDropdown(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildPriorityDropdown(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildActiveToggle(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Schedule',
                  subtitle:
                      'Control when the announcement goes live and expires.',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: MyTextFormField(
                          controller: publishAtCtrl,
                          title: 'Publish At',
                          hintText: 'Select date',
                          readOnly: true,
                          trailing: const Icon(Iconsax.calendar_1,
                              size: 18, color: AppColors.textSecondary),
                          onTap: () => _pickDate(publishAtCtrl),
                          validator: (val) => (val == null || val.isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MyTextFormField(
                          controller: expiresAtCtrl,
                          title: 'Expires At',
                          hintText: 'Select date',
                          readOnly: true,
                          trailing: const Icon(Iconsax.calendar_1,
                              size: 18, color: AppColors.textSecondary),
                          onTap: () => _pickDate(expiresAtCtrl),
                          validator: (val) => (val == null || val.isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Audience',
                  subtitle:
                      'Limit the announcement to specific branches or departments. Leave empty to target everyone.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAudienceLabel('Target Branches (optional)'),
                      const SizedBox(height: 8),
                      Obx(() {
                        final branches = controller.branches;
                        if (branches.isEmpty) {
                          return Text(
                            'No branches available.',
                            style: AppText.bodySm
                                .copyWith(color: AppColors.textMuted),
                          );
                        }
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: branches.map((branch) {
                            final selected =
                                selectedBranchIds.contains(branch.id);
                            return FilterChip(
                              label: Text(branch.branchName,
                                  style: AppText.bodySm),
                              selected: selected,
                              onSelected: (val) => setState(() {
                                if (val) {
                                  selectedBranchIds.add(branch.id);
                                } else {
                                  selectedBranchIds.remove(branch.id);
                                }
                              }),
                              backgroundColor: AppColors.surface,
                              selectedColor: AppColors.primarySubtle,
                              checkmarkColor: AppColors.primary,
                              side: BorderSide(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.borderSubtle,
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: AppRadii.brPill,
                              ),
                            );
                          }).toList(),
                        );
                      }),
                      const SizedBox(height: 16),
                      _buildAudienceLabel('Target Departments (optional)'),
                      const SizedBox(height: 8),
                      Obx(() {
                        final depts = controller.departments;
                        if (depts.isEmpty) {
                          return Text(
                            'No departments available.',
                            style: AppText.bodySm
                                .copyWith(color: AppColors.textMuted),
                          );
                        }
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: depts.map((dept) {
                            final selected =
                                selectedDepartmentIds.contains(dept.id);
                            return FilterChip(
                              label:
                                  Text(dept.name, style: AppText.bodySm),
                              selected: selected,
                              onSelected: (val) => setState(() {
                                if (val) {
                                  selectedDepartmentIds.add(dept.id);
                                } else {
                                  selectedDepartmentIds.remove(dept.id);
                                }
                              }),
                              backgroundColor: AppColors.surface,
                              selectedColor: AppColors.primarySubtle,
                              checkmarkColor: AppColors.primary,
                              side: BorderSide(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.borderSubtle,
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: AppRadii.brPill,
                              ),
                            );
                          }).toList(),
                        );
                      }),
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
              width: 160,
              height: 44,
              child: controller.isSavingAnnouncement.value
                  ? 'Saving...'
                  : (isEdit ? 'Update' : 'Create'),
              onTap: controller.isSavingAnnouncement.value ? null : _onSave,
              icon: controller.isSavingAnnouncement.value
                  ? null
                  : const Icon(Iconsax.tick_circle,
                      size: 18, color: AppColors.textOnPrimary),
            ),
          ],
        ));
  }

  Widget _buildTypeDropdown() {
    final options = _announcementTypeOptions();
    final labels = options.map((o) => o.label).toList();
    final currentLabel = options
        .firstWhereOrNull((o) => o.value == selectedAnnouncementTypeValue)
        ?.label;

    return MyDropdown(
      title: 'Announcement Type',
      hintText: currentLabel ?? 'Select type',
      items: labels,
      initialSelection: currentLabel,
      onChanged: (val) {
        setState(() {
          selectedAnnouncementTypeValue =
              options.firstWhereOrNull((o) => o.label == val)?.value;
        });
      },
    );
  }

  Widget _buildPriorityDropdown() {
    final options = _priorityOptions();
    final labels = options.map((o) => o.label).toList();
    final currentLabel = options
        .firstWhereOrNull((o) => o.value == selectedPriorityValue)
        ?.label;

    return MyDropdown(
      title: 'Priority',
      hintText: currentLabel ?? 'Select priority',
      items: labels,
      initialSelection: currentLabel,
      onChanged: (val) {
        setState(() {
          selectedPriorityValue =
              options.firstWhereOrNull((o) => o.label == val)?.value;
        });
      },
    );
  }

  Widget _buildActiveToggle() {
    return Row(
      children: [
        Text(
          'Active',
          style: AppText.bodyMd.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        Switch(
          value: isActive,
          activeThumbColor: AppColors.primary,
          onChanged: (val) => setState(() => isActive = val),
        ),
        const SizedBox(width: 8),
        StatusChip(
          label: isActive ? 'Active' : 'Inactive',
          tone: isActive ? StatusTone.success : StatusTone.neutral,
        ),
      ],
    );
  }

  Widget _buildAudienceLabel(String text) {
    return Text(
      text,
      style: AppText.bodySm.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
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
          Text(title, style: AppText.h4),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppText.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        ctrl.text = DateFormat('MMM d, yyyy').format(picked);
      });
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    if (selectedAnnouncementTypeValue == null) {
      AppToast.error(context, 'Please select an announcement type');
      return;
    }

    // Convert dates to ISO 8601 format for the API
    String apiPublishAt = '';
    String apiExpiresAt = '';
    try {
      final parsedFrom = DateFormat('MMM d, yyyy').parse(publishAtCtrl.text);
      apiPublishAt = parsedFrom.toUtc().toIso8601String();
    } catch (_) {
      apiPublishAt = publishAtCtrl.text;
    }
    try {
      final parsedTo = DateFormat('MMM d, yyyy').parse(expiresAtCtrl.text);
      apiExpiresAt = parsedTo.toUtc().toIso8601String();
    } catch (_) {
      apiExpiresAt = expiresAtCtrl.text;
    }

    final data = <String, dynamic>{
      'title': titleCtrl.text.trim(),
      'content': contentCtrl.text.trim(),
      'announcement_type': selectedAnnouncementTypeValue ?? 'general',
      'priority': selectedPriorityValue ?? 'normal',
      'branch_ids': selectedBranchIds.toList(),
      'department_ids': selectedDepartmentIds
          .map((id) => int.tryParse(id) ?? 0)
          .where((id) => id > 0)
          .toList(),
      'is_active': isActive,
      'publish_at': apiPublishAt,
      'expires_at': apiExpiresAt,
    };

    if (isEdit) {
      controller.updateAnnouncement(context, widget.announcement!.id, data);
    } else {
      controller.createAnnouncement(context, data);
    }
  }
}

// ─── VIEW ANNOUNCEMENT DIALOG ───────────────────────────────────

class ViewAnnouncementDialog extends StatelessWidget {
  final Announcement announcement;
  const ViewAnnouncementDialog({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    final BroadcastController controller = Get.find<BroadcastController>();

    final displayPublishAt = _formatDate(announcement.publishAt);
    final displayExpiresAt = _formatDate(announcement.expiresAt);

    return DialogScaffold(
      title: 'Announcement details',
      subtitle: announcement.title,
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryBanner(announcement),
          const SizedBox(height: 20),
          _buildDetailSection(
            title: 'Message',
            children: [
              Text(
                announcement.content.isEmpty ? '-' : announcement.content,
                style: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailSection(
            title: 'Announcement information',
            children: [
              _detailRow('Title', announcement.title),
              _detailRow('Type', announcement.announcementTypeDisplay),
              _detailRow('Priority', announcement.priorityDisplay),
              _detailRow('Publish At', displayPublishAt),
              _detailRow('Expires At', displayExpiresAt),
            ],
          ),
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
          child: 'Delete',
          height: 44,
          onTap: () async {
            Navigator.pop(context);
            final confirmed = await _showDeleteConfirmation(
                context, announcement.title);
            if (confirmed == true && context.mounted) {
              controller.deleteAnnouncement(context, announcement.id);
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
              builder: (_) => CreateEditAnnouncementDialog(
                  announcement: announcement),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryBanner(Announcement announcement) {
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
            child: const Icon(Iconsax.notification_bing,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(announcement.title, style: AppText.h3),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusChip(
                      label: announcement.isActive ? 'Active' : 'Inactive',
                      tone: announcement.isActive
                          ? StatusTone.success
                          : StatusTone.neutral,
                    ),
                    if (announcement.announcementTypeDisplay.isNotEmpty)
                      _buildMetaChip(
                        icon: Iconsax.tag,
                        label: announcement.announcementTypeDisplay,
                      ),
                    if (announcement.priorityDisplay.isNotEmpty)
                      _buildMetaChip(
                        icon: Iconsax.flash_1,
                        label: announcement.priorityDisplay,
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
            style: AppText.bodySm.copyWith(
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
          Text(title, style: AppText.h4),
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
              style: AppText.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: AppText.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '-';
    try {
      final parsed = DateTime.parse(dateStr);
      return DateFormat('MMMM d, yyyy').format(parsed);
    } catch (_) {
      return dateStr;
    }
  }

  Future<bool?> _showDeleteConfirmation(
      BuildContext context, String name) async {
    return DialogScaffold.show<bool>(
      context,
      title: 'Delete Announcement',
      size: DialogSize.sm,
      body: Text(
        'Are you sure you want to delete "$name"?',
        style: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
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
          child: 'Delete',
          icon: const Icon(Iconsax.trash,
              size: 18, color: AppColors.textOnPrimary),
          onTap: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}

class _OptionLabelValue {
  final String value;
  final String label;
  const _OptionLabelValue({required this.value, required this.label});
}
