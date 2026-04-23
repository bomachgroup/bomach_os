import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/components/text/row_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
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
            child: MyText('Timeline phase not found', style: AppText.bodyLg),
          ),
        ],
      );
    }

    return PageScaffold(
      header: PageHeader(
        title: timeline.name,
        subtitle: 'Project phase details and scheduling',
        trailing: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AddTimelineDialog(
                    timeline: timeline,
                  ),
                );
              },
              icon: const Icon(Iconsax.edit, size: 18),
              label: const Text('Edit'),
            ),
            MyElevatedButton(
              bgColor: AppColors.danger,
              child: 'Delete',
              icon: const Icon(Iconsax.trash, size: 18, color: Colors.white),
              onTap: () async {
                await controller.deleteTimeline(
                    context, timeline.id, timeline.projectId);
                if (context.mounted) context.pop();
              },
            ),
          ],
        ),
      ),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Phase Overview', style: AppText.h3),
              const SizedBox(height: 16),
              RowText(label: "Phase Name", value: timeline.name),
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
                          label: timeline.status,
                          tone: _getStatusTone(timeline.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              RowText(label: "Start Date", value: timeline.startDate),
              RowText(label: "End Date", value: timeline.endDate),
              RowText(label: "Project ID", value: "#${timeline.projectId}"),
              RowText(label: "Created At", value: timeline.createdAt),
              const Divider(height: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Description", style: AppText.label),
                  const SizedBox(height: 8),
                  Text(
                      timeline.description.isEmpty
                          ? "No description provided."
                          : timeline.description,
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
      case 'ongoing':
      case 'in progress':
        return StatusTone.primary;
      case 'on hold':
        return StatusTone.warning;
      case 'pending':
        return StatusTone.neutral;
      default:
        return StatusTone.neutral;
    }
  }
}
