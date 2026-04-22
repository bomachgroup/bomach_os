import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/icons.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

/// Thin wrapper over `ScaffoldMessenger` so callers write one line instead
/// of 6 lines of inline `SnackBar(...)`.
///
/// Usage:
/// ```dart
/// AppToast.success(context, 'Branch created');
/// AppToast.error(context, 'Failed to save');
/// AppToast.info(context, 'Syncing in the background');
/// ```
class AppToast {
  AppToast._();

  static void success(BuildContext context, String message,
      {Duration? duration, SnackBarAction? action}) {
    _show(
      context,
      message: message,
      icon: AppIcons.success,
      foreground: AppColors.success,
      background: AppColors.successSubtle,
      duration: duration,
      action: action,
    );
  }

  static void error(BuildContext context, String message,
      {Duration? duration, SnackBarAction? action}) {
    _show(
      context,
      message: message,
      icon: AppIcons.danger,
      foreground: AppColors.danger,
      background: AppColors.dangerSubtle,
      duration: duration,
      action: action,
    );
  }

  static void warning(BuildContext context, String message,
      {Duration? duration, SnackBarAction? action}) {
    _show(
      context,
      message: message,
      icon: AppIcons.warning,
      foreground: AppColors.warning,
      background: AppColors.warningSubtle,
      duration: duration,
      action: action,
    );
  }

  static void info(BuildContext context, String message,
      {Duration? duration, SnackBarAction? action}) {
    _show(
      context,
      message: message,
      icon: AppIcons.info,
      foreground: AppColors.info,
      background: AppColors.infoSubtle,
      duration: duration,
      action: action,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color foreground,
    required Color background,
    Duration? duration,
    SnackBarAction? action,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          duration: duration ?? const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: background,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.brMd,
            side: BorderSide(color: foreground.withValues(alpha: 0.3)),
          ),
          content: Row(
            children: [
              Icon(icon, color: foreground, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AppText.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          action: action,
        ),
      );
  }
}
