import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/analytics/models/branch_performance_models.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
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
  late BranchPerformanceSummary _summary;
  late List<BranchRevenueTrend> _revenueTrends;
  late List<BranchInsight> _keyInsights;

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

    _revenueTrends = [
      BranchRevenueTrend(month: 'Jan', revenue: 38000000, target: 35000000),
      BranchRevenueTrend(month: 'Feb', revenue: 41000000, target: 37000000),
      BranchRevenueTrend(month: 'Mar', revenue: 39500000, target: 36000000),
      BranchRevenueTrend(month: 'Apr', revenue: 44000000, target: 40000000),
      BranchRevenueTrend(month: 'May', revenue: 46000000, target: 42000000),
      BranchRevenueTrend(month: 'Jun', revenue: 45000000, target: 40000000),
    ];

    _keyInsights = [
      BranchInsight(
        type: BranchInsightType.revenue,
        title: 'Revenue Exceeds Target',
        description: 'Lagos HQ generated 112% of quarterly revenue target',
        recommendation: 'Continue current strategies and replicate in other branches',
        priority: 'High',
        icon: '📈',
      ),
      BranchInsight(
        type: BranchInsightType.efficiency,
        title: 'Operational Excellence',
        description: 'Average operational efficiency across network is 91.5%',
        recommendation: 'Share best practices from high-performing branches',
        priority: 'Medium',
        icon: '⚙️',
      ),
      BranchInsight(
        type: BranchInsightType.performance,
        title: 'Employee Productivity Peak',
        description: 'Enugu office shows 85% productivity with training investments',
        recommendation: 'Allocate more training resources to boost engagement',
        priority: 'Medium',
        icon: '👥',
      ),
      BranchInsight(
        type: BranchInsightType.growth,
        title: 'Customer Base Expansion',
        description: 'Network gained 65 new customers this quarter',
        recommendation: 'Scale successful customer acquisition strategies',
        priority: 'High',
        icon: '🎯',
      ),
      BranchInsight(
        type: BranchInsightType.risk,
        title: 'Enugu Revenue Gap',
        description: 'Enugu office revenue 11% below target',
        recommendation: 'Investigate operational challenges and provide support',
        priority: 'High',
        icon: '⚠️',
      ),
    ];

    _summary = BranchPerformanceSummary(
      totalBranches: _branches.length,
      topPerformingBranchRank: 1,
      topPerformingBranch: 'Lagos HQ',
      allBranches: _branches,
      averageRevenuePerBranch: _branches
              .fold(0.0, (sum, b) => sum + b.revenueGenerated) /
          _branches.length,
      averageEmployeeProductivity: _branches
              .fold(0.0, (sum, b) => sum + b.employeeProductivity) /
          _branches.length,
      averageCustomerSatisfaction: _branches
              .fold(0.0, (sum, b) => sum + b.customerSatisfaction) /
          _branches.length,
      totalProjects: _branches.fold(0, (sum, b) => sum + b.projectsCompleted),
      totalEmployees: _branches.fold(0, (sum, b) => sum + b.employeeCount),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                'Branch Performance Analysis',
                style: AppText.black_500_32,
              ),
              SizedBox(height: 8),
              MyText(
                'Comprehensive insights across all branch locations',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          kSizedBox,

          // Summary Cards
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildSummaryCard(
                label: 'Total Revenue',
                value:
                    '₦${(_summary.averageRevenuePerBranch * _summary.totalBranches / 1000000).toStringAsFixed(1)}M',
                subtitle: '${_branches.length} branches',
                icon: Icons.trending_up,
                color: AppColors.green,
              ),
              _buildSummaryCard(
                label: 'Avg Efficiency',
                value:
                    '${((_summary.allBranches.fold(0.0, (sum, b) => sum + b.operationalEfficiency) / _summary.totalBranches)).toStringAsFixed(1)}%',
                subtitle: 'All branches',
                icon: Icons.speed,
                color: AppColors.blue,
              ),
              _buildSummaryCard(
                label: 'Customer Satisfaction',
                value:
                    '${_summary.averageCustomerSatisfaction.toStringAsFixed(1)}%',
                subtitle: 'Network average',
                icon: Icons.sentiment_satisfied,
                color: AppColors.orange,
              ),
              _buildSummaryCard(
                label: 'Total Employees',
                value: _summary.totalEmployees.toString(),
                subtitle: 'Active workforce',
                icon: Icons.people,
                color: const Color(0xFF8B5CF6),
              ),
            ],
          ),
          kSizedBox,

          // Filters
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 15,
                  runSpacing: 15,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 250,
                      child: MyTextFormField(
                        hintText: 'Search branches...',
                        leading: Icon(
                          Icons.search,
                          color: AppColors.grey1.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const Wrap(
                      spacing: 15,
                      children: [
                        SortBar(text: 'This Quarter'),
                        SortBar(text: 'All Branches'),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          kSizedBox,
          kSizedBoxSM,

          // Key Insights Section
          const MyText(
            'Key Insights',
            style: AppText.black_500_20,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _keyInsights
                .map((insight) => _buildInsightCard(insight))
                .toList(),
          ),
          kSizedBox,

          // Revenue Trend Chart
          const MyText(
            'Revenue Trend (6 Months)',
            style: AppText.black_500_20,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SizedBox(
              height: 300,
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
                      color: AppColors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
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
                      color: AppColors.orange,
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

          // Branch Comparison Table
          const MyText(
            'Branch Performance Comparison',
            style: AppText.black_500_20,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                dataRowMinHeight: 60,
                dataRowMaxHeight: 60,
                columnSpacing: 24,
                horizontalMargin: 12,
                columns: const [
                  DataColumn(label: MyText('Branch')),
                  DataColumn(label: MyText('Revenue')),
                  DataColumn(label: MyText('Target')),
                  DataColumn(label: MyText('Achievement')),
                  DataColumn(label: MyText('Efficiency')),
                  DataColumn(label: MyText('Satisfaction')),
                  DataColumn(label: MyText('Rating')),
                ],
                rows: _branches.map((branch) {
                  final achievement = branch.getRevenueAchievementPercentage();
                  return DataRow(
                    cells: [
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MyText(
                              branch.branchName,
                              style: AppText.black_500_16,
                            ),
                            MyText(
                              branch.location,
                              style: AppText.sideMText_300_14,
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        MyText(
                          '₦${(branch.revenueGenerated / 1000000).toStringAsFixed(1)}M',
                        ),
                      ),
                      DataCell(
                        MyText(
                          '₦${(branch.revenueTarget / 1000000).toStringAsFixed(1)}M',
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: achievement >= 100
                                ? AppColors.green.withValues(alpha: 0.15)
                                : AppColors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: MyText(
                            '${achievement.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: achievement >= 100
                                  ? AppColors.green
                                  : AppColors.red,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        MyText(
                          '${branch.operationalEfficiency.toStringAsFixed(1)}%',
                        ),
                      ),
                      DataCell(
                        MyText(
                          '${branch.customerSatisfaction.toStringAsFixed(1)}%',
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: HexColor(branch.getPerformanceColor())
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: MyText(
                            branch.getPerformanceRating(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: HexColor(branch.getPerformanceColor()),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          kSizedBox,

          // Detailed Branch Cards
          const MyText(
            'Detailed Branch Analytics',
            style: AppText.black_500_20,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _branches
                .map((branch) => _buildDetailedBranchCard(branch))
                .toList(),
          ),
          kSizedBox,
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey1,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          MyText(
            value,
            style: AppText.black_500_24,
          ),
          const SizedBox(height: 4),
          MyText(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.grey1),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(BranchInsight insight) {
    final priorityColor = insight.priority == 'High'
        ? AppColors.red
        : insight.priority == 'Medium'
            ? AppColors.orange
            : AppColors.green;

    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: priorityColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
        color: priorityColor.withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MyText(
                insight.icon,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MyText(
                  insight.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: MyText(
                  insight.priority,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: priorityColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MyText(
            insight.description,
            style: const TextStyle(fontSize: 12, color: AppColors.grey1),
          ),
          const SizedBox(height: 8),
          MyText(
            'Recommendation: ${insight.recommendation}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedBranchCard(BranchPerformanceMetric branch) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    branch.branchName,
                    style: AppText.black_500_16,
                  ),
                  MyText(
                    branch.location,
                    style: const TextStyle(fontSize: 12, color: AppColors.grey1),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      HexColor(branch.getPerformanceColor()).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: MyText(
                  branch.getPerformanceRating(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: HexColor(branch.getPerformanceColor()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMetricRow('Revenue', '₦${(branch.revenueGenerated / 1000000).toStringAsFixed(1)}M',
              '${branch.getRevenueAchievementPercentage().toStringAsFixed(1)}%'),
          _buildMetricRow(
              'Employees', branch.employeeCount.toString(), '${branch.employeeProductivity.toString()}%'),
          _buildMetricRow('Projects', branch.projectsCompleted.toString(),
              '${branch.activeProjects} active'),
          _buildMetricRow('Satisfaction', '${branch.customerSatisfaction.toStringAsFixed(1)}%',
              'from ${branch.customerCount} customers'),
          _buildMetricRow('Efficiency', '${branch.operationalEfficiency.toStringAsFixed(1)}%',
              'Operational'),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey1,
                ),
              ),
              MyText(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.grey2,
                ),
              ),
            ],
          ),
          MyText(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

}

// Helper function to convert hex color string to Color
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
