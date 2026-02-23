import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
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
    // Default fill color
    final Color defaultFillColor = fillColor ?? AppColors.white;

    // Create a lighter version of the fill color for focus state
    final Color lighterFillColor = HSLColor.fromColor(defaultFillColor)
        .withLightness((HSLColor.fromColor(defaultFillColor).lightness + 0.1)
            .clamp(0.0, 1.0))
        .toColor();

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
                color: textColor ?? AppColors.black,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          SizedBox(
            height: spaceBetweenText ?? (title != null ? 10 : 0),
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
              cursorColor: Colors.black,
              autocorrect: true,
              enableSuggestions: true,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                    vertical: (height != null && height! > 50)
                        ? (height! - 40) / 2
                        : 10,
                    horizontal: 12),
                hintText: hintText,
                filled: true,
                fillColor: defaultFillColor,
                hoverColor: defaultFillColor,
                focusColor: lighterFillColor,
                border: OutlineInputBorder(
                  borderRadius: borderRadius ?? BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: AppColors.card,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: borderRadius ?? BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: AppColors.card,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: borderRadius ?? BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: AppColors.card,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: AppColors.red,
                    width: 2.0,
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
