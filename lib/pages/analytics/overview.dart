import 'package:flutter/material.dart';

import '../../components/text/my_text.dart';
import '../../src/constants/spaces.dart';
import '../../src/constants/textstyle.dart';
import 'widgets/metrics_card.dart';
import 'widgets/section_card.dart';

class AnalyticsOverviewPage extends StatelessWidget {
  const AnalyticsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final screenWidth = constraints.maxWidth;

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
            children: [
              SizedBox(
                width: cardWidth,
                child: const MetricCard(
                  title: "Total Revenue",
                  value: "₦0.00",
                  subtitle: "0.0% vs avg",
                  imgPath: 'assets/icons/dollar.png',
                  color: Colors.green,
                ),
              ),
              SizedBox(
                width: cardWidth,
                child: const MetricCard(
                  title: "Active Projects",
                  value: "0",
                  subtitle: "-50% vs avg",
                  imgPath: 'assets/icons/points.png',
                  color: Colors.blue,
                ),
              ),
              SizedBox(
                width: cardWidth,
                child: const MetricCard(
                  title: "Total Clients",
                  value: "0",
                  subtitle: "0.0% vs avg",
                  imgPath: 'assets/icons/people.png',
                  color: Colors.orange,
                ),
              ),
              SizedBox(
                width: cardWidth,
                child: const MetricCard(
                  title: "Project Success Rate",
                  value: "0.0%",
                  subtitle: "-60% vs avg",
                  imgPath: 'assets/icons/achievement.png',
                  color: Colors.red,
                ),
              ),
              SizedBox(
                width: cardWidth,
                child: const MetricCard(
                  title: "Employee Productivity",
                  value: "78/100",
                  subtitle: "3.0% vs avg",
                  imgPath: 'assets/icons/chart.png',
                  color: Colors.green,
                ),
              ),
              SizedBox(
                width: cardWidth,
                child: const MetricCard(
                  title: "Client Retention",
                  value: "85.0%",
                  subtitle: "-60% vs avg",
                  imgPath: 'assets/icons/check.png',
                  color: Colors.red,
                ),
              ),
            ],
          ),
          kSizedBox,
          MetricsSection(
            title: "Revenue Summary",
            icon: Icons.attach_money,
            items: revenueData,
          ),
          MetricsSection(
            title: "Project Metrics",
            icon: Icons.work_outline,
            items: projectData,
            progress: 0.0,
          ),
          MetricsSection(
            title: "Team Overview",
            icon: Icons.people_alt,
            items: teamData,
            progress: 0.78,
          ),
        ],
      );
    });
  }
}

class AnalyticsActions extends StatelessWidget {
  const AnalyticsActions({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // We can still modify this to a better code but for now we use layout builder.
        // Considering 800 as breakpoint but 600 for now...
        // account for sidebar + horizontal padding
        final availableWidth = constraints.maxWidth - 300 - 64;
        final isWide = availableWidth > 600; // breakpoint

        final dropdown = SizedBox(
          height: 40,
          child: DropdownButton<String>(
            value: "Last 30 days",
            isDense: true,
            underline: const SizedBox.shrink(),
            padding: const EdgeInsets.all(5),
            onTap: () {},
            items: const [
              DropdownMenuItem(
                  value: "Last 7 days", child: Text("Last 7 days")),
              DropdownMenuItem(
                  value: "Last 30 days", child: Text("Last 30 days")),
              DropdownMenuItem(
                  value: "Last 90 days", child: Text("Last 90 days")),
            ],
            onChanged: (value) {},
          ),
        );

        final buttons = [
          _buildActionButton(
            icon: Icons.refresh,
            label: "Refresh",
            isWide: isWide,
          ),
          _buildActionButton(
            icon: Icons.picture_as_pdf,
            label: "Export PDF",
            isWide: isWide,
          ),
          _buildActionButton(
            icon: Icons.table_chart,
            label: "Export Excel",
            isWide: isWide,
          ),
        ];

        if (isWide) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              dropdown,
              const SizedBox(width: 12),
              ...buttons.map((btn) => Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: btn,
                  )),
            ],
          );
        } else {
          return Wrap(
            alignment: WrapAlignment.end,
            spacing: 12,
            runSpacing: 12,
            children: [dropdown, ...buttons],
          );
        }
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isWide,
  }) {
    if (isWide) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        onPressed: () {},
      );
    } else {
      return IconButton(
        tooltip: label,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        onPressed: () {},
        icon: Icon(icon, size: 20),
      );
    }
  }
}
