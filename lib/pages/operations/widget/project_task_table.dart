import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/pages/operations/controllers/tasks_controler.dart';
import 'package:bomach_os/pages/operations/models/models.dart';
import 'package:bomach_os/pages/operations/widget/add_task_dialog.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:bomach_os/src/helper/responsive_breakpoints.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

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
    return Obx(() {
      final loading = controller.isLoading.value;
      final tasks = controller.tasks;

      return AppCard(
        padding: EdgeInsets.zero,
        elevation: AppCardElevation.sm,
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
                        const Text('Tasks', style: AppTextStyles.h3),
                        const SizedBox(height: 4),
                        Text(
                          loading
                              ? 'Loading tasks...'
                              : '${tasks.length} task${tasks.length == 1 ? '' : 's'} in this project',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const StatusChip(
                    label: 'Task Board',
                    tone: StatusTone.primary,
                    icon: Iconsax.task_square,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderSubtle),
            if (loading)
              Padding(
                padding: const EdgeInsets.all(20),
                child: LoadingSkeleton.listRows(count: 5),
              )
            else if (tasks.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: EmptyState(
                  icon: Iconsax.task_square,
                  title: 'No tasks yet',
                  subtitle:
                      'Tasks created for this project will appear here.',
                ),
              )
            else
              _buildTable(tasks),
          ],
        ),
      );
    });
  }

  Widget _buildTable(List<Task> tasks) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: tasks.map((t) => _buildMobileCard(t)).toList(),
      ),
    );
  }

  Widget _buildMobileCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${task.id}',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              StatusChip(
                label: _statusLabel(task.status),
                tone: _statusTone(task.status),
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            task.name,
            style: AppTextStyles.bodyMd.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                task.dueDate.isEmpty ? '—' : task.dueDate,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              ),
              StatusChip(
                label: task.priority.isEmpty ? '—' : task.priority,
                tone: _priorityTone(task.priority),
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: AppRadii.brSm,
                  onTapDown: (details) async {
                    final selected = await showMenu<String>(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        details.globalPosition.dx,
                        details.globalPosition.dy,
                        details.globalPosition.dx,
                        details.globalPosition.dy,
                      ),
                      items: const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    );
                    if (!mounted) return;
                    if (selected == 'edit') {
                      showDialog(
                        context: context,
                        builder: (_) => AddTaskDialog(
                            task: task, projectId: widget.projectId),
                      );
                    } else if (selected == 'delete') {
                      controller.deleteTask(
                          context, task.id, widget.projectId);
                    }
                  },
                  onTap: () {},
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.brSm,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Icon(Iconsax.more,
                        size: 16, color: AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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

  Widget _buildTaskRow(Task task) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '#${task.id}',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              task.name,
              style: AppTextStyles.bodyMd.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 140,
            child: Text(
              task.dueDate.isEmpty ? '—' : task.dueDate,
              style: AppTextStyles.bodyMd,
            ),
          ),
          SizedBox(
            width: 120,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                label: task.priority.isEmpty ? '—' : task.priority,
                tone: _priorityTone(task.priority),
                dense: true,
              ),
            ),
          ),
          SizedBox(
            width: 140,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                label: _statusLabel(task.status),
                tone: _statusTone(task.status),
                dense: true,
              ),
            ),
          ),
          SizedBox(
            width: 64,
            child: Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: AppRadii.brSm,
                  onTapDown: (details) async {
                    final selected = await showMenu<String>(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        details.globalPosition.dx,
                        details.globalPosition.dy,
                        details.globalPosition.dx,
                        details.globalPosition.dy,
                      ),
                      items: const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    );
                    if (!mounted) return;
                    if (selected == 'edit') {
                      showDialog(
                        context: context,
                        builder: (_) => AddTaskDialog(
                            task: task, projectId: widget.projectId),
                      );
                    } else if (selected == 'delete') {
                      controller.deleteTask(
                          context, task.id, widget.projectId);
                    }
                  },
                  onTap: () {},
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.brSm,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Icon(Iconsax.more,
                        size: 16, color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  StatusTone _priorityTone(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return StatusTone.danger;
      case 'medium':
        return StatusTone.warning;
      case 'low':
        return StatusTone.neutral;
      default:
        return StatusTone.neutral;
    }
  }

  StatusTone _statusTone(String status) {
    final s = status.toLowerCase().replaceAll('_', ' ').trim();
    switch (s) {
      case 'todo':
        return StatusTone.neutral;
      case 'in progress':
        return StatusTone.primary;
      case 'in review':
        return StatusTone.info;
      case 'completed':
        return StatusTone.success;
      case 'blocked':
        return StatusTone.danger;
      case 'cancelled':
      case 'canceled':
        return StatusTone.danger;
      default:
        return StatusTone.neutral;
    }
  }

  String _statusLabel(String status) {
    if (status.isEmpty) return '—';
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty
            ? w
            : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }
}
