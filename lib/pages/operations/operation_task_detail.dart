import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'models/models.dart';

import 'package:bomach_os/src/utils/app_date_format.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;
  const TaskDetailPage({super.key, required this.task});

  @override
  State<TaskDetailPage> createState() => TaskDetailPageState();
}

class TaskDetailPageState extends State<TaskDetailPage> {
  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    return PageScaffold(
      header: PageHeader(
        title: task.name,
        subtitle:
            'Created ${formatAppDateValue(task.createdAt, fallback: task.createdAt)} • Updated ${formatAppDateValue(task.updatedAt, fallback: task.updatedAt)}',
        trailing: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            MyOutlinedButton(
              height: 48,
              child: 'Edit',
              icon:
                  const Icon(Iconsax.edit, size: 18, color: AppColors.primary),
              onTap: () {},
            ),
            MyElevatedButton(
              height: 48,
              bgColor: AppColors.danger,
              child: 'Delete',
              icon: const Icon(Iconsax.trash,
                  size: 18, color: AppColors.textOnPrimary),
              onTap: () {},
            ),
          ],
        ),
      ),
      children: [
        _buildOverviewCard(task),
        _buildDescriptionCard(task),
        _buildAssigneesCard(task),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────
  // Sections
  // ────────────────────────────────────────────────────────────

  Widget _buildOverviewCard(Task task) {
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
                      const Text('Task overview', style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        'Key attributes and status for this task.',
                        style: AppTextStyles.bodyMd
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                StatusChip(
                  label: task.status.isEmpty ? 'Unknown' : task.status,
                  tone: _getStatusTone(task.status),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _infoTile(
                  icon: Iconsax.hashtag,
                  label: 'Task ID',
                  value: '#${task.id}',
                ),
                _infoTile(
                  icon: Iconsax.flag,
                  label: 'Priority',
                  value: task.priority.isEmpty ? '—' : task.priority,
                  trailing: task.priority.isEmpty
                      ? null
                      : StatusChip(
                          label: task.priority,
                          tone: _getPriorityTone(task.priority),
                          dense: true,
                        ),
                ),
                _infoTile(
                  icon: Iconsax.calendar,
                  label: 'Due date',
                  value: task.dueDate.isEmpty
                      ? '—'
                      : formatAppDateValue(task.dueDate,
                          fallback: task.dueDate),
                ),
                _infoTile(
                  icon: Iconsax.timer_1,
                  label: 'Estimated hours',
                  value: task.estimatedHours > 0
                      ? '${task.estimatedHours} hrs'
                      : '—',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(Task task) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Iconsax.document_text,
                  size: 18, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Text('Description', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            task.description.isEmpty
                ? 'No description provided.'
                : task.description,
            style: AppTextStyles.bodyMd.copyWith(
              color: task.description.isEmpty
                  ? AppColors.textMuted
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssigneesCard(Task task) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.profile_2user,
                  size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              const Text('Assigned to', style: AppTextStyles.h3),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: const BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: AppRadii.brPill,
                ),
                child: Text(
                  '${task.assignedTo.length}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (task.assignedTo.isEmpty)
            Text(
              'No assignees yet.',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: task.assignedTo
                  .map((id) => _assigneeChip('Employee #$id'))
                  .toList(),
            ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────
  // Small helpers
  // ────────────────────────────────────────────────────────────

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brMd,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.brSm,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 2),
                trailing ??
                    Text(
                      value,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _assigneeChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySubtle,
        borderRadius: AppRadii.brPill,
        border: Border.all(color: AppColors.primarySoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Iconsax.profile_circle,
              size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
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
