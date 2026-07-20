import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/pages/marketing/controllers/marketing_module_controller.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarketingReports extends StatelessWidget {
  const MarketingReports({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MarketingModuleController>();

    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText('Reports', style: AppTextStyles.displayLg),
          const SizedBox(height: 4),
          const MyText(
            'Performance reports and audit trails',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: 'Weekly Summary'),
                Tab(text: 'Support Tickets'),
                Tab(text: 'Audit Log'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                _buildWeeklySummary(c),
                _buildSupportTickets(c),
                _buildAuditLog(c),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySummary(MarketingModuleController c) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKpiSummaryRow(c),
          const SizedBox(height: 16),
          _buildBroadcastHistory(c),
        ],
      ),
    );
  }

  Widget _buildKpiSummaryRow(MarketingModuleController c) {
    return Obx(() {
      final data = c.currentPeriodData;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _kpiCard('Leads Generated', data['leads'] ?? '—', AppColors.primary),
          _kpiCard('Conversion Rate', data['conv'] ?? '—', AppColors.success),
          _kpiCard('Pipeline Value', data['pipe'] ?? '—', AppColors.info),
          _kpiCard('Content Published', data['content'] ?? '—', const Color(0xFF8B5CF6)),
        ],
      );
    });
  }

  Widget _buildBroadcastHistory(MarketingModuleController c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Broadcast History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Obx(() => Column(
            children: c.broadcasts.map((b) {
              final deliveryRate = b.sent > 0 ? ((b.delivered / b.sent) * 100).toStringAsFixed(1) : '0';
              final responseRate = b.delivered > 0 ? ((b.responses / b.delivered) * 100).toStringAsFixed(1) : '0';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.date, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          Text(b.audience, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    _metric('Sent', '${b.sent}'),
                    _metric('Delivered', '$deliveryRate%'),
                    _metric('Responses', '$responseRate%'),
                    _metric('Leads', '${b.generated}'),
                  ],
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildSupportTickets(MarketingModuleController c) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Open Tickets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Obx(() => Column(
              children: c.tickets.map((ticket) {
                final priorityColor = ticket.priority == 'urgent'
                    ? AppColors.danger
                    : ticket.priority == 'high'
                        ? AppColors.warning
                        : AppColors.textMuted;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                    border: ticket.priority == 'urgent'
                        ? Border.all(color: AppColors.danger.withValues(alpha: 0.3))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          ticket.id,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: priorityColor),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ticket.customerName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            Text(ticket.issue, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: priorityColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              ticket.priority,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: priorityColor),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(ticket.time, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditLog(MarketingModuleController c) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          const Text('Audit Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text(
            'All team actions and system events will be logged here',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _kpiCard(String label, String value, Color color) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
