import 'dart:math';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/cards/module_shortcut_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/section/module_dashboard.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import '../../components/section/responsive_stat_row.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/src/app_routes/app_route_constants.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/icons.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/spaces.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bomach_os/pages/hr/controller/dashboard_controller.dart';
import 'package:bomach_os/src/services/hr/hr_services.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';

// Local accent palette
const Color _accentGreen = AppColors.success;
const Color _accentIndigo = Color(0xFF6366F1);
const Color _accentAmber = AppColors.warning;
const Color _accentPink = Color(0xFFEC4899);
const Color _accentPurple = Color(0xFF8B5CF6);
const Color _accentOrange = AppColors.warning;
const Color _accentTeal = Color(0xFF14B8A6);
const Color _accentBlue = AppColors.primary;

class HRPage extends StatelessWidget {
  const HRPage({super.key});

  @override
  Widget build(BuildContext context) {
    final HRController controller = Get.put(HRController());

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final bool isDesktop = width >= 1100;
        final bool isMobile = width < 650;

        return PageScaffold(
          header: PageHeader(
            title: 'Human Resources',
            subtitle: 'Manage employees, payroll, leave, training, and everything people-ops',
            trailing: isMobile ? null : _buildHeaderActions(),
          ),
          children: [
            const _QuickNavSection(),
            Obx(() {
              if (controller.isLoading.value && controller.stats.value == null) {
                return LoadingSkeleton.statRow(count: 4);
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

  Widget _buildHeaderActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Iconsax.briefcase, size: 16),
          label: const Text('Job Postings'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.borderSubtle),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
            textStyle: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        kSizedBoxWidth,
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Iconsax.user_add, size: 16),
          label: const Text('Add Employee'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            elevation: 0,
            shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
            textStyle: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
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
          count: stats != null ? '${stats!.totalEmployees}' : '--',
          icon: Iconsax.people,
          accent: _accentGreen,
        ),
        _StatCard(
          title: 'New Hires (MTD)',
          count: stats != null ? '${stats!.newEmployeesCount}' : '--',
          icon: Iconsax.user_add,
          accent: _accentBlue,
        ),
        _StatCard(
          title: 'Open Roles',
          count: stats != null ? '${stats!.jobPostings}' : '--',
          icon: Iconsax.briefcase,
          accent: _accentAmber,
        ),
        _StatCard(
          title: 'Pending Leaves',
          count: stats != null ? '${stats!.leaves}' : '--',
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
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accentIndigo.withValues(alpha: 0.12),
                  borderRadius: AppRadii.brSm,
                ),
                child: const Icon(Iconsax.chart_square, size: 18, color: _accentIndigo),
              ),
              const SizedBox(width: 12),
              const MyText('Headcount by Department', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(builder: (context, constraints) {
            final bool narrow = constraints.maxWidth < 350;
            return Flex(
              direction: narrow ? Axis.vertical : Axis.horizontal,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 160,
                  width: 160,
                  child: CustomPaint(painter: DonutChartPainter()),
                ),
                SizedBox(width: narrow ? 0 : 40, height: narrow ? 20 : 0),
                const Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LegendItem(_accentIndigo, 'Development', '78 employees'),
                      _LegendItem(_accentPurple, 'Marketing', '42 employees'),
                      _LegendItem(_accentPink, 'Sales', '56 employees'),
                      _LegendItem(_accentOrange, 'Operations', '35 employees'),
                      _LegendItem(_accentTeal, 'Finance', '24 employees'),
                      _LegendItem(_accentBlue, 'HR', '12 employees'),
                    ],
                  ),
                )
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String sub;

  const _LegendItem(this.color, this.label, this.sub);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadii.brSm,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: MyText(
                    label,
                    style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: 4),
                MyText(
                  sub,
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BirthdaysSection extends StatelessWidget {
  const _BirthdaysSection();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accentPink.withValues(alpha: 0.12),
                  borderRadius: AppRadii.brSm,
                ),
                child: const Icon(Iconsax.cake, size: 18, color: _accentPink),
              ),
              const SizedBox(width: 12),
              const MyText('Upcoming Birthdays', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 20),
          const _BirthdayTile('N', 'Nicky Fry', 'Designer', 'Apr 24', _accentPurple),
          const _BirthdayTile('R', 'Rick Fry', 'Developer', 'May 11', _accentPink),
          const _BirthdayTile('A', 'Alice Fry', 'Manager', 'May 06', _accentOrange),
        ],
      ),
    );
  }
}

class _BirthdayTile extends StatelessWidget {
  final String init, name, role, date;
  final Color color;

  const _BirthdayTile(this.init, this.name, this.role, this.date, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Text(
              init,
              style: AppTextStyles.label.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  name,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                MyText(
                  role,
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          MyText(
            date,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditLogsSection extends StatelessWidget {
  const _AuditLogsSection();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: AppRadii.brSm,
                ),
                child: const Icon(Iconsax.clipboard_text, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              const MyText('Audit Logs', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 20),
          const _AuditItem('Clark Changed Rose Ells', '08:12 AM', last: false),
          const _AuditItem('Garrett added a new employee', '06:45 AM', last: false),
          const _AuditItem('Sophie generated Payroll Report', 'Yesterday', last: false),
          const _AuditItem('System Backup completed', 'Yesterday', last: true),
        ],
      ),
    );
  }
}

class _AuditItem extends StatelessWidget {
  final String title, time;
  final bool last;

  const _AuditItem(this.title, this.time, {required this.last});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                height: 8,
                width: 8,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
              ),
              if (!last)
                Container(width: 1, height: 32, color: AppColors.borderSubtle),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  title,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                MyText(time, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _LeavesSection extends StatelessWidget {
  const _LeavesSection();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accentAmber.withValues(alpha: 0.12),
                  borderRadius: AppRadii.brSm,
                ),
                child: const Icon(Iconsax.calendar_remove, size: 18, color: _accentAmber),
              ),
              const SizedBox(width: 12),
              const MyText('Recent Leaves', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 20),
          const _LeaveItem('David West', '2024-12-01 - 2024-12-14', 'Approved'),
          const _LeaveItem('Sarah Musa', '2024-12-01 - 2024-12-14', 'Pending'),
          const _LeaveItem('Benji Rider 1', '2024-12-01 - 2024-12-14', 'Rejected'),
        ],
      ),
    );
  }
}

class _LeaveItem extends StatelessWidget {
  final String name, date, status;

  const _LeaveItem(this.name, this.date, this.status);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brMd,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  name,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                MyText(date, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          StatusChip.fromStatus(status),
        ],
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 30.0;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -pi / 2;

    void drawSegment(Color color, double percentage) {
      paint.color = color;
      final sweepAngle = 2 * pi * percentage;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }

    drawSegment(_accentIndigo, 0.32);
    drawSegment(_accentPurple, 0.17);
    drawSegment(_accentPink, 0.23);
    drawSegment(_accentOrange, 0.14);
    drawSegment(_accentTeal, 0.09);
    drawSegment(_accentBlue, 0.05);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

