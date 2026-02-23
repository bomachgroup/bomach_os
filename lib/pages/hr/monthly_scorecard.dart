import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/controller/monthly_scorecard_controller.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const MyText(
            'Monthly Scorecard',
            style: AppText.black_500_32,
          ),
          kSizedBox,

          // Filters Row
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  return Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 150,
                        child: _buildFilterDropdown(
                          label: 'Month',
                          value:
                              _monthNames[_controller.selectedMonth.value - 1],
                          items: _monthNames,
                          onChanged: (value) {
                            final monthIndex = _monthNames.indexOf(value) + 1;
                            _controller.changeMonth(monthIndex);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 120,
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
              ),
            ],
          ),
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

            return _buildScorecardContent(scorecard);
          }),
        ],
      ),
    );
  }

  Widget _buildScorecardContent(MonthlyScorecard scorecard) {
    final monthName = _monthNames[scorecard.month - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Employee Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.blue, AppColors.blue2],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: MyText(
                    scorecard.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      scorecard.employeeName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    MyText(
                      scorecard.formattedLevel,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 8,
                children: [
                  _buildInfoPill('$monthName ${scorecard.year}', 'Period'),
                  if (scorecard.isAutoGenerated)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Auto-generated',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        kSizedBox,

        // Action Buttons
        // Row(
        //   spacing: 12,
        //   children: [
        //     Expanded(
        //       child: _buildActionButton(
        //         icon: Icons.download,
        //         label: 'Download Report',
        //         onPressed: () {},
        //       ),
        //     ),
        //     Expanded(
        //       child: _buildActionButton(
        //         icon: Icons.history,
        //         label: 'View History',
        //         onPressed: () {},
        //       ),
        //     ),
        //     Expanded(
        //       child: _buildActionButton(
        //         icon: Icons.compare_arrows,
        //         label: 'Compare',
        //         onPressed: () {},
        //       ),
        //     ),
        //   ],
        // ),
        // kSizedBox,

        // Score Cards Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 16,
            children: [
              _buildBigScoreCard(
                score: scorecard.overallScore.toStringAsFixed(0),
                label: 'Overall Score',
              ),
              _buildSmallMetricCard(
                value: '${scorecard.targetAchievement.toStringAsFixed(1)}%',
                label: 'Target\nAchievement',
                icon: Icons.track_changes,
                iconColor: Colors.orange,
              ),
              _buildSmallMetricCard(
                value: '#${scorecard.ranking}',
                label: 'Ranking',
                icon: Icons.leaderboard,
                iconColor: AppColors.blue,
              ),
              _buildSmallMetricCard(
                value: scorecard.targetScore.toStringAsFixed(0),
                label: 'Target\nScore',
                icon: Icons.flag,
                iconColor: Colors.green,
              ),
            ],
          ),
        ),
        kSizedBox,

        // Performance Metrics Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MyText(
              'Performance Metrics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...scorecard.metrics.map((metric) => _buildMetricRow(metric)),
          ],
        ),

        // Notes Section
        if (scorecard.notes.isNotEmpty) ...[
          kSizedBox,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MyText(
                  'Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                MyText(
                  scorecard.notes,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
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
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
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
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.blue),
            onChanged: (newValue) {
              if (newValue != null) onChanged(newValue);
            },
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: MyText(
                        item,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoPill(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        MyText(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
        MyText(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: MyText(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.blue,
        side: const BorderSide(color: AppColors.blue),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildBigScoreCard({
    required String score,
    required String label,
  }) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF8B3A3A),
            Color(0xFF5C2C2C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MyText(
            score,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          MyText(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
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
    required Color iconColor,
  }) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          Icon(icon, size: 28, color: iconColor),
          MyText(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          MyText(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(MonthlyScorecardMetric metric) {
    final achievement = metric.getAchievementPercentage();
    final statusColor = Color(
      int.parse(metric.getStatusColor().replaceFirst('#', '0xff')),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metric name and percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText(
                metric.metricName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor),
                ),
                child: MyText(
                  '${achievement.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (achievement / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),

          // Value display
          MyText(
            '${metric.currentValue.toStringAsFixed(1)}${metric.unit} / ${metric.targetValue.toStringAsFixed(0)}${metric.unit}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
