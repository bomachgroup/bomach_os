import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/pages/marketing/controllers/marketing_module_controller.dart';
import 'package:bomach_os/pages/marketing/models/marketing_lead.dart';
import 'package:bomach_os/pages/marketing/models/marketing_misc.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarketingDashboard extends StatelessWidget {
  const MarketingDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MarketingModuleController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(c),
        const SizedBox(height: 16),
        _buildKpiCards(c),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 900) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildPipelinePreview(c)),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _buildNotificationsPanel(c)),
                ],
              );
            }
            return Column(
              children: [
                _buildPipelinePreview(c),
                const SizedBox(height: 16),
                _buildNotificationsPanel(c),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 900) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildTeamPerformance(c)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildOkrProgress(c)),
                ],
              );
            }
            return Column(
              children: [
                _buildTeamPerformance(c),
                const SizedBox(height: 16),
                _buildOkrProgress(c),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader(MarketingModuleController c) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText('Marketing Command Centre', style: AppTextStyles.displayLg),
              SizedBox(height: 4),
              MyText(
                'Real-time overview of all marketing operations',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        Obx(() => _buildPeriodSelector(c.selectedPeriod.value, c.setPeriod)),
      ],
    );
  }

  Widget _buildPeriodSelector(String selected, void Function(String) onChanged) {
    final periods = ['today', 'week', 'month', 'quarter'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: periods.map((p) {
          final isActive = p == selected;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () => onChanged(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  p[0].toUpperCase() + p.substring(1),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKpiCards(MarketingModuleController c) {
    return Obx(() {
      final data = c.currentPeriodData;
      final items = [
        _KpiData('Leads Generated', data['leads'] ?? '—', Icons.person_add, AppColors.primary),
        _KpiData('Conversion Rate', data['conv'] ?? '—', Icons.trending_up, AppColors.success),
        _KpiData('Pipeline Value', data['pipe'] ?? '—', Icons.account_balance_wallet, AppColors.info),
        _KpiData('Content Published', data['content'] ?? '—', Icons.article, const Color(0xFF8B5CF6)),
      ];
      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return Row(
              children: items.map((it) => Expanded(child: _buildKpiCard(it))).toList(),
            );
          }
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: items.map((it) => SizedBox(
              width: (constraints.maxWidth - 12) / 2,
              child: _buildKpiCard(it),
            )).toList(),
          );
        },
      );
    });
  }

  Widget _buildKpiCard(_KpiData data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(data.icon, size: 20, color: data.color),
              ),
              const Spacer(),
              const Icon(Icons.more_vert, size: 18, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            data.value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.label,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelinePreview(MarketingModuleController c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText('Pipeline Preview', style: AppTextStyles.h2),
          const SizedBox(height: 16),
          Obx(() {
            final counts = c.pipelineCounts;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: LeadStage.values.map((stage) {
                  final count = counts[stage] ?? 0;
                  return _buildPipelineStage(stage, count);
                }).toList(),
              ),
            );
          }),
          const SizedBox(height: 20),
          const Divider(color: AppColors.borderSubtle),
          const SizedBox(height: 12),
          Obx(() {
            final divCounts = c.divisionLeadCounts;
            return Wrap(
              spacing: 12,
              runSpacing: 8,
              children: MarketingDivision.values.map((div) {
                final count = divCounts[div] ?? 0;
                return _buildDivisionChip(div, count);
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPipelineStage(LeadStage stage, int count) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: stage.pillColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: stage.pillColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stage.label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: stage.pillColor),
          ),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: stage.pillColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count == 1 ? 'lead' : 'leads',
            style: TextStyle(fontSize: 11, color: stage.pillColor.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildDivisionChip(MarketingDivision div, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: div.pillColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: div.pillColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '${div.label} ($count)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: div.pillTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsPanel(MarketingModuleController c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const MyText('Alerts & Notifications', style: AppTextStyles.h2),
              const Spacer(),
              Obx(() {
                final unread = c.unreadNotifications;
                if (unread == 0) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$unread new',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => Column(
            children: List.generate(c.notifications.length, (i) {
              final n = c.notifications[i];
              return _buildNotificationTile(n, () => c.markNotificationRead(i));
            }),
          )),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(MarketingNotification n, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: n.isRead ? Colors.transparent : AppColors.primarySubtle.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: n.iconBg, borderRadius: BorderRadius.circular(8)),
              child: Icon(_iconFromString(n.icon), size: 16, color: n.iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.text,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: n.isRead ? FontWeight.normal : FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(n.time, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamPerformance(MarketingModuleController c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText('Team Performance', style: AppTextStyles.h2),
          const SizedBox(height: 16),
          Obx(() {
            final topPerformers = c.team.where((t) => t.kpiPercentage > 0).toList()
              ..sort((a, b) => b.kpiPercentage.compareTo(a.kpiPercentage));
            final display = topPerformers.take(6).toList();
            return Column(
              children: display.map((member) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: member.backgroundColor,
                        child: Text(
                          member.initials,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              member.role,
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${member.kpiPercentage}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: member.kpiColor,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 60,
                            child: LinearProgressIndicator(
                              value: member.kpiPercentage / 100,
                              minHeight: 4,
                              backgroundColor: AppColors.borderSubtle,
                              valueColor: AlwaysStoppedAnimation(member.kpiColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOkrProgress(MarketingModuleController c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText('OKR Progress', style: AppTextStyles.h2),
          const SizedBox(height: 16),
          Obx(() => Column(
            children: c.okrs.map((okr) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      okr.objective,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ...okr.keyResults.map((kr) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    kr.label,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: kr.percentage / 100,
                                    minHeight: 6,
                                    backgroundColor: AppColors.borderSubtle,
                                    valueColor: AlwaysStoppedAnimation(kr.color),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${kr.percentage}%',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: kr.color,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }

  IconData _iconFromString(String icon) {
    switch (icon) {
      case 'ti-alert-triangle': return Icons.warning_amber_rounded;
      case 'ti-photo': return Icons.photo;
      case 'ti-check': return Icons.check_circle;
      case 'ti-users': return Icons.people;
      case 'ti-headset': return Icons.headset_mic;
      default: return Icons.notifications;
    }
  }
}

class _KpiData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  _KpiData(this.label, this.value, this.icon, this.color);
}
