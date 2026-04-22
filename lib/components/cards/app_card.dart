import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/shadows.dart';
import 'package:flutter/material.dart';

/// Base card surface for Bomach OS.
///
/// Renders a consistent radius, border, shadow, and padding. Higher-level
/// cards (stats, modules, real-estate, etc.) should compose over this.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.showBorder = true,
    this.elevation = AppCardElevation.sm,
    this.width,
    this.height,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final bool showBorder;
  final AppCardElevation elevation;
  final double? width;
  final double? height;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadii.brMd;
    final shadow = switch (elevation) {
      AppCardElevation.none => const <BoxShadow>[],
      AppCardElevation.sm => AppShadows.sm,
      AppCardElevation.md => AppShadows.md,
      AppCardElevation.lg => AppShadows.lg,
    };

    final decoration = BoxDecoration(
      color: backgroundColor ?? AppColors.surface,
      borderRadius: radius,
      border: showBorder
          ? Border.all(color: borderColor ?? AppColors.borderSubtle)
          : null,
      boxShadow: shadow,
    );

    final content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: decoration,
      clipBehavior: clipBehavior,
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: content,
      ),
    );
  }
}

enum AppCardElevation { none, sm, md, lg }
