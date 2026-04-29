import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models.dart';

final List<LeadSourceData> mockLeadSourceData = [
  LeadSourceData('Referrals', 35, AppColors.primary),
  LeadSourceData('Website', 25, const Color(0xFF43A047)),
  LeadSourceData('Cold Calls', 20, const Color(0xFFFFB300)),
  LeadSourceData('Events', 12, const Color(0xFFF4511E)),
  LeadSourceData('Social Media', 8, const Color(0xFF9C27B0)),
];

class LeadSourcesPieChart extends StatelessWidget {
  const LeadSourcesPieChart({super.key});

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
          const MyText('Lead Sources',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          MyText('Where your leads are coming from',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: PieChart(
              PieChartData(
                sections: _buildSections(mockLeadSourceData),
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                startDegreeOffset: 270,
                borderData: FlBorderData(show: false),
                pieTouchData: PieTouchData(enabled: false),
              ),
              duration: const Duration(milliseconds: 250),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(List<LeadSourceData> data) {
    return data.map((source) {
      return PieChartSectionData(
        color: source.color,
        value: source.percent,
        title: '${source.name} ${source.percent.toInt()}%',
        radius: 100,
        titleStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: source.percent < 15 ? Colors.black87 : Colors.white,
            shadows: [
              Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 2)
            ]),
        titlePositionPercentageOffset: 0.84,
      );
    }).toList();
  }
}
