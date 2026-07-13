import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controllers/role_risk_controller.dart';

class ComplianceDashboardPage extends StatelessWidget {
  const ComplianceDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(RoleRiskController());
    ctrl.fetchComplianceSummary();

    return PageScaffold(
      maxContentWidth: 1200,
      header: PageHeader(
        title: 'Compliance Dashboard',
        subtitle: 'Role compliance and risk obligations overview',
      ),
      children: [
        Obx(() {
          if (ctrl.isLoading.value) {
            return AppCard(
              padding: const EdgeInsets.all(24),
              child: LoadingSkeleton.listRows(count: 4),
            );
          }
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatCard(
                icon: Iconsax.shield_tick,
                label: 'Total Obligations',
                value: '${ctrl.totalCount.value}',
                color: AppColors.primary,
              ),
              _StatCard(
                icon: Iconsax.tick_circle,
                label: 'Compliant',
                value: '${ctrl.compliantCount.value}',
                color: AppColors.success,
              ),
              _StatCard(
                icon: Iconsax.danger,
                label: 'At Risk',
                value: '${ctrl.atRiskCount.value}',
                color: AppColors.warning,
              ),
              _StatCard(
                icon: Iconsax.slash,
                label: 'Overdue',
                value: '${ctrl.overdueCount.value}',
                color: AppColors.danger,
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: AppCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value,
                    style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text(label,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
