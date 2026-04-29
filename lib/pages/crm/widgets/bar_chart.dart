import 'package:bomach_os/components/text/my_text.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models.dart';

final List<PipelineStageData> mockPipelineData = [
  PipelineStageData('New Leads', 8),
  PipelineStageData('Qualified', 6),
  PipelineStageData('Proposal', 4),
  PipelineStageData('Negotiation', 3),
  PipelineStageData('Closed Won', 2),
];

class SalesPipelineBarChart extends StatelessWidget {
  const SalesPipelineBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText('Sales Pipeline',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          MyText('Current pipeline status',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: BarChart(
              _mainBarChartData(),
              duration: const Duration(milliseconds: 250),
            ),
          ),
        ],
      ),
    );
  }

  BarChartData _mainBarChartData() {
    return BarChartData(
      titlesData: FlTitlesData(
        show: true,
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 60,
            getTitlesWidget: (value, meta) {
              final stageIndex = value.toInt();
              if (stageIndex >= 0 && stageIndex < mockPipelineData.length) {
                return SideTitleWidget(
                  meta: meta,
                  space: 4,
                  angle: -0.5,
                  child: Text(
                    mockPipelineData[stageIndex].stage,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
                );
              }
              return Container();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: 2,
            getTitlesWidget: (value, meta) {
              if (value.toInt() == value) {
                return Text(value.toInt().toString(),
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 11));
              }
              return Container();
            },
          ),
        ),
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
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey.withValues(alpha: 0.3),
          strokeWidth: 1,
          dashArray: [5, 5],
        ),
      ),
      minY: 0,
      maxY: 8,
      barGroups: mockPipelineData.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: data.count.toDouble(),
              color: const Color(0xFF9C27B0).withValues(alpha: 0.8),
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        );
      }).toList(),
      barTouchData: BarTouchData(enabled: false),
    );
  }
}
