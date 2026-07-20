import 'package:bomach_os/pages/marketing/analytics/marketing_analytics.dart';
import 'package:bomach_os/pages/marketing/calendar/marketing_calendar.dart';
import 'package:bomach_os/pages/marketing/campaigns/marketing_campaigns.dart';
import 'package:bomach_os/pages/marketing/controllers/marketing_module_controller.dart';
import 'package:bomach_os/pages/marketing/dashboard/marketing_dashboard.dart';
import 'package:bomach_os/pages/marketing/media/marketing_media_library.dart';
import 'package:bomach_os/pages/marketing/new_lead/new_lead_form.dart';
import 'package:bomach_os/pages/marketing/okrs/marketing_okrs.dart';
import 'package:bomach_os/pages/marketing/pipeline/marketing_pipeline.dart';
import 'package:bomach_os/pages/marketing/reports/marketing_reports.dart';
import 'package:bomach_os/pages/marketing/team/marketing_team_directory.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarketingPage extends StatefulWidget {
  const MarketingPage({super.key});

  @override
  State<MarketingPage> createState() => _MarketingPageState();
}

class _MarketingPageState extends State<MarketingPage> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    Get.put(MarketingModuleController());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: KeyedSubtree(
              key: ValueKey(_selectedTab),
              child: _screens[_selectedTab],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildBottomNav(),
      ],
    );
  }

  static const _screens = [
    MarketingDashboard(),
    MarketingPipeline(),
    MarketingCampaigns(),
    MarketingCalendar(),
    MarketingAnalytics(),
    MarketingOkrs(),
    MarketingReports(),
    MarketingTeamDirectory(),
    NewLeadForm(),
    MarketingMediaLibrary(),
  ];

  static const _labels = [
    'Dashboard',
    'Pipeline',
    'Campaigns',
    'Calendar',
    'Analytics',
    'OKRs',
    'Reports',
    'Team',
    'New Lead',
    'Media',
  ];

  static const _icons = [
    Icons.dashboard_outlined,
    Icons.view_kanban_outlined,
    Icons.campaign_outlined,
    Icons.calendar_today_outlined,
    Icons.analytics_outlined,
    Icons.flag_outlined,
    Icons.assessment_outlined,
    Icons.people_outlined,
    Icons.person_add_outlined,
    Icons.perm_media_outlined,
  ];

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_labels.length, (i) {
            final isActive = _selectedTab == i;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_icons[i], size: 18, color: isActive ? Colors.white : AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        _labels[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isActive ? Colors.white : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
