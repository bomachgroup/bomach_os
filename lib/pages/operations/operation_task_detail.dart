import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/components/text/row_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => context.pop(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              "assets/svg/arrow-left.svg",
                              colorFilter: const ColorFilter.mode(
                                  AppColors.black, BlendMode.srcIn),
                            ),
                            kSizedBoxWidthSM,
                            const MyText('Back',
                                style: AppText.h2,
                                isSelectable: false),
                          ],
                        ),
                      ),
                      kSizedBoxWidth,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(task.name, style: AppText.h2),
                          const SizedBox(height: 8),
                          MyText(
                            'Created ${task.createdAt} • Updated ${task.updatedAt}',
                            style: AppText.bodyLg,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyElevatedButton(child: 'Edit', onTap: () {}),
                      MyElevatedButton(
                        bgColor: AppColors.danger,
                        child: 'Delete',
                        onTap: () {},
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            children: [
              RowText(label: "Task ID", value: "#${task.id}"),
              RowText(label: "Description", value: task.description),
              kSizedBoxTiny,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyText("Assigned To", style: AppText.bodyLg),
                  Container(
                    width: 300,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        border: Border.all(color: AppColors.neutral300),
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Container(
                          decoration:
                              const BoxDecoration(shape: BoxShape.circle),
                          width: 36,
                          height: 36,
                          child: const Icon(Iconsax.profile_circle),
                        ),
                        kSizedBoxWidth,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                  "Employee IDs: ${task.assignedTo.join(', ')}",
                                  weight: 400,
                                  size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              kSizedBoxTiny,
              RowText(label: "Status", value: task.status),
              RowText(label: "Priority", value: task.priority),
              RowText(label: "Due Date", value: task.dueDate),
              RowText(
                  label: "Estimated Hours",
                  value: task.estimatedHours.toString()),
            ],
          ),
        )
      ],
    );
  }
}
