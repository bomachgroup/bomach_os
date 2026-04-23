import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/text/app_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../src/constants/spaces.dart';
import 'overview.dart';

const Color kDarkBackground = Color(0xFF1E1E1E);
const Color kCardBackground = Color(0xFFFFFFFF);
const Color kGreenLine = Color(0xFF4CAF50);
const Color kBlueLine = Color(0xFF2196F3);
const Color kOrangeLine = AppColors.warning;

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
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 700;

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        !isMobile
            ? const Row(
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
                  AnalyticsActions(),
                ],
              ),
        kSizedBox,
        if (isMobile)
          Column(
            children: [
              _MetricCard(
                  title: "Team Performance", child: _TeamPerformanceMetrics()),
              const SizedBox(height: 16),
              _MetricCard(title: "Client Metrics", child: _ClientMetrics()),
              const SizedBox(height: 16),
              _MetricCard(title: "Financial Health", child: _FinancialHealth()),
            ],
          ),
        if (!isMobile)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: _MetricCard(
                      title: "Team Performance",
                      child: _TeamPerformanceMetrics())),
              const SizedBox(width: 16),
              Expanded(
                  child: _MetricCard(
                      title: "Client Metrics", child: _ClientMetrics())),
              const SizedBox(width: 16),
              Expanded(
                  child: _MetricCard(
                      title: "Financial Health", child: _FinancialHealth())),
            ],
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
        const SizedBox(width: 16),
        if (!isMobile)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _MetricCard(
                  title: "Performance by Location",
                  subtitle: "Regional performance comparison",
                  child: SizedBox(height: 280, child: _LocationBarChart()),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: _MetricCard(
                  title: "Performance Benchmarks",
                  child: _Benchmarks(),
                ),
              ),
            ],
          ),
        if (isMobile)
          Column(
            children: [
              const SizedBox(height: 16),
              _MetricCard(
                title: "Performance by Location",
                subtitle: "Regional performance comparison",
                child: SizedBox(
                  height: 220,
                  child: _LocationBarChart(),
                ),
              ),
              const SizedBox(height: 16),
              const _MetricCard(
                title: "Performance Benchmarks",
                child: _Benchmarks(),
              ),
            ],
          ),
        const SizedBox(height: 24),
      ]);
    });
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _MetricCard({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: kCardBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.h4(title),
          if (subtitle != null) ...[
            AppText.bodySm(subtitle!, color: AppColors.textMuted),
            const SizedBox(height: 12),
          ] else
            const SizedBox(height: 12),
          child,
        ],
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
        ),
        _MetricRow(
          label: "Satisfaction Score",
          value: "4.2/5",
        ),
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
          label: "Retention Rate",
          value: "88.5%",
        ),
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
        _MetricRow(label: "Revenue Growth", value: "20.3%"),
        _MetricRow(label: "Avg Project Value", value: "₦360,236.22"),
        _MetricRow(label: "Monthly Revenue", value: "₦3,850,000.00"),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetricRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 14, color: Colors.black54)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
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
            color: Colors.grey.withValues(alpha: 0.3),
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

class _LocationBarChart extends StatelessWidget {
  BarChartGroupData _makeGroup(int x, double completion, double projects) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: completion,
          color: kGreenLine,
          width: 10,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(3), topRight: Radius.circular(3)),
        ),
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
            color: Colors.grey.withValues(alpha: 0.3),
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

class _Benchmarks extends StatelessWidget {
  const _Benchmarks();

  Widget _buildBenchmarkRow(String label, double value, String industryValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(label,
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black54)),
              ),
              Text(
                '${(value * 100).truncateToDouble()}% vs $industryValue',
              ),
            ],
          ),
          LinearProgressIndicator(
            value: value,
            minHeight: 8,
            color: Colors.black,
            backgroundColor: Colors.grey,
            borderRadius: BorderRadius.circular(5),
          ),
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
          "Project Success Rate",
          0.921,
          "85% industry",
        ),
        _buildBenchmarkRow(
          "Client Retention",
          .885,
          "80% industry",
        ),
        _buildBenchmarkRow(
          "Employee Productivity",
          .87,
          "75% industry",
        ),
        _buildBenchmarkRow(
          "Revenue Growth",
          .203,
          "12% industry",
        ),
      ],
    );
  }
}
