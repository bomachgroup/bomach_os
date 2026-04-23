import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/model/board_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../controllers/board_controller.dart';

// ─── SCHEDULE / EDIT MEETING DIALOG ──────────────────────────────

class ScheduleMeetingDialog extends StatefulWidget {
  final BoardMeeting? meeting; // null = create, non-null = edit
  const ScheduleMeetingDialog({super.key, this.meeting});

  @override
  State<ScheduleMeetingDialog> createState() => _ScheduleMeetingDialogState();
}

class _ScheduleMeetingDialogState extends State<ScheduleMeetingDialog> {
  final _formKey = GlobalKey<FormState>();
  final BoardController controller = Get.find<BoardController>();

  late final TextEditingController titleCtrl;
  late final TextEditingController dateCtrl;
  late final TextEditingController agendaCtrl;
  late final TextEditingController locationCtrl;
  late final TextEditingController durationCtrl;
  late final TextEditingController notesCtrl;
  late final TextEditingController attendeeCtrl;

  String? selectedTime;
  String? selectedLocationType;
  String? selectedStatus;
  List<String> attendeeNames = [];
  bool get isEdit => widget.meeting != null;

  @override
  void initState() {
    super.initState();
    final m = widget.meeting;
    titleCtrl = TextEditingController(text: m?.title ?? '');
    agendaCtrl = TextEditingController(text: m?.agenda ?? '');
    locationCtrl = TextEditingController(text: m?.location ?? '');
    durationCtrl = TextEditingController(
        text: m != null && m.durationMinutes > 0 ? '${m.durationMinutes}' : '');
    notesCtrl = TextEditingController(text: m?.notes ?? '');
    attendeeCtrl = TextEditingController();

    // Format date for display
    String dateText = '';
    if (m?.meetingDate != null && m!.meetingDate.isNotEmpty) {
      try {
        final parsed = DateTime.parse(m.meetingDate);
        dateText = DateFormat('MMM d, yyyy').format(parsed);
      } catch (_) {
        dateText = m.meetingDate;
      }
    }
    dateCtrl = TextEditingController(text: dateText);

    // Time
    if (m?.meetingTime != null && m!.meetingTime.isNotEmpty) {
      selectedTime = _formatTimeForDisplay(m.meetingTime);
    }

    // Location type
    if (m != null && m.locationType.isNotEmpty) {
      selectedLocationType = m.locationTypeDisplay.isNotEmpty
          ? m.locationTypeDisplay
          : m.locationType;
    }

    // Status for edit
    if (m != null) {
      selectedStatus = m.statusDisplay.isNotEmpty ? m.statusDisplay : null;
      attendeeNames = m.attendees.map((a) => a.name).toList();
    } else {
      selectedStatus = 'Scheduled';
    }
  }

  String _formatTimeForDisplay(String apiTime) {
    try {
      final parts = apiTime.split(':');
      int h = int.parse(parts[0]);
      int min = int.parse(parts[1]);
      final period = h >= 12 ? 'PM' : 'AM';
      if (h > 12) h -= 12;
      if (h == 0) h = 12;
      return '$h:${min.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return apiTime;
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    dateCtrl.dispose();
    agendaCtrl.dispose();
    locationCtrl.dispose();
    durationCtrl.dispose();
    notesCtrl.dispose();
    attendeeCtrl.dispose();
    super.dispose();
  }

  List<String> _timeSlots() {
    final times = <String>[];
    for (int h = 7; h <= 20; h++) {
      for (int m = 0; m < 60; m += 30) {
        final hour = h > 12 ? h - 12 : h;
        final period = h >= 12 ? 'PM' : 'AM';
        final minute = m.toString().padLeft(2, '0');
        times.add('$hour:$minute $period');
      }
    }
    return times;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => DialogScaffold(
          title: isEdit ? 'Edit Meeting' : 'Schedule Meeting',
          subtitle: isEdit
              ? 'Update meeting details, attendees, and logistics.'
              : 'Create a new board meeting with agenda, date, and attendees.',
          size: DialogSize.lg,
          body: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  title: 'Meeting details',
                  subtitle: 'Set the title, date, time, and agenda.',
                  child: Column(
                    children: [
                      MyTextFormField(
                        controller: titleCtrl,
                        title: 'Meeting Title',
                        hintText: 'e.g. Q2 Board Review',
                        validator: (val) => (val == null || val.isEmpty)
                            ? 'Required'
                            : null,
                      ),
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
                            child: MyDropdown(
                              title: 'Time',
                              hintText: selectedTime ?? 'Select time',
                              items: _timeSlots(),
                              initialSelection: selectedTime,
                              onChanged: (val) =>
                                  setState(() => selectedTime = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      MyTextFormField(
                        controller: agendaCtrl,
                        title: 'Agenda',
                        hintText: 'Outline the key discussion points',
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Location & duration',
                  subtitle:
                      'Specify where the meeting takes place and how long it runs.',
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              controller: durationCtrl,
                              title: 'Duration (minutes)',
                              hintText: 'e.g. 60',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Obx(() {
                              final choices = controller
                                      .meetingChoices.value?.locationTypes ??
                                  [];
                              final labels =
                                  choices.map((e) => e.label).toList();
                              return MyDropdown(
                                title: 'Location Type',
                                hintText: selectedLocationType ?? 'Select',
                                items: labels,
                                initialSelection: selectedLocationType,
                                onChanged: (val) => setState(
                                    () => selectedLocationType = val),
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      MyTextFormField(
                        controller: locationCtrl,
                        title: 'Location',
                        hintText: 'e.g. Board Room, Zoom link',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Attendees',
                  subtitle:
                      'Add the people expected to attend this meeting.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (attendeeNames.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              attendeeNames.asMap().entries.map((entry) {
                            return Chip(
                              label: Text(entry.value,
                                  style: AppTextStyles.bodySm.copyWith(
                                      fontWeight: FontWeight.w500)),
                              deleteIcon: const Icon(Iconsax.close_circle,
                                  size: 16),
                              onDeleted: () => setState(
                                  () => attendeeNames.removeAt(entry.key)),
                              backgroundColor: AppColors.primarySubtle,
                              side: const BorderSide(
                                  color: AppColors.primarySubtle),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: AppRadii.brPill),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              controller: attendeeCtrl,
                              hintText: 'Add attendee name',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Material(
                            color: AppColors.primary,
                            borderRadius: AppRadii.brMd,
                            child: InkWell(
                              borderRadius: AppRadii.brMd,
                              onTap: _addAttendee,
                              child: Container(
                                width: 50,
                                height: 50,
                                alignment: Alignment.center,
                                child: const Icon(Iconsax.add,
                                    color: AppColors.textOnPrimary, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Notes',
                  child: MyTextFormField(
                    controller: notesCtrl,
                    title: 'Additional notes',
                    hintText: 'Optional notes',
                    maxLines: 3,
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
              child: controller.isSavingMeeting.value ? 'Saving...' : 'Save',
              onTap: controller.isSavingMeeting.value ? null : _onSave,
              icon: controller.isSavingMeeting.value
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

  void _addAttendee() {
    final name = attendeeCtrl.text.trim();
    if (name.isNotEmpty && !attendeeNames.contains(name)) {
      setState(() {
        attendeeNames.add(name);
        attendeeCtrl.clear();
      });
    }
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

    // Convert display date to API format (yyyy-MM-dd)
    String apiDate = '';
    try {
      final parsed = DateFormat('MMM d, yyyy').parse(dateCtrl.text);
      apiDate = DateFormat('yyyy-MM-dd').format(parsed);
    } catch (_) {
      apiDate = dateCtrl.text;
    }

    // Convert display time to API format (HH:mm:ss)
    String apiTime = '';
    if (selectedTime != null) {
      try {
        final parsed = DateFormat('h:mm a').parse(selectedTime!);
        apiTime = DateFormat('HH:mm:ss').format(parsed);
      } catch (_) {
        apiTime = selectedTime ?? '';
      }
    }

    // Map location type label to API value
    final locTypeOption = controller.meetingChoices.value?.locationTypes
        .firstWhereOrNull((e) => e.label == selectedLocationType);

    // Map status label to API value
    final statusOption = controller.meetingChoices.value?.statuses
        .firstWhereOrNull((e) => e.label == selectedStatus);

    final data = <String, dynamic>{
      'title': titleCtrl.text.trim(),
      'agenda': agendaCtrl.text.trim(),
      'meeting_date': apiDate,
      'meeting_time': apiTime,
      'status': statusOption?.value ?? 'scheduled',
      'location_type': locTypeOption?.value ?? 'physical',
      'location': locationCtrl.text.trim(),
      'attendee_ids': <int>[],
      if (durationCtrl.text.isNotEmpty)
        'duration_minutes': int.tryParse(durationCtrl.text) ?? 0,
      if (notesCtrl.text.trim().isNotEmpty) 'notes': notesCtrl.text.trim(),
    };

    if (isEdit) {
      controller.updateMeeting(context, widget.meeting!.id, data);
    } else {
      controller.createMeeting(context, data);
    }
  }
}

// ─── VIEW MEETING DIALOG ─────────────────────────────────────────

class ViewMeetingDialog extends StatelessWidget {
  final BoardMeeting meeting;
  const ViewMeetingDialog({super.key, required this.meeting});

  @override
  Widget build(BuildContext context) {
    final BoardController controller = Get.find<BoardController>();

    // Format date for display
    String displayDate = meeting.meetingDate;
    try {
      final parsed = DateTime.parse(meeting.meetingDate);
      displayDate = DateFormat('MMMM d, yyyy').format(parsed);
    } catch (_) {}

    // Format time for display
    String displayTime = meeting.meetingTime;
    try {
      final parts = meeting.meetingTime.split(':');
      int h = int.parse(parts[0]);
      int min = int.parse(parts[1]);
      final period = h >= 12 ? 'PM' : 'AM';
      if (h > 12) h -= 12;
      if (h == 0) h = 12;
      displayTime = '$h:${min.toString().padLeft(2, '0')} $period';
    } catch (_) {}

    return DialogScaffold(
      title: 'Meeting details',
      subtitle: meeting.title,
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryBanner(meeting, displayDate, displayTime),
          const SizedBox(height: 20),
          _buildDetailSection(
            title: 'Meeting information',
            children: [
              _detailRow('Title', meeting.title),
              _detailRow('Date', displayDate),
              _detailRow('Time', displayTime),
              _detailRow('Agenda', meeting.agenda),
              if (meeting.location.isNotEmpty)
                _detailRow('Location', meeting.location),
              if (meeting.locationTypeDisplay.isNotEmpty)
                _detailRow('Location Type', meeting.locationTypeDisplay),
              if (meeting.durationDisplay.isNotEmpty)
                _detailRow('Duration', meeting.durationDisplay),
              if (meeting.organizerName.isNotEmpty)
                _detailRow('Organizer', meeting.organizerName),
            ],
          ),
          if (meeting.attendees.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDetailSection(
              title: 'Attendees',
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: meeting.attendees.map((a) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: const BoxDecoration(
                        color: AppColors.primarySubtle,
                        borderRadius: AppRadii.brPill,
                      ),
                      child: Text(a.name,
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
          if (meeting.notes != null && meeting.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDetailSection(
              title: 'Notes',
              children: [
                Text(
                  meeting.notes!,
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
          child: 'Cancel meeting',
          height: 44,
          onTap: () async {
            Navigator.pop(context);
            final confirmed =
                await _showCancelConfirmation(context, meeting.title);
            if (confirmed == true && context.mounted) {
              controller.cancelMeeting(context, meeting.id);
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
              builder: (_) => ScheduleMeetingDialog(meeting: meeting),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryBanner(
      BoardMeeting meeting, String displayDate, String displayTime) {
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
            child: const Icon(Iconsax.calendar_1,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meeting.title, style: AppTextStyles.h3),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (meeting.statusDisplay.isNotEmpty)
                      StatusChip(
                        label: meeting.statusDisplay,
                        tone: _statusTone(meeting.statusDisplay),
                      ),
                    _buildMetaChip(
                      icon: Iconsax.calendar,
                      label: displayDate.isEmpty ? 'No date' : displayDate,
                    ),
                    if (displayTime.isNotEmpty)
                      _buildMetaChip(
                        icon: Iconsax.clock,
                        label: displayTime,
                      ),
                    if (meeting.locationTypeDisplay.isNotEmpty)
                      _buildMetaChip(
                        icon: Iconsax.location,
                        label: meeting.locationTypeDisplay,
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
      case 'scheduled':
      case 'upcoming':
        return StatusTone.info;
      case 'completed':
        return StatusTone.success;
      case 'cancelled':
      case 'canceled':
        return StatusTone.danger;
      case 'postponed':
      case 'in progress':
        return StatusTone.warning;
      default:
        return StatusTone.neutral;
    }
  }

  Future<bool?> _showCancelConfirmation(
      BuildContext context, String name) async {
    return DialogScaffold.show<bool>(
      context,
      title: 'Cancel meeting',
      subtitle: 'This will mark the meeting as cancelled.',
      size: DialogSize.sm,
      body: Text(
        'Are you sure you want to cancel "$name"?',
        style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
      ),
      actions: [
        MyOutlinedButton(
          child: 'No, keep it',
          height: 44,
          onTap: () => Navigator.pop(context, false),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        MyElevatedButton(
          width: 140,
          height: 44,
          child: 'Yes, cancel',
          icon: const Icon(Iconsax.close_circle,
              size: 18, color: AppColors.textOnPrimary),
          onTap: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}
