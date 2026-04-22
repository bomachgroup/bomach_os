import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_filter_bar.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/input/my_checkbox.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/loading_skeleton.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/operations/widget/add_project_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
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
  final ScrollController _scrollController = ScrollController();
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
    final tableHeight = MediaQuery.of(context).size.height - 200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Projects',
          subtitle: 'Manage your projects',
        ),
        const SizedBox(height: 16),
        Wrap(
          runSpacing: kDefaultSpace,
          spacing: kDefaultSpace,
          children: [
            MyElevatedButton(
              icon: const Icon(Iconsax.add_circle,
                  color: AppColors.textOnPrimary, size: 18),
              child: 'Add New Project',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddProjectDialog(),
                ).then((_) => controller.fetchProjects(context));
              },
            ),
            SizedBox(
              width: 220,
              child: MyTextFormField(
                hintText: 'Search...',
                leading: const Icon(Iconsax.search_normal_1,
                    color: AppColors.textMuted, size: 18),
                onChanged: (val) =>
                    controller.fetchProjects(context, search: val),
              ),
            ),
            const SortFilterBar(),
          ],
        ),
        kSizedBox,
        kSizedBoxSM,
        SizedBox(
          height: tableHeight > 400 ? tableHeight : 400,
          child: AppCard(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              if (controller.isLoading.value) {
                return LoadingSkeleton.listRows(count: 6);
              }

              if (controller.projects.isEmpty) {
                return EmptyState.empty(
                  title: 'No projects found',
                  subtitle: 'Create a new project to get started.',
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              minWidth:
                                  MediaQuery.of(context).size.width - 100),
                          child: SingleChildScrollView(
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.resolveWith(
                                  (states) => AppColors.surfaceMuted),
                              headingTextStyle: AppText.label.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              dataTextStyle: AppText.bodyMd.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              dataRowMinHeight: 68,
                              dataRowMaxHeight: 68,
                              columnSpacing: 24,
                              horizontalMargin: 12,
                              dividerThickness: 1.0,
                              columns: _createColumns(),
                              rows: _createRows(context, controller.projects),
                              showBottomBorder: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        )
      ],
    );
  }

  List<DataColumn> _createColumns() {
    return [
      DataColumn(label: MyCheckbox(isChecked: false, onChanged: (v) {})),
      const DataColumn(label: Text('PJ code')),
      const DataColumn(label: Text('Project Name')),
      const DataColumn(label: Text('Budget')),
      const DataColumn(label: Text('Start date')),
      const DataColumn(label: Text('Deadline')),
      const DataColumn(label: Text('Status')),
      const DataColumn(label: Text('Action')),
    ];
  }

  List<DataRow> _createRows(BuildContext context, List<Project> projects) {
    return projects.map((project) {
      return DataRow(cells: <DataCell>[
        DataCell(MyCheckbox(isChecked: false, onChanged: (v) {})),
        DataCell(SizedBox(width: 120, child: MyText(project.shortCode))),
        DataCell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => EachProjects(project: project)));
          },
          SizedBox(
            width: 152,
            child: Text(
              project.name,
              style: AppText.bodyMd.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        DataCell(SizedBox(
          width: 100,
          child: Text(
            '₦${project.budget}',
            style: AppText.bodyMd.copyWith(fontWeight: FontWeight.w600),
          ),
        )),
        DataCell(SizedBox(width: 100, child: MyText(project.startDate))),
        DataCell(SizedBox(width: 100, child: MyText(project.deadline))),
        DataCell(
          SizedBox(
            width: 120,
            child: StatusChip.fromStatus(project.status),
          ),
        ),
        DataCell(
          PopupMenuButton(
            icon: const Icon(Iconsax.more, size: 18),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Iconsax.trash,
                        size: 16, color: AppColors.danger),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
                onTap: () => controller.deleteProject(context, project.id),
              )
            ],
          ),
        ),
      ]);
    }).toList();
  }
}
