import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:bomach_os/src/helper/date_picker_helper.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../pages/hr/models/training_program_model.dart';
import '../controller/training_program_controller.dart';

class AddProgramDialog extends StatefulWidget {
  final String token;
  final TrainingProgram? programToEdit;

  const AddProgramDialog({super.key, required this.token, this.programToEdit});

  @override
  State<AddProgramDialog> createState() => _AddProgramDialogState();
}

class _AddProgramDialogState extends State<AddProgramDialog> {
  final TrainingProgramController controller = Get.find();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController nameCtrl;
  late TextEditingController providerCtrl;
  late TextEditingController descCtrl;
  late TextEditingController costCtrl;
  late TextEditingController startDateCtrl;
  late TextEditingController endDateCtrl;
  late TextEditingController durationCtrl;

  // State Variables
  String selectedStatus = 'scheduled';
  String selectedAudience = 'all_employees';
  bool isMandatory = false;

  // Status options with display labels
  final Map<String, String> statusMap = {
    'scheduled': 'Scheduled',
    'active': 'Active',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
  };

  // Target audience options
  final Map<String, String> audienceMap = {
    'all_employees': 'All Employees',
    'management': 'Management',
    'new_hires': 'New Hires',
    'department_specific': 'Department Specific',
    'leadership_team': 'Leadership Team',
    'technical_staff': 'Technical Staff',
    'sales_team': 'Sales Team',
    'customer_service': 'Customer Service',
  };

  bool get isEdit => widget.programToEdit != null;

  @override
  void initState() {
    super.initState();
    final p = widget.programToEdit;

    nameCtrl = TextEditingController(text: p?.programName ?? '');
    providerCtrl = TextEditingController(text: p?.provider ?? '');
    descCtrl = TextEditingController(text: p?.description ?? '');
    costCtrl = TextEditingController(text: p?.cost.toString() ?? '');

    startDateCtrl = TextEditingController(
        text: p?.startDate != null
            ? DateFormat('yyyy-MM-dd').format(p!.startDate!)
            : '');
    endDateCtrl = TextEditingController(
        text: p?.endDate != null
            ? DateFormat('yyyy-MM-dd').format(p!.endDate!)
            : '');

    durationCtrl =
        TextEditingController(text: p?.durationDays.toString() ?? '');

    selectedStatus = p?.status ?? 'scheduled';

    if (p != null && audienceMap.containsKey(p.targetAudience)) {
      selectedAudience = p.targetAudience;
    } else {
      selectedAudience = 'all_employees';
    }

    isMandatory = p?.isMandatory ?? false;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    providerCtrl.dispose();
    descCtrl.dispose();
    costCtrl.dispose();
    startDateCtrl.dispose();
    endDateCtrl.dispose();
    durationCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController ctrl) async {
    DateTime? picked = await showDatePopover(
      context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      ctrl.text = DateFormat('yyyy-MM-dd').format(picked);
      _calculateDuration();
      setState(() {});
    }
  }

  void _calculateDuration() {
    if (startDateCtrl.text.isNotEmpty && endDateCtrl.text.isNotEmpty) {
      try {
        DateTime start = DateTime.parse(startDateCtrl.text);
        DateTime end = DateTime.parse(endDateCtrl.text);
        int days = end.difference(start).inDays + 1;
        if (days > 0) {
          durationCtrl.text = days.toString();
        }
      } catch (_) {
        // Ignore parse errors
      }
    }
  }

  void _save() async {
    if (nameCtrl.text.isEmpty ||
        startDateCtrl.text.isEmpty ||
        endDateCtrl.text.isEmpty) {
      AppToast.error(context, 'Please fill in all required fields');
      return;
    }

    final newProgram = TrainingProgram(
      id: widget.programToEdit?.id ?? '',
      programName: nameCtrl.text.trim(),
      provider: providerCtrl.text.trim(),
      description: descCtrl.text.trim(),
      startDate: DateTime.tryParse(startDateCtrl.text),
      endDate: DateTime.tryParse(endDateCtrl.text),
      cost: int.tryParse(costCtrl.text.replaceAll(',', '')) ?? 0,
      targetAudience: selectedAudience,
      durationDays: int.tryParse(durationCtrl.text) ?? 0,
      status: selectedStatus,
      isMandatory: isMandatory,
    );

    bool success;
    if (widget.programToEdit != null) {
      success = await controller.updateProgram(
          widget.token, widget.programToEdit!.id, newProgram);
    } else {
      success = await controller.createProgram(newProgram);
    }

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      AppToast.success(context,
          widget.programToEdit != null ? 'Program Updated' : 'Program Created');
    } else {
      AppToast.error(context, 'Operation Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => DialogScaffold(
          title: isEdit ? 'Edit Training Program' : 'Create Training Program',
          subtitle: isEdit
              ? 'Update program details, schedule and audience.'
              : 'Set up a new program with audience, schedule and cost.',
          size: DialogSize.lg,
          body: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  title: 'Program details',
                  subtitle:
                      'Define the title, cost, status and target audience.',
                  child: Column(
                    children: [
                      MyTextFormField(
                        controller: nameCtrl,
                        title: 'Program Title',
                        hintText: 'e.g. Leadership Fundamentals',
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              controller: costCtrl,
                              title: 'Cost',
                              hintText: '0',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MyDropdown(
                              title: 'Status',
                              hintText:
                                  statusMap[selectedStatus] ?? 'Scheduled',
                              items: statusMap.values.toList(),
                              initialSelection: statusMap[selectedStatus],
                              onChanged: (val) {
                                if (val != null) {
                                  final key = statusMap.entries
                                      .firstWhere((e) => e.value == val,
                                          orElse: () =>
                                              const MapEntry('scheduled', ''))
                                      .key;
                                  setState(() => selectedStatus = key);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      MyDropdown(
                        title: 'Target Audience',
                        hintText: audienceMap[selectedAudience] ?? 'Select',
                        items: audienceMap.values.toList(),
                        initialSelection: audienceMap[selectedAudience],
                        onChanged: (val) {
                          if (val != null) {
                            final key = audienceMap.entries
                                .firstWhere((e) => e.value == val,
                                    orElse: () =>
                                        const MapEntry('all_employees', ''))
                                .key;
                            setState(() => selectedAudience = key);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      MyTextFormField(
                        controller: descCtrl,
                        title: 'Description / Syllabus',
                        maxLines: 4,
                        hintText: 'Provide a brief explanation',
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            flex: 2,
                            child: MyTextFormField(
                              controller: providerCtrl,
                              title: 'Trainer / Provider',
                              hintText: 'e.g. Coursera, Internal',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: AppRadii.brMd,
                                border: Border.all(
                                    color: AppColors.borderSubtle),
                              ),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isMandatory,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) => setState(
                                        () => isMandatory = val ?? false),
                                  ),
                                  Flexible(
                                    child: Text(
                                      'Is Mandatory?',
                                      style: AppTextStyles.bodySm.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
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
                  title: 'Schedule',
                  subtitle: 'Pick start and end dates — duration is calculated automatically.',
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              controller: startDateCtrl,
                              title: 'Start Date',
                              hintText: 'Select',
                              readOnly: true,
                              trailing: const Icon(Iconsax.calendar_1,
                                  size: 18,
                                  color: AppColors.textSecondary),
                              onTap: () => _selectDate(startDateCtrl),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MyTextFormField(
                              controller: endDateCtrl,
                              title: 'End Date',
                              hintText: 'Select',
                              readOnly: true,
                              trailing: const Icon(Iconsax.calendar_1,
                                  size: 18,
                                  color: AppColors.textSecondary),
                              onTap: () => _selectDate(endDateCtrl),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      MyTextFormField(
                        controller: durationCtrl,
                        title: 'Duration (Days)',
                        hintText: 'Auto-calculated',
                        readOnly: true,
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
              width: 160,
              height: 44,
              child: controller.isSaving.value
                  ? 'Publishing...'
                  : (isEdit ? 'Update Program' : 'Publish Program'),
              icon: controller.isSaving.value
                  ? null
                  : const Icon(Iconsax.tick_circle,
                      size: 18, color: AppColors.textOnPrimary),
              onTap: controller.isSaving.value ? null : _save,
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
