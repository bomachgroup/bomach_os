import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_filter_bar.dart';
import 'package:bms_front_end/components/input/my_checkbox.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/operations/widget/add_project_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        const MyText('Projects', style: AppText.black_500_32),
        const MyText('Manage your projects', style: AppText.black_400_14),
        const SizedBox(height: 12),
        Wrap(
          runSpacing: kDefaultSpace,
          spacing: kDefaultSpace,
          children: [
            MyElevatedButton(
              icon: const Icon(Icons.add_circle_outline_rounded,
                  color: AppColors.white),
              child: 'Add New Project',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddProjectDialog(),
                ).then((_) => controller.fetchProjects(context));
              },
            ),
            SizedBox(
              width: 180,
              child: MyTextFormField(
                hintText: 'Search...',
                leading: Icon(Icons.search,
                    color: AppColors.grey1.withValues(alpha: 0.5)),
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
                border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
                borderRadius: BorderRadius.circular(16)),
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.projects.isEmpty) {
                return const Center(
                    child: MyText("No projects found.",
                        style: AppText.black_500_16));
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
                              dataRowMinHeight: 68,
                              dataRowMaxHeight: 68,
                              columnSpacing: 24,
                              horizontalMargin: 12,
                              columns: _createColumns(),
                              rows: _createRows(context, controller.projects),
                              showBottomBorder: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // const PaginatorFooter(),
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
      const DataColumn(label: MyText("PJ code")),
      const DataColumn(label: MyText("Project Name")),
      const DataColumn(label: MyText("Budget")),
      const DataColumn(label: MyText("Start date")),
      const DataColumn(label: MyText("Deadline")),
      const DataColumn(label: MyText("Status")),
      const DataColumn(label: MyText("Action")),
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
              width: 152, child: MyText(project.name, isSelectable: false)),
        ),
        DataCell(SizedBox(width: 100, child: MyText("₦${project.budget}"))),
        DataCell(SizedBox(width: 100, child: MyText(project.startDate))),
        DataCell(SizedBox(width: 100, child: MyText(project.deadline))),
        DataCell(
          SizedBox(
            width: 100,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: _getStatusColor(project.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4)),
              child: Center(
                  child: MyText(
                project.status,
                color: _getStatusColor(project.status),
                weight: 500,
              )),
            ),
          ),
        ),
        DataCell(
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text("Delete"),
                onTap: () => controller.deleteProject(context, project.id),
              )
            ],
          ),
        ),
      ]);
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.green;
      case 'in progress':
        return AppColors.orange;
      case 'pending':
        return AppColors.red;
      default:
        return AppColors.blue;
    }
  }
}
