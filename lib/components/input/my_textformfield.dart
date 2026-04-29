import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final FormFieldValidator<String>? validator;
  final Function(String)? onSaved, onChanged;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final String hintText;
  final Widget? leading;
  final Widget? trailing;
  final double? spaceBetweenText;
  final double? height;
  final Color? fillColor;
  final Color? textColor;
  final BorderRadius? borderRadius;
  final TextAlign textAlign;
  final TextInputType keyboardType;
  final String? title;
  final void Function()? onTap;
  final int maxLines;
  final int? maxLength;
  final bool obscureText;

  final List<BoxShadow>? boxShadow;
  final bool? readOnly;
  final List<TextInputFormatter>? inputFormatters;

  const MyTextFormField({
    super.key,
    this.obscureText = false,
    this.controller,
    this.initialValue,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.textInputAction,
    this.focusNode,
    this.hintText = "Type",
    this.leading,
    this.trailing,
    this.height,
    this.fillColor,
    this.textColor,
    this.borderRadius,
    this.textAlign = TextAlign.start,
    this.keyboardType = TextInputType.text,
    this.title,
    this.onTap,
    this.maxLines = 1,
    this.maxLength,
    this.spaceBetweenText,
    this.boxShadow,
    this.readOnly,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final Color defaultFillColor = fillColor ?? AppColors.surface;
    final BorderRadius effectiveRadius = borderRadius ?? AppRadii.brMd;

    return Container(
      constraints: BoxConstraints(
        minHeight: height ?? 50,
      ),
      decoration: BoxDecoration(
        boxShadow: boxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            MyText(
              title ?? '',
              style: TextStyle(
                color: textColor ?? AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          SizedBox(
            height: spaceBetweenText ?? (title != null ? 8 : 0),
          ),
          SizedBox(
            height: height,
            child: TextFormField(
              obscureText: obscureText,
              inputFormatters: inputFormatters,
              initialValue: controller != null ? null : initialValue,
              controller: controller,
              maxLines: maxLines,
              readOnly: readOnly ?? onTap != null,
              onTap: onTap,
              maxLength: maxLength,
              keyboardType: keyboardType,
              focusNode: focusNode,
              validator: validator,
              onChanged: onChanged,
              textInputAction: textInputAction,
              textAlign: textAlign,
              cursorColor: AppColors.primary,
              autocorrect: true,
              enableSuggestions: true,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                    vertical: (height != null && height! > 50)
                        ? (height! - 40) / 2
                        : 12,
                    horizontal: 14),
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: defaultFillColor,
                hoverColor: defaultFillColor,
                border: OutlineInputBorder(
                  borderRadius: effectiveRadius,
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: effectiveRadius,
                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: effectiveRadius,
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: effectiveRadius,
                  borderSide: const BorderSide(
                    color: AppColors.danger,
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: effectiveRadius,
                  borderSide: const BorderSide(
                    color: AppColors.danger,
                    width: 1.5,
                  ),
                ),
                prefixIcon: leading,
                suffixIcon: trailing,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
