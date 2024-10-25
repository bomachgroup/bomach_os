import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String child;
  final Widget? icon;
  final double? width;
  final double? height;
  final Color? color;
  final VoidCallback onTap;
  const CustomButton(
      {super.key,
      required this.child,
      this.color,
      required this.onTap,
      this.width,
      this.height,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color ?? AppColors.buttonColor,
        ),
        child: Row(
          children: [
            icon ?? const SizedBox(),
            const SizedBox(
              width: 8,
            ),
            Text(
              child,
              style: AppText.white_400_16,
            )
          ],
        ),
      ),
    );
  }
}
