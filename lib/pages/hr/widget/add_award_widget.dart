import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
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

  bool get isEdit => widget.awardToEdit != null;

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
      setState(() {
        dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
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
    return Obx(() => DialogScaffold(
          title: isEdit ? 'Edit Award' : 'New Award',
          subtitle: isEdit
              ? 'Update award details, category and rank.'
              : 'Recognise an employee with a new award.',
          size: DialogSize.lg,
          body: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  title: 'Award details',
                  subtitle:
                      'Title, category and rank shown across the awards list.',
                  child: Column(
                    children: [
                      MyTextFormField(
                        title: 'Award Title',
                        controller: titleCtrl,
                        hintText: 'e.g. Employee of the Month',
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              title: 'Category',
                              controller: categoryCtrl,
                              hintText: 'e.g. Excellence',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MyTextFormField(
                              title: 'Rank / Level',
                              controller: rankCtrl,
                              hintText: 'e.g. Gold',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      MyTextFormField(
                        title: 'Date Awarded',
                        controller: dateCtrl,
                        hintText: 'YYYY-MM-DD',
                        readOnly: true,
                        trailing: const Icon(Iconsax.calendar_1,
                            size: 18, color: AppColors.textSecondary),
                        onTap: _selectDate,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Description',
                  subtitle: 'A short note about why this award is being given.',
                  child: MyTextFormField(
                    title: 'Description',
                    controller: descCtrl,
                    maxLines: 4,
                    hintText: 'Provide a brief description',
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
              child: controller.isSaving.value ? 'Saving...' : 'Save',
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
