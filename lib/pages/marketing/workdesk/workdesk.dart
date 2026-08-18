import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/pages/marketing/controllers/marketing_module_controller.dart';
import 'package:bomach_os/pages/marketing/models/marketing_misc.dart';
import 'package:bomach_os/pages/marketing/widget/close_of_day_card.dart';
import 'package:bomach_os/pages/marketing/widget/obligation_list.dart';
import 'package:bomach_os/pages/marketing/widget/ops_hero_banner.dart';
import 'package:bomach_os/pages/marketing/widget/performance_ring.dart';
import 'package:bomach_os/pages/marketing/widget/routine_block.dart';
import 'package:bomach_os/pages/marketing/widget/unit_grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarketingWorkdesk extends StatelessWidget {
  const MarketingWorkdesk({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MarketingModuleController>();

    return Obx(() {
      final routine = c.currentRoleRoutine;
      final key = c.todayKey;
      final dayChecks = c.dailyChecks[key] ?? {};
      final miniCrm = '${(c.workdeskScore * 0.9 + 10).round().clamp(0, 100)}%';
      final miniTarget =
          '${(c.workdeskScore * 0.75 + 18).round().clamp(0, 100)}%';
      final miniReport = c.isDailyReportSubmitted ? '100%' : '40%';

      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          _buildRoleSelector(c),
          const SizedBox(height: 16),
          OpsHeroBanner(
            eyebrow: 'Bomach OS · Role Inheritance · Daily Execution',
            title: 'Welcome back, ${c.workdeskWelcomeName}!',
            description:
                'Your dashboard is generated from your role template, permissions, daily routine, targets, KPIs, approvals and reporting obligations.',
            scoreBox: OpsScoreBox(
              score: '${c.workdeskScore}%',
              rank: c.workdeskRank,
              tasksDone: '${c.workdeskDoneTasks}',
              tasksTotal: '${c.workdeskTotalTasks}',
              reportStatus: c.isDailyReportSubmitted ? 'Submitted' : 'Pending',
            ),
          ),
          UnitGrid(units: c.fiveUnits),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildRoutineSection(c, routine, dayChecks),
                    ),
                    const SizedBox(width: 14),
                    SizedBox(
                        width: 300,
                        child: _buildRightPanel(
                            c, miniCrm, miniTarget, miniReport)),
                  ],
                );
              }
              return Column(
                children: [
                  _buildRoutineSection(c, routine, dayChecks),
                  const SizedBox(height: 14),
                  _buildRightPanel(c, miniCrm, miniTarget, miniReport),
                ],
              );
            },
          ),
        ],
      ),
    );
  });
  }

  Widget _buildRoleSelector(MarketingModuleController c) {
    final roles = MarketingModuleController.demoRoles;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EE)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.swap_horiz, size: 18, color: Color(0xFF1F3D7A)),
          const SizedBox(width: 8),
          const Text(
            'Switch role:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF535870),
            ),
          ),
          const SizedBox(width: 10),
          DropdownButton<String>(
            value: c.selectedRole.value,
            underline: const SizedBox(),
            isDense: true,
            items: roles.entries.map((e) {
              return DropdownMenuItem<String>(
                value: e.key,
                child: Text(
                  e.value['n']!,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w500),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) c.setRole(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineSection(
    MarketingModuleController c,
    RoleRoutine routine,
    Map<String, bool> dayChecks,
  ) {
    return Column(
      children: [
        RoutineBlock(
          title: 'Morning routine',
          icon: Icons.wb_sunny_outlined,
          items: routine.morning,
          checks: dayChecks,
          groupPrefix: '0',
          onToggle: (id) => c.toggleRoutine(id),
        ),
        RoutineBlock(
          title: 'Afternoon routine',
          icon: Icons.wb_cloudy_outlined,
          items: routine.afternoon,
          checks: dayChecks,
          groupPrefix: '1',
          onToggle: (id) => c.toggleRoutine(id),
        ),
        RoutineBlock(
          title: 'Before close of day',
          icon: Icons.nightlight_outlined,
          items: routine.close,
          checks: dayChecks,
          groupPrefix: '2',
          onToggle: (id) => c.toggleRoutine(id),
        ),
      ],
    );
  }

  Widget _buildRightPanel(
    MarketingModuleController c,
    String miniCrm,
    String miniTarget,
    String miniReport,
  ) {
    return Column(
      children: [
        PerformanceRing(
          percentage: c.workdeskScore,
          crmDiscipline: miniCrm,
          targetProgress: miniTarget,
          reports: miniReport,
          punctuality: '89%',
        ),
        ObligationList(obligations: c.currentRoleObligations),
        CloseOfDayCard(
          text: c.currentDailyReport.value,
          isSubmitted: c.isDailyReportSubmitted,
          onChanged: (v) => c.currentDailyReport.value = v,
          onSubmit: () {
            if (c.currentDailyReport.value.trim().isEmpty) {
              AppToast.error(Get.context!, 'Enter your close-of-day summary');
              return;
            }
            c.submitDailyReport();
            AppToast.success(Get.context!, 'Daily report submitted');
          },
        ),
      ],
    );
  }
}
