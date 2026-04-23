import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';

/// A date-picker-backed text field.
/// Tapping it opens a calendar; the selected date is formatted as YYYY-MM-DD.
class MyDateField extends StatelessWidget {
  final TextEditingController controller;
  final String title;
  final String hintText;

  const MyDateField({
    super.key,
    required this.controller,
    required this.title,
    this.hintText = 'YYYY-MM-DD',
  });

  Future<void> _pick(BuildContext context) async {
    DateTime initial = DateTime.now();
    if (controller.text.isNotEmpty) {
      initial = DateTime.tryParse(controller.text) ?? DateTime.now();
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyTextFormField(
      controller: controller,
      title: title,
      hintText: hintText,
      readOnly: true,
      trailing: const Icon(Iconsax.calendar_1, size: 18),
      onTap: () => _pick(context),
    );
  }
}
