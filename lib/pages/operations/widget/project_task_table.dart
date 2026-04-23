import 'package:bms_front_end/components/text/my_text.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/pages/operations/controllers/tasks_controler.dart';
import 'package:bms_front_end/pages/operations/widget/add_task_dialog.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/helper/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectTaskTable extends StatefulWidget {
  final int projectId;
  const ProjectTaskTable({super.key, required this.projectId});

  @override
  State<ProjectTaskTable> createState() => _ProjectTaskTableState();
}

class _ProjectTaskTableState extends State<ProjectTaskTable> {
  final ScrollController _scrollController = ScrollController();
  late final TaskController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<TaskController>()
        ? Get.find<TaskController>()
        : Get.put(TaskController());
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator()));
        }

        if (controller.tasks.isEmpty) {
          return const Center(
              child: Padding(
                  padding: EdgeInsets.all(40), child: Text("No tasks found.")));
        }

        return Column(
          children: [
            Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: bodySpace(context)),
                  child: DataTable(
                    dataRowMinHeight: 68,
                    dataRowMaxHeight: 68,
                    columnSpacing: 24,
                    horizontalMargin: 12,
                    columns: _createColumns(),
                    rows: _createRows(context),
                    showBottomBorder: true,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  List<DataColumn> _createColumns() {
    return const [
      DataColumn(
          headingRowAlignment: MainAxisAlignment.start,
          label: MyText("Task ID")),
      DataColumn(label: MyText("Task Name")),
      DataColumn(label: MyText("Due Date")),
      DataColumn(label: MyText("Priority")),
      DataColumn(label: MyText("Status")),
      DataColumn(label: MyText("Action")),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    final tasks = controller.tasks;
    return tasks.map((task) {
      return DataRow(cells: <DataCell>[
        DataCell(MyText("#${task.id}")),
        DataCell(
          MyText(task.name, isSelectable: false, size: 16, weight: 400),
        ),
        DataCell(MyText(task.dueDate.isEmpty ? '-' : task.dueDate)),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color:
                  getRandomColorFromList(task.priority).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6)),
          child: MyText(task.priority.isEmpty ? '-' : task.priority),
        )),
        DataCell(
          Row(
            children: [
              Container(
                height: 10,
                width: 10,
                decoration: ShapeDecoration(
                  color: getRandomColorFromList(task.status),
                  shape: const OvalBorder(),
                ),
              ),
              kSizedBoxWidthTiny,
              MyText(task.status),
            ],
          ),
        ),
        DataCell(PopupMenuButton(
          itemBuilder: (ctx) => [
            PopupMenuItem(
              child: const Text("Edit"),
              onTap: () => showDialog(
                context: context,
                builder: (_) =>
                    AddTaskDialog(task: task, projectId: widget.projectId),
              ),
            ),
            PopupMenuItem(
              child: const Text("Delete"),
              onTap: () =>
                  controller.deleteTask(context, task.id, widget.projectId),
            ),
          ],
          child: const Icon(Iconsax.more),
        )),
      ]);
    }).toList();
  }
}
