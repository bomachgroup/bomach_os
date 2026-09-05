import 'package:bomach_os/pages/marketing/controllers/marketing_module_controller.dart';
import 'package:bomach_os/pages/marketing/widget/marketing_webview.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarketingPage extends StatefulWidget {
  const MarketingPage({super.key});

  @override
  State<MarketingPage> createState() => _MarketingPageState();
}

class _MarketingPageState extends State<MarketingPage> {
  int _selectedSection = 0;
  int _selectedPage = 0;

  static const _sections = [
    _SectionConfig('Marketing OS', [
      _PageConfig('Dashboard', Icons.dashboard_outlined, '/dashboard'),
      _PageConfig('Pipeline', Icons.view_kanban_outlined, '/pipeline'),
      _PageConfig('Campaigns', Icons.campaign_outlined, '/campaigns'),
      _PageConfig('Calendar', Icons.calendar_today_outlined, '/calendar'),
      _PageConfig('Analytics', Icons.analytics_outlined, '/analytics'),
      _PageConfig('OKRs', Icons.flag_outlined, '/okrs'),
      _PageConfig('Reports', Icons.assessment_outlined, '/audit-log'),
      _PageConfig('Team', Icons.people_outlined, '/team-directory'),
      _PageConfig('New Lead', Icons.person_add_outlined, '/new-lead'),
      _PageConfig('Media', Icons.perm_media_outlined, '/media'),
    ]),
    _SectionConfig('Revenue Execution', [
      _PageConfig('Revenue Command', Icons.monetization_on_outlined,
          '/revenue-command'),
      _PageConfig('Daily Execution', Icons.today_outlined, '/daily-execution'),
      _PageConfig(
          'Lead Control', Icons.control_point_outlined, '/lead-control'),
      _PageConfig('Funnel Audit', Icons.filter_alt_outlined, '/funnel-audit'),
      _PageConfig('Playbooks', Icons.menu_book_outlined, '/playbooks'),
      _PageConfig(
          'Content Studio', Icons.movie_creation_outlined, '/content-studio'),
      _PageConfig('Coaching', Icons.school_outlined, '/coaching'),
      _PageConfig('Forecast', Icons.trending_up_outlined, '/forecast'),
      _PageConfig('Retention', Icons.favorite_outlined, '/retention'),
    ]),
    _SectionConfig('Integration', [
      _PageConfig(
          'Lead 360 Journal', Icons.contact_page_outlined, '/lead-journal'),
      _PageConfig('Channels', Icons.hub_outlined, '/integrations'),
    ]),
    _SectionConfig('Commercial Operations', [
      _PageConfig('Email Marketing', Icons.email_outlined, '/email-center'),
      _PageConfig('Traditional Media', Icons.tv_outlined, '/media-register'),
      _PageConfig('Sales Handoffs', Icons.swap_horiz_outlined, '/handoff'),
      _PageConfig(
          'External Realtors', Icons.people_outlined, '/realtor-portal'),
      _PageConfig('Partner Portal', Icons.share_outlined, '/partner-portal'),
    ]),
    _SectionConfig('Governance', [
      _PageConfig('Role & Permissions', Icons.admin_panel_settings_outlined,
          '/role-governance'),
      _PageConfig('Approval Center', Icons.checklist_outlined, '/approvals'),
      _PageConfig('Audit Log', Icons.history_outlined, '/audit-log'),
    ]),
  ];

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<MarketingModuleController>()) {
      Get.put(MarketingModuleController());
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionService = Get.isRegistered<PermissionService>()
        ? Get.find<PermissionService>()
        : Get.put(PermissionService());
    return Obx(() {
      permissionService.version;
      final visibleSections = _visibleSections(permissionService);
      if (visibleSections.isEmpty) {
        return const Center(
            child: Text('No Marketing screens are available for your role.'));
      }

      final sectionIndex =
          _selectedSection.clamp(0, visibleSections.length - 1).toInt();
      final pageIndex = _selectedPage
          .clamp(0, visibleSections[sectionIndex].pages.length - 1)
          .toInt();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTabs(visibleSections, sectionIndex),
          if (visibleSections[sectionIndex].pages.length > 1) ...[
            const SizedBox(height: 8),
            _buildPageTabs(visibleSections, sectionIndex, pageIndex),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: KeyedSubtree(
                key: ValueKey('$sectionIndex-$pageIndex'),
                child: _buildCurrentScreen(
                    visibleSections, sectionIndex, pageIndex),
              ),
            ),
          ),
        ],
      );
    });
  }

  List<_SectionConfig> _visibleSections(PermissionService permissionService) {
    return _sections
        .map((section) => _SectionConfig(
              section.name,
              section.pages
                  .where((page) => permissionService
                      .canAccessRouteTyped('/marketing${page.route}'))
                  .toList(),
            ))
        .where((section) => section.pages.isNotEmpty)
        .toList();
  }

  Widget _buildSectionTabs(List<_SectionConfig> sections, int selectedSection) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          children: List.generate(sections.length, (i) {
            final isActive = selectedSection == i;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedSection = i;
                _selectedPage = 0;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  border: isActive
                      ? Border.all(color: AppColors.borderSubtle)
                      : null,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 1))
                        ]
                      : null,
                ),
                child: Text(
                  sections[i].name,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPageTabs(
      List<_SectionConfig> sections, int sectionIndex, int pageIndex) {
    final pages = sections[sectionIndex].pages;
    return SizedBox(
      height: 34,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(pages.length, (i) {
            final isActive = pageIndex == i;
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: GestureDetector(
                onTap: () => setState(() => _selectedPage = i),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(pages[i].icon,
                          size: 14,
                          color: isActive ? Colors.white : AppColors.textMuted),
                      const SizedBox(width: 5),
                      Text(
                        pages[i].name,
                        style: TextStyle(
                          fontSize: 11.5,
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

  Widget _buildCurrentScreen(
      List<_SectionConfig> sections, int sectionIndex, int pageIndex) {
    final page = sections[sectionIndex].pages[pageIndex];
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: MarketingWebView(
        route: page.route,
        hideSidebar: true,
        hideTopbar: false,
      ),
    );
  }
}

class _SectionConfig {
  final String name;
  final List<_PageConfig> pages;
  const _SectionConfig(this.name, this.pages);
}

class _PageConfig {
  final String name;
  final IconData icon;
  final String route;
  const _PageConfig(this.name, this.icon, this.route);
}
