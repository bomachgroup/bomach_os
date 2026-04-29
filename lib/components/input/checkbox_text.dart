import 'package:bomach_os/components/input/my_checkbox.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/spaces.dart';
import 'package:flutter/material.dart';

class CheckboxText extends StatelessWidget {
  final String text;
  final bool isChecked;
  const CheckboxText({super.key, required this.text, this.isChecked = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MyCheckbox(
          checkColor: AppColors.primary,
          backgroundColor: AppColors.white,
          isChecked: isChecked,
          onChanged: (val) {},
        ),
        kSizedBoxWidthSM,
        MyText(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
