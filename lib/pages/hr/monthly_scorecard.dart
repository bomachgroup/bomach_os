import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/loading_skeleton.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/pages/hr/controller/monthly_scorecard_controller.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'models/monthly_scorecard_models.dart';

class MonthlyScorecardPage extends StatefulWidget {
  const MonthlyScorecardPage({super.key});

  @override
  State<MonthlyScorecardPage> createState() => _MonthlyScorecardPageState();
}

class _MonthlyScorecardPageState extends State<MonthlyScorecardPage> {
  final MonthlyScorecardController _controller =
      Get.put(MonthlyScorecardController());

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1200,
      header: PageHeader(
        title: 'Monthly Scorecard',
        subtitle:
            'Detailed performance breakdown for the selected month and year.',
        trailing: Obx(() => _buildFilters()),
      ),
      children: [
        Obx(() {
          if (_controller.isLoading.value) {
            return Column(
              children: [
                LoadingSkeleton.card(lines: 4),
                const SizedBox(height: 16),
                LoadingSkeleton.statRow(count: 4),
                const SizedBox(height: 16),
                LoadingSkeleton.listRows(count: 4),
              ],
            );
          }

          if (_controller.errorMessage.isNotEmpty) {
            return AppCard(
              padding: const EdgeInsets.all(32),
              child: EmptyState(
                icon: Iconsax.warning_2,
                title: 'Unable to load scorecard',
                subtitle: _controller.errorMessage.value,
                action: MyElevatedButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  icon: const Icon(Iconsax.refresh,
                      size: 16, color: AppColors.textOnPrimary),
                  child: 'Retry',
                  onTap: () => _controller.fetchScorecard(),
                ),
              ),
            );
          }

          final scorecard = _controller.scorecard.value;
          if (scorecard == null) {
            return AppCard(
              padding: const EdgeInsets.all(32),
              child: EmptyState.empty(
                title: 'No scorecard for this period',
                subtitle:
                    'Try selecting a different month or year to view the scorecard.',
              ),
            );
          }

          return _buildScorecardContent(scorecard);
        }),
      ],
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: 160,
          child: MyDropdown(
            hintText: 'Month',
            items: _monthNames,
            initialSelection: _monthNames[_controller.selectedMonth.value - 1],
            onChanged: (value) {
              if (value == null) return;
              final monthIndex = _monthNames.indexOf(value) + 1;
              _controller.changeMonth(monthIndex);
            },
          ),
        ),
        SizedBox(
          width: 130,
          child: MyDropdown(
            hintText: 'Year',
            items: List.generate(
              5,
              (i) => (DateTime.now().year - 2 + i).toString(),
            ),
            initialSelection: _controller.selectedYear.value.toString(),
            onChanged: (value) {
              if (value == null) return;
              _controller.changeYear(int.parse(value));
            },
          ),
        ),
      ],
    );
  }

  StatusTone _toneForScore(double score) {
    if (score >= 100) return StatusTone.success;
    if (score >= 75) return StatusTone.primary;
    if (score >= 50) return StatusTone.info;
    if (score >= 25) return StatusTone.warning;
    return StatusTone.danger;
  }

  Color _colorForTone(StatusTone tone) {
    switch (tone) {
      case StatusTone.success:
        return AppColors.success;
      case StatusTone.primary:
        return AppColors.primary;
      case StatusTone.info:
        return AppColors.info;
      case StatusTone.warning:
        return AppColors.warning;
      case StatusTone.danger:
        return AppColors.danger;
      case StatusTone.neutral:
        return AppColors.textSecondary;
    }
  }

  Widget _buildScorecardContent(MonthlyScorecard scorecard) {
    final monthName = _monthNames[scorecard.month - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildEmployeeCard(scorecard, monthName),
        const SizedBox(height: 16),
        _buildScoreCardsRow(scorecard),
        const SizedBox(height: 16),
        _buildPerformanceMetricsSection(scorecard),
        if (scorecard.notes.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildNotesSection(scorecard),
        ],
      ],
    );
  }

  Widget _buildEmployeeCard(MonthlyScorecard scorecard, String monthName) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.sm,
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryHover],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                scorecard.initials,
                style: AppText.h2.copyWith(color: AppColors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(scorecard.employeeName, style: AppText.h3),
                const SizedBox(height: 4),
                Text(scorecard.formattedLevel, style: AppText.bodySm),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Period', style: AppText.overline),
              const SizedBox(height: 2),
              Text(
                '$monthName ${scorecard.year}',
                style: AppText.label,
              ),
              if (scorecard.isAutoGenerated) ...[
                const SizedBox(height: 8),
                const StatusChip(
                  label: 'Auto-generated',
                  tone: StatusTone.info,
                  dense: true,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCardsRow(MonthlyScorecard scorecard) {
    final tone = _toneForScore(scorecard.overallScore);

    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 720;
      final big = _buildBigScoreCard(
        score: scorecard.overallScore.toStringAsFixed(0),
        label: 'Overall Score',
        tone: tone,
      );
      final smalls = [
        _buildSmallMetricCard(
          value: '${scorecard.targetAchievement.toStringAsFixed(1)}%',
          label: 'Target Achievement',
          icon: Iconsax.radar,
          accent: AppColors.warning,
        ),
        _buildSmallMetricCard(
          value: '#${scorecard.ranking}',
          label: 'Ranking',
          icon: Iconsax.chart_1,
          accent: AppColors.primary,
        ),
        _buildSmallMetricCard(
          value: scorecard.targetScore.toStringAsFixed(0),
          label: 'Target Score',
          icon: Iconsax.flag,
          accent: AppColors.success,
        ),
      ];

      if (isNarrow) {
        return Column(
          children: [
            big,
            const SizedBox(height: 12),
            for (int i = 0; i < smalls.length; i++) ...[
              smalls[i],
              if (i != smalls.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      }

      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: 180, child: big),
            const SizedBox(width: 16),
            for (int i = 0; i < smalls.length; i++) ...[
              Expanded(child: smalls[i]),
              if (i != smalls.length - 1) const SizedBox(width: 16),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildBigScoreCard({
    required String score,
    required String label,
    required StatusTone tone,
  }) {
    final accent = _colorForTone(tone);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent,
            Color.alphaBlend(
                AppColors.neutral900.withValues(alpha: 0.18), accent),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadii.brLg,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            score,
            style: AppText.displayLg.copyWith(
              color: AppColors.white,
              fontSize: 44,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppText.label.copyWith(color: AppColors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSmallMetricCard({
    required String value,
    required String label,
    required IconData icon,
    required Color accent,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppText.h3,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppText.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetricsSection(MonthlyScorecard scorecard) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Performance Metrics', style: AppText.h3),
          const SizedBox(height: 4),
          Text(
            'Achievement vs target across each tracked metric.',
            style: AppText.bodySm.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          if (scorecard.metrics.isEmpty)
            EmptyState.empty(
              title: 'No metrics recorded',
              subtitle: 'This scorecard has no performance metrics logged.',
              compact: true,
            )
          else
            Column(
              children: [
                for (int i = 0; i < scorecard.metrics.length; i++) ...[
                  _buildMetricRow(scorecard.metrics[i]),
                  if (i != scorecard.metrics.length - 1)
                    const SizedBox(height: 12),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(MonthlyScorecardMetric metric) {
    final achievement = metric.getAchievementPercentage();
    final tone = _toneForScore(achievement);
    final color = _colorForTone(tone);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brMd,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  metric.metricName,
                  style: AppText.label.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 12),
              StatusChip(
                label: '${achievement.toStringAsFixed(0)}%',
                tone: tone,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: AppRadii.brXs,
            child: LinearProgressIndicator(
              value: (achievement / 100).clamp(0.0, 1.0),
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${metric.currentValue.toStringAsFixed(1)}${metric.unit} / ${metric.targetValue.toStringAsFixed(0)}${metric.unit}',
            style: AppText.bodySm.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(MonthlyScorecard scorecard) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Iconsax.note_2, size: 18, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Text('Notes', style: AppText.h4),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            scorecard.notes,
            style: AppText.bodyMd.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
