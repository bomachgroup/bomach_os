import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

/// A consistent section surface for the engineering and survey report editors.
class ReportEditorSection extends StatelessWidget {
  const ReportEditorSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.description,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final String? description;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted.withValues(alpha: 0.72),
          borderRadius: AppRadii.brMd,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: AppRadii.brSm,
                  ),
                  child: Icon(icon, size: 17, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: AppTextStyles.bodyMd
                              .copyWith(fontWeight: FontWeight.w700)),
                      if (description != null) ...[
                        const SizedBox(height: 2),
                        Text(description!,
                            style: AppTextStyles.bodySm
                                .copyWith(color: AppColors.textSecondary)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      );
}
