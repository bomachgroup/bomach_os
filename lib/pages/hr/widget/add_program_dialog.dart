import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  String selectedAudience = 'all_employees'; // Default value
  bool isMandatory = false;

  final List<String> statusOptions = [
    'scheduled',
    'active',
    'completed',
    'cancelled'
  ];

  // Target Audience Options (Key: API Value, Value: Display Label)
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

    // Ensure the loaded audience is valid, otherwise default to all_employees
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

  Future<void> _selectDate(TextEditingController ctrl,
      {bool isStart = true}) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      ctrl.text = DateFormat('yyyy-MM-dd').format(picked);
      _calculateDuration();
    }
  }

  void _calculateDuration() {
    if (startDateCtrl.text.isNotEmpty && endDateCtrl.text.isNotEmpty) {
      try {
        DateTime start = DateTime.parse(startDateCtrl.text);
        DateTime end = DateTime.parse(endDateCtrl.text);
        int days = end.difference(start).inDays + 1; // +1 to include start date
        if (days > 0) {
          durationCtrl.text = days.toString();
        }
      } catch (e) {
        // Ignore parse errors
      }
    }
  }

  void _save() async {
    // Basic Validation
    if (nameCtrl.text.isEmpty ||
        startDateCtrl.text.isEmpty ||
        endDateCtrl.text.isEmpty) {
      Get.snackbar("Error", "Please fill in all required fields",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red);
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
      targetAudience: selectedAudience, // Using the strict dropdown value
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
      AppToast.success(context, widget.programToEdit != null
                ? "Program Updated"
                : "Program Created");
    } else {
      AppToast.error(context, 'Operation Failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText(
                    widget.programToEdit == null
                        ? 'Create Training Program'
                        : 'Edit Training Program',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Iconsax.close_circle, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.neutral100),

            // --- Scrollable Form ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Program Title
                    MyTextFormField(
                      title: 'Program Title',
                      controller: nameCtrl,
                      hintText: 'e.g. Leadership Fundamentals',
                      spaceBetweenText: 8,
                    ),
                    const SizedBox(height: 20),

                    // Row: Cost & Status
                    Row(
                      children: [
                        Expanded(
                          child: MyTextFormField(
                            title: 'Cost',
                            controller: costCtrl,
                            hintText: '0',
                            keyboardType: TextInputType.number,
                            spaceBetweenText: 8,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const MyText('Status', weight: 600, size: 14),
                              const SizedBox(height: 8),
                              MyDropdown(
                                items: statusOptions,
                                hintText: selectedStatus,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => selectedStatus = val);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Target Audience Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MyText('Target Audience', weight: 600, size: 14),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedAudience,
                              isExpanded: true,
                              icon: const Icon(Iconsax.arrow_down_1,
                                  color: Colors.grey),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedAudience = newValue;
                                  });
                                }
                              },
                              items: audienceMap.entries
                                  .map<DropdownMenuItem<String>>((entry) {
                                return DropdownMenuItem<String>(
                                  value: entry.key,
                                  child: Text(entry.value),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Description
                    MyTextFormField(
                      title: 'Description/Syllabus',
                      controller: descCtrl,
                      maxLines: 4,
                      hintText: 'Provide a brief explanation',
                      spaceBetweenText: 8,
                    ),
                    const SizedBox(height: 20),

                    // Row: Provider & Mandatory
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 2,
                          child: MyTextFormField(
                            title: 'Trainer / Provider',
                            controller: providerCtrl,
                            hintText: 'e.g. Coursera, Internal',
                            spaceBetweenText: 8,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isMandatory,
                                  activeColor: AppColors.primaryPressed,
                                  onChanged: (val) => setState(
                                      () => isMandatory = val ?? false),
                                ),
                                const MyText("Is Mandatory?", size: 13),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- Schedule Section ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: AppColors.primarySubtle,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.infoSubtle)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const MyText("Schedule",
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () =>
                                      _selectDate(startDateCtrl, isStart: true),
                                  child: IgnorePointer(
                                    child: MyTextFormField(
                                      title: 'Start Date',
                                      controller: startDateCtrl,
                                      hintText: 'Select',
                                      spaceBetweenText: 8,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: InkWell(
                                  onTap: () =>
                                      _selectDate(endDateCtrl, isStart: false),
                                  child: IgnorePointer(
                                    child: MyTextFormField(
                                      title: 'End Date',
                                      controller: endDateCtrl,
                                      hintText: 'Select',
                                      spaceBetweenText: 8,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          MyTextFormField(
                            title: 'Duration (Days)',
                            controller: durationCtrl,
                            hintText: 'Auto-calculated',
                            spaceBetweenText: 8,
                            readOnly: true,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            // --- Footer ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 120,
                    child: MyOutlinedButton(
                      textColor: Colors.black87,
                      child: 'Cancel',
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 160,
                    child: Obx(() => MyElevatedButton(
                          bgColor: AppColors.primary,
                          child: controller.isSaving.value
                              ? 'Publishing...'
                              : 'Publish Program',
                          onTap: controller.isSaving.value ? () {} : _save,
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
