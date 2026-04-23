import 'package:bms_front_end/components/text/app_text.dart';
import 'package:bms_front_end/pages/analytics/overview.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'widgets/metrics_card.dart';

class ProjectsAnalytics extends StatelessWidget {
  const ProjectsAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProjectBody();
  }
}

class ProjectBody extends StatelessWidget {
  const ProjectBody({super.key});

  static const List<ProjectStatus> statusData = [
    ProjectStatus('Completed', 100, Colors.deepPurple),
    ProjectStatus('Active', 25, Colors.deepPurple),
    ProjectStatus('On Hold', 5, Colors.deepPurple),
    ProjectStatus('Cancelled', 0, Colors.deepPurple),
  ];

  static const List<TeamPerformance> teams = [
    TeamPerformance('Survey Team A', 25, 12, 0.96),
    TeamPerformance('Survey Team B', 22, 14, 0.91),
    TeamPerformance('Engineering Team', 18, 18, 0.94),
    TeamPerformance('CAD Team', 30, 8, 0.98),
    TeamPerformance('QA Team', 32, 3, 0.99),
  ];

  static const List<Project> recentProjects = [
    Project('Phase 2 Boundary Survey', 'IZ4-001', 'Lagos State Government',
        2850000, 14, 'Completed', 100),
    Project('Industrial Estate Topographic Survey', 'IZ4-002',
        'Federal Capital Development Authority', 4200000, 21, 'Active', 75),
    Project('arcourt Residential Layout', 'IZ4-003',
        'Rivers State Ministry of Housing', 1850000, 10, 'Active', 45),
    Project('Agricultural Land Survey', 'IZ4-004', 'Kano State ADP', 950000, 8,
        'Completed', 100),
    Project('University Campus Survey', 'IZ4-005', 'University of Ibadan',
        1200000, 12, 'Active', 60),
  ];

  @override
  Widget build(BuildContext context) {
    const Color backgroundCardColor = Color(0xFFFFFFFF);
    const Color primaryPurple = Color(0xFF673AB7);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 700;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              !isMobile
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText.displayLg(
                                'Analytics',
                              ),
                              const SizedBox(height: 4),
                              AppText.bodyMd(
                                'Business intelligence and performance metrics',
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                        ),
                        const AnalyticsActions(),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.displayLg(
                          'Analytics',
                        ),
                        const SizedBox(height: 4),
                        AppText.bodyMd(
                          'Business intelligence and performance metrics',
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: 16),
                        const AnalyticsActions(),
                      ],
                    ),
              const SizedBox(height: 20),
              isMobile
                  ? const Column(
                      children: [
                        AnalyticsMetricCard(
                          title: 'Total Projects',
                          value: '127',
                          subtitle: 'All projects',
                          showtrend: false,
                        ),
                        SizedBox(height: 12),
                        AnalyticsMetricCard(
                          title: 'Active Projects',
                          value: '23',
                          showtrend: false,
                          subtitle: 'Currently running',
                        ),
                        SizedBox(height: 12),
                        AnalyticsMetricCard(
                          title: 'Completed',
                          value: '98',
                          showtrend: false,
                          subtitle: 'Successfully finished',
                          color: Colors.green,
                        ),
                        SizedBox(height: 12),
                        AnalyticsMetricCard(
                          title: 'Success Rate',
                          value: '92.1%',
                          showtrend: false,
                          subtitle: 'Project completion rate',
                          color: Colors.green,
                        ),
                      ],
                    )
                  : const Row(
                      children: [
                        Expanded(
                          child: AnalyticsMetricCard(
                            title: 'Total Projects',
                            value: '127',
                            subtitle: 'All projects',
                            showtrend: false,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: AnalyticsMetricCard(
                            title: 'Active Projects',
                            value: '23',
                            showtrend: false,
                            subtitle: 'Currently running',
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: AnalyticsMetricCard(
                            title: 'Completed',
                            value: '98',
                            showtrend: false,
                            subtitle: 'Successfully finished',
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: AnalyticsMetricCard(
                            title: 'Success Rate',
                            value: '92.1%',
                            showtrend: false,
                            subtitle: 'Project completion rate',
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 20),
              isMobile
                  ? const Column(
                      children: [
                        _ProjectStatusDistribution(
                          statusData: statusData,
                          cardColor: backgroundCardColor,
                          barColor: primaryPurple,
                        ),
                        SizedBox(height: 20),
                        _TeamPerformance(
                          teams: teams,
                          cardColor: backgroundCardColor,
                        ),
                      ],
                    )
                  : const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _ProjectStatusDistribution(
                            statusData: statusData,
                            cardColor: backgroundCardColor,
                            barColor: primaryPurple,
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _TeamPerformance(
                            teams: teams,
                            cardColor: backgroundCardColor,
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 20),
              RecentProjectsTable(),
            ],
          ),
        );
      },
    );
  }
}

class _ProjectStatusDistribution extends StatelessWidget {
  final List<ProjectStatus> statusData;
  final Color cardColor;
  final Color barColor;

  const _ProjectStatusDistribution({
    required this.statusData,
    required this.cardColor,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Project Status Distribution',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('Breakdown of projects by current status',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  minY: 0,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval:
                            25, // Adjusted to match the grid lines (0, 25, 50, 75, 100)
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style:
                              const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= statusData.length) {
                            return Container();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(statusData[idx].label,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500)),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    horizontalInterval:
                        25, // Adjusted for 25% intervals same as grid
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withValues(alpha: 0.3),
                      strokeWidth: 1,
                    ),
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(statusData.length, (i) {
                    final status = statusData[i];
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: status.count.toDouble(),
                          color: barColor,
                          width: 50,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamPerformance extends StatelessWidget {
  final List<TeamPerformance> teams;
  final Color cardColor;

  const _TeamPerformance({required this.teams, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    final totalProjects =
        teams.fold<int>(0, (sum, team) => sum + team.projects);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Team Performance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('Project completion by team',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),
            ...teams.map((team) =>
                _TeamPerformanceRow(team: team, totalProjects: totalProjects)),
          ],
        ),
      ),
    );
  }
}

class _TeamPerformanceRow extends StatelessWidget {
  final TeamPerformance team;
  final int totalProjects;

  const _TeamPerformanceRow({required this.team, required this.totalProjects});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(team.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('${(team.successRate * 100).toStringAsFixed(0)}% success',
                  style: const TextStyle(color: Colors.green)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${team.projects} projects',
                  style: const TextStyle(color: Colors.grey)),
              Text('Avg: ${team.avgDays} days',
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
          LinearProgressIndicator(
            value: team.successRate,
            minHeight: 8,
            color: Colors.black,
            backgroundColor: Colors.grey,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }
}

class ProjectStatus {
  final String label;
  final int count;
  final Color color;
  const ProjectStatus(this.label, this.count, this.color);
}

class TeamPerformance {
  final String name;
  final int projects;
  final int avgDays;
  final double successRate;
  const TeamPerformance(
      this.name, this.projects, this.avgDays, this.successRate);
}

class Project {
  final String name;
  final String id;
  final String client;
  final double value;
  final int duration;
  final String status;
  final int progress;
  const Project(this.name, this.id, this.client, this.value, this.duration,
      this.status, this.progress);
}

const List<Project> recentProjects = [
  Project('Phase 2 Boundary Survey', 'IZ4-001', 'Lagos State Government',
      2850000, 14, 'Completed', 100),
  Project('Industrial Estate Topographic Survey', 'IZ4-002',
      'Federal Capital Development Authority', 4200000, 21, 'Active', 75),
  Project('arcourt Residential Layout', 'IZ4-003',
      'Rivers State Ministry of Housing', 1850000, 10, 'Active', 45),
  Project('Agricultural Land Survey', 'IZ4-004', 'Kano State ADP', 950000, 8,
      'Completed', 100),
  Project('University Campus Survey', 'IZ4-005', 'University of Ibadan',
      1200000, 12, 'Active', 60),
];

class RecentProjectsTable extends StatelessWidget {
  RecentProjectsTable({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Active':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatCurrency(double value) {
    return '₦${value.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  Widget _buildStatusChip(String status, bool isMobile) {
    final color = _getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 6 : 8, vertical: isMobile ? 2 : 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: isMobile ? 10 : 12,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildProgressBar(int progress, Color primaryColor, bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            minHeight: isMobile ? 4 : 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text('$progress%', style: TextStyle(fontSize: isMobile ? 10 : 12)),
      ],
    );
  }

  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    const Color cardColor = Color(0xFFFFFFFF);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: cardColor,
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 10 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Recent Projects',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Text('Latest project activities and status',
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 16),
                Scrollbar(
                  controller: scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: isMobile ? 600 : 900,
                        maxWidth: isMobile ? 700 : double.infinity,
                      ),
                      child: DataTable(
                        columnSpacing: isMobile ? 16 : 30,
                        dataRowMinHeight: isMobile ? 36 : 50,
                        dataRowMaxHeight: isMobile ? 48 : 60,
                        headingRowHeight: isMobile ? 32 : 40,
                        border: TableBorder(
                          verticalInside: BorderSide.none,
                          horizontalInside: BorderSide(
                              color: Colors.grey.shade300, width: 0.5),
                          top: BorderSide(
                              color: Colors.grey.shade300, width: 0.5),
                        ),
                        columns: [
                          DataColumn(
                              label: Text('Project',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isMobile ? 12 : 14))),
                          DataColumn(
                              label: Text('Client',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isMobile ? 12 : 14))),
                          DataColumn(
                              label: Text('Value',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isMobile ? 12 : 14))),
                          DataColumn(
                              label: Text('Duration',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isMobile ? 12 : 14))),
                          DataColumn(
                              label: Text('Status',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isMobile ? 12 : 14))),
                          DataColumn(
                              label: Text('Progress',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isMobile ? 12 : 14))),
                        ],
                        rows: recentProjects
                            .map((proj) => DataRow(cells: [
                                  DataCell(Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(proj.id,
                                          style: TextStyle(
                                              fontSize: isMobile ? 10 : 12,
                                              color: Colors.grey)),
                                      Text(proj.name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: isMobile ? 11 : 13)),
                                    ],
                                  )),
                                  DataCell(Text(proj.client,
                                      style: TextStyle(
                                          fontSize: isMobile ? 11 : 13))),
                                  DataCell(Text(_formatCurrency(proj.value),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: isMobile ? 11 : 13))),
                                  DataCell(Text('${proj.duration} days',
                                      style: TextStyle(
                                          fontSize: isMobile ? 11 : 13))),
                                  DataCell(
                                      _buildStatusChip(proj.status, isMobile)),
                                  DataCell(_buildProgressBar(
                                      proj.progress, Colors.black, isMobile)),
                                ]))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
