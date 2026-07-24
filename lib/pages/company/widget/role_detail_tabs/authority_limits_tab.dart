import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/authority_limit_model.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AuthorityLimitsTab extends StatelessWidget {
  final int roleId;
  final List<AuthorityLimit> limits;

  const AuthorityLimitsTab({super.key, required this.roleId, this.limits = const []});

  @override
  Widget build(BuildContext context) {
    if (limits.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Iconsax.lock, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text('No authority limits defined for this role.',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      itemCount: limits.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final limit = limits[index];
        final amountText = limit.maxAmount != null
            ? '${limit.currency ?? 'NGN'} ${limit.maxAmount}'
            : 'No Limit';
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Iconsax.shield, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${limit.resource.toUpperCase()} : ${limit.action.toUpperCase()}',
                      style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      amountText,
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                    ),
                    if (limit.approvalLevel != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Approval Level: ${limit.approvalLevel}',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
