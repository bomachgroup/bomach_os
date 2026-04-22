import 'package:bms_front_end/components/text/my_text.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/pages/hr/controller/performance_leaderboard_controller.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'models/performance_leaderboard_models.dart';

class PerformanceLeaderboardPage extends StatefulWidget {
  const PerformanceLeaderboardPage({super.key});

  @override
  State<PerformanceLeaderboardPage> createState() =>
      _PerformanceLeaderboardPageState();
}

class _PerformanceLeaderboardPageState
    extends State<PerformanceLeaderboardPage> {
  final PerformanceLeaderboardController _controller =
      Get.put(PerformanceLeaderboardController());

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
          // Header with filters
          Row(
            children: [
              const Expanded(
                child: MyText(
                  'Performance Leaderboard',
                  style: AppText.displayLg,
                ),
              ),
              Obx(() {
                return Row(
                  spacing: 12,
                  children: [
                    _buildFilterDropdown(
                      label: 'Month',
                      value: _monthNames[_controller.selectedMonth.value - 1],
                      items: _monthNames,
                      onChanged: (value) {
                        final monthIndex = _monthNames.indexOf(value) + 1;
                        _controller.changeMonth(monthIndex);
                      },
                    ),
                    _buildFilterDropdown(
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
                  ],
                );
              }),
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
                        onPressed: () => _controller.fetchLeaderboard(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = _controller.leaderboard.value;
            if (data == null || data.entries.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text(
                    'No leaderboard data found for this period',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
              );
            }

            return _buildLeaderboardContent(data);
          }),
        ],
      ),
    );
  }

  Widget _buildLeaderboardContent(LeaderboardResponse data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top 3 Performers
        if (data.topThree.isNotEmpty) ...[
          _buildTopPerformersSection(data.topThree),
          kSizedBox,
        ],

        // Full Leaderboard Table
        _buildLeaderboardTable(data.entries),
        kSizedBox,

        // Performance Summary Section
        _buildPerformanceSummarySection(data),
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
              icon: const Icon(Iconsax.arrow_down_1, size: 18),
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

  Widget _buildTopPerformersSection(List<LeaderboardEntry> topThree) {
    return Row(
      spacing: 16,
      children: topThree.map((entry) => _buildTopPerformerCard(entry)).toList(),
    );
  }

  Widget _buildTopPerformerCard(LeaderboardEntry entry) {
    final color = Color(
      int.parse(entry.getMedalColor().replaceFirst('#', '0xff')),
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
                  entry.getMedalEmoji(),
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Employee name
            MyText(
              entry.employeeName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // Score
            MyText(
              entry.score.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),

            // Branch
            MyText(
              entry.branch,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),

            // Award
            if (entry.award != null && entry.award!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Color(
                    int.parse(entry.getStatusColor().replaceFirst('#', '0xff')),
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: MyText(
                  entry.award!,
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(
                      int.parse(
                          entry.getStatusColor().replaceFirst('#', '0xff')),
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTable(List<LeaderboardEntry> entries) {
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
                  width: 50,
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
                SizedBox(
                  width: 120,
                  child: MyText(
                    'Award',
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
          ...entries.asMap().entries.map((mapEntry) {
            final isLastRow = mapEntry.key == entries.length - 1;
            return _buildTableRow(mapEntry.value, isLastRow);
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
            width: 50,
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
              entry.score.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: entry.award != null && entry.award!.isNotEmpty
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(
                            entry.getStatusColor().replaceFirst('#', '0xff')),
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: MyText(
                      entry.award!,
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(
                          int.parse(
                              entry.getStatusColor().replaceFirst('#', '0xff')),
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : MyText(
                    '-',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummarySection(LeaderboardResponse data) {
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
          child: Row(
            spacing: 16,
            children: [
              Expanded(
                child: _buildSummaryCard(
                  label: 'Avg. Score',
                  value: data.avgScore.toStringAsFixed(1),
                ),
              ),
              Expanded(
                child: _buildSummaryCard(
                  label: 'Participants',
                  value: data.totalParticipants.toString(),
                ),
              ),
              Expanded(
                child: _buildSummaryCard(
                  label: 'Period',
                  value: '${_monthNames[data.month - 1]} ${data.year}',
                ),
              ),
              // Expanded(
              //   child: _buildActionLink(
              //     label: 'Download PDF',
              //     onTap: () {},
              //   ),
              // ),
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
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
