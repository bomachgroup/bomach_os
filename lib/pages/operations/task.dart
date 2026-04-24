import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/loading_skeleton.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/pages/operations/models/models.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

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
  final TaskController controller = Get.put(TaskController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTasks(context, projectId: widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      header: PageHeader(
        title: 'Tasks',
        subtitle: 'Management of operational tasks and deadlines',
        trailing: MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle,
              size: 18, color: AppColors.textOnPrimary),
          child: 'Add Task',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AddTaskDialog(
                projectId: widget.projectId ?? 0,
              ),
            );
          },
        ),
      ),
      children: [
        _buildToolbar(),
        Obx(() {
          final loading =
              controller.isLoading.value && controller.tasks.isEmpty;
          final isEmpty = !controller.isLoading.value && controller.tasks.isEmpty;

          return _buildTableCard(
            title: 'Tasks register',
            subtitle: loading
                ? 'Loading tasks...'
                : '${controller.tasks.length} tasks shown',
            headerTrailing: const StatusChip(
              label: 'Operational tasks',
              tone: StatusTone.primary,
              icon: Iconsax.task_square,
            ),
            body: loading
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: LoadingSkeleton.listRows(count: 5),
                  )
                : isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: EmptyState.empty(
                          title: 'No tasks found',
                          subtitle:
                              'Create a new task to track progress and deadlines.',
                          action: MyElevatedButton(
                            child: 'Add Task',
                            icon: const Icon(Iconsax.add_circle,
                                size: 18, color: AppColors.textOnPrimary),
                            onTap: () => showDialog(
                              context: context,
                              builder: (_) => AddTaskDialog(
                                projectId: widget.projectId ?? 0,
                              ),
                            ),
                          ),
                        ),
                      )
                    : _buildTaskTable(context),
          );
        }),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────
  // UI building blocks
  // ────────────────────────────────────────────────────────────

  Widget _buildToolbar() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: MyTextFormField(
        hintText: 'Search tasks by name...',
        height: 48,
        onChanged: (val) => controller.fetchTasks(
          context,
          projectId: widget.projectId,
          search: val,
        ),
        leading: const Icon(Iconsax.search_normal,
            size: 18, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildTableCard({
    required String title,
    required String subtitle,
    Widget? headerTrailing,
    required Widget body,
  }) {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.md,
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
                      Text(title, style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodyMd
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (headerTrailing != null) headerTrailing,
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          body,
        ],
      ),
    );
  }

  Widget _buildTaskTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 900),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              color: AppColors.surfaceMuted,
              child: Row(
                children: [
                  _buildHeaderCell('ID', width: 80),
                  _buildHeaderCell('Task Name', flex: 4),
                  _buildHeaderCell('Priority', flex: 2),
                  _buildHeaderCell('Due Date', flex: 2),
                  _buildHeaderCell('Hours', flex: 1),
                  _buildHeaderCell('Status', flex: 2),
                  _buildHeaderCell('', width: 48),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderSubtle),
            ...controller.tasks.map((t) => _buildTaskRow(context, t)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String label, {double? width, int? flex}) {
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

  Widget _buildTaskRow(BuildContext context, Task task) {
    return InkWell(
      onTap: () => context.push(RouteConstants.taskDetail, extra: task),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text('#${task.id}',
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.textMuted)),
            ),
            Expanded(
              flex: 4,
              child: Text(
                task.name,
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: StatusChip(
                  label: task.priority.isEmpty ? '—' : task.priority,
                  tone: _getPriorityTone(task.priority),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  const Icon(Iconsax.calendar,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      task.dueDate.isEmpty ? '—' : task.dueDate,
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                task.estimatedHours > 0
                    ? '${task.estimatedHours}h'
                    : '—',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: StatusChip(
                  label: task.status.isEmpty ? 'Unknown' : task.status,
                  tone: _getStatusTone(task.status),
                ),
              ),
            ),
            SizedBox(
              width: 48,
              child: _buildActionMenu(context, task),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context, Task task) {
    return PopupMenuButton<String>(
      icon:
          const Icon(Iconsax.more, size: 18, color: AppColors.textSecondary),
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
      onSelected: (value) async {
        switch (value) {
          case 'view':
            if (!context.mounted) return;
            context.push(RouteConstants.taskDetail, extra: task);
            break;
          case 'edit':
            showDialog(
              context: context,
              builder: (_) => AddTaskDialog(task: task),
            );
            break;
          case 'delete':
            final confirmed = await DialogScaffold.show<bool>(
              context,
              title: 'Delete Task',
              size: DialogSize.sm,
              body: Text(
                'Are you sure you want to delete "${task.name}"?',
                style: AppTextStyles.bodyMd,
              ),
              actions: [
                MyOutlinedButton(
                  child: 'Cancel',
                  height: 44,
                  onTap: () => Navigator.pop(context, false),
                  textColor: AppColors.textSecondary,
                  borderColor: AppColors.borderStrong,
                ),
                MyElevatedButton(
                  width: 120,
                  height: 44,
                  bgColor: AppColors.danger,
                  child: 'Delete',
                  onTap: () => Navigator.pop(context, true),
                ),
              ],
            );
            if (confirmed == true && context.mounted) {
              controller.deleteTask(context, task.id, widget.projectId);
            }
            break;
        }
      },
      itemBuilder: (_) => [
        _menuItem(value: 'view', icon: Iconsax.eye, label: 'View Details'),
        _menuItem(value: 'edit', icon: Iconsax.edit, label: 'Edit'),
        _menuItem(
            value: 'delete',
            icon: Iconsax.trash,
            label: 'Delete',
            destructive: true),
      ],
    );
  }

  PopupMenuItem<String> _menuItem({
    required String value,
    required IconData icon,
    required String label,
    bool destructive = false,
  }) {
    final color =
        destructive ? AppColors.danger : AppColors.textSecondary;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodyMd.copyWith(
              color: destructive ? AppColors.danger : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // Tone mappings
  // ────────────────────────────────────────────────────────────

  StatusTone _getStatusTone(String status) {
    switch (status.toLowerCase().trim()) {
      case 'completed':
      case 'approved':
        return StatusTone.success;
      case 'in_progress':
      case 'in progress':
        return StatusTone.primary;
      case 'in_review':
      case 'in review':
        return StatusTone.info;
      case 'pending':
      case 'pending_approval':
        return StatusTone.warning;
      case 'blocked':
      case 'cancelled':
      case 'canceled':
      case 'rejected':
        return StatusTone.danger;
      case 'todo':
      case 'to do':
      default:
        return StatusTone.neutral;
    }
  }

  StatusTone _getPriorityTone(String priority) {
    switch (priority.toLowerCase().trim()) {
      case 'critical':
      case 'high':
      case 'urgent':
        return StatusTone.danger;
      case 'medium':
        return StatusTone.warning;
      case 'low':
      default:
        return StatusTone.neutral;
    }
  }
}
