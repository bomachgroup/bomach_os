import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/components/text/row_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';

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
      return const Center(
        child: MyText('Task not found', style: AppText.bodyLg),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => context.pop(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset("assets/svg/arrow-left.svg",
                                colorFilter: const ColorFilter.mode(
                                    AppColors.black, BlendMode.srcIn)),
                            kSizedBoxWidthSM,
                            const MyText('Back', style: AppText.h2),
                          ],
                        ),
                      ),
                      Row(
                        spacing: 10,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MyElevatedButton(
                            child: 'Edit',
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AddTimelineDialog(
                                  timeline: timeline,
                                ),
                              );
                            },
                          ),
                          MyElevatedButton(
                            bgColor: AppColors.danger,
                            child: 'Delete',
                            onTap: () async {
                              await controller.deleteTimeline(
                                  context, timeline.id, timeline.projectId);
                              if (context.mounted) context.pop();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            kSizedBox,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  RowText(label: "Phase", value: timeline.name),
                  RowText(label: "Status", value: timeline.status),
                  RowText(label: "Start Date", value: timeline.startDate),
                  RowText(label: "End Date", value: timeline.endDate),
                  RowText(
                      label: "Project ID",
                      value: timeline.projectId.toString()),
                  RowText(label: "Created At", value: timeline.createdAt),
                  const Divider(height: 30),
                  RowText(
                      label: "Description",
                      value: timeline.description.isEmpty
                          ? "No description provided."
                          : timeline.description),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
