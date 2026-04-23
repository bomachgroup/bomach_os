import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/operations/each_project.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
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
  final OperationsDashboardController controller =
      Get.put(OperationsDashboardController());

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
        title: 'Operations Dashboard',
        subtitle: 'Overview & Project Management',
        trailing: OutlinedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const AddProjectDialog(),
            ).then((_) => controller.fetchDashboardData(context));
          },
          icon: const Icon(Iconsax.add_circle, size: 18),
          label: const Text('Add Project'),
        ),
      ),
      children: [
        // --- Stats Section ---
        Obx(() {
          if (controller.isLoadingStats.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final stats = controller.stats.value;
          if (stats == null) return const SizedBox();

          return _buildStatsGrid(stats);
        }),

        const SizedBox(height: 32),

        // --- Recent Projects Section ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const MyText('Recent Projects', style: AppText.h3),
            SizedBox(
              width: 250,
              child: MyTextFormField(
                hintText: 'Search Projects...',
                leading: Icon(Iconsax.search_normal,
                    color: AppColors.textMuted.withValues(alpha: 0.5)),
                onChanged: (val) =>
                    controller.fetchProjects(context, search: val),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Obx(() {
          if (controller.isLoadingProjects.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.projects.isEmpty) {
            return const AppCard(
              padding: EdgeInsets.all(48),
              child: Center(
                child: Column(
                  children: [
                    Icon(Iconsax.folder_open,
                        size: 48, color: AppColors.textMuted),
                    SizedBox(height: 16),
                    Text("No projects found", style: AppText.bodyLg),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.projects.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final project = controller.projects[index];
              return _buildProjectItem(context, project);
            },
          );
        }),
      ],
    );
  }

  Widget _buildStatsGrid(DashboardStats stats) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isMobile = constraints.maxWidth < 650;
      final int crossAxisCount = isMobile ? 1 : 3;

      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: isMobile ? 2.5 : 2.2,
        children: [
          _buildStatCard("Active Projects", stats.activeProjects.toString(),
              AppColors.primary, Iconsax.folder_2),
          _buildStatCard("Total Budget", "₦${stats.totalBudget}",
              AppColors.success, Iconsax.money_2),
          _buildStatCard("Budget Util.", "${stats.budgetUtilization}%",
              AppColors.warning, Iconsax.chart_2),
          _buildStatCard("Worksites", stats.totalWorksites.toString(),
              const Color(0xFF8B5CF6), Iconsax.building_4),
          _buildStatCard("Contracts", stats.totalContracts.toString(),
              const Color(0xFF14B8A6), Iconsax.document_text),
          _buildStatCard("Timelines", stats.totalTimelines.toString(),
              AppColors.danger, Iconsax.timer_1),
        ],
      );
    });
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppText.bodySm.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: AppText.h2.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectItem(BuildContext context, Project project) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EachProjects(project: project)),
        );
      },
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(
                Iconsax.folder_2,
                color: AppColors.primary,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: AppText.h4.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        project.shortCode,
                        style: AppText.overline.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "•",
                      style:
                          AppText.bodySm.copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      project.status,
                      style: AppText.bodySm.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₦${project.budget}",
                style: AppText.h4.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Iconsax.calendar_1,
                    size: 14,
                    color: AppColors.textMuted.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    project.deadline,
                    style: AppText.bodySm.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => controller.deleteProject(context, project.id),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Iconsax.trash,
                  color: AppColors.danger.withValues(alpha: 0.7),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
