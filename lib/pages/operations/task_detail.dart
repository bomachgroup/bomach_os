import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/image/image_stack.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/operations/models/models.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
            child: MyText('Task not found', style: AppText.bodyLg),
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
        trailing: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            const SizedBox(
              width: 250,
              child: MyTextFormField(
                hintText: 'Search within task...',
                leading: Icon(Iconsax.search_normal,
                    size: 18, color: AppColors.textMuted),
              ),
            ),
            const SortBar(text: "Sort"),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Iconsax.add_circle, size: 18),
              label: const Text('Add Action'),
            ),
          ],
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 24,
              runSpacing: 12,
              children: [
                _buildTaskInfoItem('Task ID', '#${task.id}', Iconsax.info_circle),
                _buildTaskInfoItem('Priority', task.priority, Iconsax.flag),
                _buildTaskInfoItem('Due Date', task.dueDate, Iconsax.calendar),
                _buildTaskInfoItem(
                    'Estimate', '${task.estimatedHours} hrs', Iconsax.timer_1),
                StatusChip(
                  label: task.status,
                  tone: _getStatusTone(task.status),
                ),
              ],
            ),
          ),
        ),
        if (isWideScreen)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: TaskDetailBody(task: task),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildTodayTasksSection(),
              )
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TaskDetailBody(task: task),
              const SizedBox(height: 24),
              _buildTodayTasksSection(),
            ],
          ),
      ],
    );
  }

  Widget _buildTaskInfoItem(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppText.label.copyWith(fontSize: 10, color: AppColors.textMuted)),
            Text(value, style: AppText.bodyMd.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  StatusTone _getStatusTone(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return StatusTone.success;
      case 'in progress':
        return StatusTone.primary;
      case 'pending':
        return StatusTone.warning;
      default:
        return StatusTone.neutral;
    }
  }

  }

  Widget _buildTodayTasksSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 3.3),
          decoration: const BoxDecoration(
            color: AppColors.warning,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(15),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                const MyText("Today's Tasks"),
                const Icon(
                  Iconsax.arrow_down_1,
                ),
                Container(
                  alignment: Alignment.center,
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySubtle,
                    shape: BoxShape.circle,
                  ),
                  child: const MyText("3"),
                ),
                const Spacer(),
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.add,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
        kSizedBoxSM,
        const ProjectCard(),
        kSizedBoxTiny,
        const ProjectCard(),
        kSizedBoxTiny,
        const ProjectCard(),
      ],
    );
  }

class TaskDetailBody extends StatefulWidget {
  final Task task;
  const TaskDetailBody({super.key, required this.task});

  @override
  State<TaskDetailBody> createState() => _TaskDetailBodyState();
}

class _TaskDetailBodyState extends State<TaskDetailBody> {
  String selectedTimeframe = 'Monthly';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey..withValues(alpha: 0.01),
                spreadRadius: 0.1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(widget.task.name, weight: 700, size: 18),
              const SizedBox(height: 8),
              MyText(
                widget.task.description,
                maxLines: 4,
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: [
                  MyText('Project ID: ${widget.task.projectId}',
                      style: const TextStyle(color: Colors.black54)),
                ],
              )
            ],
          ),
        ),
        isSmallScreen
            ? Column(
                children: [
                  _buildStatCard(index: 0),
                  const SizedBox(height: 15),
                  _buildStatCard(index: 1),
                  const SizedBox(height: 15),
                  _buildStatCard(index: 2),
                ],
              )
            : isMediumScreen
                ? Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildStatCard(index: 0)),
                          const SizedBox(width: 15),
                          Expanded(child: _buildStatCard(index: 1)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildStatCard(index: 2),
                    ],
                  )
                : SizedBox(
                    height: 150,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildStatCard(index: 0)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildStatCard(index: 1)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildStatCard(index: 2)),
                      ],
                    ),
                  ),
        const SizedBox(height: 24),
        Container(
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey..withValues(alpha: 0.01),
                spreadRadius: 0.1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MyText(
                'Task Done',
                color: AppColors.neutral800,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 24,
                runSpacing: 16,
                children: [
                  TimeframeTab(
                    title: 'Daily',
                    isSelected: selectedTimeframe == 'Daily',
                    onTap: () => setState(() => selectedTimeframe = 'Daily'),
                  ),
                  TimeframeTab(
                    title: 'Weekly',
                    isSelected: selectedTimeframe == 'Weekly',
                    onTap: () => setState(() => selectedTimeframe = 'Weekly'),
                  ),
                  TimeframeTab(
                    title: 'Monthly',
                    isSelected: selectedTimeframe == 'Monthly',
                    onTap: () => setState(() => selectedTimeframe = 'Monthly'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: isSmallScreen ? 250 : 300,
                child: const TaskChart(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStatCard({required int index}) {
    final cardData = [
      {
        'title': 'Task Completed',
        'value': '08',
        'trend': '10+ more',
        'trendPeriod': 'from last week',
        'lineColor': Colors.blue[700]!,
        'fillColor': Colors.blue[100]!,
      },
      {
        'title': 'New Task',
        'value': '10',
        'trend': '10+ more',
        'trendPeriod': 'from last week',
        'lineColor': Colors.blue[700]!,
        'fillColor': Colors.blue[100]!,
      },
      {
        'title': 'Project Done',
        'value': '10',
        'trend': '08+ more',
        'trendPeriod': 'from last week',
        'lineColor': Colors.red[400]!,
        'fillColor': Colors.red[100]!,
      },
    ];

    final data = cardData[index];

    return StatCard(
      title: data['title'] as String,
      value: data['value'] as String,
      trend: data['trend'] as String,
      trendPeriod: data['trendPeriod'] as String,
      lineColor: data['lineColor'] as Color,
      fillColor: data['fillColor'] as Color,
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final String trendPeriod;
  final Color lineColor;
  final Color fillColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.trend = '',
    this.trendPeriod = '',
    required this.lineColor,
    required this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey..withValues(alpha: 0.01),
            spreadRadius: 0.1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(5),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset("assets/svg/star-chart.svg")),
              const SizedBox(width: 10),
              Expanded(
                child: MyText(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              MyText(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 30,
                  child: MiniLineChart(
                    lineColor: lineColor,
                    fillColor: fillColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    MyText(
                      trend,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    MyText(
                      trendPeriod,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

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
              color: fillColor..withValues(alpha: 0.3),
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

class TimeframeTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const TimeframeTab({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          MyText(
            title,
            isSelectable: false,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.neutral800 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              height: 3,
              width: 60,
              decoration: BoxDecoration(
                color: AppColors.neutral800,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
        ],
      ),
    );
  }
}

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
            return FlLine(
              color: Colors.grey[200],
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
                    child: MyText(
                      months[index],
                      style: TextStyle(
                        color: Colors.grey[600],
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
                return MyText(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: Colors.grey[600],
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
            spots: [
              const FlSpot(0, 50),
              const FlSpot(1, 100),
              const FlSpot(2, 200),
              const FlSpot(3, 300),
              const FlSpot(4, 250),
              const FlSpot(5, 280),
              const FlSpot(6, 220),
              const FlSpot(7, 320),
              const FlSpot(8, 300),
              const FlSpot(9, 350),
              const FlSpot(10, 200),
              const FlSpot(11, 150),
            ],
            isCurved: true,
            color: Colors.blue[700],
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: isSmallScreen ? 3 : 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: Colors.blue[700]!,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.blue[300]!.withValues(alpha: 0.4),
                  Colors.blue[200]!..withValues(alpha: 0.2),
                  Colors.blue[100]!..withValues(alpha: 0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          LineChartBarData(
            spots: [
              const FlSpot(0, 30),
              const FlSpot(1, 70),
              const FlSpot(2, 150),
              const FlSpot(3, 230),
              const FlSpot(4, 180),
              const FlSpot(5, 220),
              const FlSpot(6, 150),
              const FlSpot(7, 250),
              const FlSpot(8, 230),
              const FlSpot(9, 300),
              const FlSpot(10, 150),
              const FlSpot(11, 100),
            ],
            isCurved: true,
            color: Colors.blue[400],
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: isSmallScreen ? 3 : 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: Colors.blue[400]!,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue[100]!..withValues(alpha: 0.3),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 8,
            tooltipBorder: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                return LineTooltipItem(
                  '${touchedSpot.y.toInt()}',
                  const TextStyle(
                    color: Colors.white,
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

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmallScreen = screenWidth < 400;

    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey..withValues(alpha: 0.03),
            spreadRadius: 0.2,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 10,
              runSpacing: 10,
              children: [
                const Expanded(
                  child: MyText(
                    'Project X dashboard UI design',
                    maxLines: 2,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyText(
                        'Ongoing',
                        style: TextStyle(
                            color: AppColors.primary.withValues(alpha: 0.8),
                            fontWeight: FontWeight.bold),
                      ),
                      Icon(
                        Iconsax.arrow_down_1,
                        color: AppColors.primary.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const MyText(
              'Dashboard UI design is a visually engaging and intuitively structured interface tailored to streamline project management',
              maxLines: 10,
              style: TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 12),
            const Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(Iconsax.clock, color: Colors.orange, size: 20),
                MyText(
                  'Deadline: ',
                  style: TextStyle(
                      color: Colors.orange, fontWeight: FontWeight.bold),
                ),
                MyText(
                  '11th - 15th August 2023',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            isVerySmallScreen
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const ProfileIconsStack(
                            imagesPath: [
                              "assets/user1.jpg",
                              "assets/user1.jpg",
                            ],
                          ),
                          kSizedBoxWidthSM,
                          SizedBox(
                            height: 28,
                            width: 28,
                            child: SvgPicture.asset(
                              "assets/svg/add-circle.svg",
                              colorFilter: const ColorFilter.mode(
                                  AppColors.neutral400, BlendMode.srcIn),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(Iconsax.attach_circle, size: 18),
                          SizedBox(width: 4),
                          MyText('2'),
                          SizedBox(width: 12),
                          Icon(Iconsax.message_text, size: 18),
                          SizedBox(width: 4),
                          MyText('3'),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const ProfileIconsStack(
                                  imagesPath: [
                                    "assets/user1.jpg",
                                    "assets/user1.jpg",
                                  ],
                                ),
                                kSizedBoxWidthTiny,
                                SizedBox(
                                  height: 28,
                                  width: 28,
                                  child: SvgPicture.asset(
                                    "assets/svg/add-circle.svg",
                                    colorFilter: const ColorFilter.mode(
                                        AppColors.neutral400, BlendMode.srcIn),
                                  ),
                                ),
                              ],
                            ),
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 28,
                                ),
                                Icon(Iconsax.attach_circle, size: 18),
                                SizedBox(width: 4),
                                MyText('2'),
                                SizedBox(width: 12),
                                Icon(Iconsax.message_text, size: 18),
                                SizedBox(width: 4),
                                MyText('3'),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  )
          ],
        ),
      ),
    );
  }
}
