import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/components/text/row_text.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/spaces.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class CampaignDetailPage extends StatefulWidget {
  const CampaignDetailPage({super.key});

  @override
  State<CampaignDetailPage> createState() => CampaignDetailPageState();
}

class CampaignDetailPageState extends State<CampaignDetailPage> {
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
                              style: AppTextStyles.h2,
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
                            'PQ1 Land Survey Awareness',
                            style: AppTextStyles.h2,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          MyText(
                            'Created 8/15/2023',
                            style: AppTextStyles.bodyLg,
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
          ),
          child: const Column(
            children: [
              RowText(label: "Campaign Number", value: "CAM-001"),
              RowText(
                  label: "Campaign Name", value: "Q1 Land Survey Awareness"),
              RowText(label: "Type", value: "Social Media"),
              RowText(label: "Status", value: "Active"),
              RowText(label: "Budget (NGN)", value: "₦500,000.00"),
              RowText(label: "Start Date", value: "9/1/2023"),
              RowText(label: "End Date", value: "1/31/2024"),
              RowText(
                  label: "Target Audience",
                  value: "Property developers in Lagos"),
            ],
          ),
        )
      ],
    );
  }
}
