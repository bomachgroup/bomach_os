import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bomach_os/pages/analytics/models/branch_performance_models.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/spaces.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BranchPerformanceAnalysisPage extends StatefulWidget {
  const BranchPerformanceAnalysisPage({super.key});

  @override
  State<BranchPerformanceAnalysisPage> createState() =>
      _BranchPerformanceAnalysisPageState();
}

class _BranchPerformanceAnalysisPageState
    extends State<BranchPerformanceAnalysisPage> {
  final ScrollController _scrollController = ScrollController();
  late List<BranchPerformanceMetric> _branches;
  late List<BranchRevenueTrend> _revenueTrends;
  int _selectedBranchIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _branches = [
      BranchPerformanceMetric(
        branchId: 'BR001',
        branchName: 'Lagos HQ',
        location: 'Lagos, Nigeria',
        revenueGenerated: 45000000,
        revenueTarget: 40000000,
        employeeCount: 120,
        employeeProductivity: 92,
        projectsCompleted: 28,
        activeProjects: 8,
        customerSatisfaction: 94,
        customerCount: 156,
        operationalEfficiency: 96,
        costPerProjection: 185000,
        trainingSessionsCompleted: 45,
        employeeRetentionRate: 94,
        lastReportDate: DateTime.now(),
      ),
      BranchPerformanceMetric(
        branchId: 'BR002',
        branchName: 'Enugu Office',
        location: 'Enugu, Nigeria',
        revenueGenerated: 28500000,
        revenueTarget: 32000000,
        employeeCount: 75,
        employeeProductivity: 85,
        projectsCompleted: 18,
        activeProjects: 5,
        customerSatisfaction: 88,
        customerCount: 98,
        operationalEfficiency: 88,
        costPerProjection: 195000,
        trainingSessionsCompleted: 32,
        employeeRetentionRate: 89,
        lastReportDate: DateTime.now(),
      ),
      BranchPerformanceMetric(
        branchId: 'BR003',
        branchName: 'Port Harcourt',
        location: 'Port Harcourt, Nigeria',
        revenueGenerated: 35200000,
        revenueTarget: 35000000,
        employeeCount: 85,
        employeeProductivity: 89,
        projectsCompleted: 22,
        activeProjects: 6,
        customerSatisfaction: 91,
        customerCount: 124,
        operationalEfficiency: 92,
        costPerProjection: 190000,
        trainingSessionsCompleted: 38,
        employeeRetentionRate: 91,
        lastReportDate: DateTime.now(),
      ),
      BranchPerformanceMetric(
        branchId: 'BR004',
        branchName: 'Abuja Office',
        location: 'Abuja, Nigeria',
        revenueGenerated: 31800000,
        revenueTarget: 30000000,
        employeeCount: 68,
        employeeProductivity: 87,
        projectsCompleted: 19,
        activeProjects: 4,
        customerSatisfaction: 89,
        customerCount: 87,
        operationalEfficiency: 90,
        costPerProjection: 188000,
        trainingSessionsCompleted: 30,
        employeeRetentionRate: 87,
        lastReportDate: DateTime.now(),
      ),
    ];

    // Generate revenue trends for each branch
    _revenueTrends = [
      BranchRevenueTrend(month: 'Jan', revenue: 38000000, target: 35000000),
      BranchRevenueTrend(month: 'Feb', revenue: 41000000, target: 37000000),
      BranchRevenueTrend(month: 'Mar', revenue: 39500000, target: 36000000),
      BranchRevenueTrend(month: 'Apr', revenue: 44000000, target: 40000000),
      BranchRevenueTrend(month: 'May', revenue: 46000000, target: 42000000),
      BranchRevenueTrend(month: 'Jun', revenue: 45000000, target: 40000000),
    ];
  }

  List<BranchInsight> _generateBranchInsights() {
    final selectedBranch = _branches[_selectedBranchIndex];
    final achievement = selectedBranch.getRevenueAchievementPercentage();

    return [
      BranchInsight(
        type: BranchInsightType.revenue,
        title: 'Revenue Status',
        description:
            '${selectedBranch.branchName} generated ${achievement.toStringAsFixed(0)}% of revenue target',
        recommendation: achievement >= 100
            ? 'Maintain current performance'
            : 'Implement growth strategies to reach target',
        priority: achievement >= 100 ? 'High' : 'High',
        icon: achievement >= 100 ? '📈' : '⚠️',
      ),
      BranchInsight(
        type: BranchInsightType.efficiency,
        title: 'Operational Efficiency',
        description:
            'Operating at ${selectedBranch.operationalEfficiency.toStringAsFixed(0)}% efficiency',
        recommendation: 'Continue optimizing processes',
        priority:
            selectedBranch.operationalEfficiency >= 90 ? 'High' : 'Medium',
        icon: '⚙️',
      ),
      BranchInsight(
        type: BranchInsightType.performance,
        title: 'Employee Productivity',
        description:
            '${selectedBranch.employeeProductivity.toStringAsFixed(0)}% productivity rate',
        recommendation: 'Consider additional training programs',
        priority: selectedBranch.employeeProductivity >= 90 ? 'High' : 'Medium',
        icon: '👥',
      ),
      BranchInsight(
        type: BranchInsightType.growth,
        title: 'Customer Satisfaction',
        description:
            '${selectedBranch.customerSatisfaction.toStringAsFixed(0)}% satisfaction from ${selectedBranch.customerCount} customers',
        recommendation: 'Leverage customer feedback to improve service',
        priority: selectedBranch.customerSatisfaction >= 90 ? 'High' : 'Medium',
        icon: '😊',
      ),
      BranchInsight(
        type: BranchInsightType.growth,
        title: 'Staff Retention',
        description:
            '${selectedBranch.employeeRetentionRate.toStringAsFixed(0)}% employee retention rate',
        recommendation: 'Maintain positive workplace culture',
        priority:
            selectedBranch.employeeRetentionRate >= 90 ? 'High' : 'Medium',
        icon: '🤝',
      ),
    ];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedBranch = _branches[_selectedBranchIndex];
    final keyInsights = _generateBranchInsights();

    return PageScaffold(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Branch Selector
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MyText(
                    'Branch Performance Analysis',
                    style: AppTextStyles.displayLg,
                  ),
                  const SizedBox(height: 8),
                  MyText(
                    'Performance insights for ${selectedBranch.branchName}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.neutral500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Branch Dropdown Selector
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.neutral100),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<int>(
                      value: _selectedBranchIndex,
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedBranchIndex = newValue;
                          });
                        }
                      },
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: _branches.asMap().entries.map((entry) {
                        return DropdownMenuItem<int>(
                          value: entry.key,
                          child: MyText(entry.value.branchName),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              kSizedBox,

              // Summary Cards for Selected Branch
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: 220,
                    child: _buildStatCard(
                      'Revenue Generated',
                      '₦${(selectedBranch.revenueGenerated / 1000000).toStringAsFixed(1)}M',
                      Iconsax.trend_up,
                      AppColors.success,
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: _buildStatCard(
                      'Operational Efficiency',
                      '${selectedBranch.operationalEfficiency.toStringAsFixed(0)}%',
                      Iconsax.speedometer,
                      AppColors.primary,
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: _buildStatCard(
                      'Customer Satisfaction',
                      '${selectedBranch.customerSatisfaction.toStringAsFixed(0)}%',
                      Iconsax.emoji_happy,
                      AppColors.warning,
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: _buildStatCard(
                      'Total Employees',
                      selectedBranch.employeeCount.toString(),
                      Iconsax.people,
                      AppColors.primaryPressed,
                    ),
                  ),
                ],
              ),
              kSizedBox,

              // Key Insights Section
              _SectionCard(
                title: 'Key Insights',
                titleIcon: Iconsax.lamp,
                child: Column(
                  children: keyInsights
                      .map((insight) => _buildInsightItem(insight))
                      .toList(),
                ),
              ),
              kSizedBox,

              // Revenue Trend Chart
              _SectionCard(
                title: 'Revenue Trend (6 Months)',
                titleIcon: Iconsax.chart,
                child: SizedBox(
                  height: 280,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() < _revenueTrends.length) {
                                return MyText(
                                  _revenueTrends[value.toInt()].month,
                                  style: const TextStyle(fontSize: 12),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return MyText(
                                '₦${(value / 1000000).toStringAsFixed(0)}M',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _revenueTrends
                              .asMap()
                              .entries
                              .map((e) => FlSpot(
                                    e.key.toDouble(),
                                    e.value.revenue,
                                  ))
                              .toList(),
                          isCurved: true,
                          color: AppColors.primary,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.primary.withValues(alpha: 0.1),
                          ),
                        ),
                        LineChartBarData(
                          spots: _revenueTrends
                              .asMap()
                              .entries
                              .map((e) => FlSpot(
                                    e.key.toDouble(),
                                    e.value.target,
                                  ))
                              .toList(),
                          isCurved: true,
                          color: AppColors.warning,
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                          dashArray: [5, 5],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              kSizedBox,

              // Detailed Branch Metrics
              _buildBranchCard(selectedBranch),
              kSizedBox,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Card(
      color: AppColors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: MyText(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.neutral500,
                    ),
                  ),
                ),
                Icon(icon, color: color, size: 22),
              ],
            ),
            const SizedBox(height: 12),
            MyText(
              value,
              style: AppTextStyles.h1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(BranchInsight insight) {
    final priorityColor = insight.priority == 'High'
        ? AppColors.danger
        : insight.priority == 'Medium'
            ? AppColors.warning
            : AppColors.success;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral100),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                MyText(
                  insight.icon,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MyText(
                    insight.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: MyText(
                    insight.priority,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: priorityColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            MyText(
              insight.description,
              style: const TextStyle(fontSize: 11, color: AppColors.neutral500),
            ),
            const SizedBox(height: 6),
            MyText(
              '→ ${insight.recommendation}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchCard(BranchPerformanceMetric branch) {
    final achievement = branch.getRevenueAchievementPercentage();
    final rating = branch.getPerformanceRating();
    final ratingColor = rating == 'Excellent'
        ? AppColors.success
        : rating == 'Good'
            ? AppColors.primary
            : rating == 'Satisfactory'
                ? AppColors.warning
                : AppColors.danger;

    return Card(
      color: AppColors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        branch.branchName,
                        style: AppTextStyles.bodyLg,
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        branch.location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: ratingColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: MyText(
                    rating,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ratingColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildMetricRow(
              'Revenue',
              '₦${(branch.revenueGenerated / 1000000).toStringAsFixed(1)}M',
              achievement >= 100
                  ? '✓ ${achievement.toStringAsFixed(0)}%'
                  : '✗ ${achievement.toStringAsFixed(0)}%',
              achievement >= 100 ? AppColors.success : AppColors.danger,
            ),
            const SizedBox(height: 10),
            _buildMetricRow(
              'Employees',
              branch.employeeCount.toString(),
              '${branch.employeeProductivity.toStringAsFixed(0)}% productivity',
              AppColors.primary,
            ),
            const SizedBox(height: 10),
            _buildMetricRow(
              'Projects',
              branch.projectsCompleted.toString(),
              '${branch.activeProjects} active',
              AppColors.warning,
            ),
            const SizedBox(height: 10),
            _buildMetricRow(
              'Customer Satisfaction',
              '${branch.customerSatisfaction.toStringAsFixed(0)}%',
              'from ${branch.customerCount} customers',
              AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    String label,
    String mainValue,
    String subValue,
    Color accentColor,
  ) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.neutral500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: MyText(
                      mainValue,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: MyText(
                      subValue,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.neutral500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Custom Section Card Widget
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData? titleIcon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
    this.titleIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 8,
              children: [
                if (titleIcon != null) Icon(titleIcon, size: 20),
                Expanded(
                  child: MyText(
                    title,
                    style: AppTextStyles.bodyLg,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
