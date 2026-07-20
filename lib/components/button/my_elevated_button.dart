import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/spaces.dart';
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
      style: ButtonStyle(
        side: WidgetStateProperty.resolveWith((states) {
          if (borderColor != null) return BorderSide(color: borderColor!);
          return null;
        }),
        padding: WidgetStateProperty.all(
          padding ?? const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return bgColor.withValues(alpha: 0.5);
          }
          return bgColor;
        }),
        elevation: WidgetStateProperty.all(0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: borderCurve != null
                ? BorderRadius.circular(borderCurve!)
                : AppRadii.brMd,
          ),
        ),
        minimumSize: WidgetStateProperty.all(Size(width ?? 0, height ?? 44)),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return AppColors.primaryPressed.withValues(alpha: 0.12);
          }
          if (states.contains(WidgetState.hovered)) {
            return AppColors.primaryHover.withValues(alpha: 0.08);
          }
          return null;
        }),
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
