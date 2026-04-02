import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/model/board_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    // API returns HH:mm:ss.SSSS or HH:mm:ss
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? 'Edit Meeting' : 'Schedule Meeting',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Meeting Title
                _fieldLabel('Meeting Title'),
                MyTextFormField(
                  controller: titleCtrl,
                  hintText: 'Type here',
                  validator: (val) =>
                      (val == null || val.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Date & Time Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Date'),
                          MyTextFormField(
                            controller: dateCtrl,
                            hintText: 'Select date',
                            readOnly: true,
                            trailing: const Icon(Icons.calendar_today,
                                size: 18, color: Colors.grey),
                            onTap: _pickDate,
                            validator: (val) => (val == null || val.isEmpty)
                                ? 'Required'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Time'),
                          _buildTimeDropdown(),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Agenda
                _fieldLabel('Agenda'),
                MyTextFormField(
                  controller: agendaCtrl,
                  hintText: 'Type here',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Duration & Location Type
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Duration (minutes)'),
                          MyTextFormField(
                            controller: durationCtrl,
                            hintText: 'e.g. 60',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Location Type'),
                          _buildLocationTypeDropdown(),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Location
                _fieldLabel('Location'),
                MyTextFormField(
                  controller: locationCtrl,
                  hintText: 'e.g. Board Room, Zoom link',
                ),
                const SizedBox(height: 16),

                // Attendees
                _fieldLabel('Attendees'),
                _buildAttendeeChips(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: MyTextFormField(
                        controller: attendeeCtrl,
                        hintText: 'Add attendee name',
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _addAttendee,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Notes
                _fieldLabel('Notes'),
                MyTextFormField(
                  controller: notesCtrl,
                  hintText: 'Optional notes',
                  maxLines: 2,
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyOutlinedButton(
                      child: 'Cancel',
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    Obx(() => MyElevatedButton(
                          child: isEdit ? 'Update Meeting' : 'Schedule Meeting',
                          isLoading: controller.isSavingMeeting.value,
                          onTap: _onSave,
                          icon: const Icon(Icons.check,
                              color: Colors.white, size: 18),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTimeDropdown() {
    final times = <String>[];
    for (int h = 7; h <= 20; h++) {
      for (int m = 0; m < 60; m += 30) {
        final hour = h > 12 ? h - 12 : h;
        final period = h >= 12 ? 'PM' : 'AM';
        final minute = m.toString().padLeft(2, '0');
        times.add('$hour:$minute $period');
      }
    }

    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: times.contains(selectedTime) ? selectedTime : null,
          hint: const Text('Select time',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: times
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (val) => setState(() => selectedTime = val),
        ),
      ),
    );
  }

  Widget _buildLocationTypeDropdown() {
    final choices = controller.meetingChoices.value?.locationTypes ?? [];
    final labels = choices.map((e) => e.label).toList();

    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: labels.contains(selectedLocationType)
              ? selectedLocationType
              : null,
          hint: const Text('Select',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: labels
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (val) => setState(() => selectedLocationType = val),
        ),
      ),
    );
  }

  Widget _buildAttendeeChips() {
    if (attendeeNames.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: attendeeNames.asMap().entries.map((entry) {
        return Chip(
          label: Text(entry.value, style: const TextStyle(fontSize: 13)),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () => setState(() => attendeeNames.removeAt(entry.key)),
          backgroundColor: AppColors.blue.withValues(alpha: 0.1),
          side: BorderSide(color: AppColors.blue.withValues(alpha: 0.3)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        );
      }).toList(),
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
      // Pass attendee names for the API to resolve
      // If the API needs IDs, this will need employee lookup
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

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Meeting Info',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildDetailRow('Meeting Title', meeting.title),
              _buildDetailRow('Date', displayDate),
              _buildDetailRow('Time', displayTime),
              _buildDetailRow('Agenda', meeting.agenda),
              if (meeting.location.isNotEmpty)
                _buildDetailRow('Location', meeting.location),
              if (meeting.locationTypeDisplay.isNotEmpty)
                _buildDetailRow('Location Type', meeting.locationTypeDisplay),
              if (meeting.durationDisplay.isNotEmpty)
                _buildDetailRow('Duration', meeting.durationDisplay),
              if (meeting.organizerName.isNotEmpty)
                _buildDetailRow('Organizer', meeting.organizerName),

              // Attendees
              if (meeting.attendees.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text('Attendees',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: meeting.attendees.map((a) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(a.name,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Status
              _buildStatusRow(meeting.statusDisplay),

              if (meeting.notes != null && meeting.notes!.isNotEmpty)
                _buildDetailRow('Notes', meeting.notes!),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButton(
                    label: 'Delete',
                    color: Colors.red,
                    onTap: () async {
                      Navigator.pop(context);
                      final confirmed =
                          await _showDeleteConfirmation(context, meeting.title);
                      if (confirmed == true && context.mounted) {
                        controller.cancelMeeting(context, meeting.id);
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    label: 'Edit',
                    color: AppColors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (_) => ScheduleMeetingDialog(meeting: meeting),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'scheduled':
      case 'upcoming':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      case 'postponed':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          const SizedBox(
            width: 110,
            child: Text('Status',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: color),
                const SizedBox(width: 6),
                Text(status,
                    style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14)),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(
      BuildContext context, String name) async {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Cancel Meeting'),
        content: Text('Are you sure you want to cancel "$name"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('No')),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Yes, Cancel',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
