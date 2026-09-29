import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/components/section/responsive_stat_row.dart';
import 'package:bomach_os/pages/operations/each_project.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controllers/dashboard_controller.dart';
import 'models/models.dart';
import 'widget/add_project_dialog.dart';

class OperationsPage extends StatefulWidget {
  const OperationsPage({super.key});

  @override
  State<OperationsPage> createState() => _OperationsPageState();
}

class _OperationsPageState extends State<OperationsPage> {
  final OperationsDashboardController controller = Get.put(
    OperationsDashboardController(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDashboardData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      header: PageHeader(
        title: 'Operations',
        subtitle: 'Overview of projects, budgets, worksites, and timelines',
        trailing: MyElevatedButton(
          height: 48,
          icon: const Icon(
            Iconsax.add_circle,
            color: AppColors.textOnPrimary,
            size: 18,
          ),
          child: 'Add Project',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const AddProjectDialog(),
            ).then((_) => controller.fetchDashboardData(context));
          },
        ),
      ),
      children: [
        // --- Stats Section ---
        Obx(() {
          if (controller.isLoadingStats.value &&
              controller.stats.value == null) {
            return LoadingSkeleton.statRow(count: 4);
          }
          final stats = controller.stats.value;
          if (stats == null) {
            return const _StatPlaceholder();
          }
          return _SummaryGridSection(stats: stats);
        }),

        // --- Recent Projects Section ---
        _RecentProjectsSection(controller: controller),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SUMMARY / STATS
// ═══════════════════════════════════════════════════════════════════

class _StatPlaceholder extends StatelessWidget {
  const _StatPlaceholder();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const Icon(
            Iconsax.info_circle,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Unable to load operations stats right now.',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryGridSection extends StatelessWidget {
  final DashboardStats stats;
  const _SummaryGridSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return ResponsiveStatRow(
      cards: [
        _StatCard(
          title: 'Active Projects',
          count: stats.activeProjects.toString(),
          icon: Iconsax.folder_2,
          accent: AppColors.primary,
        ),
        _StatCard(
          title: 'Total Budget',
          count: 'N${stats.totalBudget}',
          icon: Iconsax.money_2,
          accent: AppColors.success,
        ),
        _StatCard(
          title: 'Budget Utilisation',
          count: '${stats.budgetUtilization}%',
          icon: Iconsax.chart_2,
          accent: AppColors.warning,
        ),
        _StatCard(
          title: 'Worksites',
          count: stats.totalWorksites.toString(),
          icon: Iconsax.building_4,
          accent: const Color(0xFF8B5CF6),
        ),
        _StatCard(
          title: 'Contracts',
          count: stats.totalContracts.toString(),
          icon: Iconsax.document_text,
          accent: const Color(0xFF14B8A6),
        ),
        _StatCard(
          title: 'Timelines',
          count: stats.totalTimelines.toString(),
          icon: Iconsax.timer_1,
          accent: AppColors.danger,
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

// ═══════════════════════════════════════════════════════════════════
//  RECENT PROJECTS SECTION
// ═══════════════════════════════════════════════════════════════════

class _RecentProjectsSection extends StatelessWidget {
  final OperationsDashboardController controller;
  const _RecentProjectsSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: LayoutBuilder(
              builder: (context, constraints) {
              final compact = constraints.maxWidth < 640;
              final titleBlock = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recent Projects', style: AppTextStyles.h3),
                  const SizedBox(height: 4),
                  Text(
                    'Latest projects across the organisation',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  ),
                ],
              );

              final search = SizedBox(
                width: compact ? double.infinity : 260,
                child: MyTextFormField(
                  hintText: 'Search projects...',
                  height: 44,
                    leading: const Icon(
                      Iconsax.search_normal,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  onChanged: (val) =>
                      controller.fetchProjects(context, search: val),
                ),
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [titleBlock, const SizedBox(height: 12), search],
                );
              }

              return Row(
                children: [
                  Expanded(child: titleBlock),
                  const SizedBox(width: 16),
                  search,
                ],
              );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Obx(() {
            if (controller.isLoadingProjects.value &&
                controller.projects.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: LoadingSkeleton.listRows(count: 5),
              );
            }

            if (controller.projects.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: EmptyState(
                  icon: Iconsax.folder_open,
                  title: 'No projects found',
                  subtitle:
                      'Create a new project to start tracking operations.',
                ),
              );
            }

            final projects = controller.projects;
            return Column(
              children: [
                for (int i = 0; i < projects.length; i++) ...[
                  _ProjectTile(
                    project: projects[i],
                    onDelete: () =>
                        controller.deleteProject(context, projects[i].id),
                  ),
                  if (i != projects.length - 1)
                    const Divider(height: 1, color: AppColors.borderSubtle),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  final Project project;
  final VoidCallback onDelete;

  const _ProjectTile({required this.project, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EachProjects(project: project)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: AppRadii.brMd,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Iconsax.folder_2,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        project.shortCode,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      if (project.status.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        StatusChip(
                          label: project.status,
                          tone: projectStatusTone(project.status),
                          dense: true,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${project.budgetCurrency} ${project.formattedBudget}',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Iconsax.calendar_1,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      project.deadline.isEmpty ? '—' : project.deadline,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Iconsax.trash,
                size: 18,
                color: AppColors.danger,
              ),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  STATUS TONE MAPPING
// ═══════════════════════════════════════════════════════════════════

StatusTone projectStatusTone(String status) {
  switch (status.trim().toLowerCase()) {
    case 'planning':
      return StatusTone.neutral;
    case 'active':
    case 'in_progress':
    case 'in progress':
    case 'ongoing':
      return StatusTone.primary;
    case 'on_hold':
    case 'on hold':
      return StatusTone.warning;
    case 'completed':
      return StatusTone.success;
    case 'cancelled':
    case 'canceled':
    case 'overdue':
      return StatusTone.danger;
    default:
      return StatusTone.neutral;
  }
}

StatusTone priorityTone(String priority) {
  switch (priority.trim().toLowerCase()) {
    case 'high':
    case 'critical':
      return StatusTone.danger;
    case 'medium':
      return StatusTone.warning;
    case 'low':
      return StatusTone.neutral;
    default:
      return StatusTone.neutral;
  }
}
