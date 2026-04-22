import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/awards_controller.dart';
import '../models/awards_model.dart';

class AddAwardDialog extends StatefulWidget {
  final String token;
  final Award? awardToEdit;

  const AddAwardDialog({super.key, required this.token, this.awardToEdit});

  @override
  State<AddAwardDialog> createState() => _AddAwardDialogState();
}

class _AddAwardDialogState extends State<AddAwardDialog> {
  final _formKey = GlobalKey<FormState>();
  final AwardsController controller = Get.find();

  late TextEditingController titleCtrl;
  late TextEditingController categoryCtrl;
  late TextEditingController rankCtrl;
  late TextEditingController descCtrl;
  late TextEditingController dateCtrl;

  @override
  void initState() {
    super.initState();
    final a = widget.awardToEdit;
    titleCtrl = TextEditingController(text: a?.title ?? '');
    categoryCtrl = TextEditingController(text: a?.category ?? '');
    rankCtrl = TextEditingController(text: a?.rankLevel ?? '');
    descCtrl = TextEditingController(text: a?.description ?? '');
    dateCtrl = TextEditingController(
      text: a?.dateAwarded != null
          ? DateFormat('yyyy-MM-dd').format(a!.dateAwarded!)
          : '',
    );
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    categoryCtrl.dispose();
    rankCtrl.dispose();
    descCtrl.dispose();
    dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final newAward = Award(
      id: widget.awardToEdit?.id ?? '',
      title: titleCtrl.text,
      category: categoryCtrl.text,
      rankLevel: rankCtrl.text,
      description: descCtrl.text,
      dateAwarded: DateTime.tryParse(dateCtrl.text),
    );

    bool success;
    if (widget.awardToEdit != null) {
      success = await controller.updateAward(
          widget.token, widget.awardToEdit!.id, newAward);
    } else {
      success = await controller.createAward(widget.token, newAward);
    }

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      AppToast.success(context, 'Award saved successfully');
    } else {
      AppToast.error(context, 'Failed to save award');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(
                      widget.awardToEdit == null ? 'New Award' : 'Edit Award',
                      size: 20,
                      weight: 600,
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.close_circle),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                MyTextFormField(title: 'Award Title', controller: titleCtrl),
                kSizedBox,
                Row(
                  children: [
                    Expanded(
                        child: MyTextFormField(
                            title: 'Category', controller: categoryCtrl)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: MyTextFormField(
                            title: 'Rank / Level', controller: rankCtrl)),
                  ],
                ),
                kSizedBox,
                InkWell(
                  onTap: _selectDate,
                  child: IgnorePointer(
                    child: MyTextFormField(
                      title: 'Date Awarded',
                      controller: dateCtrl,
                      hintText: 'YYYY-MM-DD',
                    ),
                  ),
                ),
                kSizedBox,
                MyTextFormField(
                    title: 'Description', controller: descCtrl, maxLines: 3),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyOutlinedButton(
                      textColor: AppColors.neutral500,
                      child: 'Cancel',
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    Obx(() => MyElevatedButton(
                          child:
                              controller.isSaving.value ? 'Saving...' : 'Save',
                          onTap: controller.isSaving.value ? () {} : _save,
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
}
