import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/helper/responsive_breakpoints.dart';
import 'package:flutter/material.dart';

/// Canonical module-page header.
///
/// Replaces the bespoke title/subtitle/action row that every module hand-rolls.
/// On mobile the `trailing` action drops below the titles so it stays tappable.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.breadcrumbs,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final List<Widget>? breadcrumbs;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (breadcrumbs != null && breadcrumbs!.isNotEmpty) ...[
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: breadcrumbs!,
          ),
          const SizedBox(height: 8),
        ],
        Text(
          title,
          style: isMobile ? AppTextStyles.h2 : AppTextStyles.displayMd,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(child: titleBlock),
            ],
          ),
          if (trailing != null) ...[
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: trailing!),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 16),
        ],
        Expanded(child: titleBlock),
        if (trailing != null) ...[
          const SizedBox(width: 16),
          trailing!,
        ],
      ],
    );
  }
}
