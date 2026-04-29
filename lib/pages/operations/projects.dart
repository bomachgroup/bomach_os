import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/paginate/my_paginator.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/pages/operations/operations.dart' show projectStatusTone;
import 'package:bomach_os/pages/operations/widget/add_project_dialog.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controllers/project_controller.dart';
import 'each_project.dart';
import 'models/models.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final ProjectController controller = Get.put(ProjectController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchProjects(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      header: PageHeader(
        title: 'Projects',
        subtitle: 'Overview and management of all projects',
        trailing: MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'Add Project',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const AddProjectDialog(),
            ).then((_) => controller.fetchProjects(context));
          },
        ),
      ),
      children: [
        _buildToolbar(),
        _buildProjectsTable(context),
      ],
    );
  }

  Widget _buildToolbar() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: MyTextFormField(
        hintText: 'Search projects by name or short code',
        height: 48,
        leading: const Icon(Iconsax.search_normal,
            size: 18, color: AppColors.textMuted),
        onChanged: (val) => controller.fetchProjects(context, search: val),
      ),
    );
  }

  Widget _buildProjectsTable(BuildContext context) {
    return Obx(() {
      final loading =
          controller.isLoading.value && controller.projects.isEmpty;
      final isEmpty =
          !controller.isLoading.value && controller.projects.isEmpty;

      return AppCard(
        padding: EdgeInsets.zero,
        elevation: AppCardElevation.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Projects register',
                            style: AppTextStyles.h3),
                        const SizedBox(height: 4),
                        Text(
                          loading
                              ? 'Loading projects...'
                              : '${controller.totalCount.value} projects on record',
                          style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const StatusChip(
                    label: 'Project directory',
                    tone: StatusTone.primary,
                    icon: Iconsax.folder_2,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderSubtle),
            if (loading)
              Padding(
                padding: const EdgeInsets.all(20),
                child: LoadingSkeleton.listRows(count: 6),
              )
            else if (isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: EmptyState(
                  icon: Iconsax.folder_open,
                  title: 'No projects found',
                  subtitle: 'Create a new project to get started.',
                  action: MyElevatedButton(
                    child: 'Add Project',
                    icon: const Icon(Iconsax.add_circle,
                        size: 18, color: AppColors.textOnPrimary),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const AddProjectDialog(),
                      ).then((_) => controller.fetchProjects(context));
                    },
                  ),
                ),
              )
            else
              _buildTableBody(context),
            const Divider(height: 1, color: AppColors.borderSubtle),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Obx(() {
                final limit = controller.currentLimit.value;
                final offset = controller.currentOffset.value;
                final currentPage =
                    limit > 0 ? (offset ~/ limit) + 1 : 1;
                return PaginatorFooter(
                  totalItems: controller.totalCount.value,
                  limit: limit,
                  currentPage: currentPage,
                  onPageChanged: (newPage) {
                    controller.currentOffset.value = (newPage - 1) * limit;
                    controller.fetchProjects(context);
                  },
                  onLimitChanged: (newLimit) {
                    controller.currentLimit.value = newLimit;
                    controller.currentOffset.value = 0;
                    controller.fetchProjects(context);
                  },
                );
              }),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTableBody(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: AppColors.surfaceMuted,
          child: Row(
            children: [
              _headerCell('PJ Code', flex: 2),
              _headerCell('Project Name', flex: 3),
              _headerCell('Budget', flex: 2),
              _headerCell('Start Date', flex: 2),
              _headerCell('Deadline', flex: 2),
              _headerCell('Status', flex: 2),
              _headerCell('', width: 48),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderSubtle),
        ...controller.projects.map((p) => _buildProjectRow(context, p)),
      ],
    );
  }

  Widget _headerCell(String label, {double? width, int? flex}) {
    final content = Text(
      label,
      style: AppTextStyles.bodySm.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
    if (width != null) return SizedBox(width: width, child: content);
    return Expanded(flex: flex ?? 1, child: content);
  }

  Widget _buildProjectRow(BuildContext context, Project project) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => EachProjects(project: project)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.borderSubtle),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                project.shortCode.isEmpty ? '—' : project.shortCode,
                style: AppTextStyles.bodyMd
                    .copyWith(color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                project.name,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'N${project.budget.toStringAsFixed(2)}',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                project.startDate.isEmpty ? '—' : project.startDate,
                style: AppTextStyles.bodyMd
                    .copyWith(color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                project.deadline.isEmpty ? '—' : project.deadline,
                style: AppTextStyles.bodyMd
                    .copyWith(color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: StatusChip(
                  label: project.status.isEmpty ? 'Unknown' : project.status,
                  tone: projectStatusTone(project.status),
                ),
              ),
            ),
            SizedBox(
              width: 48,
              child: PopupMenuButton<String>(
                icon: const Icon(Iconsax.more,
                    size: 18, color: AppColors.textSecondary),
                shape:
                    const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
                onSelected: (value) async {
                  switch (value) {
                    case 'view':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EachProjects(project: project),
                        ),
                      );
                      break;
                    case 'delete':
                      final confirmed = await DialogScaffold.show<bool>(
                        context,
                        title: 'Delete Project',
                        size: DialogSize.sm,
                        body: Text(
                          'Are you sure you want to delete "${project.name}"? This action cannot be undone.',
                          style: AppTextStyles.bodyMd,
                        ),
                        actions: [
                          MyOutlinedButton(
                            child: 'Cancel',
                            height: 44,
                            onTap: () => Navigator.pop(context, false),
                            textColor: AppColors.textSecondary,
                            borderColor: AppColors.borderStrong,
                          ),
                          MyElevatedButton(
                            width: 120,
                            height: 44,
                            bgColor: AppColors.danger,
                            child: 'Delete',
                            onTap: () => Navigator.pop(context, true),
                          ),
                        ],
                      );
                      if (confirmed == true && context.mounted) {
                        controller.deleteProject(context, project.id);
                      }
                      break;
                  }
                },
                itemBuilder: (_) => [
                  _menuItem(
                    value: 'view',
                    icon: Iconsax.eye,
                    label: 'View Details',
                  ),
                  _menuItem(
                    value: 'delete',
                    icon: Iconsax.trash,
                    label: 'Delete',
                    destructive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem({
    required String value,
    required IconData icon,
    required String label,
    bool destructive = false,
  }) {
    final color = destructive ? AppColors.danger : AppColors.textSecondary;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodyMd.copyWith(
              color: destructive ? AppColors.danger : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
