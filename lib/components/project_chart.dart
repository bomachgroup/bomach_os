import 'package:bms_front_end/views/styles/colors_style.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProjectChart extends StatelessWidget {
  const ProjectChart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 4),
   decoration: BoxDecoration(
       color: AppColors.cardColor,
       borderRadius: BorderRadius.circular(20)
   ),
      height: 208,
   child: Center(
     child: BarChart(
      BarChartData(
        titlesData: const FlTitlesData(
          
        ),
        maxY: 100,minY: 0,
        gridData: const FlGridData()
      )),
   ),
    );
  }
}