import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/spaces.dart';
import 'package:flutter/material.dart';

class MetricsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final double? progress;
  final List<Map<String, dynamic>> items;

  const MetricsSection({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: AppColors.white,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.grey[700]),
                const SizedBox(width: 8),
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
            kSizedBox,
            ...items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item["label"],
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        item["value"],
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (progress != null)
              LinearProgressIndicator(
                borderRadius: BorderRadius.circular(5),
                minHeight: 8,
                value: progress,
                color: Colors.black,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
              )
          ],
        ),
      ),
    );
  }
}

final revenueData = [
  {"label": "This Month", "value": "₦0.00 (+0.0%)"},
  {"label": "Last Month", "value": "₦0.00"},
  {"label": "Average per Project", "value": "₦0.00"},
  {"label": "Revenue per Client", "value": "₦0.00"},
];

final projectData = [
  {"label": "Total Projects", "value": "0"},
  {"label": "Active Projects", "value": "0"},
  {"label": "Completed Projects", "value": "0"},
  {"label": "Success Rate", "value": "0.0%"},
];

final teamData = [
  {"label": "Total Employees", "value": "2"},
  {"label": "Productivity", "value": "78/100"},
  {"label": "Satisfaction", "value": "4.2/5"},
  {"label": "Productivity", "value": "78%"},
];
