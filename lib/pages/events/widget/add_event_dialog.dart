import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/pages/events/controller/event_controller.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:bomach_os/src/helper/date_picker_helper.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddEventDialog extends StatefulWidget {
  const AddEventDialog({super.key});

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedEventType = 'GENERAL_MEETING';
  DateTime? _dateFrom;
  TimeOfDay? _timeFrom;
  DateTime? _dateTo;
  TimeOfDay? _timeTo;

  bool _targetAllBranches = false;
  bool _targetAllDepartments = false;
  bool _targetAssociates = false;
  bool _targetInvestors = false;
  bool _targetPartners = false;

  bool _isSubmitting = false;

  static const List<String> _eventTypes = [
    'GENERAL_MEETING',
    'BOARD_MEETING',
    'TRAINING',
    'CONFERENCE',
    'SOCIAL_EVENT',
    'OTHER',
  ];

  String _formatEventTypeLabel(String type) {
    return type.replaceAll('_', ' ').toLowerCase().capitalizeFirst ?? type;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePopover(
      context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _dateFrom = picked;
        } else {
          _dateTo = picked;
        }
      });
    }
  }

  Future<void> _pickTime(bool isFrom) async {
    final picked = await showTimePopover(
      context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _timeFrom = picked;
        } else {
          _timeTo = picked;
        }
      });
    }
  }

  String _formatDateDisplay(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd-MM-yyyy').format(date);
  }

  String _formatTimeDisplay(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  DateTime? _combineDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dateFrom == null || _timeFrom == null) {
      Get.snackbar('Error', 'Please select start date and time');
      return;
    }
    if (_dateTo == null || _timeTo == null) {
      Get.snackbar('Error', 'Please select end date and time');
      return;
    }

    final eventTimeFrom = _combineDateTime(_dateFrom, _timeFrom);
    final eventTimeTo = _combineDateTime(_dateTo, _timeTo);

    if (eventTimeFrom == null || eventTimeTo == null) return;

    final data = <String, dynamic>{
      'title': _titleController.text.trim(),
      'event_type': _selectedEventType,
      'event_time_from': eventTimeFrom.toIso8601String(),
      'event_time_to': eventTimeTo.toIso8601String(),
    };

    if (_locationController.text.trim().isNotEmpty) {
      data['meeting_location'] = _locationController.text.trim();
    }
    if (_targetAllBranches) data['target_all_branches'] = true;
    if (_targetAllDepartments) data['target_all_departments'] = true;
    if (_targetAssociates) data['target_associates'] = true;
    if (_targetInvestors) data['target_investors'] = true;
    if (_targetPartners) data['target_partners'] = true;

    setState(() => _isSubmitting = true);

    final controller = Get.find<EventController>();
    final success = await controller.createEvent(data);

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const MyText(
                      'Create New Event',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.close_circle),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Form fields
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyTextFormField(
                          controller: _titleController,
                          hintText: 'Enter event title',
                          spaceBetweenText: 10,
                          title: 'Event Title*',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Title is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        MyDropdown(
                          spaceBetweenText: 10,
                          hintText: "Select event type",
                          items: _eventTypes
                              .map((t) => _formatEventTypeLabel(t))
                              .toList(),
                          title: 'Event Type*',
                          onChanged: (value) {
                            if (value != null) {
                              final idx = _eventTypes.indexWhere(
                                  (t) => _formatEventTypeLabel(t) == value);
                              if (idx >= 0) {
                                setState(() {
                                  _selectedEventType = _eventTypes[idx];
                                });
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Start Date & Time
                        Row(
                          children: [
                            Expanded(
                              child: MyTextFormField(
                                hintText: 'DD-MM-YYYY',
                                spaceBetweenText: 10,
                                title: 'Start Date*',
                                readOnly: true,
                                controller: TextEditingController(
                                  text: _formatDateDisplay(_dateFrom),
                                ),
                                onTap: () => _pickDate(true),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: MyTextFormField(
                                hintText: 'HH:MM',
                                spaceBetweenText: 10,
                                title: 'Start Time*',
                                readOnly: true,
                                controller: TextEditingController(
                                  text: _formatTimeDisplay(_timeFrom),
                                ),
                                onTap: () => _pickTime(true),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // End Date & Time
                        Row(
                          children: [
                            Expanded(
                              child: MyTextFormField(
                                hintText: 'DD-MM-YYYY',
                                spaceBetweenText: 10,
                                title: 'End Date*',
                                readOnly: true,
                                controller: TextEditingController(
                                  text: _formatDateDisplay(_dateTo),
                                ),
                                onTap: () => _pickDate(false),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: MyTextFormField(
                                hintText: 'HH:MM',
                                spaceBetweenText: 10,
                                title: 'End Time*',
                                readOnly: true,
                                controller: TextEditingController(
                                  text: _formatTimeDisplay(_timeTo),
                                ),
                                onTap: () => _pickTime(false),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        MyTextFormField(
                          controller: _locationController,
                          hintText: 'Enter meeting location',
                          spaceBetweenText: 10,
                          title: 'Meeting Location',
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),

                        // Target audience checkboxes
                        const MyText(
                          'Target Audience',
                          size: 14,
                          weight: 600,
                        ),
                        const SizedBox(height: 8),
                        _buildCheckbox(
                          'All Branches',
                          _targetAllBranches,
                          (v) =>
                              setState(() => _targetAllBranches = v ?? false),
                        ),
                        _buildCheckbox(
                          'All Departments',
                          _targetAllDepartments,
                          (v) => setState(
                              () => _targetAllDepartments = v ?? false),
                        ),
                        _buildCheckbox(
                          'Associates',
                          _targetAssociates,
                          (v) => setState(() => _targetAssociates = v ?? false),
                        ),
                        _buildCheckbox(
                          'Investors',
                          _targetInvestors,
                          (v) => setState(() => _targetInvestors = v ?? false),
                        ),
                        _buildCheckbox(
                          'Partners',
                          _targetPartners,
                          (v) => setState(() => _targetPartners = v ?? false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyOutlinedButton(
                      textColor: AppColors.neutral500,
                      borderColor: null,
                      child: 'Cancel',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 16),
                    MyElevatedButton(
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : SvgPicture.asset(
                              "assets/svg/check.svg",
                              colorFilter: const ColorFilter.mode(
                                  AppColors.white, BlendMode.srcIn),
                            ),
                      child: _isSubmitting ? 'Creating...' : 'Create Event',
                      onTap: _isSubmitting ? null : _handleSubmit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(
      String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        Expanded(
          child: MyText(
            label,
            size: 14,
            weight: 400,
          ),
        ),
      ],
    );
  }
}
