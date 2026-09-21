import 'package:fl_chart/fl_chart.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';

import '../../components/text/my_text.dart';
import '../../components/section/page_scaffold.dart';
import '../../src/constants/spaces.dart';
import '../../src/constants/textstyle.dart';
import 'overview.dart';
import 'widgets/metrics_card.dart';

class RevenueAnalyticsPage extends StatelessWidget {
  const RevenueAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final bool isCompact = constraints.maxWidth < 900;
          const cardGap = 16.0;
          final columns = screenWidth >= 1100
              ? 3
              : screenWidth >= 680
                  ? 2
                  : 1;
          final cardWidth = (screenWidth - (cardGap * (columns - 1))) / columns;

          return SingleChildScrollView(
            child: Column(
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
                                    style: AppTextStyles.displayLg,
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
                              style: AppTextStyles.displayLg,
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
                    spacing: cardGap,
                    runSpacing: cardGap,
                    children: summaryData.map((e) {
                      return SizedBox(
                        width: cardWidth,
                        child: AnalyticsMetricCard(
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
                  titleIcon: Iconsax.chart_2,
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
                isCompact
                    ? Column(
                        children: [
                          _buildServiceTypeCard(),
                          const SizedBox(height: 16),
                          _buildLocationCard(),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildServiceTypeCard(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildLocationCard(),
                          ),
                        ],
                      ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildServiceTypeCard() {
    return SectionCard(
      title: "Revenue by Service Type",
      titleIcon: Iconsax.chart_21,
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 0,
                sections: pieData.asMap().entries.map((entry) {
                  final i = entry.key;
                  final e = entry.value;
                  return PieChartSectionData(
                    color: _pieColors[i % _pieColors.length],
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
              return _buildLegendItem(
                _pieColors[i % _pieColors.length],
                "${e['label']} (${e['value']}%)",
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return SectionCard(
      title: "Revenue by Location",
      titleIcon: Iconsax.location,
      child: Column(
        children: locationData.map((e) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    e["label"]!,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    e["value"]!,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

const _pieColors = [
  Colors.blue,
  Colors.orange,
  Colors.green,
  Colors.purple,
  Colors.red,
  Colors.teal,
];

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
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
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
