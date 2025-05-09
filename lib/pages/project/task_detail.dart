import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TaskDetail extends StatefulWidget {
  const TaskDetail({super.key});

  @override
  State<TaskDetail> createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetail> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 10,
                runSpacing: 10,
                children: [
                  const MyText(
                    'Task',
                    style: AppText.black_500_32,
                  ),
                  Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    children: [
                      SizedBox(
                        width: 150,
                        child: MyTextFormField(
                          hintText: 'Search...',
                          leading: Icon(
                            Icons.search,
                            color: AppColors.grey1.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      const SortBar(text: "Sort"),
                      Container(
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20)),
                        child: SvgPicture.asset(
                          "assets/svg/notification.svg",
                          colorFilter: const ColorFilter.mode(
                            AppColors.black,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      MyElevatedButton(
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.white,
                        ),
                        child: "Add Task",
                        onTap: () {},
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        kSizedBox,
        const TaskDetailBody(),
      ],
    );
  }
}

class TaskDetailBody extends StatefulWidget {
  const TaskDetailBody({super.key});

  @override
  State<TaskDetailBody> createState() => _TaskDetailBodyState();
}

class _TaskDetailBodyState extends State<TaskDetailBody> {
  String selectedTimeframe = 'Monthly';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards Row
          SizedBox(
            height: 150,
            child: Row(
              spacing: 15,
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Task Completed',
                    value: '08',
                    trend: '10+ more',
                    trendPeriod: 'from last week',
                    lineColor: Colors.blue[700]!,
                    fillColor: Colors.blue[100]!,
                  ),
                ),
                Expanded(
                  child: StatCard(
                    title: 'New Task',
                    value: '10',
                    trend: '10+ more',
                    trendPeriod: 'from last week',
                    lineColor: Colors.blue[700]!,
                    fillColor: Colors.blue[100]!,
                  ),
                ),
                Expanded(
                  child: StatCard(
                    title: 'Project Done',
                    value: '10',
                    trend: '08+ more',
                    trendPeriod: 'from last week',
                    lineColor: Colors.red[400]!,
                    fillColor: Colors.red[100]!,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Task Done Chart Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MyText(
                  'Task Done',
                  color: AppColors.darkBlue,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Time period tabs
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TimeframeTab(
                      title: 'Daily',
                      isSelected: selectedTimeframe == 'Daily',
                      onTap: () => setState(() => selectedTimeframe = 'Daily'),
                    ),
                    const SizedBox(width: 24),
                    TimeframeTab(
                      title: 'Weekly',
                      isSelected: selectedTimeframe == 'Weekly',
                      onTap: () => setState(() => selectedTimeframe = 'Weekly'),
                    ),
                    const SizedBox(width: 24),
                    TimeframeTab(
                      title: 'Monthly',
                      isSelected: selectedTimeframe == 'Monthly',
                      onTap: () =>
                          setState(() => selectedTimeframe = 'Monthly'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Main chart
                const SizedBox(
                  height: 300,
                  child: TaskChart(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Project Tasks Section
          // const Column(
          //   children: [
          //     ProjectTaskCard(
          //       title: 'Project X dashboard UI design',
          //       status: 'Ongoing',
          //       description:
          //           'Dashboard UI design is a visually engaging and intuitively structured interface tailored to streamline project management.',
          //       deadline: 'Deadline: 11th - 15th August 2023',
          //       memberCount: 3,
          //     ),
          //     SizedBox(height: 16),
          //     ProjectTaskCard(
          //       title: 'Project X Product documentation',
          //       status: 'TO DO',
          //       description:
          //           'Dashboard UI design is a visually engaging and intuitively structured interface tailored to streamline project management.',
          //       deadline: 'Deadline: 11th - 15th August 2023',
          //       memberCount: 3,
          //     ),
          //     SizedBox(height: 16),
          //     ProjectTaskCard(
          //       title: 'Project X dashboard UI design',
          //       status: 'Ongoing',
          //       description:
          //           'Dashboard UI design is a visually engaging and intuitively structured interface tailored to streamline project management.',
          //       deadline: 'Deadline: 11th - 15th August 2023',
          //       memberCount: 3,
          //     ),
          //   ],
          // ),
        ],
      ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
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
                    color: AppColors.blue.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset("assets/svg/star-chart.svg")),
              kSizedBoxWidthSM,
              MyText(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
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
            spacing: 10,
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
              color: fillColor.withOpacity(0.3),
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
              color: isSelected ? AppColors.darkBlue : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              height: 3,
              width: 60,
              decoration: BoxDecoration(
                color: AppColors.darkBlue,
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
              interval: 1,
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
                        fontSize: 12,
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
                    fontSize: 12,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 11,
        minY: 0,
        maxY: 400,
        lineBarsData: [
          // Main line
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
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: Colors.blue[700]!,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue[200]!.withOpacity(0.4),
              // gradientFrom: const Offset(0, 0),
              // gradientTo: const Offset(0, 1),
              // gradientColorStops: [0, 0.7, 1.0],
              gradient: LinearGradient(
                colors: [
                  Colors.blue[300]!.withOpacity(0.4),
                  Colors.blue[200]!.withOpacity(0.2),
                  Colors.blue[100]!.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Secondary line
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
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: Colors.blue[400]!,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue[100]!.withOpacity(0.3),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            // tooltipBgColor: Colors.white,
            tooltipRoundedRadius: 8,
            tooltipBorder: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class ProjectTaskCard extends StatelessWidget {
  final String title;
  final String status;
  final String description;
  final String deadline;
  final int memberCount;

  const ProjectTaskCard({
    super.key,
    required this.title,
    required this.status,
    required this.description,
    required this.deadline,
    required this.memberCount,
  });

  @override
  Widget build(BuildContext context) {
    final isOngoing = status.toLowerCase() == 'ongoing';
    final statusColor = isOngoing ? Colors.blue : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
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
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MyText(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: statusColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: MyText(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MyText(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: Colors.orange,
              ),
              const SizedBox(width: 4),
              MyText(
                deadline,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Team members avatars
              SizedBox(
                height: 32,
                child: Stack(
                  children: List.generate(
                    memberCount,
                    (index) => Positioned(
                      left: index * 20.0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: MyText(
                            String.fromCharCode(65 + index),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )..add(
                      Positioned(
                        left: memberCount * 20.0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: const Center(
                            child: MyText(
                              '+1',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ),
              ),
              // Action buttons
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.comment_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.attach_file,
                      size: 16,
                      color: Colors.grey[600],
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
}
