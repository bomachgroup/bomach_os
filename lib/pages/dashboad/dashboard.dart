import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/pages/dashboad/controller/dashboard_controller.dart';
import 'package:bomach_os/pages/dashboad/models/dashboard_models.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController controller = Get.put(DashboardController());

  // Per-tile accent palette — kept as explicit local choices to preserve the
  // differentiated feel of the dashboard stat cards.
  static const _accentIndigo = Color(0xFF6366F1);
  static const _accentCyan = AppColors.info;
  static const _accentAmber = AppColors.warning;
  static const _accentGreen = AppColors.success;
  static const _accentRed = AppColors.danger;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState();
      }

      if (controller.errorMessage.isNotEmpty) {
        return Center(
          child: EmptyState(
            title: 'Could not load dashboard',
            subtitle: controller.errorMessage.value,
            icon: Iconsax.warning_2,
            action: OutlinedButton.icon(
              onPressed: controller.fetchAll,
              icon: const Icon(Iconsax.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ),
        );
      }

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Dashboard',
              subtitle:
                  "Welcome back — here's what's happening across your workspace",
            ),
            const SizedBox(height: 16),
            _buildWelcomeHeader(),
            const SizedBox(height: 24),
            _buildStatsGrid(),
            const SizedBox(height: 24),
            _buildPerformanceSection(),
            const SizedBox(height: 24),
            _buildOverviewSection(),
            const SizedBox(height: 24),
          ],
        ),
      );
    });
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 160,
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: AppRadii.brLg,
            ),
          ),
          const SizedBox(height: 24),
          LoadingSkeleton.statRow(count: 5),
          const SizedBox(height: 24),
          LoadingSkeleton.card(lines: 5),
          const SizedBox(height: 24),
          LoadingSkeleton.card(lines: 4),
        ],
      ),
    );
  }

  // ── Welcome Header ────────────────────────────────────────────────────
  Widget _buildWelcomeHeader() {
    final s = controller.summary.value;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryPressed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadii.brLg,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.2),
                  borderRadius: AppRadii.brMd,
                ),
                child: Center(
                  child: Text(
                    _getInitials(s?.fullName ?? 'U'),
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      'Welcome back, ${s?.fullName ?? 'User'}!',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    MyText(
                      '${s?.jobTitle ?? ''}${s?.departmentName != null && s!.departmentName.isNotEmpty ? ' \u2022 ${s.departmentName}' : ''}',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textOnPrimary.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (s?.scorecard != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.textOnPrimary.withValues(alpha: 0.1),
                borderRadius: AppRadii.brMd,
                border: Border.all(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildHeaderStat(
                      'Overall Score',
                      '${s!.scorecard.overallScore.toInt()}%',
                      Iconsax.speedometer,
                    ),
                  ),
                  _verticalDivider(),
                  Expanded(
                    child: _buildHeaderStat(
                      'Ranking',
                      '#${s.ranking.rank}/${s.ranking.totalMembers}',
                      Iconsax.ranking,
                    ),
                  ),
                  _verticalDivider(),
                  Expanded(
                    child: _buildHeaderStat(
                      'Performance',
                      s.scorecard.rankText,
                      Iconsax.chart_2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: AppColors.textOnPrimary.withValues(alpha: 0.15),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: AppColors.textOnPrimary.withValues(alpha: 0.7),
          size: 20,
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                value,
                style: AppTextStyles.bodyLg.copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              MyText(
                label,
                style: AppTextStyles.overline.copyWith(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Stats Grid ────────────────────────────────────────────────────────
  Widget _buildStatsGrid() {
    final st = controller.stats.value;
    if (st == null) return const SizedBox.shrink();

    final stats = [
      _StatItem('Projects', st.totalProjects.toString(), Iconsax.folder_cloud,
          _accentIndigo),
      _StatItem('Contracts', st.totalContracts.toString(),
          Iconsax.document_text, _accentCyan),
      _StatItem('Worksites', st.totalWorksites.toString(), Iconsax.location,
          _accentAmber),
      _StatItem('Budget Used', '${st.budgetUtilization.toStringAsFixed(1)}%',
          Iconsax.wallet_3, _accentGreen),
      _StatItem('Timelines', st.totalTimelines.toString(), Iconsax.timer_1,
          _accentRed),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 5
            : constraints.maxWidth > 600
                ? 3
                : 2;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: stats.map((s) {
            final cardWidth =
                (constraints.maxWidth - (crossAxisCount - 1) * 16) /
                    crossAxisCount;
            return SizedBox(
              width: cardWidth,
              child: _buildStatCard(s),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildStatCard(_StatItem item) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: AppRadii.brMd,
            ),
            child: Icon(item.icon, color: item.color, size: 22),
          ),
          const SizedBox(height: 16),
          MyText(
            item.value,
            style: AppTextStyles.displayMd.copyWith(
              fontSize: 26,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          MyText(
            item.label,
            style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  // ── Performance Section ───────────────────────────────────────────────
  Widget _buildPerformanceSection() {
    final pc = controller.performanceCard.value;
    if (pc == null) return const SizedBox.shrink();

    return AppCard(
      padding: const EdgeInsets.all(24),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppRadii.brSm,
                ),
                child: const Icon(Iconsax.chart_square,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const MyText('Performance Overview', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 700) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildScoreGauge(pc),
                    const SizedBox(width: 24),
                    Expanded(child: _buildWorkReportCard(pc)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildPunctualityCard(pc)),
                  ],
                );
              }
              return Column(
                children: [
                  _buildScoreGauge(pc),
                  const SizedBox(height: 20),
                  _buildWorkReportCard(pc),
                  const SizedBox(height: 20),
                  _buildPunctualityCard(pc),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScoreGauge(PerformanceCard pc) {
    final scoreColor = _getScoreColor(pc.overallScore);
    return Container(
      width: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scoreColor.withValues(alpha: 0.05),
            scoreColor.withValues(alpha: 0.02),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: AppRadii.brLg,
        border: Border.all(color: scoreColor.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 130,
            height: 130,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: CircularProgressIndicator(
                    value: pc.overallScore / 100,
                    strokeWidth: 12,
                    strokeCap: StrokeCap.round,
                    backgroundColor: AppColors.neutral100,
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyText(
                      '${pc.overallScore.toInt()}%',
                      style: AppTextStyles.displayLg.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    MyText(
                      'Score',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.12),
              borderRadius: AppRadii.brPill,
            ),
            child: MyText(
              pc.rankText,
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w600,
                color: scoreColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkReportCard(PerformanceCard pc) {
    final wr = pc.workReport;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _accentCyan.withValues(alpha: 0.1),
                  borderRadius: AppRadii.brSm,
                ),
                child: const Icon(Iconsax.document_text,
                    color: _accentCyan, size: 18),
              ),
              const SizedBox(width: 10),
              MyText(
                'Work Reports',
                style: AppTextStyles.h4.copyWith(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressStat(
              'Score', wr.score / 100, '${wr.score.toInt()}%', _accentCyan),
          const SizedBox(height: 14),
          _buildInfoRow(Iconsax.send_1, 'Submitted', '${wr.reportsSubmitted}',
              _accentIndigo),
          const SizedBox(height: 10),
          _buildInfoRow(
              Iconsax.tick_circle, 'Approved', '${wr.approved}', _accentGreen),
          const SizedBox(height: 10),
          _buildInfoRow(Iconsax.star_1, 'Avg Rating',
              wr.averageRating.toStringAsFixed(1), _accentAmber),
        ],
      ),
    );
  }

  Widget _buildPunctualityCard(PerformanceCard pc) {
    final pr = pc.punctualityReport;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _accentGreen.withValues(alpha: 0.1),
                  borderRadius: AppRadii.brSm,
                ),
                child: const Icon(Iconsax.clock, color: _accentGreen, size: 18),
              ),
              const SizedBox(width: 10),
              MyText(
                'Punctuality',
                style: AppTextStyles.h4.copyWith(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressStat(
              'Score', pr.score / 100, '${pr.score.toInt()}%', _accentGreen),
          const SizedBox(height: 14),
          _buildInfoRow(Iconsax.calendar_1, 'Total Days', '${pr.totalDays}',
              _accentIndigo),
          const SizedBox(height: 10),
          _buildInfoRow(
              Iconsax.tick_square, 'On Time', '${pr.onTimeDays}', _accentGreen),
          const SizedBox(height: 10),
          _buildInfoRow(
              Iconsax.timer_1, 'Late', '${pr.lateDays}', _accentAmber),
          const SizedBox(height: 10),
          _buildInfoRow(
              Iconsax.close_circle, 'Absent', '${pr.absentDays}', _accentRed),
        ],
      ),
    );
  }

  Widget _buildProgressStat(
      String label, double progress, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MyText(label,
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
            MyText(
              value,
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: AppRadii.brXs,
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 10),
        Expanded(
          child: MyText(
            label,
            style:
                AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
          ),
        ),
        MyText(
          value,
          style: AppTextStyles.bodyMd.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ── Overview Section ──────────────────────────────────────────────────
  Widget _buildOverviewSection() {
    final ov = controller.overview.value;
    if (ov == null) return const SizedBox.shrink();

    return AppCard(
      padding: const EdgeInsets.all(24),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accentIndigo.withValues(alpha: 0.1),
                  borderRadius: AppRadii.brSm,
                ),
                child: const Icon(Iconsax.building_3,
                    color: _accentIndigo, size: 20),
              ),
              const SizedBox(width: 12),
              const MyText('Organization Overview', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth > 700
                  ? (constraints.maxWidth - 48) / 4
                  : (constraints.maxWidth - 16) / 2;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                      width: cardWidth,
                      child: _buildOverviewCard(
                          'Total Employees',
                          '${ov.totalEmployees}',
                          Iconsax.people,
                          _accentIndigo)),
                  SizedBox(
                      width: cardWidth,
                      child: _buildOverviewCard(
                          'New (30 days)',
                          '${ov.newHires30Days}',
                          Iconsax.user_add,
                          _accentCyan)),
                  SizedBox(
                      width: cardWidth,
                      child: _buildOverviewCard(
                          'Hired Today',
                          '${ov.newHiresToday}',
                          Iconsax.calendar_tick,
                          _accentGreen)),
                  SizedBox(
                      width: cardWidth,
                      child: _buildOverviewCard('Open Roles', '${ov.openRoles}',
                          Iconsax.briefcase, _accentAmber)),
                ],
              );
            },
          ),
          if (ov.headcountByDepartment.isNotEmpty) ...[
            const SizedBox(height: 24),
            MyText(
              'Headcount by Department',
              style: AppTextStyles.h4.copyWith(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ov.headcountByDepartment.map((dept) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: AppRadii.brSm,
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyText(
                        dept.department,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: AppRadii.brXs,
                        ),
                        child: MyText(
                          '${dept.count}',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverviewCard(
      String label, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.04),
        borderRadius: AppRadii.brMd,
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadii.brMd,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  count,
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 22,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                MyText(
                  label,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────
  Color _getScoreColor(double score) {
    if (score >= 80) return _accentGreen;
    if (score >= 60) return _accentCyan;
    if (score >= 40) return _accentAmber;
    return _accentRed;
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  _StatItem(this.label, this.value, this.icon, this.color);
}
