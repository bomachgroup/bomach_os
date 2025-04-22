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
  final double? width;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    // Create a key to get the width of the container
    final containerKey = GlobalKey();

    return FormField<String>(
      validator: validator,
      builder: (FormFieldState<String> state) {
        // Use LayoutBuilder to get the parent's constraints
        return LayoutBuilder(builder: (context, constraints) {
          // The actual width we should use (from constraints if width is null)
          final actualWidth = width ?? constraints.maxWidth;

          return SizedBox(
            width: actualWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title ?? '',
                    style: AppText.black_400_16,
                  ),
                Container(
                  key: containerKey,
                  height: height,
                  decoration: !state.hasError
                      ? null
                      : BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border:
                              Border.all(color: AppColors.redColor, width: 1),
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
                    width: actualWidth,
                    menuHeight: media.height * 0.6,
                    hintText: hintText,
                    textStyle:
                        height != null ? const TextStyle(height: 2.0) : null,
                    menuStyle: MenuStyle(
                      fixedSize: WidgetStateProperty.all(
                        Size(actualWidth, 250),
                      ),
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      )),
                      elevation: WidgetStateProperty.all(8),
                      shadowColor: WidgetStateProperty.all(
                          Colors.black.withOpacity(0.1)),
                      backgroundColor: WidgetStateProperty.all(
                          fillColor ?? AppColors.greyBg),
                      padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 8)),
                      side: WidgetStateProperty.all(BorderSide(
                          color: Colors.grey.withOpacity(0.2), width: 1)),
                      visualDensity: VisualDensity.comfortable,
                      surfaceTintColor:
                          WidgetStateProperty.all(Colors.transparent),
                    ),
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
                            style: ButtonStyle(
                              // Control the width of individual items in the menu
                              minimumSize: WidgetStateProperty.all(Size.zero),
                              // Add horizontal padding but keep vertical compact
                              padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              // Change background color on hover
                              backgroundColor:
                                  WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.hovered)) {
                                  return AppColors.blueColor.withOpacity(0.05);
                                }
                                return Colors.transparent;
                              }),
                              // Text style for the items
                              textStyle: WidgetStateProperty.all(
                                const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black87,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              // Smooth transition effect
                              animationDuration:
                                  const Duration(milliseconds: 150),
                              // Show a divider between items if desired
                              overlayColor:
                                  WidgetStateProperty.all(Colors.transparent),
                            ),
                            // leadingIcon: item.contains("Premium")
                            //     ? const Icon(Icons.star,
                            //         size: 16, color: Colors.amber)
                            //     : null,
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
        });
      },
    );
  }
}
