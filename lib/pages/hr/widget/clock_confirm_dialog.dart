import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../components/button/my_elevated_button.dart';
import '../../../components/button/my_outlined_button.dart';
import '../../../src/constants/colors.dart';
import '../../../src/constants/textstyle.dart';
import '../../../src/utils/wat_time.dart';

/// Confirmation dialog shown before clocking in or clocking out to prevent
/// accidental taps.
class ClockConfirmDialog extends StatelessWidget {
  final bool isClockIn;
  final String? workspaceName;
  final DateTime? currentTime;

  const ClockConfirmDialog({
    super.key,
    required this.isClockIn,
    this.workspaceName,
    this.currentTime,
  });

  /// Convenience helper to display the dialog and return `true` if confirmed.
  static Future<bool?> show(
    BuildContext context, {
    required bool isClockIn,
    String? workspaceName,
    DateTime? currentTime,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ClockConfirmDialog(
        isClockIn: isClockIn,
        workspaceName: workspaceName,
        currentTime: currentTime,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = isClockIn ? AppColors.success : AppColors.primary;
    final actionLabel = isClockIn ? 'Clock In' : 'Clock Out';
    final actionIcon = isClockIn ? Iconsax.login_1 : Iconsax.logout_1;
    final displayTime =
        currentTime != null ? WatTime.toWat(currentTime!) : WatTime.now();
    final timeStr = DateFormat('hh:mm a').format(displayTime);
    final dateStr = DateFormat('EEEE, dd-MM-yyyy').format(displayTime);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular icon badge
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(actionIcon, color: themeColor, size: 28),
                ),
              ),
              const SizedBox(height: 18),

              // Title
              Text(
                'Confirm $actionLabel',
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                isClockIn
                    ? 'Are you sure you want to clock in now? Your attendance, time, and location will be recorded.'
                    : 'Are you sure you want to clock out now? This will record your departure time and end your shift for today.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Time & Workspace Details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Iconsax.clock,
                            size: 16, color: AppColors.neutral500),
                        const SizedBox(width: 8),
                        Text(
                          'Time (WAT):',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.neutral500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            timeStr,
                            textAlign: TextAlign.end,
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.neutral900,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Iconsax.calendar_1,
                            size: 16, color: AppColors.neutral500),
                        const SizedBox(width: 8),
                        Text(
                          'Date:',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.neutral500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dateStr,
                            textAlign: TextAlign.end,
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.neutral900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (workspaceName != null &&
                        workspaceName!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Iconsax.location,
                              size: 16, color: AppColors.neutral500),
                          const SizedBox(width: 8),
                          Text(
                            'Workspace:',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.neutral500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              workspaceName!.trim(),
                              textAlign: TextAlign.end,
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.neutral900,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: MyOutlinedButton(
                      child: 'Cancel',
                      height: 44,
                      textColor: AppColors.textSecondary,
                      borderColor: AppColors.borderStrong,
                      onTap: () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MyElevatedButton(
                      child: actionLabel,
                      height: 44,
                      bgColor: themeColor,
                      onTap: () => Navigator.pop(context, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
