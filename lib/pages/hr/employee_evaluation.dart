import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/loading_skeleton.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/pages/hr/controller/employee_evaluation_controller.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'models/monthly_scorecard_models.dart';

class EmployeeEvaluationPage extends StatefulWidget {
  const EmployeeEvaluationPage({super.key});

  @override
  State<EmployeeEvaluationPage> createState() => _EmployeeEvaluationPageState();
}

class _EmployeeEvaluationPageState extends State<EmployeeEvaluationPage> {
  final EmployeeEvaluationController _controller =
      Get.put(EmployeeEvaluationController());
  final TextEditingController _commentsController = TextEditingController();

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
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: const PageHeader(
        title: 'Employee Evaluation',
        subtitle:
            'Review monthly performance scorecards and submit evaluation decisions.',
      ),
      children: [
        // Filters row
        Obx(() => _buildFiltersRow()),

        // Content
        Obx(() {
          if (_controller.isLoading.value) {
            return LoadingSkeleton.card(lines: 6);
          }

          if (_controller.errorMessage.isNotEmpty) {
            return AppCard(
              padding: const EdgeInsets.all(32),
              child: EmptyState(
                icon: Iconsax.warning_2,
                title: 'Unable to load evaluation',
                subtitle: _controller.errorMessage.value,
                action: MyElevatedButton(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
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
                    'Try selecting a different month or year to view an evaluation.',
              ),
            );
          }

          return _buildEvaluationContent(scorecard);
        }),
      ],
    );
  }

  Widget _buildFiltersRow() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: Row(
        children: [
          Expanded(
            child: MyDropdown(
              title: 'Month',
              hintText: 'Select month',
              items: _monthNames,
              initialSelection:
                  _monthNames[_controller.selectedMonth.value - 1],
              onChanged: (value) {
                if (value == null) return;
                final monthIndex = _monthNames.indexOf(value) + 1;
                _controller.changeMonth(monthIndex);
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: MyDropdown(
              title: 'Year',
              hintText: 'Select year',
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
      ),
    );
  }

  Widget _buildEvaluationContent(MonthlyScorecard scorecard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildEmployeeInfoCard(scorecard),
        const SizedBox(height: 24),
        _buildPerformanceScoresSection(scorecard),
        const SizedBox(height: 24),
        _buildKPIReviewSection(scorecard),
        const SizedBox(height: 24),
        _buildManagerCommentsSection(),
        const SizedBox(height: 24),
        _buildRecommendationSection(),
        const SizedBox(height: 24),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildEmployeeInfoCard(MonthlyScorecard scorecard) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.sm,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.primarySubtle,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                scorecard.initials,
                style: AppText.h4.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(scorecard.employeeName, style: AppText.h4),
                const SizedBox(height: 4),
                Text(
                  'Level: ${scorecard.formattedLevel}',
                  style: AppText.bodySm,
                ),
                const SizedBox(height: 2),
                Text(
                  'Period: ${_monthNames[scorecard.month - 1]} ${scorecard.year}',
                  style: AppText.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Overall Score',
                  style: AppText.overline
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(
                '${scorecard.overallScore.toStringAsFixed(1)}%',
                style: AppText.h2.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 6),
              StatusChip(
                label: 'Rank #${scorecard.ranking}',
                tone: _toneForRank(scorecard.ranking),
                dense: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  StatusTone _toneForRank(int rank) {
    switch (rank) {
      case 1:
        return StatusTone.success;
      case 2:
        return StatusTone.primary;
      case 3:
        return StatusTone.warning;
      default:
        return StatusTone.neutral;
    }
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

  Widget _buildPerformanceScoresSection(MonthlyScorecard scorecard) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Performance Scores', style: AppText.h3),
          const SizedBox(height: 4),
          Text(
            'Breakdown of evaluation metrics for this period.',
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
                  _buildScoreRow(scorecard.metrics[i]),
                  if (i != scorecard.metrics.length - 1)
                    const Divider(
                        height: 24, color: AppColors.borderSubtle),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(MonthlyScorecardMetric metric) {
    final achievement = metric.getAchievementPercentage();
    final tone = _toneForScore(achievement);
    final color = _colorForTone(tone);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                metric.metricName,
                style: AppText.label,
              ),
            ),
            const SizedBox(width: 12),
            StatusChip(
              label: '${metric.currentValue.toStringAsFixed(1)}%',
              tone: tone,
              dense: true,
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: AppRadii.brXs,
          child: LinearProgressIndicator(
            value: (achievement / 100).clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: AppColors.surfaceMuted,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildKPIReviewSection(MonthlyScorecard scorecard) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('KPIs Review', style: AppText.h3),
          const SizedBox(height: 4),
          Text(
            'Summary of target achievement and ranking.',
            style: AppText.bodySm.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              _buildKPIRow(
                  'Target Score', scorecard.targetScore.toStringAsFixed(1), '%'),
              const Divider(height: 20, color: AppColors.borderSubtle),
              _buildKPIRow('Target Achievement',
                  scorecard.targetAchievement.toStringAsFixed(1), '%'),
              const Divider(height: 20, color: AppColors.borderSubtle),
              _buildKPIRow('Overall Score',
                  scorecard.overallScore.toStringAsFixed(1), '%'),
              const Divider(height: 20, color: AppColors.borderSubtle),
              _buildKPIRow('Ranking', '#${scorecard.ranking}', ''),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKPIRow(String label, String value, String unit) {
    final numValue = double.tryParse(value.replaceAll('#', ''));
    final isGood = numValue != null && numValue >= 75;
    final exceeded = numValue != null && numValue >= 100;

    final statusLabel = exceeded
        ? 'Exceeded'
        : (isGood ? 'On Target' : 'Below Target');
    final tone = exceeded
        ? StatusTone.success
        : (isGood ? StatusTone.primary : StatusTone.danger);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: AppText.label),
              const SizedBox(height: 4),
              Text('$value$unit', style: AppText.caption),
            ],
          ),
        ),
        const SizedBox(width: 12),
        StatusChip(label: statusLabel, tone: tone, dense: true),
      ],
    );
  }

  Widget _buildManagerCommentsSection() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Manager's Comments", style: AppText.h3),
          const SizedBox(height: 4),
          Text(
            'Document feedback and context for this review.',
            style: AppText.bodySm.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentsController,
            maxLines: 4,
            onChanged: (value) => _controller.managerComments.value = value,
            style: AppText.bodyMd,
            decoration: InputDecoration(
              hintText: 'Enter manager comments...',
              hintStyle: AppText.bodyMd.copyWith(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.all(14),
              border: const OutlineInputBorder(
                borderRadius: AppRadii.brMd,
                borderSide: BorderSide(color: AppColors.borderSubtle),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: AppRadii.brMd,
                borderSide: BorderSide(color: AppColors.borderSubtle),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: AppRadii.brMd,
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationSection() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recommendation & Decision', style: AppText.h3),
          const SizedBox(height: 4),
          Text(
            'Flag any follow-up actions for this employee.',
            style: AppText.bodySm.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Obx(() {
            return Column(
              children: [
                _buildCheckboxRow(
                  label: 'Promotion Required',
                  value: _controller.promotionRequired.value,
                  onChanged: (val) =>
                      _controller.promotionRequired.value = val ?? false,
                ),
                _buildCheckboxRow(
                  label: 'Training Required',
                  value: _controller.trainingRequired.value,
                  onChanged: (val) =>
                      _controller.trainingRequired.value = val ?? false,
                ),
                _buildCheckboxRow(
                  label: 'Salary Increase',
                  value: _controller.salaryIncrease.value,
                  onChanged: (val) =>
                      _controller.salaryIncrease.value = val ?? false,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      borderRadius: AppRadii.brSm,
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 4),
            Text(label, style: AppText.bodyMd),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Obx(() {
      final isSubmitting = _controller.isSubmitting.value;

      return Row(
        children: [
          Expanded(
            child: MyElevatedButton(
              isLoading: isSubmitting,
              padding: const EdgeInsets.symmetric(vertical: 12),
              icon: const Icon(Iconsax.tick_circle,
                  size: 16, color: AppColors.textOnPrimary),
              child: 'Submit Evaluation',
              onTap: () async {
                final success = await _controller.submitEvaluation();
                if (success && mounted) {
                  _commentsController.clear();
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: MyOutlinedButton(
              padding: const EdgeInsets.symmetric(vertical: 12),
              icon: const Icon(Iconsax.document_download,
                  size: 16, color: AppColors.primary),
              child: 'Generate PDF',
              onTap: () {},
            ),
          ),
        ],
      );
    });
  }
}
