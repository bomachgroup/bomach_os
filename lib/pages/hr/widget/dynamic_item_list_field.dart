import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Helper utilities for serializing and deserializing itemized work report fields.
class WorkReportFormatUtils {
  /// Serializes a list of [TextEditingController]s into a newline-separated string.
  /// All lines are trimmed and empty or whitespace-only lines are eliminated.
  /// Returns `null` if no non-empty items exist.
  static String? serializeItems(List<TextEditingController> controllers) {
    final items = controllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
    if (items.isEmpty) return null;
    return items.join('\n');
  }

  /// Parses a newline-separated string into a list of non-empty, trimmed items.
  static List<String> parseItems(String? raw) {
    if (raw == null || raw.trim().isEmpty) return [];
    return raw
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }
}

/// A form component that manages an itemized list of text fields with
/// a number badge, a `+` button to add new entries beneath, a delete button to remove rows,
/// and a configurable max limit.
class DynamicItemListField extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String hintText;
  final List<TextEditingController> controllers;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final int maxItems;
  final bool readOnly;

  const DynamicItemListField({
    super.key,
    required this.title,
    this.subtitle,
    required this.hintText,
    required this.controllers,
    required this.onAdd,
    required this.onRemove,
    this.maxItems = 10,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Text(
                '${controllers.length}/$maxItems',
                style: AppTextStyles.bodySm.copyWith(
                  color: controllers.length >= maxItems
                      ? AppColors.warning
                      : AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controllers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final isLast = index == controllers.length - 1;
            final canAdd = isLast && controllers.length < maxItems && !readOnly;
            final canRemove = controllers.length > 1 && !readOnly;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Number badge
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: AppTextStyles.bodySm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Input text field
                Expanded(
                  child: TextFormField(
                    controller: controllers[index],
                    readOnly: readOnly,
                    textInputAction: isLast
                        ? (controllers.length < maxItems
                            ? TextInputAction.next
                            : TextInputAction.done)
                        : TextInputAction.next,
                    onFieldSubmitted: (val) {
                      if (canAdd) {
                        onAdd();
                      }
                    },
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 11,
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                      border: const OutlineInputBorder(
                        borderRadius: AppRadii.brMd,
                        borderSide: BorderSide(color: AppColors.borderSubtle),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: AppRadii.brMd,
                        borderSide: BorderSide(color: AppColors.borderSubtle),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: AppRadii.brMd,
                        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                ),
                // Action buttons
                if (canRemove || canAdd) ...[
                  const SizedBox(width: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (canRemove)
                        IconButton(
                          icon: const Icon(Iconsax.trash, size: 18),
                          color: AppColors.textMuted,
                          hoverColor: AppColors.danger.withValues(alpha: 0.1),
                          splashRadius: 18,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: EdgeInsets.zero,
                          tooltip: 'Remove item',
                          onPressed: () => onRemove(index),
                        ),
                      if (canAdd)
                        IconButton(
                          icon: const Icon(Iconsax.add_circle, size: 22),
                          color: AppColors.primary,
                          hoverColor: AppColors.primary.withValues(alpha: 0.1),
                          splashRadius: 18,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: EdgeInsets.zero,
                          tooltip: 'Add new item',
                          onPressed: onAdd,
                        ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
