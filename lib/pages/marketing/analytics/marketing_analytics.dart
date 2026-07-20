import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/pages/marketing/controllers/marketing_module_controller.dart';
import 'package:bomach_os/pages/marketing/models/marketing_lead.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarketingAnalytics extends StatelessWidget {
  const MarketingAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MarketingModuleController>();

    return DefaultTabController(
      length: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText('Analytics & Insights', style: AppTextStyles.displayLg),
          const SizedBox(height: 4),
          const MyText(
            'Performance metrics across all marketing channels',
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
              isScrollable: true,
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: 'Lead Analytics'),
                Tab(text: 'Campaign ROI'),
                Tab(text: 'Content Performance'),
                Tab(text: 'Division Breakdown'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                _buildOverviewTab(c),
                _buildLeadAnalyticsTab(c),
                _buildCampaignRoiTab(c),
                _buildContentPerformanceTab(c),
                _buildDivisionBreakdownTab(c),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(MarketingModuleController c) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final data = c.currentPeriodData;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _statCard('All Leads (This Division)', data['allLeads'] ?? '—', AppColors.primary),
                _statCard('Revenue Closed', data['allRevenue'] ?? '—', AppColors.success),
                _statCard('Conversion Rate', data['conv'] ?? '—', AppColors.info),
                _statCard('Pipeline Value', data['pipe'] ?? '—', AppColors.warning),
              ],
            );
          }),
          const SizedBox(height: 20),
          _buildConversionFunnel(c),
        ],
      ),
    );
  }

  Widget _buildLeadAnalyticsTab(MarketingModuleController c) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lead Source Distribution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Obx(() {
            final sourceMap = <String, int>{};
            for (final lead in c.leads) {
              sourceMap[lead.source] = (sourceMap[lead.source] ?? 0) + 1;
            }
            final sorted = sourceMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
            return Column(
              children: sorted.map((e) {
                final pct = c.leads.isNotEmpty ? (e.value / c.leads.length) : 0.0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(e.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 8,
                          backgroundColor: AppColors.borderSubtle,
                          valueColor: AlwaysStoppedAnimation(AppColors.primary.withValues(alpha: 0.6 + pct * 0.4)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('${e.value} (${(pct * 100).toStringAsFixed(0)}%)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCampaignRoiTab(MarketingModuleController c) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Campaign Performance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Obx(() => Column(
            children: c.campaigns.map((camp) {
            return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(camp.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(camp.channels, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    _metricCol('Budget', '₦${(camp.budget / 1000).toStringAsFixed(0)}K'),
                    _metricCol('Spent', '₦${(camp.spent / 1000).toStringAsFixed(0)}K'),
                    _metricCol('Leads', '${camp.leads}'),
                    _metricCol('CPL', camp.costPerLead),
                    _metricCol('Conv', camp.conversionRate),
                  ],
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildContentPerformanceTab(MarketingModuleController c) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Content by Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Obx(() {
            final statusMap = <String, int>{};
            for (final item in c.contentItems) {
              statusMap[item.status.label] = (statusMap[item.status.label] ?? 0) + 1;
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: statusMap.entries.map((e) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text('${e.value}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                      Text(e.key, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDivisionBreakdownTab(MarketingModuleController c) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Leads by Division', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Obx(() {
            final divCounts = c.divisionLeadCounts;
            return Column(
              children: MarketingDivision.values.map((div) {
                final count = divCounts[div] ?? 0;
                final pct = c.leads.isNotEmpty ? (count / c.leads.length) : 0.0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: div.pillColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(color: div.pillColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(div.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: div.pillTextColor)),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: pct,
                              minHeight: 6,
                              backgroundColor: AppColors.borderSubtle,
                              valueColor: AlwaysStoppedAnimation(div.pillColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: div.pillTextColor)),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildConversionFunnel(MarketingModuleController c) {
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
          const Text('Conversion Funnel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Obx(() {
            final counts = c.pipelineCounts;
            final total = c.leads.length;
            return Column(
              children: LeadStage.values.take(5).map((stage) {
                final count = counts[stage] ?? 0;
                final pct = total > 0 ? (count / total) : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(stage.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 24,
                            backgroundColor: stage.pillColor.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation(stage.pillColor.withValues(alpha: 0.5)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 50,
                        child: Text('$count', textAlign: TextAlign.end,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      width: 200,
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

  Widget _metricCol(String label, String value) {
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
