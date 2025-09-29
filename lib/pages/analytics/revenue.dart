import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../components/text/my_text.dart';
import '../../src/constants/spaces.dart';
import '../../src/constants/textstyle.dart';
import 'overview.dart';
import 'widgets/metrics_card.dart';

class RevenueAnalyticsPage extends StatelessWidget {
  const RevenueAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final screenWidth = constraints.maxWidth;
      final bool isMobile = constraints.maxWidth < 700;

      ///TODO: Find way to use a similar logic as the one already used in previous codes later on
      ///This one dey stressful
      // subtract sidebar (300) and horizontal padding (32 * 2 = 64)
      final availableWidth = screenWidth - 300 - 64;

      double cardWidth;
      if (screenWidth > 1200) {
        // 3 cards per row
        cardWidth = availableWidth / 3;
      } else if (screenWidth > 800) {
        // 2 cards per row
        cardWidth = availableWidth / 2;
      } else {
        // 1 card per row (mobile view)
        cardWidth = screenWidth;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            screenWidth > 800
                ? const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              'Analytics',
                              style: AppText.black_500_32,
                            ),
                            SizedBox(height: 4),
                            MyText(
                              'Business intelligence and performance metrics',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnalyticsActions(),
                    ],
                  )
                : const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        'Analytics',
                        style: AppText.black_500_32,
                      ),
                      SizedBox(height: 4),
                      MyText(
                        'Business intelligence and performance metrics',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 16),
                      AnalyticsActions(),
                    ],
                  ),
            kSizedBox,
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: summaryData.map((e) {
                return SizedBox(
                  width: cardWidth,
                  child: MetricCard(
                    title: e["title"] ?? '',
                    value: e["value"] ?? '',
                    subtitle: e['subtitle'] ?? '',
                    showtrend: false,
                  ),
                );
              }).toList(),
            )
          ]),
          kSizedBox,
          SectionCard(
            title: "Revenue Trend Analysis",
            titleIcon: Icons.bar_chart_rounded,
            child: SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(1, 2),
                        const FlSpot(2, 2.2),
                        const FlSpot(3, 2.5),
                        const FlSpot(4, 2.7),
                        const FlSpot(5, 3),
                        const FlSpot(6, 3.2),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withValues(alpha: 0.2)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          kSizedBox,

          ///TODO: Remove redundant codes
          isMobile
              ? Wrap(
                  children: [
                    Expanded(
                      child: SectionCard(
                        title: "Revenue by Service Type",
                        titleIcon: Icons.pie_chart_outline_outlined,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 220,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 0,
                                  sections:
                                      pieData.asMap().entries.map((entry) {
                                    final i = entry.key;
                                    final e = entry.value;
                                    final colors = [
                                      Colors.blue,
                                      Colors.orange,
                                      Colors.green,
                                      Colors.purple,
                                      Colors.red,
                                      Colors.teal,
                                    ];
                                    return PieChartSectionData(
                                      color: colors[i % colors.length],
                                      value: e['value'] as double,
                                      radius: 70,
                                      showTitle: false,
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: pieData.asMap().entries.map((entry) {
                                final i = entry.key;
                                final e = entry.value;
                                final colors = [
                                  Colors.blue,
                                  Colors.orange,
                                  Colors.green,
                                  Colors.purple,
                                  Colors.red,
                                  Colors.teal,
                                ];
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: colors[i % colors.length],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text("${e['label']} (${e['value']}%)"),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SectionCard(
                        title: "Revenue by Location",
                        titleIcon: Icons.location_on,
                        child: Column(
                          children: locationData.map((e) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(e["label"]!),
                                  Text(e["value"]!,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SectionCard(
                        title: "Revenue by Service Type",
                        titleIcon: Icons.pie_chart_outline_outlined,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 220,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 0,
                                  sections:
                                      pieData.asMap().entries.map((entry) {
                                    final i = entry.key;
                                    final e = entry.value;
                                    final colors = [
                                      Colors.blue,
                                      Colors.orange,
                                      Colors.green,
                                      Colors.purple,
                                      Colors.red,
                                      Colors.teal,
                                    ];
                                    return PieChartSectionData(
                                      color: colors[i % colors.length],
                                      value: e['value'] as double,
                                      radius: 70,
                                      showTitle: false,
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: pieData.asMap().entries.map((entry) {
                                final i = entry.key;
                                final e = entry.value;
                                final colors = [
                                  Colors.blue,
                                  Colors.orange,
                                  Colors.green,
                                  Colors.purple,
                                  Colors.red,
                                  Colors.teal,
                                ];
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: colors[i % colors.length],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text("${e['label']} (${e['value']}%)"),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SectionCard(
                        title: "Revenue by Location",
                        titleIcon: Icons.location_on,
                        child: Column(
                          children: locationData.map((e) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(e["label"]!),
                                  Text(e["value"]!,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      );
    });
  }
}

final summaryData = [
  {
    "title": "Total Revenue",
    "value": "₦45,750,000.00",
    "subtitle": 'All time revenue'
  },
  {
    "title": "This Month",
    "value": "₦3,850,000.00",
    "subtitle": '+20.3% from last month'
  },
  {
    "title": "Avg Project Value",
    "value": "₦360,236.22",
    "subtitle": 'Per project'
  },
  {
    "title": "Revenue per Client",
    "value": "₦454,642.86",
    "subtitle": 'Per client'
  },
];

final pieData = [
  {"label": "Land Surveys", "value": 45.0},
  {"label": "Topographic", "value": 25.0},
  {"label": "Engineering Surveys", "value": 15.0},
  {"label": "Boundary Surveys", "value": 20.0},
];

final locationData = [
  {"label": "Geospatial", "value": "₦15,500,000.00"},
  {"label": "Kaduna", "value": "₦10,000,000.00"},
  {"label": "Abuja", "value": "₦9,750,000.00"},
  {"label": "Port Harcourt", "value": "₦6,000,000.00"},
  {"label": "Lagos", "value": "₦2,000,000.00"},
];

class SectionCard extends StatelessWidget {
  final String title;
  final IconData? titleIcon;
  final Widget child;

  const SectionCard(
      {super.key, required this.title, required this.child, this.titleIcon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 4,
              children: [
                if (titleIcon != null) Icon(titleIcon),
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
