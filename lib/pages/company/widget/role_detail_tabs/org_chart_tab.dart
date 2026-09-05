import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/role_reporting_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/role_reporting_controller.dart';

class OrgChartTab extends StatelessWidget {
  final int roleId;

  const OrgChartTab({super.key, required this.roleId});

  @override
  Widget build(BuildContext context) {
    final tag = 'role_reporting_$roleId';
    if (!Get.isRegistered<RoleReportingController>(tag: tag)) {
      Get.put(RoleReportingController(), tag: tag).fetch(roleId);
    }

    return GetX<RoleReportingController>(
      tag: tag,
      builder: (ctrl) {
        if (ctrl.isLoading.value && ctrl.tree.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.errorMessage.value.isNotEmpty) {
          return _message(
            icon: Iconsax.warning_2,
            title: 'Error loading reporting relationships',
            body: ctrl.errorMessage.value,
            action: TextButton.icon(
              onPressed: () => ctrl.fetch(roleId),
              icon: const Icon(Iconsax.refresh),
              label: const Text('Retry'),
            ),
          );
        }

        final tree = ctrl.tree.value;
        if (tree == null ||
            (tree.reportsTo == null && tree.directReports.isEmpty)) {
          return _message(
            icon: Iconsax.hierarchy,
            title: 'No reporting relationships defined.',
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (tree.reportsTo != null) ...[
                const Text('Reports To', style: AppTextStyles.label),
                const SizedBox(height: 8),
                _roleCard(
                  node: tree.reportsTo!,
                  icon: Iconsax.arrow_up,
                  color: AppColors.warning,
                  subtitle: 'Superior role',
                ),
                const SizedBox(height: 16),
              ],
              if (tree.directReports.isNotEmpty) ...[
                Text(
                  'Direct Reports (${tree.directReports.length})',
                  style: AppTextStyles.label,
                ),
                const SizedBox(height: 8),
                ...tree.directReports.map(
                  (node) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _roleCard(
                      node: node,
                      icon: Iconsax.arrow_down,
                      color: AppColors.info,
                      subtitle: 'Reports to this role',
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _roleCard({
    required RoleReportingNode node,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
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
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.name,
                  style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _message({
    required IconData icon,
    required String title,
    String? body,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
            ),
            if (body != null) ...[
              const SizedBox(height: 8),
              Text(
                body,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 12), action],
          ],
        ),
      ),
    );
  }
}
