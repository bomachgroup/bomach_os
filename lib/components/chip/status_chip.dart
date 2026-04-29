import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

/// Tonal pill used for statuses (active / pending / failed / etc.).
///
/// Replaces the scattered `Container + BoxDecoration + Text` status badges
/// across branches, legal, workspace, CRM, finance.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.tone = StatusTone.neutral,
    this.icon,
    this.dense = false,
  });

  final String label;
  final StatusTone tone;
  final IconData? icon;
  final bool dense;

  /// Infer tone from a status string like "Active", "Pending", "Rejected".
  /// Falls back to `neutral` when nothing matches.
  factory StatusChip.fromStatus(
    String status, {
    Key? key,
    IconData? icon,
    bool dense = false,
  }) {
    return StatusChip(
      key: key,
      label: status,
      tone: _toneFromStatus(status),
      icon: icon,
      dense: dense,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette(tone);
    final verticalPad = dense ? 2.0 : 4.0;
    final horizontalPad = dense ? 8.0 : 10.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPad,
        vertical: verticalPad,
      ),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: AppRadii.brPill,
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 12 : 14, color: palette.foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: palette.foreground,
              fontWeight: FontWeight.w600,
              fontSize: dense ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }

  _ChipPalette _palette(StatusTone tone) {
    switch (tone) {
      case StatusTone.success:
        return const _ChipPalette(
          background: AppColors.successSubtle,
          foreground: AppColors.success,
          border: AppColors.successSubtle,
        );
      case StatusTone.warning:
        return const _ChipPalette(
          background: AppColors.warningSubtle,
          foreground: AppColors.warning,
          border: AppColors.warningSubtle,
        );
      case StatusTone.danger:
        return const _ChipPalette(
          background: AppColors.dangerSubtle,
          foreground: AppColors.danger,
          border: AppColors.dangerSubtle,
        );
      case StatusTone.info:
        return const _ChipPalette(
          background: AppColors.infoSubtle,
          foreground: AppColors.info,
          border: AppColors.infoSubtle,
        );
      case StatusTone.primary:
        return const _ChipPalette(
          background: AppColors.primarySubtle,
          foreground: AppColors.primary,
          border: AppColors.primarySubtle,
        );
      case StatusTone.neutral:
        return const _ChipPalette(
          background: AppColors.surfaceMuted,
          foreground: AppColors.textSecondary,
          border: AppColors.borderSubtle,
        );
    }
  }
}

enum StatusTone { success, warning, danger, info, primary, neutral }

class _ChipPalette {
  const _ChipPalette({
    required this.background,
    required this.foreground,
    required this.border,
  });
  final Color background;
  final Color foreground;
  final Color border;
}

StatusTone _toneFromStatus(String status) {
  final s = status.trim().toLowerCase();
  const success = {
    'active',
    'approved',
    'completed',
    'paid',
    'success',
    'successful',
    'done',
    'resolved',
    'verified',
    'passed',
    'settled',
    'live',
    'published',
    'operational',
  };
  const warning = {
    'pending',
    'review',
    'in review',
    'review due',
    'in progress',
    'processing',
    'draft',
    'overdue',
    'expiring',
    'on hold',
    'scheduled',
    'partial',
  };
  const danger = {
    'rejected',
    'failed',
    'cancelled',
    'canceled',
    'closed',
    'terminated',
    'expired',
    'inactive',
    'blocked',
    'suspended',
    'error',
    'unpaid',
  };
  const info = {
    'new',
    'submitted',
    'queued',
    'invited',
    'upcoming',
  };

  if (success.contains(s)) return StatusTone.success;
  if (warning.contains(s)) return StatusTone.warning;
  if (danger.contains(s)) return StatusTone.danger;
  if (info.contains(s)) return StatusTone.info;
  return StatusTone.neutral;
}
