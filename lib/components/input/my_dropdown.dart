import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Reusable dropdown with the same visual language as [MyTextFormField]:
/// 12 px radius, slate border, slate surface fill, primary focus ring, and
/// a softly-elevated menu with hover + selected states.
///
/// API is backwards-compatible with the previous implementation — older call
/// sites (branch dialog, estate dialog, etc.) pass `hintText` / `items` /
/// `onChanged` and continue to work unchanged.
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
    this.spaceBetweenText,
    this.initialSelection,
    this.enabled = true,
    this.leading,
  });

  final List<String> items;
  final String? title;
  final TextEditingController? controller;
  final String hintText;
  final String? initialSelection;
  final Function(String? value)? onChanged;
  final String? Function(String?)? validator;
  final Color? fillColor;
  final double? height;
  final double? width;
  final double? spaceBetweenText;
  final bool enabled;

  /// Optional leading icon inside the field (e.g. flag emoji, globe icon).
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final effectiveFill = fillColor ??
        (enabled ? AppColors.surface : AppColors.surfaceMuted);

    return FormField<String>(
      validator: validator,
      initialValue: initialSelection,
      builder: (FormFieldState<String> state) {
        return LayoutBuilder(builder: (context, constraints) {
          final actualWidth = width ?? constraints.maxWidth;
          final hasError = state.hasError;

          return SizedBox(
            width: actualWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  MyText(
                    title ?? '',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                SizedBox(
                  height: spaceBetweenText ?? (title != null ? 8 : 0),
                ),
                SizedBox(
                  height: height ?? 50,
                  child: DropdownMenu<String>(
                    enabled: enabled,
                    controller: controller,
                    initialSelection: initialSelection,
                    leadingIcon: leading,
                    trailingIcon: const Icon(
                      Iconsax.arrow_down_1,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    selectedTrailingIcon: const Icon(
                      Iconsax.arrow_up_3,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    width: actualWidth,
                    menuHeight: media.height * 0.4,
                    hintText: hintText,
                    requestFocusOnTap: false,
                    textStyle: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    onSelected: (value) {
                      if (controller != null) {
                        controller?.text = value?.toString() ?? '';
                      }
                      state.didChange(value);
                      if (onChanged != null) {
                        onChanged!(value);
                      }
                    },
                    menuStyle: MenuStyle(
                      maximumSize: WidgetStateProperty.all(
                        Size(actualWidth, 320),
                      ),
                      shape: WidgetStateProperty.all(
                        const RoundedRectangleBorder(
                          borderRadius: AppRadii.brMd,
                        ),
                      ),
                      elevation: WidgetStateProperty.all(6),
                      shadowColor: WidgetStateProperty.all(
                        Colors.black.withValues(alpha: 0.08),
                      ),
                      backgroundColor:
                          WidgetStateProperty.all(AppColors.surface),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 6),
                      ),
                      side: WidgetStateProperty.all(
                        const BorderSide(color: AppColors.borderSubtle),
                      ),
                      visualDensity: VisualDensity.comfortable,
                      surfaceTintColor:
                          WidgetStateProperty.all(Colors.transparent),
                    ),
                    inputDecorationTheme: InputDecorationTheme(
                      isDense: true,
                      filled: true,
                      fillColor: effectiveFill,
                      focusColor: effectiveFill,
                      hoverColor: effectiveFill,
                      hintStyle: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w400,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      errorStyle: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 12,
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: AppRadii.brMd,
                        borderSide: BorderSide(color: AppColors.borderSubtle),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadii.brMd,
                        borderSide: BorderSide(
                          color: hasError
                              ? AppColors.danger
                              : AppColors.borderSubtle,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadii.brMd,
                        borderSide: BorderSide(
                          color: hasError
                              ? AppColors.danger
                              : AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      errorBorder: const OutlineInputBorder(
                        borderRadius: AppRadii.brMd,
                        borderSide:
                            BorderSide(color: AppColors.danger, width: 1.5),
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderRadius: AppRadii.brMd,
                        borderSide:
                            BorderSide(color: AppColors.danger, width: 1.5),
                      ),
                    ),
                    dropdownMenuEntries: items
                        .map(
                          (item) => DropdownMenuEntry<String>(
                            value: item,
                            label: item,
                            style: ButtonStyle(
                              minimumSize: WidgetStateProperty.all(
                                Size(actualWidth, 40),
                              ),
                              maximumSize: WidgetStateProperty.all(
                                Size(actualWidth, 40),
                              ),
                              padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                              ),
                              backgroundColor:
                                  WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.hovered)) {
                                  return AppColors.primarySubtle;
                                }
                                if (states.contains(WidgetState.focused)) {
                                  return AppColors.primarySubtle;
                                }
                                return Colors.transparent;
                              }),
                              foregroundColor:
                                  WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.hovered) ||
                                    states.contains(WidgetState.focused)) {
                                  return AppColors.primary;
                                }
                                return AppColors.textPrimary;
                              }),
                              textStyle: WidgetStateProperty.all(
                                AppTextStyles.bodyMd.copyWith(
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              animationDuration:
                                  const Duration(milliseconds: 120),
                              overlayColor: WidgetStateProperty.all(
                                Colors.transparent,
                              ),
                              shape: WidgetStateProperty.all(
                                const RoundedRectangleBorder(
                                  borderRadius: AppRadii.brSm,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                if (hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0, left: 4.0),
                    child: Text(
                      state.errorText ?? '',
                      style: const TextStyle(
                        color: AppColors.danger,
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
