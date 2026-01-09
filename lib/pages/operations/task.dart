import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/operations/models/task_approval_models.dart';
import 'package:bms_front_end/pages/operations/widget/assign_task_dialog.dart';
import 'package:bms_front_end/pages/operations/widget/task_approval_dialog.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => TaskPageState();
}

class TaskPageState extends State<TaskPage> {
  final ScrollController _scrollController = ScrollController();
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _initializeSampleTasks();
  }

  void _initializeSampleTasks() {
    _tasks = [
      Task(
        id: '1',
        code: '#1234567',
        title: 'Benji Express user login Interface',
        description:
            'Design and implement user login interface for the Benji Express platform',
        assignedTo: 'John Michael',
        assignedToId: 'emp001',
        projectId: 'proj001',
        startDate: DateTime(2024, 11, 2),
        dueDate: DateTime(2024, 11, 15),
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        estimatedHours: 40,
        attachments: [],
      ),
      Task(
        id: '2',
        code: '#1234568',
        title: 'API Integration',
        description: 'Integrate backend APIs with mobile application',
        assignedTo: 'Sarah Johnson',
        assignedToId: 'emp002',
        projectId: 'proj001',
        startDate: DateTime(2024, 12, 2),
        dueDate: DateTime(2024, 12, 19),
        status: TaskStatus.inProgress,
        priority: TaskPriority.medium,
        estimatedHours: 32,
        attachments: [],
      ),
      Task(
        id: '3',
        code: '#1234569',
        title: 'Database Optimization',
        description: 'Optimize database queries for improved performance',
        assignedTo: 'Nicholas Chidera',
        assignedToId: 'emp003',
        projectId: 'proj001',
        startDate: DateTime(2024, 10, 2),
        dueDate: DateTime(2024, 10, 15),
        status: TaskStatus.completed,
        priority: TaskPriority.low,
        estimatedHours: 16,
        attachments: [],
      ),
    ];
  }

  void _handleTaskAssignment(Map<String, dynamic> taskData) {
    setState(() {
      _tasks.insert(
          0,
          Task(
            id: DateTime.now().toString(),
            code: taskData['code'] ?? '#N/A',
            title: taskData['title'] ?? 'Untitled Task',
            description: taskData['description'] ?? '',
            assignedTo: taskData['assignedTo'] ?? 'Unassigned',
            assignedToId: taskData['assignedToId'] ?? '',
            projectId: taskData['projectId'] ?? '',
            startDate: taskData['startDate'] ?? DateTime.now(),
            dueDate: taskData['dueDate'] ?? DateTime.now(),
            status: TaskStatus.pending,
            priority: _parsePriority(taskData['priority'] ?? 'medium'),
            estimatedHours:
                double.tryParse(taskData['estimatedHours'].toString()) ?? 0,
            attachments: [],
          ));
    });
  }

  void _handleTaskApproval(int index, Task updatedTask) {
    setState(() {
      _tasks[index] = updatedTask;
    });
    _showSuccessMessage('Task approved successfully!');
  }

  void _openApprovalDialog(BuildContext context, int index, Task task) {
    showDialog(
      context: context,
      builder: (context) {
        return TaskApprovalDialog(
          task: task,
          reviewerName: 'Manager Account',
          onApprovalComplete: (updatedTask) {
            _handleTaskApproval(index, updatedTask);
          },
        );
      },
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: MyText(message),
        backgroundColor: AppColors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  TaskPriority _parsePriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
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
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 10,
                runSpacing: 10,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        'Tasks',
                        style: AppText.black_500_32,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      MyText(
                        'Tasks',
                        style: AppText.black_400_14,
                      ),
                    ],
                  ),
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
                      const SortBar(text: "Sort"),
                      Container(
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20)),
                        child: SvgPicture.asset(
                          "assets/svg/notification.svg",
                          colorFilter: const ColorFilter.mode(
                            AppColors.black,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      MyElevatedButton(
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.white,
                        ),
                        child: "Add Task",
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AssignTaskDialog(
                                onAssign: _handleTaskAssignment,
                              );
                            },
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
        kSizedBoxSM,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                trackVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: bodySpace(context),
                    ),
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
              const MyPaginator(),
            ],
          ),
        ),
      ],
    );
  }

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: MyText(
          "Task code",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Task Name",
        ),
      ),
      const DataColumn(
          label: MyText(
        "Assign to",
      )),
      const DataColumn(
        label: MyText(
          "Start date",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Due date",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Status",
        ),
      ),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    return _tasks.asMap().entries.map((entry) {
      final index = entry.key;
      final task = entry.value;
      return DataRow(cells: <DataCell>[
        DataCell(
          MyText(
            task.code,
          ),
        ),
        DataCell(
          onTap: () {
            context.go(RouteConstants.taskDetail);
          },
          MyText(
            task.title,
            size: 16,
            weight: 400,
            isSelectable: false,
          ),
        ),
        DataCell(
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            width: 36,
            height: 36,
            child: CircleAvatar(
              backgroundColor: AppColors.blue.withValues(alpha: 0.1),
              child: MyText(
                task.assignedTo.isNotEmpty
                    ? task.assignedTo[0].toUpperCase()
                    : '?',
                weight: 600,
                color: AppColors.blue,
              ),
            ),
          ),
        ),
        DataCell(
          MyText(
            _formatDate(task.startDate),
          ),
        ),
        DataCell(
          MyText(
            _formatDate(task.dueDate),
          ),
        ),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      height: 10,
                      width: 10,
                      decoration: ShapeDecoration(
                        color: _getStatusColor(task.status.displayName),
                        shape: const OvalBorder(),
                      ),
                    ),
                    kSizedBoxWidthTiny,
                    MyText(
                      task.status.displayName,
                    ),
                  ],
                ),
              ),
              _buildActionMenu(context, index, task),
            ],
          ),
        ),
      ]);
    }).toList();
  }

  Widget _buildActionMenu(BuildContext context, int index, Task task) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        if (value == 'review') {
          _openApprovalDialog(context, index, task);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'review',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyText('Review Task', isSelectable: false),
            ],
          ),
        ),
      ],
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD5D5D5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.more_vert, size: 18, color: AppColors.grey1),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.green;
      case 'in progress':
        return AppColors.blue;
      case 'pending':
        return const Color(0xFFFFA500);
      case 'undone':
        return const Color(0xFF64748B);
      default:
        return AppColors.grey1;
    }
  }
}
