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

import 'controllers/authority_limit_controller.dart';
import 'controllers/roles_controller.dart';
import 'widget/roles_dialogs.dart';
import 'widget/role_detail_tabs/authority_limits_tab.dart';
import 'widget/role_detail_tabs/career_path_tab.dart';
import 'widget/role_detail_tabs/kpi_tab.dart';
import 'widget/role_detail_tabs/okr_tab.dart';
import 'widget/role_detail_tabs/org_chart_tab.dart';
import 'widget/role_detail_tabs/overview_tab.dart';

class RoleDetailPage extends StatelessWidget {
  final int roleId;

  const RoleDetailPage({super.key, required this.roleId});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RolesController>();
    final role = ctrl.roles.firstWhereOrNull((r) => r.id == roleId);

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

    final tabs = [
      'Overview',
      'Authority Limits',
      'Org Chart',
      'KPIs',
      'OKRs',
      'Career Path',
    ];

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
        _RoleBody(role: role, roleId: roleId, tabs: tabs),
      ],
    );
  }
}

class _RoleBody extends StatelessWidget {
  final Role role;
  final int roleId;
  final List<String> tabs;

  const _RoleBody({
    required this.role,
    required this.roleId,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.surface,
            child: TabBar(
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: TabBarView(
              children: [
                OverviewTab(role: role),
                _AuthorityLimitsWrapper(roleId: roleId),
                _OrgChartWrapper(role: role),
                KpiTab(roleId: roleId),
                OkrTab(roleId: roleId),
                CareerPathTab(role: role),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthorityLimitsWrapper extends StatelessWidget {
  final int roleId;

  const _AuthorityLimitsWrapper({required this.roleId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthorityLimitController>(
      init: Get.put(AuthorityLimitController()),
      builder: (limitCtrl) {
        return AuthorityLimitsTab(
          roleId: roleId,
          limits: limitCtrl.authorityLimits
              .where((l) => l.roleId == roleId.toString())
              .toList(),
        );
      },
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
