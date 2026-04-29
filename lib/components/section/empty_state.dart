import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/icons.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

/// Placeholder for empty lists, tables, and sections.
///
/// Replaces silent empty `Column()`s with a clear icon + title + optional
/// subtitle and action. Pass [compact]: true for inline usage inside cards
/// or small panels.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
    this.compact = false,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;
  final bool compact;

  /// Preset for empty list/table results.
  factory EmptyState.noResults({
    Key? key,
    String title = 'No results found',
    String? subtitle = 'Try adjusting your filters or search terms.',
    Widget? action,
    bool compact = false,
  }) =>
      EmptyState(
        key: key,
        title: title,
        subtitle: subtitle,
        icon: AppIcons.emptySearch,
        action: action,
        compact: compact,
      );

  /// Preset for "nothing here yet" states.
  factory EmptyState.empty({
    Key? key,
    required String title,
    String? subtitle,
    Widget? action,
    bool compact = false,
  }) =>
      EmptyState(
        key: key,
        title: title,
        subtitle: subtitle,
        icon: AppIcons.emptyBox,
        action: action,
        compact: compact,
      );

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 28.0 : 36.0;
    final iconPad = compact ? 12.0 : 16.0;
    final verticalPad = compact ? 24.0 : 48.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: verticalPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(iconPad),
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: AppRadii.brLg,
            ),
            child: Icon(
              icon ?? AppIcons.emptyBox,
              size: iconSize,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: compact ? 12 : 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: compact ? AppTextStyles.h4 : AppTextStyles.h3,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
          if (action != null) ...[
            SizedBox(height: compact ? 12 : 20),
            action!,
          ],
        ],
      ),
    );
  }
}
