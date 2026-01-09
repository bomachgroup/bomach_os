import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'models/performance_leaderboard_models.dart';

class PerformanceLeaderboardPage extends StatefulWidget {
  const PerformanceLeaderboardPage({super.key});

  @override
  State<PerformanceLeaderboardPage> createState() =>
      _PerformanceLeaderboardPageState();
}

class _PerformanceLeaderboardPageState extends State<PerformanceLeaderboardPage> {
  String selectedMonth = 'Month';
  String selectedBranch = 'Branch';
  late PerformanceLeaderboardSummary leaderboardSummary;

  @override
  void initState() {
    super.initState();
    leaderboardSummary = _getMockLeaderboardSummary();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with filters
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const MyText(
                'Performance Leaderboard',
                style: AppText.black_500_32,
              ),
              Row(
                spacing: 12,
                children: [
                  _buildFilterDropdown(
                    label: 'Month',
                    value: selectedMonth,
                    items: ['Month', 'January', 'February', 'March', 'April'],
                    onChanged: (value) =>
                        setState(() => selectedMonth = value),
                  ),
                  _buildFilterDropdown(
                    label: 'Branch',
                    value: selectedBranch,
                    items: ['Branch', 'All Branches', 'Enugu', 'Lagos', 'Abuja'],
                    onChanged: (value) =>
                        setState(() => selectedBranch = value),
                  ),
                  _buildFilterDropdown(
                    label: 'Overall Score',
                    value: 'Overall Score',
                    items: ['Overall Score', 'Score Desc', 'Score Asc'],
                    onChanged: (value) {},
                  ),
                ],
              ),
            ],
          ),
          kSizedBox,

          // Top 3 Performers
          _buildTopPerformersSection(),
          kSizedBox,

          // Full Leaderboard Table
          _buildLeaderboardTable(),
          kSizedBox,

          // Performance Summary Section
          _buildPerformanceSummarySection(),
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
    return SizedBox(
      width: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
            ),
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              underline: Container(),
              icon: const Icon(Icons.arrow_drop_down, size: 18),
              onChanged: (newValue) {
                if (newValue != null) onChanged(newValue);
              },
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: MyText(
                          item,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformersSection() {
    final topThree = leaderboardSummary.topThree;

    return Row(
      spacing: 16,
      children: topThree
          .map((performer) => _buildTopPerformerCard(performer))
          .toList(),
    );
  }

  Widget _buildTopPerformerCard(TopPerformer performer) {
    final color = Color(
      int.parse(performer.getMedalColor().replaceFirst('#', '0xff')),
    );

    return Expanded(
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Medal
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: MyText(
                  performer.medal,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Employee name
            MyText(
              performer.employeeName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // Score
            MyText(
              performer.score.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.blue,
              ),
            ),
            const SizedBox(height: 4),

            // Branch
            MyText(
              performer.branch,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTable() {
    final entries = leaderboardSummary.fullLeaderboard;

    return Container(
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
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: MyText(
                    'Rank',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: MyText(
                    'Name',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                Expanded(
                  child: MyText(
                    'Branch',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: MyText(
                    'Score',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                Expanded(
                  child: MyText(
                    'Awards',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: MyText(
                    'Status',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Rows
          ...entries.asMap().entries.map((entry) {
            final isLastRow = entry.key == entries.length - 1;
            return _buildTableRow(entry.value, isLastRow);
          }),
        ],
      ),
    );
  }

  Widget _buildTableRow(LeaderboardEntry entry, bool isLastRow) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLastRow
            ? null
            : Border(
                bottom: BorderSide(color: Colors.grey.shade100),
              ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: entry.rank <= 3
                ? Row(
                    spacing: 4,
                    children: [
                      MyText(
                        entry.getMedalEmoji(),
                        style: const TextStyle(fontSize: 14),
                      ),
                      MyText(
                        entry.rank.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : MyText(
                    entry.rank.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          Expanded(
            flex: 2,
            child: MyText(
              entry.employeeName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: MyText(
              entry.branch,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          SizedBox(
            width: 70,
            child: MyText(
              entry.performanceScore.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.blue,
              ),
            ),
          ),
          Expanded(
            child: MyText(
              entry.achievements.join(', '),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(
                  int.parse(
                    entry.getStatusColor().replaceFirst('#', '0xff'),
                  ),
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: MyText(
                entry.status,
                style: TextStyle(
                  fontSize: 10,
                  color: Color(
                    int.parse(
                      entry.getStatusColor().replaceFirst('#', '0xff'),
                    ),
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummarySection() {
    final trendData = leaderboardSummary.performanceTrend;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText(
          'Performance Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                'Top 10 Performance Trend',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),

              // Performance trend chart
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          trendData.length,
                          (i) => FlSpot(i.toDouble(), trendData[i]),
                        ),
                        isCurved: true,
                        color: AppColors.blue,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.blue.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                    minY: 70,
                    maxY: 95,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Summary stats
              Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      label: 'Avg. Score',
                      value: leaderboardSummary.averageScore.toStringAsFixed(1),
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryCard(
                      label: 'Participants',
                      value: leaderboardSummary.totalParticipants.toString(),
                    ),
                  ),
                  Expanded(
                    child: _buildActionLink(
                      label: 'View Details',
                      onTap: () {},
                    ),
                  ),
                  Expanded(
                    child: _buildActionLink(
                      label: 'Download PDF',
                      onTap: () {},
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

  Widget _buildSummaryCard({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          MyText(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionLink({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.lightBlue,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.blue),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 6,
          children: [
            if (label.contains('Download'))
              const Icon(Icons.download, size: 14, color: AppColors.blue)
            else
              const Icon(Icons.arrow_forward, size: 14, color: AppColors.blue),
            MyText(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mock leaderboard data
  PerformanceLeaderboardSummary _getMockLeaderboardSummary() {
    return PerformanceLeaderboardSummary(
      filterMonth: 'April',
      filterBranch: 'All Branches',
      topThree: [
        TopPerformer(
          rank: 1,
          employeeName: 'Kumie Teyesi',
          branch: 'Lagos',
          score: 92.3,
          medal: '🥇',
        ),
        TopPerformer(
          rank: 2,
          employeeName: 'Tochukwu Chukwu',
          branch: 'Abuja',
          score: 91.0,
          medal: '🥈',
        ),
        TopPerformer(
          rank: 3,
          employeeName: 'Kumie Teyesi',
          branch: 'Lagos',
          score: 90.6,
          medal: '🥉',
        ),
      ],
      fullLeaderboard: [
        LeaderboardEntry(
          rank: 1,
          employeeId: 'emp-001',
          employeeName: 'Kumie Teyesi',
          branch: 'Lagos',
          performanceScore: 92.3,
          achievements: ['Employee of Month'],
          status: 'Employee of the Month',
        ),
        LeaderboardEntry(
          rank: 2,
          employeeId: 'emp-002',
          employeeName: 'Tochukwu Chukwu',
          branch: 'Abuja',
          performanceScore: 91.0,
          achievements: ['Best Rep'],
          status: 'Consistent Performer',
        ),
        LeaderboardEntry(
          rank: 3,
          employeeId: 'emp-003',
          employeeName: 'Kumie Teyesi',
          branch: 'Segosa',
          performanceScore: 90.6,
          achievements: ['Rising Star'],
          status: 'Rising Star',
        ),
        LeaderboardEntry(
          rank: 4,
          employeeId: 'emp-004',
          employeeName: 'Anita Okafor',
          branch: 'Enugu',
          performanceScore: 89.5,
          achievements: [],
          status: 'Consistent Performer',
        ),
        LeaderboardEntry(
          rank: 5,
          employeeId: 'emp-005',
          employeeName: 'Oladipo Adeyemi',
          branch: 'Ibadan',
          performanceScore: 89.4,
          achievements: [],
          status: 'Consistent Performer',
        ),
        LeaderboardEntry(
          rank: 6,
          employeeId: 'emp-006',
          employeeName: 'Fyke Ugoma',
          branch: 'Kano',
          performanceScore: 87.8,
          achievements: ['Employee of Month'],
          status: 'Employee of the Month',
        ),
        LeaderboardEntry(
          rank: 7,
          employeeId: 'emp-007',
          employeeName: 'John Okafor',
          branch: 'Lagos',
          performanceScore: 87.2,
          achievements: [],
          status: 'Consistent Performer',
        ),
        LeaderboardEntry(
          rank: 8,
          employeeId: 'emp-008',
          employeeName: 'Sandra Okoye',
          branch: 'Enugu',
          performanceScore: 85.8,
          achievements: [],
          status: 'Consistent Performer',
        ),
        LeaderboardEntry(
          rank: 9,
          employeeId: 'emp-009',
          employeeName: 'Debola Baji',
          branch: 'Osogbo',
          performanceScore: 84.7,
          achievements: ['Best Branch Rep'],
          status: 'Best Branch Rep',
        ),
        LeaderboardEntry(
          rank: 10,
          employeeId: 'emp-010',
          employeeName: 'Mnewj Odor',
          branch: 'Maiduri',
          performanceScore: 83.6,
          achievements: ['Employee of Month'],
          status: 'Employee of the Month',
        ),
      ],
      averageScore: 86.9,
      totalParticipants: 450,
      performanceTrend: [78, 79, 81, 82, 83, 84, 85, 85, 86, 87, 86.5, 86.9],
    );
  }
}
