import 'package:bms_front_end/components/button/in_button.dart';
import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/operations/models/models.dart';
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
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

import 'widget/project_meetings.dart';

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
      return const Center(
        child: MyText('Project not found', style: AppText.black_500_20),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 10,
                runSpacing: 10,
                children: [
                  MyText(project.name, style: AppText.black_500_32),
                  Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    children: [
                      SizedBox(
                        width: 150,
                        child: MyTextFormField(
                          hintText: 'Search...',
                          leading: Icon(
                            Icons.search,
                            color: AppColors.grey1.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      if ([1, 2, 4, 5].contains(_currentTab))
                        MyElevatedButton(
                          icon: const Icon(
                            Icons.add_circle_outline_rounded,
                            color: AppColors.white,
                          ),
                          child: _getButtonTitle(_currentTab),
                          onTap: () =>
                              _handleButtonTap(context, _currentTab, project),
                        )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        kSizedBoxSM,
        Row(
          children: [
            const MyText('Projects', style: AppText.black_400_14),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_outlined, size: 12),
            const SizedBox(width: 8),
            MyText(project.shortCode, style: AppText.black_400_14),
          ],
        ),
        const SizedBox(height: 21),
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildTabButton("Overview", 0),
              _buildTabButton("Members", 1),
              _buildTabButton("Work site", 2),
              _buildTabButton("Files", 3),
              _buildTabButton("Milestone", 4),
              _buildTabButton("Tasks", 5),
              _buildTabButton("Associates", 6),
              _buildTabButton("Meetings", 7),
            ],
          ),
        ),
        const SizedBox(height: 23),
        _buildPageContent(project),
      ],
    );
  }

  Widget _buildTabButton(String title, int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InButton(
        title: title,
        onTap: () => setState(() => _currentTab = index),
        isSelected: _currentTab == index,
      ),
    );
  }

  Widget _buildPageContent(Project project) {
    switch (_currentTab) {
      case 0:
        return ProjectOverview(project: project);
      case 1:
        return ProjectMembers(projectId: project.id);
      case 2:
        return ProjectWorkSite(projectId: project.id);
      case 3:
        return const ProjectFiles();
      case 4:
        return ProjectMilestone(projectId: project.id);
      case 5:
        return ProjectTaskTable(projectId: project.id);
      case 6:
        return const ProjectAssociate();
      case 7:
        return const ProjectMeetings();
      default:
        return const SizedBox();
    }
  }

  String _getButtonTitle(int index) {
    switch (index) {
      case 1:
        return 'Add Project Member';
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
}
