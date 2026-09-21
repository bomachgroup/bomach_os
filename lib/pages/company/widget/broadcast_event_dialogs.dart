import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/broadcast_model.dart';
import 'package:flutter/material.dart';
import 'package:bomach_os/src/helper/date_picker_helper.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
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

  DateTime? selectedFrom;
  DateTime? selectedTo;

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

    if (e != null) {
      selectedFrom =
          e.eventTimeFrom.isNotEmpty ? parseApiDateTime(e.eventTimeFrom) : null;
      selectedTo =
          e.eventTimeTo.isNotEmpty ? parseApiDateTime(e.eventTimeTo) : null;
    }

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
    final parsed = parseApiDateTime(dateStr);
    if (parsed != null) {
      return DateFormat('MM-dd-yyyy, hh:mma').format(parsed);
    }
    return dateStr;
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
    return DialogScaffold(
      title: isEdit ? 'Edit Event' : 'Create Event',
      subtitle: isEdit
          ? 'Update the details for this organizational event.'
          : 'Schedule a new event for branches or departments.',
      size: DialogSize.md,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Basic Information',
              icon: Iconsax.info_circle,
              children: [
                _fieldLabel('Event Title'),
                MyTextFormField(
                  controller: titleCtrl,
                  hintText: 'e.g. Annual General Meeting',
                  validator: (val) =>
                      (val == null || val.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _fieldLabel('Event Type'),
                _buildEventTypeDropdown(),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Schedule & Location',
              icon: Iconsax.calendar_1,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Date/Time (From)'),
                          MyTextFormField(
                            controller: dateFromCtrl,
                            hintText: 'Select start',
                            readOnly: true,
                            leading: const Icon(Iconsax.calendar_1, size: 18),
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
                            hintText: 'Select end',
                            readOnly: true,
                            leading: const Icon(Iconsax.calendar_1, size: 18),
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
                _fieldLabel('Meeting Location / Link'),
                MyTextFormField(
                  controller: locationCtrl,
                  hintText: 'Physical address or virtual link',
                  maxLines: 2,
                  leading: const Icon(Iconsax.location, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Target Audience',
              icon: Iconsax.user_tag,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildAudienceToggle('All Branches', targetAllBranches,
                        (v) => setState(() => targetAllBranches = v)),
                    _buildAudienceToggle(
                        'All Departments',
                        targetAllDepartments,
                        (v) => setState(() => targetAllDepartments = v)),
                    _buildAudienceToggle('Associates', targetAssociates,
                        (v) => setState(() => targetAssociates = v)),
                    _buildAudienceToggle('Investors', targetInvestors,
                        (v) => setState(() => targetInvestors = v)),
                    _buildAudienceToggle('Partners', targetPartners,
                        (v) => setState(() => targetPartners = v)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Settings',
              icon: Iconsax.setting_2,
              children: [
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
              ],
            ),
          ],
        ),
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          onTap: () => Navigator.pop(context),
        ),
        Obx(() => MyElevatedButton(
              width: 160,
              height: 44,
              child: isEdit ? 'Update Event' : 'Create Event',
              isLoading: controller.isSavingEvent.value,
              onTap: _onSave,
              icon: const Icon(Iconsax.tick_circle,
                  color: AppColors.textOnPrimary, size: 18),
            )),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: AppTextStyles.bodySm.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.bodyMd.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildAudienceToggle(
      String label, bool value, ValueChanged<bool> onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: value
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value ? AppColors.primary : AppColors.borderSubtle,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              value ? Iconsax.tick_circle5 : Iconsax.add_circle,
              size: 16,
              color: value ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodySm.copyWith(
                fontWeight: value ? FontWeight.w600 : FontWeight.w400,
                color: value ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTypeDropdown() {
    final labels = eventTypes.map((e) => e['label']!).toList();
    final currentLabel = eventTypes
        .firstWhereOrNull((e) => e['value'] == selectedEventType)?['label'];

    return MyDropdown(
      hintText: 'Select event type',
      items: labels,
      initialSelection: currentLabel,
      height: 48,
      onChanged: (label) {
        final val =
            eventTypes.firstWhereOrNull((e) => e['label'] == label)?['value'];
        setState(() => selectedEventType = val);
      },
    );
  }

  Widget _buildReminderDropdown() {
    final labels = reminderOptions.map((r) => r['label'] as String).toList();
    final currentLabel = reminderOptions
        .firstWhereOrNull((r) => r['value'] == reminderOffset)?['label'];

    return MyDropdown(
      hintText: 'Select reminder',
      items: labels,
      initialSelection: currentLabel,
      height: 48,
      onChanged: (label) {
        final val = reminderOptions
            .firstWhereOrNull((r) => r['label'] == label)?['value'];
        setState(() => reminderOffset = val ?? 0);
      },
    );
  }

  Widget _buildRecurrenceDropdown() {
    final labels = recurrenceOptions.map((r) => _recurrenceLabel(r)).toList();
    final currentLabel =
        _recurrenceLabel(selectedRecurrence ?? 'DOES_NOT_REPEAT');

    return MyDropdown(
      hintText: 'Recurrence',
      items: labels,
      initialSelection: currentLabel,
      height: 48,
      onChanged: (label) {
        final val = recurrenceOptions
            .firstWhereOrNull((r) => _recurrenceLabel(r) == label);
        setState(() => selectedRecurrence = val);
      },
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
    final date = await showDatePopover(
      context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePopover(
      context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final combined =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (ctrl == dateFromCtrl) {
        selectedFrom = combined;
      } else {
        selectedTo = combined;
      }
      ctrl.text = DateFormat('MM-dd-yyyy, hh:mma').format(combined);
    });
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    if (selectedEventType == null) {
      AppToast.error(context, 'Please select an event type');
      return;
    }

    String apiFromDt = '';
    String apiToDt = '';

    if (selectedFrom != null) {
      apiFromDt = selectedFrom!.toUtc().toIso8601String();
    } else {
      try {
        final parsedFrom =
            DateFormat('MM-dd-yyyy, hh:mma').parse(dateFromCtrl.text);
        apiFromDt = parsedFrom.toUtc().toIso8601String();
      } catch (_) {
        apiFromDt = dateFromCtrl.text;
      }
    }

    if (selectedTo != null) {
      apiToDt = selectedTo!.toUtc().toIso8601String();
    } else {
      try {
        final parsedTo =
            DateFormat('MM-dd-yyyy, hh:mma').parse(dateToCtrl.text);
        apiToDt = parsedTo.toUtc().toIso8601String();
      } catch (_) {
        apiToDt = dateToCtrl.text;
      }
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
      'recurrence': (selectedRecurrence == 'DOES_NOT_REPEAT' ||
              selectedRecurrence == 'No Recurrence' ||
              selectedRecurrence == null)
          ? null
          : selectedRecurrence,
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

    return DialogScaffold(
      title: 'Event Info',
      subtitle: 'Viewing details for scheduled organizational event.',
      size: DialogSize.md,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: event.targetAudienceLabels
                  .map((a) => _buildAudienceChip(a))
                  .toList(),
            ),
            const SizedBox(height: 14),
          ],

          if (event.recurrence.isNotEmpty &&
              event.recurrence != 'DOES_NOT_REPEAT')
            _buildDetailRow('Recurrence', _recurrenceLabel(event.recurrence)),

          if (event.reminderOffset > 0)
            _buildDetailRow('Reminder', _reminderLabel(event.reminderOffset)),
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Delete',
          height: 44,
          onTap: () async {
            final confirmed = await DialogScaffold.show<bool>(
              context,
              title: 'Delete Event',
              size: DialogSize.sm,
              body: Text('Are you sure you want to delete "${event.title}"?'),
              actions: [
                MyOutlinedButton(
                  child: 'Cancel',
                  height: 44,
                  onTap: () => Navigator.pop(context, false),
                ),
                MyElevatedButton(
                  width: 120,
                  height: 44,
                  child: 'Delete',
                  bgColor: AppColors.danger,
                  onTap: () => Navigator.pop(context, true),
                ),
              ],
            );
            if (confirmed == true && context.mounted) {
              Navigator.pop(context); // Close View Dialog
              controller.deleteEvent(context, event.id);
            }
          },
        ),
        const SizedBox(width: 8),
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
              builder: (_) => CreateEditEventDialog(event: event),
            );
          },
        ),
      ],
    );
  }

  String _formatDateTime(String dateStr) {
    if (dateStr.isEmpty) return '–';
    final parsed = parseApiDateTime(dateStr);
    if (parsed != null) {
      return DateFormat('MMMM d, yyyy – h:mm a').format(parsed);
    }
    return dateStr;
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
                style:
                    AppTextStyles.bodySm.copyWith(color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(value,
                style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildAudienceChip(String label) {
    final bool isBranch = label.contains('Branch');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isBranch
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBranch ? AppColors.success : AppColors.primary,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySm.copyWith(
          color: isBranch ? AppColors.success : AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
