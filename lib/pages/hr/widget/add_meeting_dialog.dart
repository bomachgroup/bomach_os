import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_date_field.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/controller/meeting_controller.dart';
import 'package:bms_front_end/pages/hr/models/meeting_model.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

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
  late final MeetingController controller;

  late TextEditingController titleCtrl;
  late TextEditingController agendaCtrl;
  late TextEditingController dateCtrl;
  late TextEditingController timeCtrl;
  late TextEditingController durationCtrl;
  late TextEditingController locationCtrl;
  late TextEditingController notesCtrl;
  final TextEditingController _attendeeSearchCtrl = TextEditingController();

  String selectedStatusLabel = 'Scheduled';
  String selectedLocationLabel = 'Physical';
  List<int> selectedAttendeeIds = [];
  String _attendeeQuery = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<MeetingController>()
        ? Get.find<MeetingController>()
        : Get.put(MeetingController());

    final m = widget.meeting;
    titleCtrl = TextEditingController(text: m?.title ?? '');
    agendaCtrl = TextEditingController(text: m?.agenda ?? '');
    dateCtrl = TextEditingController(text: m?.meetingDate ?? '');
    timeCtrl = TextEditingController(text: m?.meetingTime ?? '');
    durationCtrl = TextEditingController(
        text: m != null ? m.durationMinutes.toString() : '');
    locationCtrl = TextEditingController(text: m?.location ?? '');
    notesCtrl = TextEditingController(text: m?.notes ?? '');
    selectedAttendeeIds = List<int>.from(m?.attendeeIds ?? []);

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
    timeCtrl.dispose();
    durationCtrl.dispose();
    locationCtrl.dispose();
    notesCtrl.dispose();
    _attendeeSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    TimeOfDay initial = TimeOfDay.now();
    if (timeCtrl.text.isNotEmpty) {
      final parts = timeCtrl.text.split(':');
      if (parts.length >= 2) {
        initial = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      timeCtrl.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.meeting != null;

    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        height: 680,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText(
                    isEdit ? 'Edit Meeting' : 'Create Meeting',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyTextFormField(
                      controller: titleCtrl,
                      title: 'Meeting Title*',
                      hintText: 'e.g. Q1 Review',
                    ),
                    const SizedBox(height: 24),
                    MyTextFormField(
                      controller: agendaCtrl,
                      title: 'Agenda*',
                      maxLines: 3,
                      hintText: 'Meeting agenda...',
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: MyDateField(
                            controller: dateCtrl,
                            title: 'Meeting Date*',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MyTextFormField(
                            controller: timeCtrl,
                            title: 'Meeting Time*',
                            hintText: 'HH:MM',
                            readOnly: true,
                            trailing: const Icon(Iconsax.clock,
                                size: 18),
                            onTap: _pickTime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: MyTextFormField(
                            controller: durationCtrl,
                            title: 'Duration (minutes)*',
                            hintText: '60',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MyDropdown(
                            hintText: '',
                            title: 'Status',
                            items: _statusItems.keys.toList(),
                            controller: TextEditingController(
                                text: selectedStatusLabel),
                            onChanged: (val) =>
                                setState(() => selectedStatusLabel = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: MyDropdown(
                            hintText: '',
                            title: 'Location Type',
                            items: _locationTypes.keys.toList(),
                            controller: TextEditingController(
                                text: selectedLocationLabel),
                            onChanged: (val) =>
                                setState(() => selectedLocationLabel = val!),
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
                    const SizedBox(height: 24),

                    // Attendees
                    _AttendeesField(
                      controller: controller,
                      selectedIds: selectedAttendeeIds,
                      searchCtrl: _attendeeSearchCtrl,
                      query: _attendeeQuery,
                      onQueryChanged: (q) {
                        setState(() => _attendeeQuery = q);
                        if (q.length >= 2) {
                          controller.fetchEmployees(search: q);
                        }
                      },
                      onToggle: (id) => setState(() {
                        if (selectedAttendeeIds.contains(id)) {
                          selectedAttendeeIds.remove(id);
                        } else {
                          selectedAttendeeIds.add(id);
                        }
                      }),
                    ),
                    const SizedBox(height: 24),

                    MyTextFormField(
                      controller: notesCtrl,
                      title: 'Notes',
                      maxLines: 3,
                      hintText: 'Additional notes...',
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                    child: 'Cancel',
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  _isSaving
                      ? const CircularProgressIndicator()
                      : MyElevatedButton(
                          icon: SvgPicture.asset('assets/svg/check.svg',
                              colorFilter: const ColorFilter.mode(
                                  AppColors.white, BlendMode.srcIn)),
                          child: isEdit ? 'Update' : 'Save',
                          onTap: _save,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (titleCtrl.text.isEmpty ||
        agendaCtrl.text.isEmpty ||
        dateCtrl.text.isEmpty ||
        timeCtrl.text.isEmpty ||
        durationCtrl.text.isEmpty) {
      return;
    }

    setState(() => _isSaving = true);

    final meeting = Meeting(
      id: widget.meeting?.id ?? 0,
      meetingId: widget.meeting?.meetingId ?? '',
      title: titleCtrl.text,
      agenda: agendaCtrl.text,
      meetingDate: dateCtrl.text,
      meetingTime: timeCtrl.text,
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
}

// ── Attendee picker widget ────────────────────────────────────────────────────

class _AttendeesField extends StatelessWidget {
  final MeetingController controller;
  final List<int> selectedIds;
  final TextEditingController searchCtrl;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<int> onToggle;

  const _AttendeesField({
    required this.controller,
    required this.selectedIds,
    required this.searchCtrl,
    required this.query,
    required this.onQueryChanged,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoadingEmployees.value;
      final employees = controller.employees;

      final filtered = query.isEmpty
          ? employees
          : employees
              .where((e) =>
                  '${e.firstName} ${e.lastName}'
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  (e.id).toLowerCase().contains(query.toLowerCase()))
              .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText('Attendees', weight: 500),
          const SizedBox(height: 8),

          // Selected chips
          if (selectedIds.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: selectedIds.map((id) {
                final emp = employees
                    .where((e) => int.tryParse(e.id) == id)
                    .firstOrNull;
                final label =
                    emp != null ? '${emp.firstName} ${emp.lastName}' : '$id';
                return Chip(
                  label: Text(label, style: const TextStyle(fontSize: 12)),
                  deleteIcon: const Icon(Iconsax.close_circle, size: 14),
                  onDeleted: () => onToggle(id),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  side:
                      BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],

          // Search
          TextField(
            controller: searchCtrl,
            onChanged: onQueryChanged,
            decoration: InputDecoration(
              hintText: 'Search employees by name or ID...',
              prefixIcon:
                  const Icon(Iconsax.search_normal, size: 18, color: Colors.grey),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0XFFD5D5D5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0XFFD5D5D5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Employee list
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0XFFD5D5D5)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : employees.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Start typing to search employees.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : filtered.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No employees match your search.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const Divider(
                                height: 1, color: Color(0XFFD5D5D5)),
                            itemBuilder: (ctx, i) {
                              final emp = filtered[i];
                              final userId = int.tryParse(emp.id) ?? 0;
                              final isSelected = selectedIds.contains(userId);
                              return InkWell(
                                onTap: () => onToggle(userId),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: isSelected,
                                        onChanged: (_) => onToggle(userId),
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
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              emp.id,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey),
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
      );
    });
  }
}
