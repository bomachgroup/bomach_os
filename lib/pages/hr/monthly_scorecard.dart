import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'models/monthly_scorecard_models.dart';

class MonthlyScorecardPage extends StatefulWidget {
  const MonthlyScorecardPage({super.key});

  @override
  State<MonthlyScorecardPage> createState() => _MonthlyScorecardPageState();
}

class _MonthlyScorecardPageState extends State<MonthlyScorecardPage> {
  String selectedMonth = 'November';
  late MonthlyScorecard currentScorecard;

  @override
  void initState() {
    super.initState();
    currentScorecard = _getMockScorecard();
  }

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
                child: Wrap(
                  spacing: 15,
                  runSpacing: 15,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 150,
                      child: _buildFilterDropdown(
                        label: 'Month',
                        value: selectedMonth,
                        items: ['October', 'November', 'December'],
                        onChanged: (value) =>
                            setState(() => selectedMonth = value),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          kSizedBox,

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
                // Avatar
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.blue, AppColors.blue2],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: MyText(
                      'TD',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Employee Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        currentScorecard.employeeName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        currentScorecard.employeeRole,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Info Pills
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 8,
                  children: [
                    _buildInfoPill(selectedMonth, 'Month'),
                  ],
                ),
              ],
            ),
          ),
          kSizedBox,

          // Action Buttons
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.download,
                  label: 'Download Report',
                  onPressed: () {},
                ),
              ),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.history,
                  label: 'View History',
                  onPressed: () {},
                ),
              ),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.compare_arrows,
                  label: 'Compare',
                  onPressed: () {},
                ),
              ),
            ],
          ),
          kSizedBox,

          // Score Cards Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 16,
              children: [
                _buildBigScoreCard(
                  score: currentScorecard.overallScore.toStringAsFixed(0),
                  label: 'Overall Score',
                ),
                _buildSmallMetricCard(
                  value: '9%',
                  label: 'Target\nAchievement',
                  icon: '🎯',
                ),
                _buildSmallMetricCard(
                  value: '2nd',
                  label: 'Branch\nRanking',
                  icon: '📊',
                ),
                _buildSmallMetricCard(
                  value: '🎓',
                  label: 'Skill Update\nProgress',
                  icon: '⭐',
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
              ...currentScorecard.metrics
                  .map((metric) => _buildMetricRow(metric)),
            ],
          ),
          kSizedBox,
        ],
      ),
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
    required String icon,
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
          MyText(
            icon,
            style: const TextStyle(fontSize: 28),
          ),
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
          const SizedBox(height: 10),

          // Mini line chart
          SizedBox(
            height: 40,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      metric.historyData.length,
                      (i) => FlSpot(i.toDouble(), metric.historyData[i]),
                    ),
                    isCurved: true,
                    color: statusColor,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: statusColor.withValues(alpha: 0.15),
                    ),
                  ),
                ],
                minY: 0,
                maxY: 100,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Value display
          MyText(
            '${metric.currentValue}${metric.unit} / ${metric.targetValue}${metric.unit}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// Mock data generator
  MonthlyScorecard _getMockScorecard() {
    return MonthlyScorecard(
      id: 'sc-001',
      employeeId: 'emp-001',
      employeeName: 'Engr. Tochukwu David',
      employeeEmail: 'tochukwu@company.com',
      employeeRole: 'Regional Manager',
      department: 'Operations',
      month: DateTime.now(),
      overallScore: 88,
      scoreGrade: 'A',
      metrics: [
        MonthlyScorecardMetric(
          id: 'metric-1',
          metricName: 'Attendance',
          currentValue: 85,
          targetValue: 100,
          unit: '%',
          historyData: [65, 70, 72, 75, 78, 80, 82, 83, 84, 85],
          category: 'Attendance',
          lastUpdated: DateTime.now(),
          trend: 'UP',
        ),
        MonthlyScorecardMetric(
          id: 'metric-2',
          metricName: 'Task Delivery',
          currentValue: 93,
          targetValue: 100,
          unit: '%',
          historyData: [75, 80, 85, 88, 90, 91, 92, 93],
          category: 'Delivery',
          lastUpdated: DateTime.now(),
          trend: 'UP',
        ),
        MonthlyScorecardMetric(
          id: 'metric-3',
          metricName: 'Report Accuracy',
          currentValue: 90,
          targetValue: 100,
          unit: '%',
          historyData: [80, 82, 85, 87, 88, 89, 90],
          category: 'Accuracy',
          lastUpdated: DateTime.now(),
          trend: 'UP',
        ),
        MonthlyScorecardMetric(
          id: 'metric-4',
          metricName: 'Brand Contribution',
          currentValue: 80,
          targetValue: 100,
          unit: '%',
          historyData: [60, 65, 68, 70, 72, 75, 77, 78, 80],
          category: 'Contribution',
          lastUpdated: DateTime.now(),
          trend: 'UP',
        ),
        MonthlyScorecardMetric(
          id: 'metric-5',
          metricName: 'Training Progress',
          currentValue: 75,
          targetValue: 100,
          unit: '%',
          historyData: [50, 55, 60, 65, 68, 70, 72, 75],
          category: 'Training',
          lastUpdated: DateTime.now(),
          trend: 'UP',
        ),
      ],
      managerName: 'John Doe',
      status: 'Approved',
      reviewedAt: DateTime.now(),
      reviewedBy: 'John Doe',
      feedback: 'Great performance this month! Keep up the good work.',
    );
  }
}
