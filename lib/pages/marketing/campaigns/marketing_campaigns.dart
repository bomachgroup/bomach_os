import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/pages/marketing/controllers/marketing_module_controller.dart';
import 'package:bomach_os/pages/marketing/models/marketing_campaign.dart';
import 'package:bomach_os/pages/marketing/models/marketing_misc.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bomach_os/src/utils/app_date_format.dart';

class MarketingCampaigns extends StatelessWidget {
  const MarketingCampaigns({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MarketingModuleController>();

    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
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
                Tab(text: 'Portfolio'),
                Tab(text: 'Requests'),
                Tab(text: 'Templates'),
                Tab(text: 'Remote Ops'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                _buildPortfolioTab(c),
                _buildRequestsTab(c),
                _buildTemplatesTab(c),
                _buildRemoteOpsTab(c),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText('Campaign Management', style: AppTextStyles.displayLg),
              SizedBox(height: 4),
              MyText(
                'Plan, launch, and track multi-channel campaigns',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioTab(MarketingModuleController c) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText('Active Campaigns', style: AppTextStyles.h2),
          const SizedBox(height: 12),
          Obx(() {
            final active = c.campaigns
                .where((c) => c.status == CampaignStatus.active)
                .toList();
            final draft = c.campaigns
                .where((c) => c.status == CampaignStatus.draft)
                .toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...active.map((camp) => _buildCampaignCard(camp)),
                if (draft.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const MyText('Drafts', style: AppTextStyles.h2),
                  const SizedBox(height: 12),
                  ...draft.map((camp) => _buildCampaignCard(camp)),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(MarketingCampaignV2 camp) {
    final progress =
        camp.budget > 0 ? (camp.spent / camp.budget).clamp(0.0, 1.0) : 0.0;
    final isDraft = camp.status == CampaignStatus.draft;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: const [
          BoxShadow(
              color: Color(0x05000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            camp.name,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDraft
                                ? AppColors.surfaceMuted
                                : AppColors.successSubtle,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            camp.status.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDraft
                                  ? AppColors.textMuted
                                  : AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      camp.channels,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₦${(camp.spent / 1000).toStringAsFixed(0)}K',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'of ₦${(camp.budget / 1000).toStringAsFixed(0)}K',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColors.borderSubtle,
            valueColor: AlwaysStoppedAnimation(
              isDraft ? AppColors.textMuted : AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          if (!isDraft)
            Row(
              children: [
                _metric('Leads', '${camp.leads}'),
                const SizedBox(width: 16),
                _metric('CPL', camp.costPerLead),
                const SizedBox(width: 16),
                _metric('Conv', camp.conversionRate),
                const SizedBox(width: 16),
                _metric('Days', '${camp.daysActive}'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildRequestsTab(MarketingModuleController c) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text('No pending campaign requests',
              style: TextStyle(color: AppColors.textMuted)),
          SizedBox(height: 8),
          Text(
            'Campaign requests from team members will appear here for approval',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesTab(MarketingModuleController c) {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: c.campaignTemplates.map((t) {
          return Container(
            width: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.campaign,
                      size: 20, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  t.name,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  t.description,
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRemoteOpsTab(MarketingModuleController c) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText('Broadcast History', style: AppTextStyles.h2),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              children: [
                _buildBroadcastHeader(),
                ...c.broadcasts.map((b) => _buildBroadcastRow(b)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBroadcastHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: const Row(
        children: [
          Expanded(
              flex: 2,
              child: Text('Date',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted))),
          Expanded(
              flex: 3,
              child: Text('Audience',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted))),
          Expanded(
              flex: 2,
              child: Text('Sent',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted))),
          Expanded(
              flex: 2,
              child: Text('Delivered',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted))),
          Expanded(
              flex: 2,
              child: Text('Responses',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted))),
          Expanded(
              flex: 2,
              child: Text('Leads',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted))),
        ],
      ),
    );
  }

  Widget _buildBroadcastRow(BroadcastRecord b) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(formatAppDateValue(b.date, fallback: b.date),
                  style: const TextStyle(fontSize: 13))),
          Expanded(
              flex: 3,
              child: Text(b.audience, style: const TextStyle(fontSize: 13))),
          Expanded(
              flex: 2,
              child: Text('${b.sent}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontFeatures: [FontFeature.tabularFigures()]))),
          Expanded(
              flex: 2,
              child: Text('${b.delivered}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontFeatures: [FontFeature.tabularFigures()]))),
          Expanded(
              flex: 2,
              child: Text('${b.responses}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontFeatures: [FontFeature.tabularFigures()]))),
          Expanded(
              flex: 2,
              child: Text('${b.generated}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontFeatures: [FontFeature.tabularFigures()]))),
        ],
      ),
    );
  }
}
