import 'package:bms_front_end/components/text/my_text.dart' show MyText;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

const List<double> newClientsData = [15, 18, 22, 28, 30, 35];
const List<double> newLeadsData = [28, 32, 29, 42, 38, 45];
const List<double> revenueData = [
  35000000,
  42000000,
  38000000,
  55000000,
  50000000,
  65000000
];

double max_y_clients = 60;
double max_y_revenue = 80000000;
double min_y = 0;

double revenue_scale_factor = max_y_revenue / max_y_clients;

class MonthlyPerformanceChart extends StatelessWidget {
  const MonthlyPerformanceChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText(
            'Monthly Performance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          MyText(
            'Client acquisition and revenue trends',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: LineChart(
              _mainLineChartData(),
              duration: const Duration(milliseconds: 250),
            ),
          ),
          const SizedBox(height: 20),
          _buildLegend(),
        ],
      ),
    );
  }

  LineChartData _mainLineChartData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withValues(alpha: 0.3),
            strokeWidth: 1,
            dashArray: [5, 5],
          );
        },
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom:
              BorderSide(color: Colors.grey.withValues(alpha: 0.5), width: 1),
          left: const BorderSide(color: Colors.transparent),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            getTitlesWidget: (value, meta) {
              // Primary Y-Axis
              return Text(value.toInt().toString(),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11));
            },
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 60,
            getTitlesWidget: (value, meta) {
              // Secondary Y-Axis
              final actualRevenue = (value * revenue_scale_factor);

              String formatNumber(double number) {
                // A simple way to format, you might use intl package for real formatting but i dont like using too much packages
                return number.toInt().toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},');
              }

              if (value == 0 || value.toInt() % 15 == 0) {
                return Text(formatNumber(actualRevenue),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                    textAlign: TextAlign.right);
              }
              return Container();
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTitlesWidget: (value, meta) {
              const List<String> months = [
                'Aug',
                'Sep',
                'Oct',
                'Nov',
                'Dec',
                'Jan'
              ];
              if (value >= 0 && value < months.length) {
                return SideTitleWidget(
                  meta: meta,
                  fitInside: SideTitleFitInsideData(
                      enabled: true,
                      axisPosition: meta.axisPosition,
                      parentAxisSize: meta.parentAxisSize,
                      distanceFromEdge: 12),
                  child: Text(months[value.toInt()],
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                );
              }
              return Container();
            },
          ),
        ),
      ),
      minX: 0,
      maxX: newClientsData.length.toDouble() - 1,
      minY: min_y,
      maxY: max_y_clients,
      lineBarsData: [
        _buildLineBarData(
            newClientsData,
            const Color(0xFF673AB7).withValues(alpha: 0.5),
            true,
            const Color(0xFF673AB7).withValues(alpha: 0.2)),
        _buildLineBarData(newLeadsData, Colors.green.withValues(alpha: 0.7),
            true, Colors.green.withValues(alpha: 0.2)),
        _buildRevenueLineBarData(),
      ],
      lineTouchData: const LineTouchData(enabled: true),
    );
  }

  LineChartBarData _buildLineBarData(
      List<double> data, Color color, bool showArea, Color areaColor) {
    return LineChartBarData(
      spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i])),
      isCurved: true,
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: showArea,
        color: areaColor,
      ),
    );
  }

  LineChartBarData _buildRevenueLineBarData() {
    final scaledRevenueData =
        revenueData.map((rev) => rev / revenue_scale_factor).toList();

    return LineChartBarData(
      spots: List.generate(scaledRevenueData.length,
          (i) => FlSpot(i.toDouble(), scaledRevenueData[i])),
      isCurved: true,
      color: Colors.orange,
      barWidth: 3,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
          radius: 4,
          color: Colors.orange,
          strokeWidth: 2,
          strokeColor: Colors.white,
        ),
      ),
      belowBarData: BarAreaData(show: false),
    );
  }

  Widget _buildLegend() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: Color(0xFF673AB7), label: 'New Clients'),
        SizedBox(width: 20),
        _LegendItem(color: Colors.green, label: 'New Leads'),
        SizedBox(width: 20),
        _LegendItem(color: Colors.orange, label: 'Revenue'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }
}
