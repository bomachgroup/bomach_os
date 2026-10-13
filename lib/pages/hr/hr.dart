import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/cards/module_shortcut_card.dart';
import 'package:bomach_os/components/permission/permission_gate.dart';
import 'package:bomach_os/components/section/module_dashboard.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/components/section/responsive_stat_row.dart';
import 'package:bomach_os/components/backend_capability_unavailable.dart';
import 'package:bomach_os/pages/hr/controller/dashboard_controller.dart';
import 'package:bomach_os/pages/hr/widget/add_new_employee.dart';
import 'package:bomach_os/src/app_routes/app_route_constants.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/icons.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/spaces.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/services/hr/hr_services.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

const Color _accentGreen = AppColors.success;
const Color _accentAmber = AppColors.warning;
const Color _accentPink = Color(0xFFEC4899);
const Color _accentBlue = AppColors.primary;

class HRPage extends StatelessWidget {
  const HRPage({super.key});

  @override
  Widget build(BuildContext context) {
    final HRController controller = Get.put(HRController());

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1100;
        final isMobile = constraints.maxWidth < 650;

        return PageScaffold(
          header: PageHeader(
            title: 'Human Resources',
            subtitle:
                'Manage employees, payroll, leave, training, and everything people-ops',
            trailing: isMobile ? null : _buildHeaderActions(context),
          ),
          children: [
            const _QuickNavSection(),
            Obx(() {
              if (controller.isLoading.value &&
                  controller.stats.value == null) {
                return const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (controller.errorMessage.value.isNotEmpty &&
                  controller.stats.value == null) {
                return AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Unable to load HR dashboard statistics.',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySm,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: controller.fetchDashboardStats,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              return _SummaryGridSection(stats: controller.stats.value);
            }),
            if (isDesktop)
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _ChartSection()),
                  kSizedBoxWidth,
                  Expanded(flex: 1, child: _BirthdaysSection()),
                ],
              )
            else ...[
              const _ChartSection(),
              kSizedBox,
              const _BirthdaysSection(),
            ],
            if (isDesktop)
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _AuditLogsSection()),
                  kSizedBoxWidth,
                  Expanded(child: _LeavesSection()),
                ],
              )
            else ...[
              const _AuditLogsSection(),
              kSizedBox,
              const _LeavesSection(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          onPressed: () => GoRouter.of(context).go(RouteConstants.jobPost),
          icon: const Icon(Iconsax.briefcase, size: 16),
          label: const Text('Job Postings'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.borderSubtle),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
            textStyle:
                AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        kSizedBoxWidth,
        PermissionGate(
          require: Perms.employeesCreate,
          child: ElevatedButton.icon(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const AddEmployeeDialog(),
            ),
            icon: const Icon(Iconsax.user_add, size: 16),
            label: const Text('Add Employee'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              elevation: 0,
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
              textStyle:
                  AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickNavSection extends StatelessWidget {
  const _QuickNavSection();

  @override
  Widget build(BuildContext context) {
    final perms = Get.find<PermissionService>();

    ModuleShortcutCard card({
      required IconData icon,
      required String title,
      required String subtitle,
      required String route,
      required List<String> resources,
    }) =>
        ModuleShortcutCard(
          icon: icon,
          title: title,
          subtitle: subtitle,
          route: route,
          enabled: perms.canAccessRoute(route, resources),
        );

    return ModuleQuickNav(
      shortcuts: [
        card(
          icon: AppIcons.employee,
          title: 'Employees',
          subtitle: 'Directory and profiles',
          route: RouteConstants.employees,
          resources: const [PermissionConstants.resEmployees],
        ),
        card(
          icon: Iconsax.clock,
          title: 'Attendance',
          subtitle: 'Clock-ins and hours',
          route: RouteConstants.attendance,
          resources: const [PermissionConstants.resEmployees],
        ),
        card(
          icon: Iconsax.calendar_1,
          title: 'Work Calendar',
          subtitle: 'Public holidays and office closures',
          route: RouteConstants.attendanceCalendar,
          resources: const [PermissionConstants.resAttendanceCalendar],
        ),
        card(
          icon: Iconsax.briefcase,
          title: 'Recruitment',
          subtitle: 'Job posts and applicants',
          route: RouteConstants.jobPost,
          resources: const [PermissionConstants.resJobPostings],
        ),
        card(
          icon: Iconsax.calendar_remove,
          title: 'Leave Requests',
          subtitle: 'Approve and track leave',
          route: RouteConstants.leaveRequest,
          resources: const [PermissionConstants.resLeaveRequests],
        ),
        card(
          icon: Iconsax.trend_up,
          title: 'Performance',
          subtitle: 'Reviews and scorecards',
          route: RouteConstants.performanceReview,
          resources: const [PermissionConstants.resPerformanceReviews],
        ),
        card(
          icon: Iconsax.teacher,
          title: 'Training',
          subtitle: 'Programs and progress',
          route: RouteConstants.trainingProgram,
          resources: const [PermissionConstants.resTrainingPrograms],
        ),
      ],
    );
  }
}

class _SummaryGridSection extends StatelessWidget {
  final DashboardStatsModel? stats;

  const _SummaryGridSection({this.stats});

  @override
  Widget build(BuildContext context) {
    return ResponsiveStatRow(
      cards: [
        _StatCard(
          title: 'Total Employees',
          count: stats == null ? '--' : '${stats!.totalEmployees}',
          icon: Iconsax.people,
          accent: _accentGreen,
        ),
        _StatCard(
          title: 'New Hires (MTD)',
          count: stats == null ? '--' : '${stats!.newEmployeesCount}',
          icon: Iconsax.user_add,
          accent: _accentBlue,
        ),
        _StatCard(
          title: 'Open Roles',
          count: stats == null ? '--' : '${stats!.jobPostings}',
          icon: Iconsax.briefcase,
          accent: _accentAmber,
        ),
        _StatCard(
          title: 'Pending Leaves',
          count: stats == null ? '--' : '${stats!.leaves}',
          icon: Iconsax.calendar_remove,
          accent: _accentPink,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color accent;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: AppRadii.brSm,
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: AppTextStyles.h1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartSection extends StatelessWidget {
  const _ChartSection();

  @override
  Widget build(BuildContext context) {
    return const BackendCapabilityUnavailable(
      featureName: 'Headcount by Department',
      explanation:
          'The dashboard does not have a published department headcount endpoint, so no sample chart is shown.',
      contractRequirement:
          'Publish an aggregated department headcount API before enabling this chart.',
    );
  }
}

class _BirthdaysSection extends StatelessWidget {
  const _BirthdaysSection();

  @override
  Widget build(BuildContext context) {
    return const BackendCapabilityUnavailable(
      featureName: 'Upcoming Birthdays',
      explanation:
          'The current contract does not expose a birthday listing endpoint.',
      contractRequirement:
          'Publish a birthday query with employee identity and date fields before enabling this panel.',
    );
  }
}

class _AuditLogsSection extends StatelessWidget {
  const _AuditLogsSection();

  @override
  Widget build(BuildContext context) {
    return const _DashboardLinkCard(
      title: 'Audit Logs',
      icon: Iconsax.clipboard_text,
      message: 'Review current audit events from the supported audit log API.',
      buttonLabel: 'Open Audit Logs',
      route: RouteConstants.auditLog,
    );
  }
}

class _LeavesSection extends StatelessWidget {
  const _LeavesSection();

  @override
  Widget build(BuildContext context) {
    return const PermissionGate(
      require: Perms.leaveRequestsList,
      child: _DashboardLinkCard(
        title: 'Leave Requests',
        icon: Iconsax.calendar_remove,
        message: 'Review and manage leave records from the supported HR flow.',
        buttonLabel: 'Open Leave Requests',
        route: RouteConstants.leaveRequest,
      ),
    );
  }
}

class _DashboardLinkCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;
  final String buttonLabel;
  final String route;

  const _DashboardLinkCard({
    required this.title,
    required this.icon,
    required this.message,
    required this.buttonLabel,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(title, style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 16),
          Text(message, style: AppTextStyles.bodySm),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => GoRouter.of(context).go(route),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}
