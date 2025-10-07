import 'package:bms_front_end/pages/crm/widgets/line_chart.dart';
import 'package:flutter/material.dart';

import '../../components/text/my_text.dart';
import '../../src/constants/colors.dart';
import 'dialogs/client_dialog.dart';
import 'dialogs/lead_dialog.dart';
import 'models.dart';
import 'widgets/bar_chart.dart';
import 'widgets/pie_chart.dart';
import 'widgets/widgets.dart';

class CrmDashboardPage extends StatelessWidget {
  const CrmDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth < 900;

    Widget buildActionButton({
      required IconData icon,
      required String label,
      required bool isWide,
      void Function()? onPressed,
      Color? foregroundColor,
      Color? backgroundColor,
    }) {
      if (isWide) {
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.white,
            foregroundColor: foregroundColor ?? Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          icon: Icon(icon, size: 18),
          label: Text(label, style: const TextStyle(fontSize: 12)),
          onPressed: onPressed,
        );
      } else {
        return IconButton(
          tooltip: label,
          style: IconButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.white,
            foregroundColor: foregroundColor ?? Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
        );
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 12,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MyText(
                      'Customer Relationship Management',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    MyText(
                      'Manage clients, leads, and customer interactions',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Row(
                spacing: 8,
                children: [
                  buildActionButton(
                      onPressed: () {},
                      icon: Icons.message,
                      label: 'Log Interactions',
                      isWide: !isMobile),
                  buildActionButton(
                      onPressed: () {
                        AddNewLeadDialog.show(context);
                      },
                      icon: Icons.control_point_duplicate_sharp,
                      label: 'Add Lead',
                      isWide: !isMobile),
                  buildActionButton(
                      onPressed: () {
                        AddNewClientDialog.show(context);
                      },
                      icon: Icons.person_add_alt_1_rounded,
                      label: 'Add Client',
                      backgroundColor: AppColors.blue,
                      foregroundColor: Colors.white,
                      isWide: !isMobile),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: crmMetrics.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : 4,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: isMobile
                  ? 1.5
                  : isTablet
                      ? 1
                      : 1.8,
            ),
            itemBuilder: (context, index) =>
                StandardMetricCard(data: crmMetrics[index]),
          ),
          const SizedBox(height: 32),
          if (!isMobile)
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: LeadSourcesPieChart()),
                SizedBox(width: 24),
                Expanded(child: SalesPipelineBarChart()),
              ],
            )
          else
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LeadSourcesPieChart(),
                SizedBox(height: 24),
                SalesPipelineBarChart(),
              ],
            ),
          const SizedBox(height: 32),
          const MonthlyPerformanceChart(),
          const SizedBox(height: 32),
          const TopClientsByValue(),
        ],
      ),
    );
  }
}

class TopClientsByValue extends StatelessWidget {
  const TopClientsByValue({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Top Clients by Value',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Your most valuable client relationships',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: mockTopClients.length,
            itemBuilder: (context, index) {
              return TopClientListItem(client: mockTopClients[index]);
            },
          ),
        ],
      ),
    );
  }
}

class TopClientListItem extends StatelessWidget {
  final ClientItem client;

  const TopClientListItem({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                client.name,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              Text(
                '${client.projects} projects',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
          Text(
            client.value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
