import 'package:bms_front_end/src/constants/colors.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';

class MyCheckbox extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool> onChanged;
  final Color? backgroundColor;
  final Color? backgroundNotCheckedColor;
  final Color? borderNotCheckedColor;
  final Color? checkColor;

  const MyCheckbox({
    super.key,
    required this.isChecked,
    required this.onChanged,
    this.backgroundColor,
    this.backgroundNotCheckedColor,
    this.borderNotCheckedColor,
    this.checkColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveBackgroundColor = isChecked
        ? (backgroundColor ?? AppColors.primary)
        : backgroundNotCheckedColor ?? AppColors.white;
    final Color effectiveBorderColor = isChecked
        ? (backgroundColor ?? AppColors.primary)
        : borderNotCheckedColor ?? Colors.grey.shade300;

    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: effectiveBorderColor,
            width: 2,
          ),
        ),
        child: isChecked
            ? Icon(
                Iconsax.tick_circle,
                size: 16,
                color: checkColor ?? Colors.white,
              )
            : null,
      ),
    );
  }
}
