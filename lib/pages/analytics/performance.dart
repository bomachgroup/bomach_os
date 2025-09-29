import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'projects.dart';

const Color kDarkBackground = Color(0xFF1E1E1E);
const Color kCardBackground = Color(0xFFFFFFFF);
const Color kGreenLine = Color(0xFF4CAF50); // Efficiency/Completion
const Color kBlueLine = Color(0xFF2196F3); // Productivity/Projects
const Color kOrangeLine = Color(0xFFFF9800); // Satisfaction

const List<FlSpot> efficiencyData = [
  FlSpot(0, 80),
  FlSpot(1, 80),
  FlSpot(2, 79),
  FlSpot(3, 85),
  FlSpot(4, 85),
  FlSpot(5, 87),
];
const List<FlSpot> productivityData = [
  FlSpot(0, 87),
  FlSpot(1, 87),
  FlSpot(2, 87),
  FlSpot(3, 90),
  FlSpot(4, 90),
  FlSpot(5, 90),
];
const List<FlSpot> satisfactionData = [
  FlSpot(0, 4.2),
  FlSpot(1, 4.2),
  FlSpot(2, 4.2),
  FlSpot(3, 4.2),
  FlSpot(4, 4.2),
  FlSpot(5, 4.2),
];

const List<Map<String, dynamic>> locationData = [
  {'city': 'Lagos', 'completion': 95, 'projects': 40},
  {'city': 'Abuja', 'completion': 90, 'projects': 35},
  {'city': 'Port Harcourt', 'completion': 88, 'projects': 30},
  {'city': 'Kano', 'completion': 85, 'projects': 15},
  {'city': 'Ibadan', 'completion': 80, 'projects': 10},
];

class PerformanceAnalytics extends StatelessWidget {
  const PerformanceAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardPage();
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 1100) {
                      return Column(
                        children: [
                          _MetricCard(
                              title: "Team Performance",
                              child: _TeamPerformanceMetrics()),
                          const SizedBox(height: 16),
                          _MetricCard(
                              title: "Client Metrics", child: _ClientMetrics()),
                          const SizedBox(height: 16),
                          _MetricCard(
                              title: "Financial Health",
                              child: _FinancialHealth()),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _MetricCard(
                                title: "Team Performance",
                                child: _TeamPerformanceMetrics())),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _MetricCard(
                                title: "Client Metrics",
                                child: _ClientMetrics())),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _MetricCard(
                                title: "Financial Health",
                                child: _FinancialHealth())),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                _MetricCard(
                  title: "Performance Trends",
                  subtitle: "Key performance indicators over time",
                  child: SizedBox(
                    height: 280,
                    child: _PerformanceTrendsChart(),
                  ),
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 1100) {
                      return Column(
                        children: [
                          _MetricCard(
                              title: "Performance by Location",
                              subtitle: "Regional performance comparison",
                              child: SizedBox(
                                  height: 280, child: _LocationBarChart())),
                          const SizedBox(height: 16),
                          const _MetricCard(
                              title: "Performance Benchmarks",
                              child: _Benchmarks()),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _MetricCard(
                              title: "Performance by Location",
                              subtitle: "Regional performance comparison",
                              child: SizedBox(
                                  height: 280, child: _LocationBarChart())),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: _MetricCard(
                              title: "Performance Benchmarks",
                              child: _Benchmarks()),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kDarkBackground,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Analytics',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              Text('Business intelligence and performance metrics',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey)),
            ],
          ),
          Row(
            children: [
              _ActionButton(
                  label: 'Last 30 days',
                  icon: Icons.arrow_drop_down,
                  isPrimary: true),
              SizedBox(width: 8),
              _ActionButton(label: 'Refresh', icon: Icons.refresh),
              SizedBox(width: 8),
              _ActionButton(label: 'Export PDF', icon: Icons.picture_as_pdf),
              SizedBox(width: 8),
              _ActionButton(label: 'Export Excel', icon: Icons.table_chart),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;

  const _ActionButton(
      {required this.label, required this.icon, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isPrimary ? Colors.white : kDarkBackground,
        border: Border.all(color: Colors.grey.shade600),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isPrimary ? Colors.black : Colors.white),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isPrimary ? Colors.black : Colors.white)),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _MetricCard({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: kCardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (subtitle != null) ...[
              Text(subtitle!,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 12),
            ] else
              const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _TeamPerformanceMetrics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetricRow(label: "Total Employees", value: "42"),
        _MetricRow(
            label: "Productivity Score",
            value: "87/100",
            valueColor: kBlueLine),
        _MetricRow(
            label: "Satisfaction Score",
            value: "4.2/5",
            valueColor: kOrangeLine),
      ],
    );
  }
}

class _ClientMetrics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetricRow(label: "Total Clients", value: "84"),
        _MetricRow(label: "New This Month", value: "7"),
        _MetricRow(
            label: "Retention Rate", value: "88.5%", valueColor: kGreenLine),
      ],
    );
  }
}

class _FinancialHealth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetricRow(
            label: "Revenue Growth", value: "20.3%", valueColor: kGreenLine),
        _MetricRow(label: "Avg Project Value", value: "₦360,236.22"),
        _MetricRow(label: "Monthly Revenue", value: "₦3,850,000.00"),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _MetricRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceTrendsChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"];
                final index = value.toInt();
                if (index >= 0 && index < months.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(months[index],
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  );
                }
                return Container();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString(),
                    style: const TextStyle(fontSize: 10, color: Colors.grey));
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.3),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: efficiencyData,
            isCurved: true,
            color: kGreenLine,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
                show: true, getDotPainter: _getDotPainter(kGreenLine)),
            belowBarData: BarAreaData(show: false),
          ),
          LineChartBarData(
            spots: productivityData,
            isCurved: true,
            color: kBlueLine,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData:
                FlDotData(show: true, getDotPainter: _getDotPainter(kBlueLine)),
            belowBarData: BarAreaData(show: false),
          ),
          LineChartBarData(
            spots: satisfactionData
                .map((spot) => FlSpot(spot.x, spot.y * 20))
                .toList(),
            isCurved: true,
            color: kOrangeLine,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
                show: true, getDotPainter: _getDotPainter(kOrangeLine)),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}

// Custom Dot Painter to match the circle style in the image
FlDotCirclePainter Function(
        dynamic spot, dynamic percent, dynamic bar, dynamic index)
    _getDotPainter(Color color) {
  return (spot, percent, bar, index) => FlDotCirclePainter(
        radius: 4,
        color: color,
        strokeColor: color,
        strokeWidth: 0,
      );
}

// --- Location Bar Chart Widget ---

class _LocationBarChart extends StatelessWidget {
  BarChartGroupData _makeGroup(int x, double completion, double projects) {
    return BarChartGroupData(
      x: x,
      barRods: [
        // Completion (Green Bar)
        BarChartRodData(
          toY: completion,
          color: kGreenLine,
          width: 10,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3), topRight: Radius.circular(3)),
        ),
        // Projects (Blue Bar)
        BarChartRodData(
          toY: projects,
          color: kBlueLine,
          width: 10,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3), topRight: Radius.circular(3)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(value.toInt().toString(),
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(locationData[index]['city']!,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500)),
                );
              },
              interval: 1,
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.3),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(locationData.length, (i) {
          final data = locationData[i];
          return _makeGroup(
              i, data['completion']!.toDouble(), data['projects']!.toDouble());
        }),
      ),
    );
  }
}

// --- Benchmarks Widget ---

class _Benchmarks extends StatelessWidget {
  const _Benchmarks();

  // Helper to build a benchmark comparison row
  Widget _buildBenchmarkRow(
      String label, String value, String industryValue, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$value vs $industryValue',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: valueColor)),
              // Simple simulation of the progress bar/line in the image
              Container(
                width: 150,
                height: 2,
                color: Colors.grey.shade300,
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 100, // Represents the length of the internal bar
                  height: 2,
                  color: valueColor,
                ),
              )
            ],
          ),
          const Divider(height: 16, color: Colors.grey),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Key metrics vs industry standards",
            style: TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 12),
        _buildBenchmarkRow(
            "Project Success Rate", "92.1%", "85% industry", kGreenLine),
        _buildBenchmarkRow(
            "Client Retention", "88.5%", "80% industry", kGreenLine),
        _buildBenchmarkRow(
            "Employee Productivity", "87%", "75% industry", kBlueLine),
        _buildBenchmarkRow(
            "Revenue Growth", "20.3%", "12% industry", kGreenLine),
      ],
    );
  }
}

class RecentProjectsTable extends StatelessWidget {
  const RecentProjectsTable({super.key});

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
        color: color.withOpacity(0.1),
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

  @override
  Widget build(BuildContext context) {
    const Color cardColor = Color(0xFFFFFFFF);
    const Color primaryPurple = Color(0xFF673AB7);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey.shade200),
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: isMobile ? 700 : 0),
                    child: DataTable(
                      columnSpacing: isMobile ? 16 : 30,
                      dataRowMinHeight: isMobile ? 36 : 50,
                      dataRowMaxHeight: isMobile ? 48 : 60,
                      headingRowHeight: isMobile ? 32 : 40,
                      border: TableBorder(
                        verticalInside: BorderSide.none,
                        horizontalInside:
                            BorderSide(color: Colors.grey.shade300, width: 0.5),
                        top:
                            BorderSide(color: Colors.grey.shade300, width: 0.5),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    proj.progress, primaryPurple, isMobile)),
                              ]))
                          .toList(),
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
