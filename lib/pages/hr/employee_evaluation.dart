import 'package:bms_front_end/components/text/my_text.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/pages/hr/controller/employee_evaluation_controller.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const MyText(
            'Employee Evaluation Form',
            style: AppText.displayLg,
          ),
          const MyText(
            'Monthly Evaluation',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          kSizedBox,

          // Filters
          Obx(() {
            return Row(
              spacing: 16,
              children: [
                Expanded(
                  child: _buildFilterDropdown(
                    label: 'Month',
                    value: _monthNames[_controller.selectedMonth.value - 1],
                    items: _monthNames,
                    onChanged: (value) {
                      final monthIndex = _monthNames.indexOf(value) + 1;
                      _controller.changeMonth(monthIndex);
                    },
                  ),
                ),
                Expanded(
                  child: _buildFilterDropdown(
                    label: 'Year',
                    value: _controller.selectedYear.value.toString(),
                    items: List.generate(
                      5,
                      (i) => (DateTime.now().year - 2 + i).toString(),
                    ),
                    onChanged: (value) {
                      _controller.changeYear(int.parse(value));
                    },
                  ),
                ),
              ],
            );
          }),
          kSizedBox,

          // Content
          Obx(() {
            if (_controller.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (_controller.errorMessage.isNotEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _controller.errorMessage.value,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _controller.fetchScorecard(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final scorecard = _controller.scorecard.value;
            if (scorecard == null) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text(
                    'No scorecard data found for this period',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
              );
            }

            return _buildEvaluationContent(scorecard);
          }),
        ],
      ),
    );
  }

  Widget _buildEvaluationContent(MonthlyScorecard scorecard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Employee Info Card
        _buildEmployeeInfoCard(scorecard),
        kSizedBox,

        // Performance Scores Section (from scorecard)
        _buildPerformanceScoresSection(scorecard),
        kSizedBox,

        // KPI Review Section (from scorecard metrics)
        _buildKPIReviewSection(scorecard),
        kSizedBox,

        // Manager's Comments
        _buildManagerCommentsSection(),
        kSizedBox,

        // Recommendation & Decision
        _buildRecommendationSection(),
        kSizedBox,

        // Action Buttons
        _buildActionButtons(),
        kSizedBox,
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: Container(),
            icon: const Icon(Iconsax.arrow_down_1, size: 18),
            onChanged: (newValue) {
              if (newValue != null) onChanged(newValue);
            },
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: MyText(item, style: const TextStyle(fontSize: 13)),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeInfoCard(MonthlyScorecard scorecard) {
    final scoreColor = Color(
      int.parse(scorecard.getScoreColor().replaceFirst('#', '0xff')),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 12,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppColors.primarySubtle,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: MyText(
                    scorecard.initials,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      scorecard.employeeName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    MyText(
                      'Level: ${scorecard.formattedLevel}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    MyText(
                      'Period: ${_monthNames[scorecard.month - 1]} ${scorecard.year}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 4,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: scoreColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: scoreColor),
                    ),
                    child: MyText(
                      'Overall Score',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  MyText(
                    '${scorecard.overallScore.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  MyText(
                    'Rank #${scorecard.ranking}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceScoresSection(MonthlyScorecard scorecard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText(
          'Performance Scores',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            children: scorecard.metrics
                .map((metric) => _buildScoreRow(metric))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreRow(MonthlyScorecardMetric metric) {
    final achievement = metric.getAchievementPercentage();
    final statusColor = Color(
      int.parse(metric.getStatusColor().replaceFirst('#', '0xff')),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText(
                metric.metricName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: statusColor),
                ),
                child: MyText(
                  '${metric.currentValue.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (achievement / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIReviewSection(MonthlyScorecard scorecard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText(
          'KPIs Review',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            children: [
              _buildKPIRow(
                'Target Score',
                scorecard.targetScore.toStringAsFixed(1),
                '%',
              ),
              Divider(height: 16, color: Colors.grey.shade200),
              _buildKPIRow(
                'Target Achievement',
                scorecard.targetAchievement.toStringAsFixed(1),
                '%',
              ),
              Divider(height: 16, color: Colors.grey.shade200),
              _buildKPIRow(
                'Overall Score',
                scorecard.overallScore.toStringAsFixed(1),
                '%',
              ),
              Divider(height: 16, color: Colors.grey.shade200),
              _buildKPIRow(
                'Ranking',
                '#${scorecard.ranking}',
                '',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKPIRow(String label, String value, String unit) {
    final numValue = double.tryParse(value.replaceAll('#', ''));
    final isGood = numValue != null && numValue >= 75;

    final statusLabel = numValue != null && numValue >= 100
        ? 'Exceeded'
        : (isGood ? 'On Target' : 'Below Target');
    final statusColor = numValue != null && numValue >= 100
        ? AppColors.success
        : (isGood ? AppColors.primary : const Color(0xFFEC2623));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                MyText(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                MyText(
                  '$value$unit',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: statusColor),
            ),
            child: MyText(
              statusLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagerCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText(
          "Manager's Comments",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: TextField(
            maxLines: 4,
            controller: _commentsController,
            onChanged: (value) => _controller.managerComments.value = value,
            decoration: InputDecoration(
              hintText: 'Enter manager comments...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText(
          'Recommendation & Decision',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Obx(() {
            return Column(
              spacing: 12,
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
        ),
      ],
    );
  }

  Widget _buildCheckboxRow({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
        MyText(
          label,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Obx(() {
      final isSubmitting = _controller.isSubmitting.value;

      return Row(
        spacing: 12,
        children: [
          Expanded(
            child: isSubmitting
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () async {
                      final success = await _controller.submitEvaluation();
                      if (success && mounted) {
                        _commentsController.clear();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const MyText(
                      'Submit Evaluation',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Iconsax.document_download, size: 16),
              label: const MyText(
                'Generate PDF',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primarySubtle,
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
