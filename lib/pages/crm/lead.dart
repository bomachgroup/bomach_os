import 'package:flutter/material.dart';
import 'package:bomach_os/src/helper/responsive_breakpoints.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';

import '../../components/input/my_dropdown.dart';
import '../../components/text/my_text.dart';
import '../../src/constants/colors.dart';
import '../../src/services/crm/crm_service.dart';
import 'controllers/crm_controller.dart';
import 'dialogs/client_dialog.dart';
import 'dialogs/lead_dialog.dart' show AddNewLeadDialog;
import 'models.dart';
import 'widgets/widgets.dart';

class CrmLeadsPage extends StatelessWidget {
  const CrmLeadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CrmController());
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

    return Column(
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
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                    icon: Iconsax.message_text,
                    label: 'Log Interactions',
                    isWide: !isMobile),
                buildActionButton(
                    onPressed: () {
                      AddNewLeadDialog.show(context);
                    },
                    icon: Iconsax.copy,
                    label: 'Add Lead',
                    isWide: !isMobile),
                buildActionButton(
                    onPressed: () {
                      AddNewClientDialog.show(context);
                    },
                    icon: Iconsax.user_add,
                    label: 'Add Client',
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    isWide: !isMobile),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Obx(() {
          final metrics = [
            MetricData(
                title: 'Total Clients',
                value: controller.totalClients.value.toString(),
                icon: Iconsax.people,
                color: Colors.blue.shade600,
                subtitle: 'Active client base'),
            MetricData(
                title: 'Total Leads',
                value: controller.totalLeads.value.toString(),
                icon: Iconsax.trend_up,
                color: Colors.green.shade600,
                subtitle: 'Current leads'),
            MetricData(
                title: 'Conversion Rate',
                value: controller.totalLeads.value > 0
                    ? '${((controller.totalClients.value / (controller.totalClients.value + controller.totalLeads.value)) * 100).toStringAsFixed(1)}%'
                    : '0%',
                icon: Iconsax.money_recive,
                color: Colors.purple.shade600,
                subtitle: 'Lead to client'),
            MetricData(
                title: 'Retention Rate',
                value: '—',
                icon: Iconsax.star1,
                color: Colors.orange.shade600,
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
        _LeadsTableLive(controller: controller),
      ],
    );
  }
}

Map<String, Color> _getStatusColors(String status) {
  switch (status.toLowerCase()) {
    case 'qualified':
      return {'bg': const Color(0xFFF6F0FF), 'text': const Color(0xFF9B59B6)};
    case 'proposal':
      return {'bg': AppColors.warningSubtle, 'text': const Color(0xFFF1C40F)};
    case 'converted':
      return {'bg': AppColors.successSubtle, 'text': AppColors.success};
    case 'new':
    default:
      return {'bg': const Color(0xFFEEF7FF), 'text': const Color(0xFF3498DB)};
  }
}

class _LeadsTableLive extends StatelessWidget {
  final CrmController controller;
  const _LeadsTableLive({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sales Pipeline',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 4),
          const Text('Track and manage your sales leads',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search leads...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.neutral100,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                  onChanged: controller.onLeadSearchChanged,
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 150,
                child: MyDropdown(
                  hintText: 'All Status',
                  items: const [
                    'All Status',
                    'new',
                    'qualified',
                    'proposal',
                    'converted'
                  ],
                  onChanged: (val) {
                    controller.onLeadStatusFilterChanged(
                        val == 'All Status' ? null : val);
                  },
                  fillColor: AppColors.neutral100,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Obx(() {
            if (controller.isLoadingLeads.value) {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ));
            }
            if (controller.leadList.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                    child: Text('No leads found.',
                        style: TextStyle(color: Colors.grey))),
              );
            }
            return _LeadDataTableLive(
                leads: controller.leadList, controller: controller);
          }),
        ],
      ),
    );
  }
}

class _LeadDataTableLive extends StatelessWidget {
  final List<CrmLead> leads;
  final CrmController controller;
  _LeadDataTableLive({required this.leads, required this.controller});

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: leads.map((lead) => _buildMobileCard(context, lead)).toList(),
      ),
    );
  }

  Widget _buildMobileCard(BuildContext context, CrmLead lead) {
    final statusColors = _getStatusColors(lead.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  lead.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildTag(
                lead.status.toUpperCase(),
                backgroundColor: statusColors['bg']!,
                textColor: statusColors['text']!,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            lead.interestedServices,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),
          if (lead.companyName != null && lead.companyName!.isNotEmpty) ...[
            Text(
              'Company: ${lead.companyName}',
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 6),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lead.email,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Text(
                lead.phoneNumber ?? '—',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTag(
                lead.source,
                backgroundColor: AppColors.neutral100,
                textColor: Colors.black87,
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Iconsax.arrow_swap_horizontal, size: 18),
                    onPressed: () => controller.convertLeadToClient(context, lead.id),
                    tooltip: 'Convert to Client',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.trash, size: 18, color: Colors.red),
                    onPressed: () => controller.deleteLead(context, lead.id),
                    tooltip: 'Delete',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text,
      {required Color backgroundColor, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text,
          style: TextStyle(
              color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
