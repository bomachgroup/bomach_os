import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/components/text/row_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class TimelineDetailPage extends StatefulWidget {
  const TimelineDetailPage({super.key});

  @override
  State<TimelineDetailPage> createState() => TimelineDetailPageState();
}

class TimelineDetailPageState extends State<TimelineDetailPage> {
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
                      InkWell(
                        onTap: () {
                          context.pop();
                        },
                        child: Row(
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
                              isSelectable: false,
                            ),
                          ],
                        ),
                      ),
                      kSizedBoxWidth,
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            'Timeline: Site Preparation',
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
          child: const Column(
            children: [
              RowText(label: "Phase", value: "Site Preparation"),
              RowText(
                  label: "Description",
                  value: "Initial site reconnaissance and access preparation"),
              RowText(label: "Start Date", value: "9/1/2023"),
              RowText(label: "End Date", value: "1/31/2024"),
              RowText(label: "Status", value: "Pending"),
            ],
          ),
        )
      ],
    );
  }
}
