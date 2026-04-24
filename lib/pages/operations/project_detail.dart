import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/operations/models/models.dart';
import 'package:bms_front_end/pages/operations/operations.dart'
    show projectStatusTone, priorityTone;
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controllers/project_controller.dart';

class ProjectDetailPage extends StatelessWidget {
  final Project? project;
  const ProjectDetailPage({super.key, this.project});

  @override
  Widget build(BuildContext context) {
    final ProjectController controller = Get.find<ProjectController>();

    final Project? proj =
        project ?? ModalRoute.of(context)?.settings.arguments as Project?;

    if (proj == null) {
      return const PageScaffold(
        children: [
          Center(
            child: MyText('Project not found', style: AppTextStyles.bodyLg),
          ),
        ],
      );
    }

    return PageScaffold(
      header: PageHeader(
        title: proj.name,
        subtitle: 'Project details and configuration',
        trailing: MyElevatedButton(
          height: 48,
          bgColor: AppColors.danger,
          icon: const Icon(Iconsax.trash,
              size: 18, color: AppColors.textOnPrimary),
          child: 'Delete Project',
          onTap: () => _confirmDelete(context, controller, proj),
        ),
      ),
      children: [
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: AppRadii.brMd,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Iconsax.folder_2,
                        size: 24, color: AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Project Overview',
                            style: AppTextStyles.h3),
                        const SizedBox(height: 4),
                        Text(
                          'Key information on file for this project.',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (proj.status.isNotEmpty)
                    StatusChip(
                      label: proj.status,
                      tone: projectStatusTone(proj.status),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              // Details grid
              _DetailSection(
                items: [
                  _DetailItem('Project Name', proj.name),
                  _DetailItem('Short Code',
                      proj.shortCode.isEmpty ? '—' : proj.shortCode),
                  _DetailItem(
                      'Category', proj.category.isEmpty ? '—' : proj.category),
                  _DetailItem('Department',
                      proj.department.isEmpty ? '—' : proj.department),
                  _DetailItem(
                    'Priority',
                    proj.priority.isEmpty ? '—' : proj.priority,
                    chipTone: proj.priority.isEmpty
                        ? null
                        : priorityTone(proj.priority),
                  ),
                  _DetailItem(
                      'Budget', 'N${proj.budget.toStringAsFixed(2)}'),
                  _DetailItem('Start Date',
                      proj.startDate.isEmpty ? '—' : proj.startDate),
                  _DetailItem('Deadline',
                      proj.deadline.isEmpty ? '—' : proj.deadline),
                  _DetailItem(
                      'Location', proj.location.isEmpty ? '—' : proj.location),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: AppRadii.brLg,
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Description', style: AppTextStyles.h4),
                    const SizedBox(height: 8),
                    Text(
                      proj.summary.isEmpty
                          ? 'No description provided.'
                          : proj.summary,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, ProjectController controller, Project proj) async {
    final confirmed = await DialogScaffold.show<bool>(
      context,
      title: 'Delete Project',
      size: DialogSize.sm,
      body: Text(
        'Are you sure you want to delete "${proj.name}"? This action cannot be undone.',
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
      controller.deleteProject(context, proj.id);
    }
  }
}

class _DetailItem {
  final String label;
  final String value;
  final StatusTone? chipTone;
  const _DetailItem(this.label, this.value, {this.chipTone});
}

class _DetailSection extends StatelessWidget {
  final List<_DetailItem> items;
  const _DetailSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final twoCol = constraints.maxWidth >= 640;
      if (!twoCol) {
        return Column(
          children: [
            for (final item in items) _row(item),
          ],
        );
      }

      final rows = <Widget>[];
      for (var i = 0; i < items.length; i += 2) {
        rows.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _row(items[i])),
            const SizedBox(width: 24),
            Expanded(
              child: i + 1 < items.length
                  ? _row(items[i + 1])
                  : const SizedBox(),
            ),
          ],
        ));
      }
      return Column(children: rows);
    });
  }

  Widget _row(_DetailItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              item.label,
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: item.chipTone != null
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: StatusChip(
                      label: item.value,
                      tone: item.chipTone!,
                    ),
                  )
                : Text(
                    item.value,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
