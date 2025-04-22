import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

class MyCheckbox extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  const MyCheckbox({
    super.key,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: isChecked ? AppColors.blueColor : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isChecked ? AppColors.blueColor : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: isChecked
            ? const Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}
