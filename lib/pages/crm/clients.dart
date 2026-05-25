import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/helper/responsive_breakpoints.dart';
import 'package:bomach_os/components/paginate/responsive_table.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../src/constants/colors.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'controllers/crm_controller.dart';
import 'dialogs/client_dialog.dart';
import 'dialogs/lead_dialog.dart' show AddNewLeadDialog;
import 'models.dart';
import 'widgets/widgets.dart';

class CrmClientsPage extends StatelessWidget {
  const CrmClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CrmController());
    final bp = context.breakpoint;
    final isMobile = bp.isMobile;
    final isTablet = bp.isMobileOrTablet;

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
            textStyle:
                AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w500),
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

    return PageScaffold(
      header: PageHeader(
        title: 'CRM',
        subtitle: 'Manage clients, leads, and customer interactions',
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
      children: [
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
              crossAxisCount: isMobile
                  ? 2
                  : isTablet
                      ? 2
                      : 4,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: isMobile ? 1.4 : 1.8,
            ),
            itemBuilder: (context, index) =>
                StandardMetricCard(data: metrics[index]),
          );
        }),
        const SizedBox(height: 32),
        AppCard(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Clients', style: AppTextStyles.h2),
              const SizedBox(height: 4),
              Text(
                'Manage your client relationships',
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              TextField(
                style: AppTextStyles.bodyMd,
                decoration: InputDecoration(
                  hintText: 'Search clients...',
                  hintStyle:
                      AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
                  prefixIcon: const Icon(Iconsax.search_normal_1,
                      size: 18, color: AppColors.textMuted),
                  border: const OutlineInputBorder(
                    borderRadius: AppRadii.brMd,
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: AppRadii.brMd,
                    borderSide: BorderSide(color: AppColors.borderSubtle),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: AppRadii.brMd,
                    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceMuted,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
                onChanged: controller.onClientSearchChanged,
              ),
              const SizedBox(height: 32),
              Obx(() {
                if (controller.isLoadingClients.value) {
                  return LoadingSkeleton.listRows(count: 5);
                }
                if (controller.clientList.isEmpty) {
                  return EmptyState.noResults(
                    title: 'No clients found',
                    subtitle: 'Try adjusting your search or add a new client.',
                  );
                }
                return ResponsiveTable(
                  items: controller.clientList,
                  columns: const [
                    DataColumn(label: Text('Client')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Phone')),
                    DataColumn(label: Text('Balance')),
                  ],
                  rowBuilder: (c, index) => DataRow(cells: [
                    DataCell(Text(c.fullName,
                        style: AppTextStyles.bodyMd.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary))),
                    DataCell(Text(c.email)),
                    DataCell(Text(c.phoneNumber ?? '—')),
                    DataCell(Text('₦${c.balance.toStringAsFixed(2)}',
                        style: AppTextStyles.bodyMd.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary))),
                  ]),
                  mobileCardBuilder: (c, index) => AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: MyText(c.fullName,
                                  weight: 700,
                                  size: 15,
                                  color: AppColors.textPrimary),
                            ),
                            MyText('₦${c.balance.toStringAsFixed(2)}',
                                weight: 700,
                                size: 14,
                                color: AppColors.primary),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Iconsax.sms,
                                size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Expanded(
                                child: MyText(c.email,
                                    size: 13, color: AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Iconsax.call,
                                size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            MyText(c.phoneNumber ?? '—',
                                size: 13, color: AppColors.textSecondary),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
