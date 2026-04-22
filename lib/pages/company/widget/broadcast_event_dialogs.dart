import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/model/broadcast_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/broadcast_controller.dart';

// ─── CREATE / EDIT EVENT DIALOG ─────────────────────────────────

class CreateEditEventDialog extends StatefulWidget {
  final BroadcastEvent? event; // null = create, non-null = edit
  const CreateEditEventDialog({super.key, this.event});

  @override
  State<CreateEditEventDialog> createState() => _CreateEditEventDialogState();
}

class _CreateEditEventDialogState extends State<CreateEditEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final BroadcastController controller = Get.find<BroadcastController>();

  late final TextEditingController titleCtrl;
  late final TextEditingController dateFromCtrl;
  late final TextEditingController dateToCtrl;
  late final TextEditingController locationCtrl;

  String? selectedEventType;
  String? selectedRecurrence;
  int reminderOffset = 0;

  // Target audience booleans
  bool targetAllBranches = false;
  bool targetAllDepartments = false;
  bool targetAssociates = false;
  bool targetInvestors = false;
  bool targetPartners = false;

  bool get isEdit => widget.event != null;

  // Event types matching the API (GENERAL_MEETING, etc.)
  final List<Map<String, String>> eventTypes = [
    {'value': 'GENERAL_MEETING', 'label': 'General Meeting'},
    {'value': 'BOARD_MEETING', 'label': 'Board Meeting'},
    {'value': 'WEBINAR', 'label': 'Webinar'},
    {'value': 'CONFERENCE', 'label': 'Conference'},
    {'value': 'TRAINING', 'label': 'Training'},
    {'value': 'OTHER', 'label': 'Other'},
  ];

  // Reminder offset options (in minutes)
  final List<Map<String, dynamic>> reminderOptions = [
    {'value': 0, 'label': 'No reminder'},
    {'value': 5, 'label': '5 minutes before'},
    {'value': 15, 'label': '15 minutes before'},
    {'value': 30, 'label': '30 minutes before'},
    {'value': 60, 'label': '1 hour before'},
    {'value': 1440, 'label': '1 day before'},
  ];

  // Recurrence options
  final List<String> recurrenceOptions = [
    'DOES_NOT_REPEAT',
    'DAILY',
    'WEEKLY',
    'MONTHLY',
    'YEARLY',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    titleCtrl = TextEditingController(text: e?.title ?? '');
    locationCtrl = TextEditingController(text: e?.meetingLocation ?? '');

    // Format datetimes for display
    dateFromCtrl = TextEditingController(
        text: _formatDateTimeForDisplay(e?.eventTimeFrom ?? ''));
    dateToCtrl = TextEditingController(
        text: _formatDateTimeForDisplay(e?.eventTimeTo ?? ''));

    if (e != null) {
      selectedEventType = e.eventType.isNotEmpty ? e.eventType : null;
      selectedRecurrence =
          e.recurrence.isNotEmpty ? e.recurrence : 'DOES_NOT_REPEAT';
      reminderOffset = e.reminderOffset;
      targetAllBranches = e.targetAllBranches;
      targetAllDepartments = e.targetAllDepartments;
      targetAssociates = e.targetAssociates;
      targetInvestors = e.targetInvestors;
      targetPartners = e.targetPartners;
    } else {
      selectedRecurrence = 'DOES_NOT_REPEAT';
    }
  }

  String _formatDateTimeForDisplay(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final parsed = DateTime.parse(dateStr);
      return DateFormat('MM-dd-yyyy, hh:mma').format(parsed);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    dateFromCtrl.dispose();
    dateToCtrl.dispose();
    locationCtrl.dispose();
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
                      isEdit ? 'Edit Event' : 'Create Event',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.close_circle),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Event Title
                _fieldLabel('Event Title'),
                MyTextFormField(
                  controller: titleCtrl,
                  hintText: 'Type here',
                  validator: (val) =>
                      (val == null || val.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Event Type
                _fieldLabel('Event Type'),
                _buildEventTypeDropdown(),
                const SizedBox(height: 16),

                // Date/Time Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Date/Time (From)'),
                          MyTextFormField(
                            controller: dateFromCtrl,
                            hintText: 'Select date & time',
                            readOnly: true,
                            trailing: const Icon(Iconsax.calendar_1,
                                size: 18, color: Colors.grey),
                            onTap: () => _pickDateTime(dateFromCtrl),
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
                          _fieldLabel('Date/Time (To)'),
                          MyTextFormField(
                            controller: dateToCtrl,
                            hintText: 'Select date & time',
                            readOnly: true,
                            trailing: const Icon(Iconsax.calendar_1,
                                size: 18, color: Colors.grey),
                            onTap: () => _pickDateTime(dateToCtrl),
                            validator: (val) => (val == null || val.isEmpty)
                                ? 'Required'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Location / Meeting Link
                _fieldLabel('Meeting Location'),
                MyTextFormField(
                  controller: locationCtrl,
                  hintText: 'Type here',
                ),
                const SizedBox(height: 16),

                // Target Audience (individual boolean toggles)
                _fieldLabel('Target Audience'),
                CheckboxListTile(
                  title: const Text('All Branches',
                      style: TextStyle(fontSize: 14)),
                  value: targetAllBranches,
                  activeColor: AppColors.primary,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (val) =>
                      setState(() => targetAllBranches = val ?? false),
                ),
                CheckboxListTile(
                  title: const Text('All Departments',
                      style: TextStyle(fontSize: 14)),
                  value: targetAllDepartments,
                  activeColor: AppColors.primary,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (val) =>
                      setState(() => targetAllDepartments = val ?? false),
                ),
                CheckboxListTile(
                  title:
                      const Text('Associates', style: TextStyle(fontSize: 14)),
                  value: targetAssociates,
                  activeColor: AppColors.primary,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (val) =>
                      setState(() => targetAssociates = val ?? false),
                ),
                CheckboxListTile(
                  title:
                      const Text('Investors', style: TextStyle(fontSize: 14)),
                  value: targetInvestors,
                  activeColor: AppColors.primary,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (val) =>
                      setState(() => targetInvestors = val ?? false),
                ),
                CheckboxListTile(
                  title: const Text('Partners', style: TextStyle(fontSize: 14)),
                  value: targetPartners,
                  activeColor: AppColors.primary,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (val) =>
                      setState(() => targetPartners = val ?? false),
                ),
                const SizedBox(height: 16),

                // Reminder & Recurrence Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Reminder'),
                          _buildReminderDropdown(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Recurrence'),
                          _buildRecurrenceDropdown(),
                        ],
                      ),
                    ),
                  ],
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
                          child: isEdit ? 'Update Event' : 'Create Event',
                          isLoading: controller.isSavingEvent.value,
                          onTap: _onSave,
                          icon: const Icon(Iconsax.tick_circle,
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

  Widget _buildEventTypeDropdown() {
    final typeValues = eventTypes.map((e) => e['value']!).toList();

    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value:
              typeValues.contains(selectedEventType) ? selectedEventType : null,
          hint: const Text('Select event type',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
          isExpanded: true,
          icon: const Icon(Iconsax.arrow_down_1, color: Colors.grey),
          items: eventTypes
              .map((t) => DropdownMenuItem(
                  value: t['value'],
                  child:
                      Text(t['label']!, style: const TextStyle(fontSize: 14))))
              .toList(),
          onChanged: (val) => setState(() => selectedEventType = val),
        ),
      ),
    );
  }

  Widget _buildReminderDropdown() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: reminderOffset,
          hint: const Text('Select reminder',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
          isExpanded: true,
          icon: const Icon(Iconsax.arrow_down_1, color: Colors.grey),
          items: reminderOptions
              .map((r) => DropdownMenuItem<int>(
                  value: r['value'] as int,
                  child: Text(r['label'] as String,
                      style: const TextStyle(fontSize: 14))))
              .toList(),
          onChanged: (val) => setState(() => reminderOffset = val ?? 0),
        ),
      ),
    );
  }

  Widget _buildRecurrenceDropdown() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: recurrenceOptions.contains(selectedRecurrence)
              ? selectedRecurrence
              : null,
          hint: const Text('Does not repeat',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
          isExpanded: true,
          icon: const Icon(Iconsax.arrow_down_1, color: Colors.grey),
          items: recurrenceOptions
              .map((r) => DropdownMenuItem(
                  value: r,
                  child: Text(_recurrenceLabel(r),
                      style: const TextStyle(fontSize: 14))))
              .toList(),
          onChanged: (val) => setState(() => selectedRecurrence = val),
        ),
      ),
    );
  }

  String _recurrenceLabel(String value) {
    switch (value) {
      case 'DOES_NOT_REPEAT':
        return 'Does not repeat';
      case 'DAILY':
        return 'Daily';
      case 'WEEKLY':
        return 'Weekly';
      case 'MONTHLY':
        return 'Monthly';
      case 'YEARLY':
        return 'Yearly';
      default:
        return value;
    }
  }

  Future<void> _pickDateTime(TextEditingController ctrl) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final combined =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      ctrl.text = DateFormat('MM-dd-yyyy, hh:mma').format(combined);
    });
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    if (selectedEventType == null) {
      AppToast.error(context, 'Please select an event type');
      return;
    }

    // Convert display datetimes to ISO 8601 UTC format with Z suffix
    // API expects: "2026-03-12T04:41:47.732Z"
    String apiFromDt = '';
    String apiToDt = '';
    try {
      final parsedFrom =
          DateFormat('MM-dd-yyyy, hh:mma').parse(dateFromCtrl.text);
      // Format as ISO 8601 with milliseconds and Z suffix
      apiFromDt =
          DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(parsedFrom.toUtc());
    } catch (_) {
      apiFromDt = dateFromCtrl.text;
    }
    try {
      final parsedTo = DateFormat('MM-dd-yyyy, hh:mma').parse(dateToCtrl.text);
      apiToDt =
          DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(parsedTo.toUtc());
    } catch (_) {
      apiToDt = dateToCtrl.text;
    }

    final data = <String, dynamic>{
      'title': titleCtrl.text.trim(),
      'event_type': selectedEventType ?? 'GENERAL_MEETING',
      'event_time_from': apiFromDt,
      'event_time_to': apiToDt,
      'meeting_location': locationCtrl.text.trim(),
      'target_all_branches': targetAllBranches,
      'target_all_departments': targetAllDepartments,
      'target_associates': targetAssociates,
      'target_investors': targetInvestors,
      'target_partners': targetPartners,
      'reminder_offset': reminderOffset,
      'recurrence': selectedRecurrence ?? 'DOES_NOT_REPEAT',
    };

    if (isEdit) {
      controller.updateEvent(context, widget.event!.id, data);
    } else {
      controller.createEvent(context, data);
    }
  }
}

// ─── VIEW EVENT DIALOG ──────────────────────────────────────────

class ViewEventDialog extends StatelessWidget {
  final BroadcastEvent event;
  const ViewEventDialog({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final BroadcastController controller = Get.find<BroadcastController>();

    // Format dates
    String displayFrom = _formatDateTime(event.eventTimeFrom);
    String displayTo = _formatDateTime(event.eventTimeTo);

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
                  const Text('Event info',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildDetailRow('Event Title', event.title),
              _buildDetailRow('Event Type', event.eventTypeDisplay),
              _buildDetailRow('From', displayFrom),
              _buildDetailRow('To', displayTo),

              if (event.meetingLocation.isNotEmpty)
                _buildDetailRow('Meeting Location', event.meetingLocation),

              // Target Audience
              if (event.targetAudienceLabels.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('Target Audience',
                      style: TextStyle(color: AppColors.neutral500, fontSize: 13)),
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: event.targetAudienceLabels
                      .map((a) => _buildAudienceChip(a))
                      .toList(),
                ),
                const SizedBox(height: 14),
              ],

              if (event.recurrence.isNotEmpty &&
                  event.recurrence != 'DOES_NOT_REPEAT')
                _buildDetailRow(
                    'Recurrence', _recurrenceLabel(event.recurrence)),

              if (event.reminderOffset > 0)
                _buildDetailRow(
                    'Reminder', _reminderLabel(event.reminderOffset)),

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
                          await _showDeleteConfirmation(context, event.title);
                      if (confirmed == true && context.mounted) {
                        controller.deleteEvent(context, event.id);
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    label: 'Edit',
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (_) => CreateEditEventDialog(event: event),
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

  String _formatDateTime(String dateStr) {
    if (dateStr.isEmpty) return '–';
    try {
      final parsed = DateTime.parse(dateStr);
      return DateFormat('MMMM d, yyyy – h:mm a').format(parsed);
    } catch (_) {
      return dateStr;
    }
  }

  String _recurrenceLabel(String value) {
    switch (value) {
      case 'DOES_NOT_REPEAT':
        return 'Does not repeat';
      case 'DAILY':
        return 'Daily';
      case 'WEEKLY':
        return 'Weekly';
      case 'MONTHLY':
        return 'Monthly';
      case 'YEARLY':
        return 'Yearly';
      default:
        return value;
    }
  }

  String _reminderLabel(int offset) {
    if (offset == 0) return 'No reminder';
    if (offset == 5) return '5 minutes before';
    if (offset == 15) return '15 minutes before';
    if (offset == 30) return '30 minutes before';
    if (offset == 60) return '1 hour before';
    if (offset == 1440) return '1 day before';
    return '$offset minutes before';
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label,
                style: const TextStyle(color: AppColors.neutral500, fontSize: 13)),
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

  Widget _buildAudienceChip(String label) {
    Color chipColor;
    if (label.contains('Branch')) {
      chipColor = Colors.green;
    } else {
      chipColor = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
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
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
