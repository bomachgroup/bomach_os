import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

class MyTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final Function(String?)? onSaved, onChanged;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final String hintText;
  final Widget? leading;
  final Widget? trailing;
  final double? spaceBettwenText;
  final double? height;
  final Color? fillColor;
  final Color? textColor;
  final BorderRadius? borderRadius;
  final TextAlign textAlign;
  final TextInputType keyboardType;
  final String? title;
  final void Function()? onTap;
  final int maxLines;
  final List<BoxShadow>? boxShadow;

  const MyTextFormField({
    super.key,
    this.controller,
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
    this.spaceBettwenText,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    // Default fill color
    final Color defaultFillColor = fillColor ?? AppColors.whiteColor;

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
            Text(
              title ?? '',
              style: TextStyle(
                color: textColor ?? AppColors.blackColor,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          SizedBox(
            height: spaceBettwenText ?? 0,
          ),
          SizedBox(
            height: height,
            child: TextFormField(
              maxLines: maxLines,
              readOnly: onTap != null,
              onTap: onTap,
              focusNode: focusNode,
              controller: controller,
              validator: validator,
              onSaved: onSaved,
              onChanged: onChanged,
              textInputAction: textInputAction,
              textAlign: textAlign,
              cursorColor: Colors.black,
              autocorrect: true,
              enableSuggestions: true,
              keyboardType: keyboardType,
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
                    color: AppColors.cardColor,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: borderRadius ?? BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: AppColors.cardColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: borderRadius ?? BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: AppColors.cardColor,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: AppColors.redColor,
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
