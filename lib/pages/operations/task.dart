import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/loading_skeleton.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/pages/operations/models/models.dart';
import 'package:bms_front_end/src/constants/colors.dart';
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
    return PageScaffold(
      header: PageHeader(
        title: 'Tasks',
        subtitle: 'Management of operational tasks and deadlines',
        trailing: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 250,
              child: MyTextFormField(
                hintText: 'Search tasks...',
                leading: const Icon(Iconsax.search_normal, size: 18, color: AppColors.textMuted),
                onChanged: (val) => controller.fetchTasks(context,
                    projectId: widget.projectId, search: val),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddTaskDialog(),
                );
              },
              icon: const Icon(Iconsax.add_circle, size: 18),
              label: const Text('Add Task'),
            ),
          ],
        ),
      ),
      children: [
        AppCard(
          padding: const EdgeInsets.all(0),
          child: Obx(() {
            if (controller.isLoading.value) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: LoadingSkeleton.listRows(count: 8),
              );
            }

            if (controller.tasks.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(48),
                child: EmptyState.empty(
                  title: 'No tasks found',
                  subtitle: 'Create a new task to track progress.',
                ),
              );
            }

            return Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.resolveWith(
                        (states) => AppColors.surfaceMuted.withValues(alpha: 0.5)),
                    headingTextStyle: AppText.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    dataTextStyle: AppText.bodyMd.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    dataRowMinHeight: 64,
                    dataRowMaxHeight: 64,
                    columnSpacing: 24,
                    horizontalMargin: 20,
                    dividerThickness: 1.0,
                    columns: _createColumns(),
                    rows: _createRows(context, controller.tasks),
                    showBottomBorder: false,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  List<DataColumn> _createColumns() {
    return const [
      DataColumn(label: Text("ID")),
      DataColumn(label: Text("Task Name")),
      DataColumn(label: Text("Priority")),
      DataColumn(label: Text("Due Date")),
      DataColumn(label: Text("Hours")),
      DataColumn(label: Text("Status")),
      DataColumn(label: Text("Action")),
    ];
  }

  List<DataRow> _createRows(BuildContext context, List<Task> tasks) {
    return tasks.map((task) {
      return DataRow(cells: <DataCell>[
        DataCell(Text("#${task.id}", style: AppText.label)),
        DataCell(
          onTap: () {
            context.push(RouteConstants.taskDetail, extra: task);
          },
          SizedBox(
              width: 250, child: Text(task.name, style: AppText.bodyMd.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ),
        DataCell(Text(task.priority)),
        DataCell(Text(task.dueDate)),
        DataCell(Text(task.estimatedHours.toString())),
        DataCell(StatusChip(
          label: task.status,
          tone: _getStatusTone(task.status),
        )),
        DataCell(
          PopupMenuButton(
            icon: const Icon(Iconsax.more, size: 18),
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
                child: const Text("Delete"),
                onTap: () =>
                    controller.deleteTask(context, task.id, widget.projectId),
              ),
            ],
          ),
        ),
      ]);
    }).toList();
  }

  StatusTone _getStatusTone(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return StatusTone.success;
      case 'in progress':
        return StatusTone.primary;
      case 'pending':
        return StatusTone.warning;
      default:
        return StatusTone.neutral;
    }
  }
}
