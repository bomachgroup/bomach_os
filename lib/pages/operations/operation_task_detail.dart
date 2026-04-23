import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/text/row_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

import 'models/models.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;
  const TaskDetailPage({super.key, required this.task});

  @override
  State<TaskDetailPage> createState() => TaskDetailPageState();
}

class TaskDetailPageState extends State<TaskDetailPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    return PageScaffold(
      header: PageHeader(
        title: task.name,
        subtitle: 'Created ${task.createdAt} • Updated ${task.updatedAt}',
        trailing: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Iconsax.edit, size: 18),
              label: const Text('Edit'),
            ),
            MyElevatedButton(
              bgColor: AppColors.danger,
              child: 'Delete',
              icon: const Icon(Iconsax.trash, size: 18, color: Colors.white),
              onTap: () {},
            ),
          ],
        ),
      ),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Task Information', style: AppText.h3),
              const SizedBox(height: 16),
              RowText(label: "Task ID", value: "#${task.id}"),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const SizedBox(
                        width: 200, child: Text("Status", style: AppText.label)),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: StatusChip(
                          label: task.status,
                          tone: _getStatusTone(task.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              RowText(label: "Priority", value: task.priority),
              RowText(label: "Due Date", value: task.dueDate),
              RowText(
                  label: "Estimated Hours", value: "${task.estimatedHours} hrs"),
              const Divider(height: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Assigned To", style: AppText.label),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: task.assignedTo
                        .map((id) => Chip(
                              avatar: const Icon(Iconsax.profile_circle, size: 16),
                              label: Text("Employee #$id", style: AppText.bodySm),
                              backgroundColor: AppColors.surfaceMuted,
                              side: BorderSide.none,
                            ))
                        .toList(),
                  ),
                ],
              ),
              const Divider(height: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Description", style: AppText.label),
                  const SizedBox(height: 8),
                  Text(
                      task.description.isEmpty
                          ? 'No description provided.'
                          : task.description,
                      style: AppText.bodyMd),
                ],
              ),
            ],
          ),
        )
      ],
    );
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
