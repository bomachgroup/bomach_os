import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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

  late TextEditingController nameCtrl;
  late TextEditingController providerCtrl;
  late TextEditingController startDateCtrl;
  late TextEditingController endDateCtrl;
  late TextEditingController descCtrl;
  late TextEditingController costCtrl;
  late TextEditingController audienceCtrl;
  late TextEditingController statusCtrl;
  late TextEditingController durationCtrl;

  bool isMandatory = false;

  @override
  void initState() {
    super.initState();
    final p = widget.programToEdit;
    nameCtrl = TextEditingController(text: p?.programName ?? '');
    providerCtrl = TextEditingController(text: p?.provider ?? '');
    startDateCtrl = TextEditingController(
        text: p?.startDate != null
            ? DateFormat('yyyy-MM-dd').format(p!.startDate!)
            : '');
    endDateCtrl = TextEditingController(
        text: p?.endDate != null
            ? DateFormat('yyyy-MM-dd').format(p!.endDate!)
            : '');
    descCtrl = TextEditingController(text: p?.description ?? '');
    costCtrl = TextEditingController(text: p?.cost.toString() ?? '');
    audienceCtrl = TextEditingController(text: p?.targetAudience ?? '');
    statusCtrl = TextEditingController(text: p?.status ?? 'scheduled');
    durationCtrl =
        TextEditingController(text: p?.durationDays.toString() ?? '');
    isMandatory = p?.isMandatory ?? false;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    providerCtrl.dispose();
    startDateCtrl.dispose();
    endDateCtrl.dispose();
    descCtrl.dispose();
    costCtrl.dispose();
    audienceCtrl.dispose();
    statusCtrl.dispose();
    durationCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController ctrl) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      ctrl.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _save() async {
    final newProgram = TrainingProgram(
      id: widget.programToEdit?.id ?? '',
      programName: nameCtrl.text,
      provider: providerCtrl.text,
      description: descCtrl.text,
      startDate: DateTime.tryParse(startDateCtrl.text),
      endDate: DateTime.tryParse(endDateCtrl.text),
      cost: int.tryParse(costCtrl.text) ?? 100,
      targetAudience: audienceCtrl.text,
      durationDays: int.tryParse(durationCtrl.text) ?? 0,
      status: statusCtrl.text.isEmpty ? 'scheduled' : statusCtrl.text,
      isMandatory: isMandatory,
    );

    bool success;
    if (widget.programToEdit != null) {
      success = await controller.updateProgram(
          widget.token, widget.programToEdit!.id, newProgram);
    } else {
      success = await controller.createProgram(widget.token, newProgram);
    }

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Training Program saved"),
            backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Failed to save"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText(
                    widget.programToEdit == null
                        ? 'New Program'
                        : 'Edit Program',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    Row(children: [
                      Expanded(
                          child: MyTextFormField(
                              title: 'Program Name', controller: nameCtrl)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: MyTextFormField(
                              title: 'Provider', controller: providerCtrl)),
                    ]),
                    const SizedBox(height: 24),
                    Row(children: [
                      Expanded(
                          child: InkWell(
                        onTap: () => _selectDate(startDateCtrl),
                        child: IgnorePointer(
                            child: MyTextFormField(
                                title: 'Start Date',
                                controller: startDateCtrl,
                                hintText: 'YYYY-MM-DD')),
                      )),
                      const SizedBox(width: 16),
                      Expanded(
                          child: InkWell(
                        onTap: () => _selectDate(endDateCtrl),
                        child: IgnorePointer(
                            child: MyTextFormField(
                                title: 'End Date',
                                controller: endDateCtrl,
                                hintText: 'YYYY-MM-DD')),
                      )),
                    ]),
                    const SizedBox(height: 24),
                    MyTextFormField(
                        title: 'Description',
                        controller: descCtrl,
                        maxLines: 4),
                    const SizedBox(height: 24),
                    Row(children: [
                      Expanded(
                          child: MyTextFormField(
                              title: 'Cost', controller: costCtrl)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: MyTextFormField(
                              title: 'Target Audience',
                              controller: audienceCtrl)),
                    ]),
                    const SizedBox(height: 24),
                    Row(children: [
                      Expanded(
                          child: MyTextFormField(
                              title: 'Duration (Days)',
                              controller: durationCtrl)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: MyTextFormField(
                              title: 'Status',
                              controller: statusCtrl,
                              hintText: 'scheduled/completed')),
                    ]),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Checkbox(
                          value: isMandatory,
                          onChanged: (val) =>
                              setState(() => isMandatory = val ?? false),
                        ),
                        const MyText("Is Mandatory?"),
                      ],
                    )
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                    textColor: AppColors.darkGrey1,
                    child: 'Cancel',
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  Obx(() => MyElevatedButton(
                        child: controller.isSaving.value ? 'Saving...' : 'Save',
                        onTap: controller.isSaving.value ? () {} : _save,
                        icon: SvgPicture.asset("assets/svg/check.svg",
                            colorFilter: const ColorFilter.mode(
                                AppColors.white, BlendMode.srcIn)),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
