import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/pages/operations/controllers/tasks_controler.dart';
import 'package:bomach_os/pages/operations/models/models.dart';
import 'package:bomach_os/pages/operations/models/task_adapter.dart';
import 'package:bomach_os/pages/operations/models/task_approval_models.dart'
    as approval;
import 'package:bomach_os/pages/operations/widget/task_approval_dialog.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/shadows.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:bomach_os/src/utils/app_date_format.dart';

class TaskDetail extends StatefulWidget {
  final Task? task;
  const TaskDetail({super.key, this.task});

  @override
  State<TaskDetail> createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetail> {
  @override
  Widget build(BuildContext context) {
    final Task? task =
        widget.task ?? ModalRoute.of(context)?.settings.arguments as Task?;

    if (task == null) {
      return const PageScaffold(
        children: [
          Center(
            child: Text('Task not found', style: AppTextStyles.bodyLg),
          ),
        ],
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 900;

    return PageScaffold(
      header: PageHeader(
        title: task.name,
        subtitle: 'Comprehensive task overview and analytics',
        trailing: MyElevatedButton(
          height: 48,
          bgColor: AppColors.success,
          icon: const Icon(Iconsax.tick_circle,
              size: 18, color: AppColors.textOnPrimary),
          child: 'Approve',
          onTap: () => _showApprovalDialog(context, task),
        ),
      ),
      children: [
        _TaskSummaryCard(task: task),
        if (isWideScreen)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: TaskDetailBody(task: task),
              ),
              const SizedBox(width: 24),
              const Expanded(
                child: _TodayTasksSection(),
              ),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TaskDetailBody(task: task),
              const SizedBox(height: 24),
              const _TodayTasksSection(),
            ],
          ),
      ],
    );
  }

  void _showApprovalDialog(BuildContext context, Task task) {
    final TaskController controller = Get.isRegistered<TaskController>()
        ? Get.find<TaskController>()
        : Get.put(TaskController());

    showDialog<TaskApprovalResult>(
      context: context,
      builder: (_) => TaskApprovalDialog(
        task: task.toApprovalTask(),
        reviewerName: 'Manager',
        onApprovalComplete: (approvalTask) {
          final newStatus = approvalTask.status == approval.TaskStatus.completed
              ? 'completed'
              : approvalTask.status == approval.TaskStatus.rejected
                  ? 'rejected'
                  : 'on_hold';
          final updatedTask = Task(
            id: task.id,
            projectId: task.projectId,
            milestoneId: task.milestoneId,
            name: task.name,
            description: task.description,
            status: newStatus,
            priority: task.priority,
            assignedTo: task.assignedTo,
            dueDate: task.dueDate,
            estimatedHours: task.estimatedHours,
            createdAt: task.createdAt,
            updatedAt: task.updatedAt,
          );
          controller.updateTask(context, task.id, updatedTask);
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  TASK SUMMARY CARD (Header Section)
// ═══════════════════════════════════════════════════════════════════

class _TaskSummaryCard extends StatelessWidget {
  final Task task;
  const _TaskSummaryCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Task overview', style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        'Snapshot of priority, deadline and estimate.',
                        style: AppTextStyles.bodyMd
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                StatusChip(
                  label: task.status.isEmpty ? 'Unknown' : task.status,
                  tone: _statusTone(task.status),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _InfoTile(
                  icon: Iconsax.hashtag,
                  label: 'Task ID',
                  value: '#${task.id}',
                ),
                _InfoTile(
                  icon: Iconsax.flag,
                  label: 'Priority',
                  value: task.priority.isEmpty ? '—' : task.priority,
                ),
                _InfoTile(
                  icon: Iconsax.calendar,
                  label: 'Due date',
                  value: task.dueDate.isEmpty
                      ? '—'
                      : formatAppDateValue(task.dueDate,
                          fallback: task.dueDate),
                ),
                _InfoTile(
                  icon: Iconsax.timer_1,
                  label: 'Estimate',
                  value: task.estimatedHours > 0
                      ? '${task.estimatedHours} hrs'
                      : '—',
                ),
                _InfoTile(
                  icon: Iconsax.briefcase,
                  label: 'Project',
                  value: '#${task.projectId}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
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
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.brSm,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  TASK DETAIL BODY (left column)
// ═══════════════════════════════════════════════════════════════════

class TaskDetailBody extends StatefulWidget {
  final Task task;
  const TaskDetailBody({super.key, required this.task});

  @override
  State<TaskDetailBody> createState() => _TaskDetailBodyState();
}

class _TaskDetailBodyState extends State<TaskDetailBody> {
  String selectedTimeframe = 'Monthly';
  static const _timeframes = ['Daily', 'Weekly', 'Monthly'];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDescriptionCard(),
        const SizedBox(height: 24),
        _buildStatsGrid(
            isSmallScreen: isSmallScreen, isMediumScreen: isMediumScreen),
        const SizedBox(height: 24),
        _buildChartCard(isSmallScreen: isSmallScreen),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────
  // Description section
  // ────────────────────────────────────────────────────────────

  Widget _buildDescriptionCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.document_text,
                  size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(widget.task.name, style: AppTextStyles.h3),
              ),
              StatusChip(
                label: 'Project #${widget.task.projectId}',
                tone: StatusTone.neutral,
                icon: Iconsax.briefcase,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.task.description.isEmpty
                ? 'No description provided.'
                : widget.task.description,
            style: AppTextStyles.bodyMd.copyWith(
              color: widget.task.description.isEmpty
                  ? AppColors.textMuted
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // Stat grid
  // ────────────────────────────────────────────────────────────

  Widget _buildStatsGrid({
    required bool isSmallScreen,
    required bool isMediumScreen,
  }) {
    final cards = [
      _buildStatCard(index: 0),
      _buildStatCard(index: 1),
      _buildStatCard(index: 2),
    ];

    if (isSmallScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          cards[0],
          const SizedBox(height: 12),
          cards[1],
          const SizedBox(height: 12),
          cards[2],
        ],
      );
    }

    if (isMediumScreen) {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 12),
              Expanded(child: cards[1]),
            ],
          ),
          const SizedBox(height: 12),
          cards[2],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: cards[0]),
        const SizedBox(width: 12),
        Expanded(child: cards[1]),
        const SizedBox(width: 12),
        Expanded(child: cards[2]),
      ],
    );
  }

  Widget _buildStatCard({required int index}) {
    final task = widget.task;
    final cardData = [
      {
        'title': 'Estimated Hours',
        'value': task.estimatedHours > 0
            ? '${task.estimatedHours.toStringAsFixed(0)}h'
            : '—',
        'trend': task.estimatedHours > 0 ? 'Actual hours TBD' : '',
        'trendPeriod': '',
        'icon': Iconsax.timer_1,
        'tone': StatusTone.primary,
      },
      {
        'title': 'Days Remaining',
        'value': _daysRemaining(task.dueDate),
        'trend': _daysRemaining(task.dueDate) == '—' ? '' : 'from today',
        'trendPeriod': '',
        'icon': Iconsax.calendar,
        'tone': StatusTone.success,
      },
      {
        'title': 'Status',
        'value': task.status.isEmpty ? '—' : task.status.replaceAll('_', ' '),
        'trend': 'Priority: ${task.priority.isEmpty ? "—" : task.priority}',
        'trendPeriod': '',
        'icon': Iconsax.status,
        'tone': _cardTone(task.status),
      },
    ];

    final data = cardData[index];
    final tone = data['tone'] as StatusTone;

    return StatCard(
      title: data['title'] as String,
      value: data['value'] as String,
      trend: data['trend'] as String,
      trendPeriod: data['trendPeriod'] as String,
      icon: data['icon'] as IconData,
      tone: tone,
    );
  }

  String _daysRemaining(String dueDate) {
    if (dueDate.isEmpty) return '—';
    try {
      final date = DateTime.parse(dueDate.substring(0, 10));
      final days = date.difference(DateTime.now()).inDays;
      if (days < 0) return '${days.abs()} overdue';
      if (days == 0) return 'Today';
      return '$days days';
    } catch (_) {
      return '—';
    }
  }

  StatusTone _cardTone(String status) {
    switch (status.toLowerCase().trim()) {
      case 'completed':
        return StatusTone.success;
      case 'in_progress':
      case 'in progress':
        return StatusTone.primary;
      case 'pending':
        return StatusTone.warning;
      case 'blocked':
      case 'cancelled':
        return StatusTone.danger;
      default:
        return StatusTone.neutral;
    }
  }

  // ────────────────────────────────────────────────────────────
  // Chart card with pill tab bar
  // ────────────────────────────────────────────────────────────

  Widget _buildChartCard({required bool isSmallScreen}) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Task Done', style: AppTextStyles.h3),
                    const SizedBox(height: 4),
                    Text(
                      'Completion trend over time',
                      style: AppTextStyles.bodyMd
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimeframePillBar(),
          const SizedBox(height: 16),
          SizedBox(
            height: isSmallScreen ? 250 : 300,
            child: const TaskChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframePillBar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: _timeframes
            .map((label) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _buildTimeframeButton(label),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildTimeframeButton(String label) {
    final isActive = selectedTimeframe == label;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadii.brMd,
        onTap: () => setState(() => selectedTimeframe = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? AppColors.surface : Colors.transparent,
            borderRadius: AppRadii.brMd,
            boxShadow: isActive ? AppShadows.sm : const <BoxShadow>[],
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyMd.copyWith(
              color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  STAT CARD
// ═══════════════════════════════════════════════════════════════════

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final String trendPeriod;
  final IconData icon;
  final StatusTone tone;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.trend = '',
    this.trendPeriod = '',
    required this.icon,
    this.tone = StatusTone.primary,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _tonePalette(tone);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.background,
                  borderRadius: AppRadii.brSm,
                ),
                child: Icon(icon, size: 18, color: palette.foreground),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.h2,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 30,
                  child: MiniLineChart(
                    lineColor: palette.foreground,
                    fillColor: palette.background,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    trend,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    trendPeriod,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  _StatPalette _tonePalette(StatusTone tone) {
    switch (tone) {
      case StatusTone.success:
        return const _StatPalette(
          foreground: AppColors.success,
          background: AppColors.successSubtle,
        );
      case StatusTone.warning:
        return const _StatPalette(
          foreground: AppColors.warning,
          background: AppColors.warningSubtle,
        );
      case StatusTone.danger:
        return const _StatPalette(
          foreground: AppColors.danger,
          background: AppColors.dangerSubtle,
        );
      case StatusTone.info:
        return const _StatPalette(
          foreground: AppColors.info,
          background: AppColors.infoSubtle,
        );
      case StatusTone.primary:
        return const _StatPalette(
          foreground: AppColors.primary,
          background: AppColors.primarySubtle,
        );
      case StatusTone.neutral:
        return const _StatPalette(
          foreground: AppColors.textSecondary,
          background: AppColors.surfaceMuted,
        );
    }
  }
}

class _StatPalette {
  final Color foreground;
  final Color background;
  const _StatPalette({required this.foreground, required this.background});
}

// ═══════════════════════════════════════════════════════════════════
//  MINI LINE CHART
// ═══════════════════════════════════════════════════════════════════

class MiniLineChart extends StatelessWidget {
  final Color lineColor;
  final Color fillColor;

  const MiniLineChart({
    super.key,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 1),
              FlSpot(1, 1.5),
              FlSpot(2, 1.2),
              FlSpot(3, 2.1),
              FlSpot(4, 1.5),
              FlSpot(5, 2.3),
            ],
            isCurved: true,
            color: lineColor,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: fillColor.withValues(alpha: 0.6),
            ),
          ),
        ],
        lineTouchData: const LineTouchData(enabled: false),
        minX: 0,
        maxX: 5,
        minY: 0,
        maxY: 3,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  TASK CHART
// ═══════════════════════════════════════════════════════════════════

class TaskChart extends StatelessWidget {
  const TaskChart({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 100,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: AppColors.neutral200,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: isSmallScreen ? 2 : 1,
              getTitlesWidget: (value, meta) {
                const months = [
                  'May',
                  'Jun',
                  'Jul',
                  'Aug',
                  'Sep',
                  'Oct',
                  'Nov',
                  'Dec',
                  'Jan',
                  'Feb',
                  'Mar',
                  'Apr'
                ];
                final index = value.toInt();
                if (index >= 0 && index < months.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      months[index],
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                        fontSize: isSmallScreen ? 10 : 12,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 100,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
                    fontSize: isSmallScreen ? 10 : 12,
                  ),
                );
              },
              reservedSize: isSmallScreen ? 30 : 40,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 11,
        minY: 0,
        maxY: 400,
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 50),
              FlSpot(1, 100),
              FlSpot(2, 200),
              FlSpot(3, 300),
              FlSpot(4, 250),
              FlSpot(5, 280),
              FlSpot(6, 220),
              FlSpot(7, 320),
              FlSpot(8, 300),
              FlSpot(9, 350),
              FlSpot(10, 200),
              FlSpot(11, 150),
            ],
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: isSmallScreen ? 3 : 4,
                  color: AppColors.surface,
                  strokeWidth: 2,
                  strokeColor: AppColors.primary,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.25),
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.02),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          LineChartBarData(
            spots: const [
              FlSpot(0, 30),
              FlSpot(1, 70),
              FlSpot(2, 150),
              FlSpot(3, 230),
              FlSpot(4, 180),
              FlSpot(5, 220),
              FlSpot(6, 150),
              FlSpot(7, 250),
              FlSpot(8, 230),
              FlSpot(9, 300),
              FlSpot(10, 150),
              FlSpot(11, 100),
            ],
            isCurved: true,
            color: AppColors.info,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: isSmallScreen ? 3 : 4,
                  color: AppColors.surface,
                  strokeWidth: 2,
                  strokeColor: AppColors.info,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.infoSubtle.withValues(alpha: 0.5),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 8,
            tooltipBorder: const BorderSide(
              color: AppColors.borderSubtle,
              width: 1,
            ),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                return LineTooltipItem(
                  '${touchedSpot.y.toInt()}',
                  const TextStyle(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  TODAY'S TASKS SIDEBAR
// ═══════════════════════════════════════════════════════════════════

class _TodayTasksSection extends StatelessWidget {
  const _TodayTasksSection();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                const Icon(Iconsax.calendar_1,
                    size: 18, color: AppColors.warning),
                const SizedBox(width: 8),
                const Text("Today's Tasks", style: AppTextStyles.h4),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: const BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: AppRadii.brPill,
                  ),
                  child: Text(
                    '3',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Material(
                  color: AppColors.primary,
                  borderRadius: AppRadii.brPill,
                  child: InkWell(
                    borderRadius: AppRadii.brPill,
                    onTap: () {},
                    child: const SizedBox(
                      width: 28,
                      height: 28,
                      child: Icon(
                        Iconsax.add,
                        color: AppColors.textOnPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                ProjectCard(),
                SizedBox(height: 12),
                ProjectCard(),
                SizedBox(height: 12),
                ProjectCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  PROJECT CARD (in Today's Tasks sidebar)
// ═══════════════════════════════════════════════════════════════════

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brMd,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Project X dashboard UI design',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const StatusChip(
                label: 'Ongoing',
                tone: StatusTone.primary,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Dashboard UI design is a visually engaging and intuitively structured interface tailored to streamline project management.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style:
                AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Iconsax.clock, color: AppColors.warning, size: 14),
              const SizedBox(width: 4),
              Text(
                'Deadline: ',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Flexible(
                child: Text(
                  '11th - 15th Aug 2023',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAvatarStack(),
                  const SizedBox(width: 8),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: AppRadii.brPill,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Icon(
                      Iconsax.add,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.attach_circle,
                      size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text('2',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary)),
                  const SizedBox(width: 12),
                  const Icon(Iconsax.message_text,
                      size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text('3',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarStack() {
    return SizedBox(
      width: 44,
      height: 26,
      child: Stack(
        children: [
          _miniAvatar(0, AppColors.primary, 'A'),
          Positioned(
            left: 18,
            child: _miniAvatar(1, AppColors.success, 'B'),
          ),
        ],
      ),
    );
  }

  Widget _miniAvatar(int index, Color color, String letter) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadii.brPill,
        border: Border.all(color: AppColors.surface, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: AppTextStyles.caption
            .copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  TONE HELPERS
// ═══════════════════════════════════════════════════════════════════

StatusTone _statusTone(String status) {
  switch (status.toLowerCase().trim()) {
    case 'completed':
    case 'approved':
      return StatusTone.success;
    case 'in_progress':
    case 'in progress':
      return StatusTone.primary;
    case 'in_review':
    case 'in review':
      return StatusTone.info;
    case 'pending':
    case 'pending_approval':
      return StatusTone.warning;
    case 'blocked':
    case 'cancelled':
    case 'canceled':
    case 'rejected':
      return StatusTone.danger;
    case 'todo':
    case 'to do':
    default:
      return StatusTone.neutral;
  }
}
