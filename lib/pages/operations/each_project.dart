import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/operations/models/models.dart';
import 'package:bms_front_end/pages/operations/operations.dart'
    show projectStatusTone;
import 'package:bms_front_end/pages/operations/widget/add_project_member_dialog.dart';
import 'package:bms_front_end/pages/operations/widget/add_task_dialog.dart';
import 'package:bms_front_end/pages/operations/widget/add_worksite_dialog.dart';
import 'package:bms_front_end/pages/operations/widget/project_associate.dart';
import 'package:bms_front_end/pages/operations/widget/project_files.dart';
import 'package:bms_front_end/pages/operations/widget/project_members.dart';
import 'package:bms_front_end/pages/operations/widget/project_milestone.dart';
import 'package:bms_front_end/pages/operations/widget/project_overview.dart';
import 'package:bms_front_end/pages/operations/widget/project_task_table.dart';
import 'package:bms_front_end/pages/operations/widget/project_work_sites.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/shadows.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'widget/project_meetings.dart';

const List<String> _projectTabs = [
  'Overview',
  'Members',
  'Work site',
  'Files',
  'Milestone',
  'Tasks',
  'Associates',
  'Meetings',
];

class EachProjects extends StatefulWidget {
  final Project? project;
  const EachProjects({super.key, this.project});

  @override
  State<EachProjects> createState() => _EachProjectsState();
}

class _EachProjectsState extends State<EachProjects> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final Project? project = widget.project ??
        ModalRoute.of(context)?.settings.arguments as Project?;

    if (project == null) {
      return const PageScaffold(
        children: [
          Center(
            child: MyText('Project not found', style: AppTextStyles.h2),
          ),
        ],
      );
    }

    return PageScaffold(
      header: PageHeader(
        title: project.name,
        subtitle: 'Project detail · ${project.shortCode}',
        trailing: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const SizedBox(
              width: 220,
              child: MyTextFormField(
                hintText: 'Search...',
                height: 48,
                leading: Icon(Iconsax.search_normal,
                    size: 18, color: AppColors.textMuted),
              ),
            ),
            if ([1, 2, 4, 5].contains(_currentTab))
              MyElevatedButton(
                height: 48,
                icon: const Icon(Iconsax.add_circle,
                    color: AppColors.textOnPrimary, size: 18),
                child: _getButtonTitle(_currentTab),
                onTap: () => _handleButtonTap(context, _currentTab, project),
              ),
          ],
        ),
      ),
      children: [
        // Summary header strip
        _buildSummaryCard(project),

        // Tab Bar
        _buildTabBar(),

        // Page Content
        _buildPageContent(project),
      ],
    );
  }

  Widget _buildSummaryCard(Project project) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        final title = Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: AppRadii.brMd,
              ),
              alignment: Alignment.center,
              child: const Icon(Iconsax.folder_2,
                  size: 24, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: AppTextStyles.h3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    project.summary.isEmpty
                        ? project.shortCode
                        : project.summary,
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        );

        final chips = Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (project.status.isNotEmpty)
              StatusChip(
                label: project.status,
                tone: projectStatusTone(project.status),
              ),
            if (project.priority.isNotEmpty)
              StatusChip(
                label: 'Priority: ${project.priority}',
                tone: _priorityTone(project.priority),
                icon: Iconsax.flash_1,
              ),
            if (project.category.isNotEmpty)
              StatusChip(
                label: project.category,
                tone: StatusTone.neutral,
                icon: Iconsax.tag,
              ),
          ],
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 16),
              chips,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: title),
            const SizedBox(width: 16),
            chips,
          ],
        );
      }),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_projectTabs.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                  right: index == _projectTabs.length - 1 ? 0 : 6),
              child: _buildTabButton(_projectTabs[index], index),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isActive = _currentTab == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadii.brMd,
        onTap: () => setState(() => _currentTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.surface : Colors.transparent,
            borderRadius: AppRadii.brMd,
            boxShadow: isActive ? AppShadows.sm : const <BoxShadow>[],
          ),
          child: Text(
            title,
            style: AppTextStyles.bodyMd.copyWith(
              color: isActive
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageContent(Project project) {
    Widget content;
    switch (_currentTab) {
      case 0:
        content = ProjectOverview(project: project);
        break;
      case 1:
        content = ProjectMembers(projectId: project.id);
        break;
      case 2:
        content = ProjectWorkSite(projectId: project.id);
        break;
      case 3:
        content = const ProjectFiles();
        break;
      case 4:
        content = ProjectMilestone(projectId: project.id);
        break;
      case 5:
        content = ProjectTaskTable(projectId: project.id);
        break;
      case 6:
        content = const ProjectAssociate();
        break;
      case 7:
        content = const ProjectMeetings();
        break;
      default:
        content = const SizedBox();
    }

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: content,
    );
  }

  String _getButtonTitle(int index) {
    switch (index) {
      case 1:
        return 'Add Member';
      case 2:
        return 'Add Worksite';
      case 4:
        return 'Create Milestone';
      case 5:
        return 'Add Task';
      default:
        return 'Add';
    }
  }

  void _handleButtonTap(BuildContext context, int index, Project project) {
    switch (index) {
      case 1:
        showDialog(
            context: context,
            builder: (_) => const AddProjectMemberDialog());
        break;
      case 2:
        showDialog(
            context: context,
            builder: (_) => AddWorksiteDialog(projectId: project.id));
        break;
      case 4:
        showDialog(
            context: context,
            builder: (_) => AddMileStoneDialog(projectId: project.id));
        break;
      case 5:
        showDialog(
            context: context,
            builder: (_) => AddTaskDialog(projectId: project.id));
        break;
    }
  }

  StatusTone _priorityTone(String priority) {
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
}
