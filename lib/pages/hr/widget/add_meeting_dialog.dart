import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/pages/hr/controller/meeting_controller.dart';
import 'package:bomach_os/pages/hr/models/meeting_model.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:bomach_os/src/helper/date_picker_helper.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

const _statusItems = {
  'Scheduled': 'scheduled',
  'In Progress': 'in_progress',
  'Completed': 'completed',
  'Cancelled': 'cancelled',
};

const _locationTypes = {
  'Physical': 'physical',
  'Virtual': 'virtual',
  'Hybrid': 'hybrid',
};

class AddMeetingDialog extends StatefulWidget {
  final Meeting? meeting;
  const AddMeetingDialog({super.key, this.meeting});

  @override
  State<AddMeetingDialog> createState() => _AddMeetingDialogState();
}

class _AddMeetingDialogState extends State<AddMeetingDialog> {
  final _formKey = GlobalKey<FormState>();
  late final MeetingController controller;

  late TextEditingController titleCtrl;
  late TextEditingController agendaCtrl;
  late TextEditingController dateCtrl;
  late TextEditingController durationCtrl;
  late TextEditingController locationCtrl;
  late TextEditingController notesCtrl;
  late TextEditingController attendeeCtrl;

  String? selectedTime; // display label e.g. "9:00 AM"
  String selectedStatusLabel = 'Scheduled';
  String selectedLocationLabel = 'Physical';
  List<int> selectedAttendeeIds = [];
  bool _isSaving = false;

  bool get isEdit => widget.meeting != null;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<MeetingController>()
        ? Get.find<MeetingController>()
        : Get.put(MeetingController());

    final m = widget.meeting;
    titleCtrl = TextEditingController(text: m?.title ?? '');
    agendaCtrl = TextEditingController(text: m?.agenda ?? '');
    durationCtrl = TextEditingController(
        text: m != null && m.durationMinutes > 0
            ? m.durationMinutes.toString()
            : '');
    locationCtrl = TextEditingController(text: m?.location ?? '');
    notesCtrl = TextEditingController(text: m?.notes ?? '');
    attendeeCtrl = TextEditingController();
    selectedAttendeeIds = List<int>.from(m?.attendeeIds ?? []);

    // Format date for display
    String dateText = '';
    if (m != null && m.meetingDate.isNotEmpty) {
      try {
        final parsed = DateTime.parse(m.meetingDate);
        dateText = DateFormat('dd-MM-yyyy').format(parsed);
      } catch (_) {
        dateText = m.meetingDate;
      }
    }
    dateCtrl = TextEditingController(text: dateText);

    // Time
    if (m != null && m.meetingTime.isNotEmpty) {
      selectedTime = _formatTimeForDisplay(m.meetingTime);
    }

    if (m != null) {
      final statusEntry =
          _statusItems.entries.where((e) => e.value == m.status).firstOrNull;
      if (statusEntry != null) selectedStatusLabel = statusEntry.key;

      final locEntry = _locationTypes.entries
          .where((e) => e.value == m.locationType)
          .firstOrNull;
      if (locEntry != null) selectedLocationLabel = locEntry.key;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.employees.isEmpty) {
        controller.fetchEmployees();
      }
    });
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    agendaCtrl.dispose();
    dateCtrl.dispose();
    durationCtrl.dispose();
    locationCtrl.dispose();
    notesCtrl.dispose();
    attendeeCtrl.dispose();
    super.dispose();
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

  Future<void> _pickDate() async {
    final picked = await showDatePopover(
      context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        dateCtrl.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  void _addAttendeeByName() {
    final query = attendeeCtrl.text.trim();
    if (query.isEmpty) return;

    // Try to match an employee by name or ID; if found, add them.
    final emp = controller.employees.firstWhereOrNull((e) {
      final fullName = '${e.firstName} ${e.lastName}'.toLowerCase();
      final q = query.toLowerCase();
      return fullName.contains(q) || e.id.toLowerCase() == q;
    });

    if (emp != null) {
      final id = int.tryParse(emp.id);
      if (id != null && !selectedAttendeeIds.contains(id)) {
        setState(() {
          selectedAttendeeIds.add(id);
          attendeeCtrl.clear();
        });
      } else {
        attendeeCtrl.clear();
      }
    } else {
      // No match — trigger a remote search to populate.
      controller.fetchEmployees(search: query);
    }
  }

  void _removeAttendee(int id) {
    setState(() => selectedAttendeeIds.remove(id));
  }

  String _attendeeLabel(int id) {
    final emp =
        controller.employees.firstWhereOrNull((e) => int.tryParse(e.id) == id);
    if (emp == null) return '$id';
    return '${emp.firstName} ${emp.lastName}'.trim().isEmpty
        ? '$id'
        : '${emp.firstName} ${emp.lastName}';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (titleCtrl.text.isEmpty ||
        agendaCtrl.text.isEmpty ||
        dateCtrl.text.isEmpty ||
        selectedTime == null ||
        durationCtrl.text.isEmpty) {
      return;
    }

    setState(() => _isSaving = true);

    // Convert display date to API format
    String apiDate = '';
    try {
      final parsed = DateFormat('dd-MM-yyyy').parse(dateCtrl.text);
      apiDate = DateFormat('yyyy-MM-dd').format(parsed);
    } catch (_) {
      apiDate = dateCtrl.text;
    }

    // Convert display time to API format
    String apiTime = '';
    if (selectedTime != null) {
      try {
        final parsed = DateFormat('h:mm a').parse(selectedTime!);
        apiTime = DateFormat('HH:mm:ss').format(parsed);
      } catch (_) {
        apiTime = selectedTime ?? '';
      }
    }

    final meeting = Meeting(
      id: widget.meeting?.id ?? 0,
      meetingId: widget.meeting?.meetingId ?? '',
      title: titleCtrl.text,
      agenda: agendaCtrl.text,
      meetingDate: apiDate,
      meetingTime: apiTime,
      durationMinutes: int.tryParse(durationCtrl.text) ?? 60,
      durationDisplay: '',
      status: _statusItems[selectedStatusLabel] ?? 'scheduled',
      statusDisplay: '',
      locationType: _locationTypes[selectedLocationLabel] ?? 'physical',
      locationTypeDisplay: '',
      location: locationCtrl.text.isEmpty ? null : locationCtrl.text,
      attendees: widget.meeting?.attendees ?? [],
      attendeeIds: selectedAttendeeIds,
      attendeeCount: selectedAttendeeIds.length,
      notes: notesCtrl.text.isEmpty ? null : notesCtrl.text,
      createdAt: widget.meeting?.createdAt ?? '',
    );

    try {
      if (widget.meeting == null) {
        await controller.createMeeting(context, meeting);
      } else {
        await controller.updateMeeting(context, meeting.id, meeting);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: isEdit ? 'Edit Meeting' : 'Create Meeting',
      subtitle: isEdit
          ? 'Update meeting details, attendees, and logistics.'
          : 'Schedule a new meeting with agenda, date, and attendees.',
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
                    hintText: 'e.g. Q1 Review',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
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
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Required' : null,
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
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Type & duration',
              subtitle:
                  'Specify the meeting type, status and how long it runs.',
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: MyTextFormField(
                          controller: durationCtrl,
                          title: 'Duration (minutes)',
                          hintText: '60',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MyDropdown(
                          title: 'Status',
                          hintText: selectedStatusLabel,
                          items: _statusItems.keys.toList(),
                          initialSelection: selectedStatusLabel,
                          onChanged: (val) => setState(
                              () => selectedStatusLabel = val ?? 'Scheduled'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: MyDropdown(
                          title: 'Location Type',
                          hintText: selectedLocationLabel,
                          items: _locationTypes.keys.toList(),
                          initialSelection: selectedLocationLabel,
                          onChanged: (val) => setState(
                              () => selectedLocationLabel = val ?? 'Physical'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MyTextFormField(
                          controller: locationCtrl,
                          title: 'Location',
                          hintText: 'e.g. Board Room / Zoom link',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Attendees',
              subtitle: 'Add the people expected to attend this meeting.',
              child: Obx(() {
                // Touch employees so chip names update when fetch completes.
                final _ = controller.employees.length;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (selectedAttendeeIds.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedAttendeeIds.map((id) {
                          return Chip(
                            label: Text(
                              _attendeeLabel(id),
                              style: AppTextStyles.bodySm
                                  .copyWith(fontWeight: FontWeight.w500),
                            ),
                            deleteIcon: const Icon(Iconsax.close_circle,
                                size: 16),
                            onDeleted: () => _removeAttendee(id),
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
                            hintText: 'Search employee by name or ID',
                            onChanged: (q) {
                              if (q.length >= 2) {
                                controller.fetchEmployees(search: q);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Material(
                          color: AppColors.primary,
                          borderRadius: AppRadii.brMd,
                          child: InkWell(
                            borderRadius: AppRadii.brMd,
                            onTap: _addAttendeeByName,
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
                    if (controller.isLoadingEmployees.value) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Searching employees...',
                            style: AppTextStyles.bodySm
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                    if (attendeeCtrl.text.length >= 2 &&
                        !controller.isLoadingEmployees.value &&
                        controller.employees.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 180),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadii.brMd,
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: controller.employees.length,
                          separatorBuilder: (_, __) => const Divider(
                              height: 1, color: AppColors.borderSubtle),
                          itemBuilder: (ctx, i) {
                            final emp = controller.employees[i];
                            final userId = int.tryParse(emp.id) ?? 0;
                            final isSelected =
                                selectedAttendeeIds.contains(userId);
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedAttendeeIds.remove(userId);
                                  } else {
                                    selectedAttendeeIds.add(userId);
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: isSelected,
                                      onChanged: (_) {
                                        setState(() {
                                          if (isSelected) {
                                            selectedAttendeeIds
                                                .remove(userId);
                                          } else {
                                            selectedAttendeeIds.add(userId);
                                          }
                                        });
                                      },
                                      activeColor: AppColors.primary,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${emp.firstName} ${emp.lastName}',
                                            style: AppTextStyles.bodyMd.copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            emp.id,
                                            style: AppTextStyles.bodySm.copyWith(
                                                color:
                                                    AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                );
              }),
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
          width: 140,
          height: 44,
          child: _isSaving ? 'Saving...' : (isEdit ? 'Update' : 'Save'),
          icon: _isSaving
              ? null
              : const Icon(Iconsax.tick_circle,
                  size: 18, color: AppColors.textOnPrimary),
          onTap: _isSaving ? null : _save,
        ),
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
}
