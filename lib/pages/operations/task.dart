import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/operations/widget/assign_task_dialog.dart';
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
  late List<Map<String, dynamic>> _tasks;

  @override
  void initState() {
    super.initState();
    _initializeSampleTasks();
  }

  void _initializeSampleTasks() {
    _tasks = [
      {
        'code': '#1234567',
        'title': 'Benji Express user login Interface',
        'assignedTo': 'John Michael',
        'startDate': '11/02/2024',
        'dueDate': '11/02/2024',
        'status': 'Undone',
        'priority': 'High',
        'estimatedHours': '40',
        'description': 'Design and implement user login interface',
      },
      {
        'code': '#1234568',
        'title': 'API Integration',
        'assignedTo': 'Sarah Johnson',
        'startDate': '12/02/2024',
        'dueDate': '19/02/2024',
        'status': 'In Progress',
        'priority': 'Medium',
        'estimatedHours': '32',
        'description': 'Integrate backend APIs',
      },
      {
        'code': '#1234569',
        'title': 'Database Optimization',
        'assignedTo': 'Nicholas Chidera',
        'startDate': '10/02/2024',
        'dueDate': '15/02/2024',
        'status': 'Completed',
        'priority': 'Low',
        'estimatedHours': '16',
        'description': 'Optimize database queries',
      },
    ];
  }

  void _handleTaskAssignment(Map<String, dynamic> taskData) {
    setState(() {
      _tasks.insert(0, taskData);
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
      final task = entry.value;
      return DataRow(cells: <DataCell>[
        DataCell(
          MyText(
            task['code'] ?? '#N/A',
          ),
        ),
        DataCell(
          onTap: () {
            context.go(RouteConstants.taskDetail);
          },
          MyText(
            task['title'] ?? 'Untitled Task',
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
                (task['assignedTo'] as String).isNotEmpty
                    ? (task['assignedTo'] as String)[0].toUpperCase()
                    : '?',
                weight: 600,
                color: AppColors.blue,
              ),
            ),
          ),
        ),
        DataCell(
          MyText(
            task['startDate'] ?? '---',
          ),
        ),
        DataCell(
          MyText(
            task['dueDate'] ?? '---',
          ),
        ),
        DataCell(
          Row(
            children: [
              Container(
                height: 10,
                width: 10,
                decoration: ShapeDecoration(
                  color: _getStatusColor(task['status'] ?? 'Undone'),
                  shape: const OvalBorder(),
                ),
              ),
              kSizedBoxWidthTiny,
              MyText(
                task['status'] ?? 'Undone',
              ),
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
