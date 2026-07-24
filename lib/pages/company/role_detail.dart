import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/app_routes/app_route_constants.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/model/role_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import 'controllers/roles_controller.dart';
import 'widget/roles_dialogs.dart';
import 'widget/role_detail_tabs/career_path_tab.dart';
import 'widget/role_detail_tabs/daily_routine_tab.dart';
import 'widget/role_detail_tabs/performance_analytics_tab.dart';
import 'widget/role_detail_tabs/resources_tab.dart';
import 'widget/role_detail_tabs/targets_tab.dart';
import 'widget/role_detail_tabs/task_template_tab.dart';
import 'widget/role_detail_tabs/sop_tab.dart';
import 'widget/role_detail_tabs/success_playbook_tab.dart';
import 'widget/role_detail_tabs/training_tab.dart';
import 'widget/role_detail_tabs/kpi_tab.dart';
import 'widget/role_detail_tabs/org_chart_tab.dart';
import 'widget/role_detail_tabs/overview_tab.dart';
import 'widget/role_detail_tabs/authority_limits_tab.dart';

class RoleCategory {
  final String title;
  final IconData icon;
  final List<RoleTabItem> items;

  const RoleCategory({
    required this.title,
    required this.icon,
    required this.items,
  });
}

class RoleTabItem {
  final String label;
  final Widget Function(Role role, int roleId) builder;

  const RoleTabItem({
    required this.label,
    required this.builder,
  });
}

class RoleDetailPage extends StatefulWidget {
  final int roleId;

  const RoleDetailPage({super.key, required this.roleId});

  @override
  State<RoleDetailPage> createState() => _RoleDetailPageState();
}

class _RoleDetailPageState extends State<RoleDetailPage> {
  int _selectedCategoryIndex = 0;
  int _selectedSubTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RolesController>();
    final role = ctrl.roles.firstWhereOrNull((r) => r.id == widget.roleId);

    if (role == null) {
      return PageScaffold(
        header: PageHeader(
          title: 'Role Not Found',
          subtitle: 'The requested role could not be found.',
          trailing: MyOutlinedButton(
            height: 44,
            child: 'Back to Roles',
            onTap: () => GoRouter.of(context).go(RouteConstants.roles),
          ),
        ),
        children: const [
          Center(
            child: Padding(
              padding: EdgeInsets.all(64),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.security_user, size: 64, color: AppColors.textMuted),
                  SizedBox(height: 16),
                  Text('Role not found', style: TextStyle(fontSize: 18, color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final categories = [
      RoleCategory(
        title: 'Core & Structure',
        icon: Iconsax.hierarchy,
        items: [
          RoleTabItem(label: 'Overview', builder: (role, id) => OverviewTab(role: role)),
          RoleTabItem(label: 'Authority Limits', builder: (role, id) => AuthorityLimitsTab(roleId: id)),
          RoleTabItem(label: 'Org Chart', builder: (role, id) => _OrgChartWrapper(role: role)),
          RoleTabItem(label: 'Career Path', builder: (role, id) => CareerPathTab(role: role)),
          RoleTabItem(
            label: 'Succession Plan',
            builder: (role, id) => const ComingSoonTab(
              title: 'Succession Planning',
              description: 'Identify and track potential successors for key organizational roles.',
              icon: Iconsax.user_search,
            ),
          ),
        ],
      ),
      RoleCategory(
        title: 'Performance & Goals',
        icon: Iconsax.status_up,
        items: [
          RoleTabItem(label: 'KPIs', builder: (role, id) => KpiTab(roleId: id)),
          RoleTabItem(
            label: 'OKRs',
            builder: (role, id) => const ComingSoonTab(
              title: 'Role OKRs',
              description: 'Set and track quarterly objectives and key results for this role.',
              icon: Iconsax.ranking,
            ),
          ),
          RoleTabItem(label: 'Targets', builder: (role, id) => TargetsTab(roleId: id)),
          RoleTabItem(label: 'Performance Analytics', builder: (role, id) => PerformanceAnalyticsTab(roleId: id)),
          RoleTabItem(
            label: 'Reports',
            builder: (role, id) => const ComingSoonTab(
              title: 'Role Reports',
              description: 'Configure and track recurring performance and compliance reports for this role.',
              icon: Iconsax.document_text,
            ),
          ),
        ],
      ),
      RoleCategory(
        title: 'Workflows & Tasks',
        icon: Iconsax.task_square,
        items: [
          RoleTabItem(label: 'Task Templates', builder: (role, id) => TaskTemplateTab(roleId: id)),
          RoleTabItem(label: 'SOPs', builder: (role, id) => SopTab(roleId: id)),
          RoleTabItem(label: 'Daily Work Routine', builder: (role, id) => DailyRoutineTab(roleId: id)),
          RoleTabItem(
            label: 'Decision Matrix',
            builder: (role, id) => const ComingSoonTab(
              title: 'Decision Matrix',
              description: 'Define decision authority, required approvals, and escalation paths for this role.',
              icon: Iconsax.category,
            ),
          ),
        ],
      ),
      RoleCategory(
        title: 'Learning & Resources',
        icon: Iconsax.teacher,
        items: [
          RoleTabItem(label: 'Training', builder: (role, id) => TrainingTab(roleId: id)),
          RoleTabItem(label: 'Success Playbook', builder: (role, id) => SuccessPlaybookTab(roleId: id)),
          RoleTabItem(label: 'Resources', builder: (role, id) => ResourcesTab(roleId: id)),
          RoleTabItem(
            label: 'Knowledge Base',
            builder: (role, id) => const ComingSoonTab(
              title: 'Knowledge Base',
              description: 'Centralized repository of role-specific documentation and guides.',
              icon: Iconsax.book,
            ),
          ),
        ],
      ),
      RoleCategory(
        title: 'Governance & People',
        icon: Iconsax.shield_tick,
        items: [
          RoleTabItem(
            label: 'Risk Profile',
            builder: (role, id) => const ComingSoonTab(
              title: 'Risk Profile',
              description: 'Identify operational, financial, and compliance risks associated with this role.',
              icon: Iconsax.warning_2,
            ),
          ),
          RoleTabItem(
            label: 'Stakeholders',
            builder: (role, id) => const ComingSoonTab(
              title: 'Role Stakeholders',
              description: 'Manage internal and external key stakeholder relationships for this role.',
              icon: Iconsax.people,
            ),
          ),
        ],
      ),
    ];

    final activeCategory = categories[_selectedCategoryIndex];
    if (_selectedSubTabIndex >= activeCategory.items.length) {
      _selectedSubTabIndex = 0;
    }
    final activeSubTab = activeCategory.items[_selectedSubTabIndex];

    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: role.name,
        subtitle: 'Role detail & configuration',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyOutlinedButton(
              height: 44,
              child: 'Edit Role',
              icon: const Icon(Iconsax.edit, size: 16, color: AppColors.textPrimary),
              onTap: () => showDialog(
                context: context,
                builder: (_) => CreateEditRoleDialog(ctrl: ctrl, role: role),
              ),
            ),
            const SizedBox(width: 12),
            MyOutlinedButton(
              height: 44,
              child: 'Back',
              icon: const Icon(Iconsax.arrow_left, size: 16, color: AppColors.textPrimary),
              onTap: () => GoRouter.of(context).go(RouteConstants.roles),
            ),
          ],
        ),
      ),
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border),
          ),
          color: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Category Level 1 Navigation Bar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(categories.length, (index) {
                      final cat = categories[index];
                      final isSelected = index == _selectedCategoryIndex;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          showCheckmark: false,
                          avatar: Icon(
                            cat.icon,
                            size: 18,
                            color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
                          ),
                          label: Text(
                            cat.title,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.neutral100,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategoryIndex = index;
                                _selectedSubTabIndex = 0;
                              });
                            }
                          },
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 12),
                // Sub-Tab Level 2 Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(activeCategory.items.length, (subIndex) {
                      final subTab = activeCategory.items[subIndex];
                      final isSubSelected = subIndex == _selectedSubTabIndex;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          showCheckmark: false,
                          label: Text(
                            subTab.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSubSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSubSelected ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                          selected: isSubSelected,
                          selectedColor: AppColors.primarySubtle,
                          backgroundColor: AppColors.surface,
                          side: BorderSide(
                            color: isSubSelected ? AppColors.primary : AppColors.border,
                            width: isSubSelected ? 1.5 : 1.0,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedSubTabIndex = subIndex;
                              });
                            }
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Active Sub-Tab Viewport
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.border),
            ),
            child: activeSubTab.builder(role, widget.roleId),
          ),
        ),
      ],
    );
  }
}

class _OrgChartWrapper extends StatelessWidget {
  final Role role;

  const _OrgChartWrapper({required this.role});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RolesController>(
      builder: (ctrl) => OrgChartTab(role: role, allRoles: ctrl.roles),
    );
  }
}

class ComingSoonTab extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const ComingSoonTab({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: const Text(
                'Module Coming Soon in Next Backend Update',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
