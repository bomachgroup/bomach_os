import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

class MyDropdown extends StatelessWidget {
  const MyDropdown({
    super.key,
    this.controller,
    required this.hintText,
    required this.items,
    this.title,
    this.onChanged,
    this.validator,
    this.fillColor,
    this.height,
    this.width,
  });

  final List<String> items;
  final String? title;
  final TextEditingController? controller;
  final String hintText;
  final Function(String? value)? onChanged;
  final String? Function(String?)? validator;
  final Color? fillColor;
  final double? height;
  final double? width; // Added width parameter

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return FormField<String>(
      validator: validator,
      builder: (FormFieldState<String> state) {
        return SizedBox(
          width: width, // Apply width constraint if provided
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(
                  title ?? '',
                  style: AppText.black_400_16,
                ),
              Container(
                height: height,
                decoration: !state.hasError
                    ? null
                    : BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: AppColors.redColor, width: 1),
                      ),
                child: DropdownMenu(
                  controller: controller,
                  onSelected: (value) {
                    controller?.text = value?.toString() ?? '';
                    state.didChange(controller?.text);
                    if (onChanged != null) {
                      onChanged!(value);
                    }
                  },
                  // Use available width or explicit width if provided
                  width: width,
                  // Ensure dropdown doesn't exceed screen width
                  menuStyle: MenuStyle(
                    maximumSize: WidgetStateProperty.all(
                      Size(width ?? media.width * 0.8, media.height * 0.6),
                    ),
                  ),
                  menuHeight: media.height * 0.6,
                  hintText: hintText,
                  textStyle:
                      height != null ? const TextStyle(height: 2.0) : null,
                  inputDecorationTheme: InputDecorationTheme(
                    errorStyle: const TextStyle(
                      color: AppColors.redColor,
                    ),
                    filled: true,
                    fillColor: fillColor ?? AppColors.whiteColor,
                    focusColor: fillColor ?? AppColors.whiteColor,
                    hoverColor: fillColor ?? AppColors.whiteColor,
                    contentPadding: height != null
                        ? EdgeInsets.symmetric(
                            vertical: (height! - 40) / 2, horizontal: 16)
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: AppColors.cardColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: AppColors.cardColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
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
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: AppColors.redColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                  dropdownMenuEntries: items
                      .map(
                        (item) => DropdownMenuEntry(
                          value: item,
                          label: item,
                        ),
                      )
                      .toList(),
                ),
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    state.errorText!,
                    style: const TextStyle(
                      color: AppColors.redColor,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
