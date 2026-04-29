import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controllers/timeline_controller.dart';
import 'models/models.dart';
import 'widget/add_timeline_dialog.dart';

class TimelineDetailPage extends StatelessWidget {
  final TimelineModel? t;

  const TimelineDetailPage({super.key, this.t});

  @override
  Widget build(BuildContext context) {
    final TimelineController controller = Get.find<TimelineController>();

    final TimelineModel? timeline =
        t ?? ModalRoute.of(context)?.settings.arguments as TimelineModel?;

    if (timeline == null) {
      return const PageScaffold(
        children: [
          Center(
            child: MyText('Timeline phase not found', style: AppTextStyles.bodyLg),
          ),
        ],
      );
    }

    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: timeline.name.isEmpty ? 'Phase' : timeline.name,
        subtitle: 'Project phase details and scheduling.',
        trailing: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            MyOutlinedButton(
              height: 48,
              icon: const Icon(Iconsax.edit, size: 18, color: AppColors.primary),
              child: 'Edit',
              onTap: () => showDialog(
                context: context,
                builder: (_) => AddTimelineDialog(timeline: timeline),
              ),
            ),
            MyElevatedButton(
              height: 48,
              bgColor: AppColors.danger,
              child: 'Delete',
              icon: const Icon(Iconsax.trash, size: 18, color: Colors.white),
              onTap: () => _confirmDelete(context, controller, timeline),
            ),
          ],
        ),
      ),
      children: [
        _buildOverviewHeader(timeline),
        _buildPhaseDetailsCard(timeline),
        _buildDescriptionCard(timeline),
      ],
    );
  }

  Widget _buildOverviewHeader(TimelineModel timeline) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.md,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: AppRadii.brMd,
            ),
            child: const Icon(
              Iconsax.calendar_1,
              size: 26,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeline.name.isEmpty ? 'Phase' : timeline.name,
                  style: AppTextStyles.h3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusChip(
                      label:
                          timeline.status.isEmpty ? 'Unknown' : timeline.status,
                      tone: _getStatusTone(timeline.status),
                    ),
                    StatusChip(
                      label: 'Project #${timeline.projectId}',
                      tone: StatusTone.neutral,
                      icon: Iconsax.briefcase,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseDetailsCard(TimelineModel timeline) {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Text('Phase Overview', style: AppTextStyles.h3),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                _detailRow('Phase Name',
                    timeline.name.isEmpty ? '—' : timeline.name),
                _detailRowChip(
                  'Status',
                  StatusChip(
                    label:
                        timeline.status.isEmpty ? 'Unknown' : timeline.status,
                    tone: _getStatusTone(timeline.status),
                  ),
                ),
                _detailRow('Start Date',
                    timeline.startDate.isEmpty ? '—' : timeline.startDate),
                _detailRow('End Date',
                    timeline.endDate.isEmpty ? '—' : timeline.endDate),
                _detailRow('Project ID', '#${timeline.projectId}'),
                _detailRow('Created At',
                    timeline.createdAt.isEmpty ? '—' : timeline.createdAt),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(TimelineModel timeline) {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Text('Description', style: AppTextStyles.h3),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Text(
              timeline.description.isEmpty
                  ? 'No description provided.'
                  : timeline.description,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
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

  Widget _detailRowChip(String label, Widget chip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Align(alignment: Alignment.centerLeft, child: chip),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TimelineController controller,
    TimelineModel timeline,
  ) async {
    final confirmed = await DialogScaffold.show<bool>(
      context,
      title: 'Delete Phase',
      size: DialogSize.sm,
      body: Text(
        'Are you sure you want to delete "${timeline.name}"?',
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
          child: 'Delete',
          onTap: () => Navigator.pop(context, true),
        ),
      ],
    );
    if (confirmed == true && context.mounted) {
      await controller.deleteTimeline(context, timeline.id, timeline.projectId);
      if (context.mounted) context.pop();
    }
  }

  StatusTone _getStatusTone(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return StatusTone.success;
      case 'ongoing':
      case 'in progress':
      case 'in_progress':
        return StatusTone.primary;
      case 'on hold':
      case 'at risk':
      case 'at_risk':
        return StatusTone.warning;
      case 'overdue':
      case 'blocked':
        return StatusTone.danger;
      case 'pending':
        return StatusTone.neutral;
      default:
        return StatusTone.neutral;
    }
  }
}
