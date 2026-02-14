import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/operations/models/models.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../src/app_routes/app_route_constants.dart';
import 'controllers/tasks_controler.dart';
import 'widget/add_task_dialog.dart';

class TaskPage extends StatefulWidget {
  final int? projectId;
  const TaskPage({super.key, this.projectId});

  @override
  State<TaskPage> createState() => TaskPageState();
}

class TaskPageState extends State<TaskPage> {
  final ScrollController _scrollController = ScrollController();
  final TaskController controller = Get.put(TaskController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTasks(context, projectId: widget.projectId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  const MyText('Tasks', size: 32, weight: 500),
                  Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    children: [
                      SizedBox(
                        width: 200,
                        child: MyTextFormField(
                          hintText: 'Search...',
                          leading: Icon(Icons.search,
                              color: AppColors.grey1.withValues(alpha: 0.5)),
                          onChanged: (val) => controller.fetchTasks(context,
                              projectId: widget.projectId, search: val),
                        ),
                      ),
                      MyElevatedButton(
                        icon: const Icon(Icons.add_circle_outline_rounded,
                            color: AppColors.white),
                        child: "Add Task",
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => const AddTaskDialog(),
                          );
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        kSizedBox,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.tasks.isEmpty) {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(20),
                child: Text("No tasks found."),
              ));
            }

            return Column(
              children: [
                Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width - 100),
                      child: DataTable(
                        dataRowMinHeight: 68,
                        dataRowMaxHeight: 68,
                        columnSpacing: 24,
                        horizontalMargin: 12,
                        columns: _createColumns(),
                        rows: _createRows(context, controller.tasks),
                        showBottomBorder: true,
                      ),
                    ),
                  ),
                ),
                const MyPaginator(),
              ],
            );
          }),
        ),
      ],
    );
  }

  List<DataColumn> _createColumns() {
    return const [
      DataColumn(label: MyText("ID")),
      DataColumn(label: MyText("Task Name")),
      DataColumn(label: MyText("Priority")),
      DataColumn(label: MyText("Due Date")),
      DataColumn(label: MyText("Est. Hours")),
      DataColumn(label: MyText("Status")),
      DataColumn(label: MyText("Action")),
    ];
  }

  List<DataRow> _createRows(BuildContext context, List<Task> tasks) {
    return tasks.map((task) {
      return DataRow(cells: <DataCell>[
        DataCell(MyText("#${task.id}")),
        DataCell(
          onTap: () {
            context.push(RouteConstants.taskDetail, extra: task);
          },
          SizedBox(
              width: 200, child: MyText(task.name, weight: 500, maxLines: 1)),
        ),
        DataCell(MyText(task.priority)),
        DataCell(MyText(task.dueDate)),
        DataCell(MyText(task.estimatedHours.toString())),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: _getStatusColor(task.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4)),
          child: MyText(task.status,
              color: _getStatusColor(task.status), weight: 600),
        )),
        DataCell(
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text("Edit"),
                onTap: () {
                  Future.delayed(Duration.zero, () {
                    showDialog(
                      context: context,
                      builder: (context) => AddTaskDialog(task: task),
                    );
                  });
                },
              ),
              PopupMenuItem(
                child:
                    const Text("Delete", style: TextStyle(color: Colors.red)),
                onTap: () =>
                    controller.deleteTask(context, task.id, widget.projectId),
              ),
            ],
            child: const Icon(Icons.more_vert),
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
        return AppColors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return AppColors.grey1;
    }
  }
}
