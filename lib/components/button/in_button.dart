import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

class InButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  const InButton({
    super.key,
    required this.title,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(color: AppColors.blueColor, width: 0.6)
              : Border.all(color: AppColors.darkGrey2, width: 0.6),
          color: isSelected ? AppColors.blueColor : AppColors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          title,
          style: isSelected ? AppText.white_300_16 : AppText.black_300_16,
        ),
      ),
    );
  }
}
