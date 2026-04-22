import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';

class MyElevatedButton extends StatelessWidget {
  final Widget? icon;
  final String child;
  final Function()? onTap;
  final bool isLoading;
  final bool disable;
  final bool upper;
  final Color bgColor;
  final Color textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final double? borderCurve;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;

  const MyElevatedButton({
    super.key,
    this.icon,
    required this.child,
    required this.onTap,
    this.isLoading = false,
    this.disable = false,
    this.upper = false,
    this.textColor = AppColors.textOnPrimary,
    this.bgColor = AppColors.primary,
    this.borderColor,
    this.width,
    this.height,
    this.borderCurve,
    this.padding,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: disable || isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        side: borderColor != null ? BorderSide(color: borderColor!) : null,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        disabledBackgroundColor: bgColor.withValues(alpha: 0.5),
        backgroundColor: bgColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: borderCurve != null
              ? BorderRadius.circular(borderCurve!)
              : AppRadii.brMd,
        ),
        shadowColor: AppColors.neutral900.withValues(alpha: 0.08),
        minimumSize: Size(width ?? 0, height ?? 44), // Allows flexible width
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.white),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  icon!,
                  kSizedBoxWidthSM,
                ],
                Flexible(
                  child: Text(
                    upper ? child.toUpperCase() : child,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize ?? 14,
                      fontFamily: fontFamily ?? "Poppins",
                      fontWeight: fontWeight ?? FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
