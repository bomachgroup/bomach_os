import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/components/text/row_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TaskDetailPage extends StatefulWidget {
  const TaskDetailPage({super.key});

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
                      SvgPicture.asset(
                        "assets/svg/arrow-left.svg",
                        colorFilter: const ColorFilter.mode(
                          AppColors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                      kSizedBoxWidthSM,
                      const MyText(
                        'Back',
                        style: AppText.black_500_20,
                      ),
                      kSizedBoxWidth,
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            'Initial Site Reconnaissance',
                            style: AppText.black_500_20,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          MyText(
                            'Created 8/15/2023 • Updated 1/31/2024',
                            style: AppText.black_400_16,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyElevatedButton(
                        child: 'Edit',
                        onTap: () {},
                      ),
                      MyElevatedButton(
                        bgColor: AppColors.red,
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
          ),
          child: Column(
            children: [
              const RowText(
                  label: "Task Name", value: "Initial Site Reconnaissance"),
              const RowText(label: "Task Number", value: "TSK-001"),
              const RowText(
                  label: "Description",
                  value:
                      "Conduct preliminary site visit to assess terrain and access points"),
              kSizedBoxTiny,
              Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: MyText(
                      "Assigned To",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          width: 36,
                          height: 36,
                          child: Image.asset('assets/icons/profile-icon.png'),
                        ),
                        kSizedBoxWidth,
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              "Nicholas Chidera Ani",
                              weight: 400,
                              size: 16,
                            ),
                            MyText(
                              "MTN Nigeria",
                              weight: 400,
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              kSizedBoxTiny,
              const RowText(label: "Status", value: "In Progress"),
              const RowText(label: "Priority", value: "High"),
              const RowText(label: "Due Date", value: "1/31/2024"),
              const RowText(label: "Estimated Hours", value: "16"),
              const RowText(label: "Actual Hours", value: "14"),
            ],
          ),
        )
      ],
    );
  }
}
