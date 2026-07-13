import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/role_model.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class OrgChartTab extends StatelessWidget {
  final Role role;
  final List<Role> allRoles;

  const OrgChartTab({super.key, required this.role, required this.allRoles});

  @override
  Widget build(BuildContext context) {
    final reportsTo = allRoles.where((r) => r.id == role.reportsToRoleId).firstOrNull;
    final directReports = allRoles
        .where((r) => role.directReportRoleIds.contains(r.id))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reportsTo != null) ...[
            Text('Reports To', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Container(
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
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Iconsax.arrow_up, color: AppColors.warning, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(reportsTo.name,
                            style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                        Text('Superior role',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (directReports.isNotEmpty) ...[
            Text('Direct Reports (${directReports.length})', style: AppTextStyles.label),
            const SizedBox(height: 8),
            ...directReports.map((r) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
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
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Iconsax.arrow_down, color: AppColors.info, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.name,
                                style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                            Text('Reports to this role',
                                style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          if (reportsTo == null && directReports.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.hierarchy, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text('No reporting relationships defined.',
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
