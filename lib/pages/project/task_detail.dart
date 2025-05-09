import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/image/image_stack.dart';
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
    // Get screen width to determine layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 900; // Threshold for layout change

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with search and actions
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

        // Main content area - Responsive layout
        isWideScreen
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    flex: 3,
                    child: TaskDetailBody(),
                  ),
                  const SizedBox(width: 20), // Add spacing between columns
                  Expanded(
                    child: _buildTodayTasksSection(),
                  )
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TaskDetailBody(),
                  const SizedBox(height: 20), // Add spacing between sections
                  _buildTodayTasksSection(),
                ],
              ),
      ],
    );
  }

  // Extract Today's Tasks section to reuse in both layouts
  Widget _buildTodayTasksSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 3.3),
          decoration: const BoxDecoration(
            color: AppColors.orange,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(15),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.grey6,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                const MyText("Today's Tasks"),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                ),
                Container(
                  alignment: Alignment.center,
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.lightBlue,
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
                    Icons.add,
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
        const ProjectCard(),
        const ProjectCard(),
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
    // Get screen width to determine card layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats Cards Row - Make responsive based on screen size
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

        // Task Done Chart Section
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
              color: AppColors.white, borderRadius: BorderRadius.circular(15)),
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

              // Time period tabs - Make responsive
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

              // Main chart with responsive height
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

  // Helper method to build stat cards with consistent data
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
    // Get screen width to adjust chart display
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
              interval:
                  isSmallScreen ? 2 : 1, // Show fewer labels on small screens
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
                  radius: isSmallScreen ? 3 : 4,
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

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmallScreen = screenWidth < 400;

    return Card(
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and status - Make responsive
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
                    color: AppColors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyText(
                        'Ongoing',
                        style: TextStyle(
                            color: AppColors.blue.withValues(alpha: 0.8),
                            fontWeight: FontWeight.bold),
                      ),
                      Icon(
                        Icons.arrow_drop_down_sharp,
                        color: AppColors.blue.withValues(alpha: 0.8),
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
            // Deadline - Uses Wrap for responsiveness
            const Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(Icons.access_time, color: Colors.orange, size: 20),
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
            // Avatars and icons - Make responsive
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
                                  AppColors.grey3, BlendMode.srcIn),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(Icons.attach_file, size: 18),
                          SizedBox(width: 4),
                          MyText('2'),
                          SizedBox(width: 12),
                          Icon(Icons.chat_bubble_outline, size: 18),
                          SizedBox(width: 4),
                          MyText('3'),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      // Avatars
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
                              AppColors.grey3, BlendMode.srcIn),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.attach_file, size: 18),
                      const SizedBox(width: 4),
                      const MyText('2'),
                      const SizedBox(width: 12),
                      const Icon(Icons.chat_bubble_outline, size: 18),
                      const SizedBox(width: 4),
                      const MyText('3'),
                    ],
                  )
          ],
        ),
      ),
    );
  }
}
