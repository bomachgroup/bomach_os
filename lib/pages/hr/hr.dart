import 'dart:math';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/cards/module_shortcut_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/section/module_dashboard.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/icons.dart';
import 'package:bms_front_end/src/constants/permissions.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/services/permission_service.dart';
import 'package:bms_front_end/pages/company/company.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

// Local accent palette for differentiated stat tiles / chart / birthdays.
// Surfaces, borders, text, and shadows flow through semantic tokens — these
// constants only carry the intentional per-section colour differentiation.
const Color _accentGreen = AppColors.success;
const Color _accentIndigo = Color(0xFF6366F1);
const Color _accentAmber = AppColors.warning;
const Color _accentPink = Color(0xFFEC4899);
const Color _accentPurple = Color(0xFF8B5CF6);
const Color _accentOrange = AppColors.warning;
const Color _accentTeal = Color(0xFF14B8A6);
const Color _accentBlue = AppColors.primary;

class HRPage extends StatefulWidget {
  const HRPage({super.key});

  @override
  State<HRPage> createState() => _HRPageState();
}

class _HRPageState extends State<HRPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final bool isDesktop = width >= 1100;
        final bool isMobile = width < 650;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isMobile),
              kSizedBox,
              _buildQuickNav(),
              kSizedBox,
              _buildSummaryGrid(),
              kSizedBox,
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildChartSection()),
                    kSizedBoxWidth,
                    Expanded(flex: 1, child: _buildBirthdaysSection()),
                  ],
                )
              else ...[
                _buildChartSection(),
                kSizedBox,
                _buildBirthdaysSection(),
              ],
              kSizedBox,
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildAuditLogsSection()),
                    kSizedBoxWidth,
                    Expanded(child: _buildLeavesSection()),
                  ],
                )
              else ...[
                _buildAuditLogsSection(),
                kSizedBox,
                _buildLeavesSection(),
              ],
              kSizedBox,
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickNav() {
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

  // Header
  Widget _buildHeader(bool isMobile) {
    return PageHeader(
      title: 'Human Resources',
      subtitle:
          'Manage employees, payroll, leave, training, and everything people-ops',
      trailing: isMobile
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Iconsax.briefcase, size: 16),
                  label: const Text('Job Postings'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.borderSubtle),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadii.brMd,
                    ),
                    textStyle: AppText.bodyMd.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadii.brMd,
                    ),
                    textStyle: AppText.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Summary grid
  Widget _buildSummaryGrid() {
    return ResponsiveStatRow(
      cards: [
        _buildStatCard(
          title: 'Total Employees',
          count: '234',
          icon: Iconsax.people,
          accent: _accentGreen,
        ),
        _buildStatCard(
          title: 'New Hires (30 days)',
          count: '18',
          icon: Iconsax.user_add,
          accent: _accentBlue,
        ),
        _buildStatCard(
          title: 'Open Roles',
          count: '12',
          icon: Iconsax.briefcase,
          accent: _accentAmber,
        ),
        _buildStatCard(
          title: 'On Leave Today',
          count: '2',
          icon: Iconsax.calendar_remove,
          accent: _accentPink,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color accent,
  }) {
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
            style: AppText.bodySm.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: AppText.h1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // Chart section
  Widget _buildChartSection() {
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
                child: const Icon(Iconsax.chart_square,
                    size: 18, color: _accentIndigo),
              ),
              const SizedBox(width: 12),
              const MyText('Headcount by Department', style: AppText.h3),
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
                  child: CustomPaint(
                    painter: DonutChartPainter(),
                  ),
                ),
                SizedBox(width: narrow ? 0 : 40, height: narrow ? 20 : 0),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(
                          _accentIndigo, 'Development', '78 employees'),
                      _buildLegendItem(
                          _accentPurple, 'Marketing', '42 employees'),
                      _buildLegendItem(_accentPink, 'Sales', '56 employees'),
                      _buildLegendItem(
                          _accentOrange, 'Operations', '35 employees'),
                      _buildLegendItem(_accentTeal, 'Finance', '24 employees'),
                      _buildLegendItem(_accentBlue, 'HR', '12 employees'),
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

  Widget _buildLegendItem(Color color, String label, String sub) {
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
                    style: AppText.label.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                MyText(
                  sub,
                  style: AppText.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Birthdays section
  Widget _buildBirthdaysSection() {
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
              const MyText('Upcoming Birthdays', style: AppText.h3),
            ],
          ),
          const SizedBox(height: 20),
          _buildBirthdayTile(
              'N', 'Nicky Fry', 'Designer', 'Apr 24', _accentPurple),
          _buildBirthdayTile(
              'R', 'Rick Fry', 'Developer', 'May 11', _accentPink),
          _buildBirthdayTile(
              'A', 'Alice Fry', 'Manager', 'May 06', _accentOrange),
        ],
      ),
    );
  }

  Widget _buildBirthdayTile(
      String init, String name, String role, String date, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Text(
              init,
              style: AppText.label.copyWith(
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
                  style: AppText.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                MyText(
                  role,
                  style: AppText.bodySm.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          MyText(
            date,
            style: AppText.bodySm.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Audit logs
  Widget _buildAuditLogsSection() {
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
                child: const Icon(Iconsax.clipboard_text,
                    size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              const MyText('Audit Logs', style: AppText.h3),
            ],
          ),
          const SizedBox(height: 20),
          _buildAuditItem('Clark Changed Rose Ells', '08:12 AM', last: false),
          _buildAuditItem('Garrett added a new employee', '06:45 AM',
              last: false),
          _buildAuditItem('Sophie generated Payroll Report', 'Yesterday',
              last: false),
          _buildAuditItem('System Backup completed', 'Yesterday', last: true),
        ],
      ),
    );
  }

  Widget _buildAuditItem(String title, String time, {required bool last}) {
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
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
              if (!last)
                Container(
                  width: 1,
                  height: 32,
                  color: AppColors.borderSubtle,
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  title,
                  style: AppText.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                MyText(
                  time,
                  style: AppText.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Leaves section
  Widget _buildLeavesSection() {
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
                child: const Icon(Iconsax.calendar_remove,
                    size: 18, color: _accentAmber),
              ),
              const SizedBox(width: 12),
              const MyText('Recent Leaves', style: AppText.h3),
            ],
          ),
          const SizedBox(height: 20),
          _buildLeaveItem('David West', '2024-12-01 - 2024-12-14', 'Approved'),
          _buildLeaveItem('Sarah Musa', '2024-12-01 - 2024-12-14', 'Pending'),
          _buildLeaveItem(
              'Benji Rider 1', '2024-12-01 - 2024-12-14', 'Rejected'),
        ],
      ),
    );
  }

  Widget _buildLeaveItem(String name, String date, String status) {
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
                  style: AppText.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                MyText(
                  date,
                  style: AppText.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          StatusChip.fromStatus(status),
        ],
      ),
    );
  }
}

// Zero-dependency donut chart painter — uses the local accent palette.
class DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 30.0;
    final rect =
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

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
