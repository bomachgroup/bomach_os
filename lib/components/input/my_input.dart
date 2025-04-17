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
  final double? height;
  final double? width;
  final Color? fillColor;
  final BorderRadius? borderRadius;
  final TextAlign textAlign;
  final TextInputType keyboardType;

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
    this.width,
    this.fillColor,
    this.borderRadius,
    this.textAlign = TextAlign.start,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, // Takes only available space if null
      height: height, // Can be set to custom height if needed
      constraints:
          const BoxConstraints(minHeight: 50), // Ensures it’s not too small
      child: TextFormField(
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
        maxLines: 1,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: fillColor ?? AppColors.whiteColor,
          hoverColor: AppColors.whiteColor,
          border: OutlineInputBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.cardColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.cardColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.cardColor,
              width: 2,
            ),
          ),
          prefixIcon: leading,
          suffixIcon: trailing,
        ),
      ),
    );
  }
}
