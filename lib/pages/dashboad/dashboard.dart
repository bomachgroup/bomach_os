import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/dashboad/controller/dashboard_controller.dart';
import 'package:bms_front_end/pages/dashboad/models/dashboard_models.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../src/app_routes/app_route_constants.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              MyText(controller.errorMessage.value,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => controller.fetchAll(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 24),
            _buildQuickActions(),
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

  // ── Welcome Header ────────────────────────────────────────────────────
  Widget _buildWelcomeHeader() {
    final s = controller.summary.value;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0055FF), Color(0xFF1A3FCC), Color(0xFF0D2B99)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0055FF).withValues(alpha: 0.25),
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
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    _getInitials(s?.fullName ?? 'U'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    MyText(
                      '${s?.jobTitle ?? ''}${s?.departmentName != null && s!.departmentName.isNotEmpty ? ' \u2022 ${s.departmentName}' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white.withValues(alpha: 0.75),
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
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildHeaderStat(
                      'Overall Score',
                      '${s!.scorecard.overallScore.toInt()}%',
                      Icons.speed_rounded,
                    ),
                  ),
                  _verticalDivider(),
                  Expanded(
                    child: _buildHeaderStat(
                      'Ranking',
                      '#${s.ranking.rank}/${s.ranking.totalMembers}',
                      Icons.leaderboard_rounded,
                    ),
                  ),
                  _verticalDivider(),
                  Expanded(
                    child: _buildHeaderStat(
                      'Performance',
                      s.scorecard.rankText,
                      Icons.trending_up_rounded,
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
      color: Colors.white.withValues(alpha: 0.15),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 20),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(value,
                  style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.white,
                      fontWeight: FontWeight.w700)),
              MyText(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.white.withValues(alpha: 0.65),
                      fontWeight: FontWeight.w400)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Quick Actions ─────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    return Row(
      children: [
        _buildActionCard(
          icon: Icons.task_alt_rounded,
          label: 'My Tasks',
          color: const Color(0xFF6366F1),
          onTap: () => context.go(RouteConstants.employeeMyTasks),
        ),
        const SizedBox(width: 12),
        _buildActionCard(
          icon: Icons.description_rounded,
          label: 'Work Reports',
          color: const Color(0xFF0EA5E9),
          onTap: () => context.go(RouteConstants.employeeMyReports),
        ),
        const SizedBox(width: 12),
        _buildActionCard(
          icon: Icons.refresh_rounded,
          label: 'Refresh',
          color: const Color(0xFF10B981),
          onTap: () => controller.fetchAll(),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: MyText(label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Stats Grid ────────────────────────────────────────────────────────
  Widget _buildStatsGrid() {
    final st = controller.stats.value;
    if (st == null) return const SizedBox.shrink();

    final stats = [
      _StatItem('Projects', st.totalProjects.toString(),
          Icons.folder_copy_rounded, const Color(0xFF6366F1)),
      _StatItem('Contracts', st.totalContracts.toString(),
          Icons.handshake_rounded, const Color(0xFF0EA5E9)),
      _StatItem('Worksites', st.totalWorksites.toString(),
          Icons.location_on_rounded, const Color(0xFFF59E0B)),
      _StatItem('Budget Used', '${st.budgetUtilization.toStringAsFixed(1)}%',
          Icons.account_balance_wallet_rounded, const Color(0xFF10B981)),
      _StatItem('Timelines', st.totalTimelines.toString(),
          Icons.timeline_rounded, const Color(0xFFEF4444)),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MyText(item.value,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          MyText(item.label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  // ── Performance Section ───────────────────────────────────────────────
  Widget _buildPerformanceSection() {
    final pc = controller.performanceCard.value;
    if (pc == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.insights_rounded,
                    color: AppColors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              const MyText('Performance Overview',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B))),
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
        borderRadius: BorderRadius.circular(16),
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
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyText(
                      '${pc.overallScore.toInt()}%',
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B)),
                    ),
                    MyText('Score',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500)),
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
              borderRadius: BorderRadius.circular(20),
            ),
            child: MyText(pc.rankText,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: scoreColor)),
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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.description_rounded,
                    color: Color(0xFF0EA5E9), size: 18),
              ),
              const SizedBox(width: 10),
              const MyText('Work Reports',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155))),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressStat('Score', wr.score / 100, '${wr.score.toInt()}%',
              const Color(0xFF0EA5E9)),
          const SizedBox(height: 14),
          _buildInfoRow(Icons.send_rounded, 'Submitted',
              '${wr.reportsSubmitted}', const Color(0xFF6366F1)),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.check_circle_rounded, 'Approved',
              '${wr.approved}', const Color(0xFF10B981)),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.star_rounded, 'Avg Rating',
              wr.averageRating.toStringAsFixed(1), const Color(0xFFF59E0B)),
        ],
      ),
    );
  }

  Widget _buildPunctualityCard(PerformanceCard pc) {
    final pr = pc.punctualityReport;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.schedule_rounded,
                    color: Color(0xFF10B981), size: 18),
              ),
              const SizedBox(width: 10),
              const MyText('Punctuality',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155))),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressStat('Score', pr.score / 100, '${pr.score.toInt()}%',
              const Color(0xFF10B981)),
          const SizedBox(height: 14),
          _buildInfoRow(Icons.calendar_today_rounded, 'Total Days',
              '${pr.totalDays}', const Color(0xFF6366F1)),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.check_rounded, 'On Time', '${pr.onTimeDays}',
              const Color(0xFF10B981)),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.access_time_rounded, 'Late', '${pr.lateDays}',
              const Color(0xFFF59E0B)),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.cancel_rounded, 'Absent', '${pr.absentDays}',
              const Color(0xFFEF4444)),
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
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500)),
            MyText(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
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

  Widget _buildInfoRow(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 10),
        Expanded(
          child: MyText(label,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400)),
        ),
        MyText(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B))),
      ],
    );
  }

  // ── Overview Section ──────────────────────────────────────────────────
  Widget _buildOverviewSection() {
    final ov = controller.overview.value;
    if (ov == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.business_rounded,
                    color: Color(0xFF6366F1), size: 20),
              ),
              const SizedBox(width: 12),
              const MyText('Organization Overview',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B))),
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
                      child: _buildOverviewCard('Total Employees',
                          '${ov.totalEmployees}', Icons.people_rounded,
                          const Color(0xFF6366F1))),
                  SizedBox(
                      width: cardWidth,
                      child: _buildOverviewCard('New (30 days)',
                          '${ov.newHires30Days}', Icons.person_add_rounded,
                          const Color(0xFF0EA5E9))),
                  SizedBox(
                      width: cardWidth,
                      child: _buildOverviewCard('Hired Today',
                          '${ov.newHiresToday}', Icons.today_rounded,
                          const Color(0xFF10B981))),
                  SizedBox(
                      width: cardWidth,
                      child: _buildOverviewCard('Open Roles',
                          '${ov.openRoles}', Icons.work_outline_rounded,
                          const Color(0xFFF59E0B))),
                ],
              );
            },
          ),
          if (ov.headcountByDepartment.isNotEmpty) ...[
            const SizedBox(height: 24),
            const MyText('Headcount by Department',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155))),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ov.headcountByDepartment.map((dept) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyText(dept.department,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF475569))),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: MyText('${dept.count}',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.blue)),
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(count,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B))),
                MyText(label,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────
  Color _getScoreColor(double score) {
    if (score >= 80) return const Color(0xFF10B981);
    if (score >= 60) return const Color(0xFF0EA5E9);
    if (score >= 40) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
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
