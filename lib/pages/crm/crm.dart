import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/pages/crm/widgets/line_chart.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../src/constants/colors.dart';
import 'controllers/crm_controller.dart';
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
      final bg = backgroundColor ?? AppColors.surface;
      final fg = foregroundColor ?? AppColors.textPrimary;
      if (isWide) {
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            elevation: 0,
            side: backgroundColor == null
                ? const BorderSide(color: AppColors.borderSubtle)
                : BorderSide.none,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadii.brMd,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            textStyle: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w500),
          ),
          icon: Icon(icon, size: 16),
          label: Text(label),
          onPressed: onPressed,
        );
      } else {
        return IconButton(
          tooltip: label,
          style: IconButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            side: backgroundColor == null
                ? const BorderSide(color: AppColors.borderSubtle)
                : null,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadii.brMd,
            ),
          ),
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
        );
      }
    }

    final controller = Get.put(CrmController());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'CRM Dashboard',
            subtitle: 'Overview of your clients, leads, and pipeline',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                buildActionButton(
                    onPressed: () {},
                    icon: Iconsax.message,
                    label: 'Log Interactions',
                    isWide: !isMobile),
                buildActionButton(
                    onPressed: () {
                      AddNewLeadDialog.show(context);
                    },
                    icon: Iconsax.flash_1,
                    label: 'Add Lead',
                    isWide: !isMobile),
                buildActionButton(
                    onPressed: () {
                      AddNewClientDialog.show(context);
                    },
                    icon: Iconsax.user_add,
                    label: 'Add Client',
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    isWide: !isMobile),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Obx(() {
            final metrics = [
              MetricData(
                  title: 'Total Clients',
                  value: controller.totalClients.value.toString(),
                  icon: Iconsax.profile_2user,
                  color: AppColors.primary,
                  subtitle: 'Active client base'),
              MetricData(
                  title: 'Total Leads',
                  value: controller.totalLeads.value.toString(),
                  icon: Iconsax.trend_up,
                  color: AppColors.success,
                  subtitle: 'Current leads'),
              MetricData(
                  title: 'Conversion Rate',
                  value: controller.totalLeads.value > 0
                      ? '${((controller.totalClients.value / (controller.totalClients.value + controller.totalLeads.value)) * 100).toStringAsFixed(1)}%'
                      : '0%',
                  icon: Iconsax.dollar_circle,
                  color: const Color(0xFF8B5CF6),
                  subtitle: 'Lead to client'),
              MetricData(
                  title: 'Retention Rate',
                  value: '—',
                  icon: Iconsax.star_1,
                  color: AppColors.warning,
                  subtitle: 'Client retention'),
            ];

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: metrics.length,
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
                  StandardMetricCard(data: metrics[index]),
            );
          }),
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
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Top Clients by Value', style: AppTextStyles.h3),
                const SizedBox(height: 2),
                Text(
                  'Your most valuable client relationships',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: mockTopClients.length,
            itemBuilder: (context, index) {
              return TopClientListItem(
                client: mockTopClients[index],
                isLast: index == mockTopClients.length - 1,
              );
            },
          ),
        ],
      ),
    );
  }
}

class TopClientListItem extends StatelessWidget {
  final ClientItem client;
  final bool isLast;

  const TopClientListItem({
    super.key,
    required this.client,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom:
                    BorderSide(color: AppColors.borderSubtle, width: 1),
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
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${client.projects} projects',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          Text(
            client.value,
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
