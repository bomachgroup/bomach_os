import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../controllers/performance_analytics_controller.dart';

class PerformanceAnalyticsTab extends StatelessWidget {
  final int roleId;

  const PerformanceAnalyticsTab({super.key, required this.roleId});

  @override
  Widget build(BuildContext context) {
    final tag = 'role_detail_$roleId';
    if (!Get.isRegistered<PerformanceAnalyticsController>(tag: tag)) {
      Get.put(PerformanceAnalyticsController(), tag: tag)
        ..scopedRoleId = roleId
        ..fetchAnalytics(roleId: roleId);
    }

    return GetBuilder<PerformanceAnalyticsController>(
      tag: tag,
      builder: (ctrl) {
        return Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ctrl.employees.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.chart, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text('No employees assigned to this role.',
                        style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildSummaryRow(ctrl),
              const SizedBox(height: 24),
              Text('Individual Performance',
                  style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ...ctrl.perfData.map((pd) => _buildEmployeeCard(pd)),
            ],
          );
        });
      },
    );
  }

  Widget _buildSummaryRow(PerformanceAnalyticsController ctrl) {
    final avg = ctrl.aggregateAvgScore.value;
    final avgColor = avg >= 85
        ? AppColors.success
        : avg >= 70
            ? AppColors.warning
            : AppColors.danger;

  return Row(
      children: [
        _statCard(Iconsax.people, 'Total Employees', ctrl.totalEmployees.value.toString(),
            AppColors.primary),
        const SizedBox(width: 12),
        _statCard(Iconsax.star, 'Avg Score', '${avg.toStringAsFixed(0)}%', avgColor),
        const SizedBox(width: 12),
        _statCard(Iconsax.document, 'Reviews', ctrl.totalReviews.value.toString(),
            AppColors.info),
      ],
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value,
                style: AppTextStyles.bodyLg.copyWith(
                    fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(EmployeePerfData pd) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Center(
              child: Text(
                pd.employee.fullName.isNotEmpty
                    ? pd.employee.fullName.split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join()
                    : '??',
                style: AppTextStyles.bodySm.copyWith(
                    fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pd.employee.fullName,
                    style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                if (pd.employee.designation != null)
                  Text(pd.employee.designation!,
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (pd.avgScore != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _scoreBgColor(pd.avgScore!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${pd.avgScore!.toStringAsFixed(0)}%',
                  style: AppTextStyles.bodySm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _scoreTextColor(pd.avgScore!))),
            ),
        ],
      ),
    );
  }

  Color _scoreBgColor(double score) {
    if (score >= 85) return AppColors.success.withValues(alpha: 0.1);
    if (score >= 70) return AppColors.warning.withValues(alpha: 0.1);
    return AppColors.danger.withValues(alpha: 0.1);
  }

  Color _scoreTextColor(double score) {
    if (score >= 85) return AppColors.success;
    if (score >= 70) return AppColors.warning;
    return AppColors.danger;
  }
}
