import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ProjectOverview extends StatelessWidget {
  const ProjectOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                runSpacing: 20,
                spacing: 20,
                children: [
                  Container(
                    height: 160,
                    width: isLargeScreen(context) ? null : double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border:
                          Border.all(width: 1, color: AppColors.borderColor),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Project progress',
                              style: AppText.black_500_16,
                            ),
                            const SizedBox(height: 10),
                            CircularPercentIndicator(
                              startAngle: 180.0,
                              percent: 0.67,
                              radius: 40.0,
                              lineWidth: 15.0,
                              circularStrokeCap: CircularStrokeCap.round,
                              center: const MyText(
                                '67%',
                                size: 18,
                                weight: 400,
                                color: AppColors.orange,
                              ),
                              linearGradient: const LinearGradient(
                                colors: [
                                  Color(0xFFE8620F),
                                  Color(0xFFFFDC3D),
                                  Color(0xFFFFDC3D),
                                ],
                                stops: [0.0, 0.5, 1.0],
                              ),
                              rotateLinearGradient: true,
                              backgroundColor: AppColors.grey2,
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        // This nested Row now also lines up at the top
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  'Start date',
                                  size: 12,
                                  weight: 400,
                                  color: AppColors.grey2,
                                ),
                                SizedBox(height: 8),
                                MyText(
                                  'Start date',
                                  size: 16,
                                  weight: 500,
                                ),
                              ],
                            ),
                            SizedBox(width: 21),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  'Start date',
                                  size: 12,
                                  weight: 400,
                                  color: AppColors.grey2,
                                ),
                                SizedBox(height: 8),
                                MyText(
                                  'Due date',
                                  size: 16,
                                  weight: 500,
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 150,
                    width: isLargeScreen(context) ? null : double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 18),
                    decoration: BoxDecoration(
                        border:
                            Border.all(width: 1, color: AppColors.borderColor),
                        borderRadius: BorderRadius.circular(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MyText(
                          'Client',
                          size: 16,
                          weight: 500,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.asset(
                                  "assets/image/man-demo.png",
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 24,
                            ),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  'Miss Jane',
                                  size: 20,
                                  weight: 500,
                                ),
                                MyText(
                                  'Jenny group of company',
                                  size: 14,
                                  weight: 400,
                                  color: AppColors.grey2,
                                ),
                              ],
                            ),
                            kSizedBoxWidthBG,
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 32,
        ),
        const MyText(
          'Statistics',
          size: 20,
          weight: 500,
        ),
        const SizedBox(
          height: 16,
        ),
        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ProjectExpenceTrack(
                expence: 'Project budget',
                amount: 0.00,
              ),
              SizedBox(
                width: 20,
              ),
              ProjectExpenceTrack(
                expence: 'Expenses',
                amount: 0.00,
              ),
              SizedBox(
                width: 20,
              ),
              ProjectExpenceTrack(
                expence: 'Earnings',
                amount: 0.00,
              ),
              SizedBox(
                width: 20,
              ),
              ProjectExpenceTrack(
                expence: 'Profit',
                amount: 0.00,
              ),
              SizedBox(
                width: 20,
              ),
            ],
          ),
        )
      ],
    );
  }
}

class ProjectExpenceTrack extends StatelessWidget {
  final String expence;
  final double amount;
  const ProjectExpenceTrack({
    super.key,
    required this.expence,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 283,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(21)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            expence,
            size: 20,
            weight: 500,
          ),
          const SizedBox(
            height: 5,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const SizedBox(),
                Positioned(
                  left: -13,
                  child: SvgPicture.asset(
                    "assets/svg/naira-coin.svg",
                    height: 44,
                  ),
                ),
                Positioned(
                  child: SvgPicture.asset(
                    "assets/svg/naira-coin.svg",
                    height: 44,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          const MyText(
            '0.00',
            size: 20,
            weight: 500,
          )
        ],
      ),
    );
  }
}
