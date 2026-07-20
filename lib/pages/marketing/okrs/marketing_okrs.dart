import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/pages/marketing/controllers/marketing_module_controller.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarketingOkrs extends StatelessWidget {
  const MarketingOkrs({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MarketingModuleController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText('OKRs & Targets', style: AppTextStyles.displayLg),
        const SizedBox(height: 4),
        const MyText(
          'Track objectives, key results, and weekly targets',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.textMuted),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOkrSection(c),
                const SizedBox(height: 24),
                _buildTargetsTable(c),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOkrSection(MarketingModuleController c) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: c.okrs.map((okr) {
        final avgProgress = okr.keyResults.isNotEmpty
            ? okr.keyResults.map((kr) => kr.percentage).reduce((a, b) => a + b) / okr.keyResults.length
            : 0.0;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      okr.objective,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: avgProgress >= 70 ? AppColors.successSubtle : AppColors.warningSubtle,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${avgProgress.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: avgProgress >= 70 ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...okr.keyResults.map((kr) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(kr.label, style: const TextStyle(fontSize: 13)),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: kr.percentage / 100,
                              minHeight: 6,
                              backgroundColor: AppColors.borderSubtle,
                              valueColor: AlwaysStoppedAnimation(kr.color),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${kr.percentage}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: kr.color,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      }).toList(),
    ));
  }

  Widget _buildTargetsTable(MarketingModuleController c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Targets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('Metric', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted))),
                Expanded(flex: 2, child: Text('Target', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted))),
                Expanded(flex: 2, child: Text('Actual', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted))),
                Expanded(flex: 2, child: Text('%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted))),
                Expanded(flex: 2, child: Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Column(
            children: c.targets.map((t) {
              final status = t.percentage >= 90 ? 'On track' : t.percentage >= 70 ? 'Close' : 'Behind';
              final statusColor = t.percentage >= 90
                  ? AppColors.success
                  : t.percentage >= 70
                      ? AppColors.warning
                      : AppColors.danger;
              return Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(t.label, style: const TextStyle(fontSize: 13))),
                    Expanded(flex: 2, child: Text(t.target, style: const TextStyle(fontSize: 13))),
                    Expanded(flex: 2, child: Text(t.actual, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                    Expanded(flex: 2, child: Text('${t.percentage}%', style: TextStyle(fontSize: 13, color: t.color, fontWeight: FontWeight.w600))),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: statusColor)),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }
}
