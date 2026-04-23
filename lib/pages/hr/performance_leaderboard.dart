import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/loading_skeleton.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/pages/hr/controller/performance_leaderboard_controller.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

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
    return PageScaffold(
      maxContentWidth: 1200,
      header: PageHeader(
        title: 'Performance Leaderboard',
        subtitle:
            'Compare monthly performance rankings across employees and branches.',
        trailing: Obx(() => _buildFilters()),
      ),
      children: [
        Obx(() {
          if (_controller.isLoading.value) {
            return Column(
              children: [
                LoadingSkeleton.statRow(count: 3),
                const SizedBox(height: 16),
                LoadingSkeleton.listRows(count: 6),
              ],
            );
          }

          if (_controller.errorMessage.isNotEmpty) {
            return AppCard(
              padding: const EdgeInsets.all(32),
              child: EmptyState(
                icon: Iconsax.warning_2,
                title: 'Unable to load leaderboard',
                subtitle: _controller.errorMessage.value,
                action: MyElevatedButton(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  icon: const Icon(Iconsax.refresh,
                      size: 16, color: AppColors.textOnPrimary),
                  child: 'Retry',
                  onTap: () => _controller.fetchLeaderboard(),
                ),
              ),
            );
          }

          final data = _controller.leaderboard.value;
          if (data == null || data.entries.isEmpty) {
            return AppCard(
              padding: const EdgeInsets.all(32),
              child: EmptyState.empty(
                title: 'No leaderboard data',
                subtitle:
                    'There is no leaderboard activity for this month and year yet.',
              ),
            );
          }

          return _buildLeaderboardContent(data);
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
            initialSelection:
                _monthNames[_controller.selectedMonth.value - 1],
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

  Widget _buildLeaderboardContent(LeaderboardResponse data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (data.topThree.isNotEmpty) ...[
          _buildTopPerformersSection(data.topThree),
          const SizedBox(height: 24),
        ],
        _buildLeaderboardTable(data.entries),
        const SizedBox(height: 24),
        _buildPerformanceSummarySection(data),
      ],
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

  Color _medalColorForRank(int rank) {
    switch (rank) {
      case 1:
        return AppColors.success;
      case 2:
        return AppColors.primary;
      case 3:
        return AppColors.warning;
      default:
        return AppColors.neutral400;
    }
  }

  Widget _buildTopPerformersSection(List<LeaderboardEntry> topThree) {
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 720;
      if (isNarrow) {
        return Column(
          children: [
            for (int i = 0; i < topThree.length; i++) ...[
              _buildTopPerformerCard(topThree[i]),
              if (i != topThree.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      }
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < topThree.length; i++) ...[
              Expanded(child: _buildTopPerformerCard(topThree[i])),
              if (i != topThree.length - 1) const SizedBox(width: 16),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildTopPerformerCard(LeaderboardEntry entry) {
    final medalColor = _medalColorForRank(entry.rank);
    final tone = _toneForRank(entry.rank);

    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.sm,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: medalColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: medalColor, width: 2),
            ),
            child: Center(
              child: entry.rank == 1
                  ? Icon(Iconsax.crown, color: medalColor, size: 32)
                  : Text(
                      entry.initials,
                      style: AppText.h2.copyWith(color: medalColor),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          StatusChip(label: 'Rank #${entry.rank}', tone: tone, dense: true),
          const SizedBox(height: 12),
          Text(
            entry.employeeName,
            style: AppText.h4,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            entry.branch,
            style: AppText.bodySm,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            entry.score.toStringAsFixed(1),
            style: AppText.displayMd.copyWith(color: AppColors.primary),
          ),
          const Text('Score', style: AppText.caption),
          if (entry.award != null && entry.award!.isNotEmpty) ...[
            const SizedBox(height: 10),
            StatusChip(
              label: entry.award!,
              tone: StatusTone.success,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeaderboardTable(List<LeaderboardEntry> entries) {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              border: Border(
                bottom: BorderSide(color: AppColors.borderSubtle),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text('Rank', style: _headerStyle()),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Name', style: _headerStyle()),
                ),
                Expanded(
                  child: Text('Branch', style: _headerStyle()),
                ),
                SizedBox(
                  width: 80,
                  child: Text('Score', style: _headerStyle()),
                ),
                SizedBox(
                  width: 140,
                  child: Text('Award', style: _headerStyle()),
                ),
              ],
            ),
          ),
          ...entries.asMap().entries.map((mapEntry) {
            final isLastRow = mapEntry.key == entries.length - 1;
            return _buildTableRow(mapEntry.value, isLastRow);
          }),
        ],
      ),
    );
  }

  TextStyle _headerStyle() {
    return AppText.overline.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w600,
    );
  }

  Widget _buildTableRow(LeaderboardEntry entry, bool isLastRow) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: isLastRow
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.borderSubtle),
              ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: entry.rank <= 3
                ? Row(
                    children: [
                      Text(
                        entry.getMedalEmoji(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        entry.rank.toString(),
                        style: AppText.label,
                      ),
                    ],
                  )
                : Text(
                    entry.rank.toString(),
                    style: AppText.label,
                  ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              entry.employeeName,
              style: AppText.bodyMd.copyWith(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              entry.branch,
              style: AppText.bodySm.copyWith(color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              entry.score.toStringAsFixed(1),
              style: AppText.label.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 140,
            child: entry.award != null && entry.award!.isNotEmpty
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: StatusChip(
                      label: entry.award!,
                      tone: StatusTone.success,
                      dense: true,
                    ),
                  )
                : Text(
                    '—',
                    style: AppText.bodySm.copyWith(color: AppColors.textMuted),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummarySection(LeaderboardResponse data) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Performance Summary', style: AppText.h3),
          const SizedBox(height: 4),
          Text(
            'Aggregate metrics for the selected period.',
            style: AppText.bodySm.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 600;
            final children = [
              _buildSummaryCard(
                label: 'Avg. Score',
                value: data.avgScore.toStringAsFixed(1),
                icon: Iconsax.chart_21,
              ),
              _buildSummaryCard(
                label: 'Participants',
                value: data.totalParticipants.toString(),
                icon: Iconsax.people,
              ),
              _buildSummaryCard(
                label: 'Period',
                value: '${_monthNames[data.month - 1]} ${data.year}',
                icon: Iconsax.calendar_1,
              ),
            ];
            if (isNarrow) {
              return Column(
                children: [
                  for (int i = 0; i < children.length; i++) ...[
                    children[i],
                    if (i != children.length - 1) const SizedBox(height: 12),
                  ],
                ],
              );
            }
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < children.length; i++) ...[
                    Expanded(child: children[i]),
                    if (i != children.length - 1) const SizedBox(width: 16),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brMd,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primarySubtle,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.chart_1,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppText.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppText.h4.copyWith(color: AppColors.primary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // intentionally use the supplied icon for visual variety on wide
          Icon(icon, size: 18, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
