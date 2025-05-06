import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ProjectOverview extends StatelessWidget {
  const ProjectOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
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
                    width: isLargeScreen(context) ? 400 : double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: AppColors.border),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      // mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const MyText(
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
                        const Expanded(
                          child: Wrap(
                            spacing: 15,
                            runSpacing: 15,
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
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 150,
                    width: isLargeScreen(context) ? 400 : double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 18),
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: AppColors.border),
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
                          // mainAxisSize: MainAxisSize.min,
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
                            const Expanded(
                              child: Column(
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
        kSizedBoxBG,
        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ProjectExpenceTrack(
                expence: 'Project budget',
                amount: 0.00,
              ),
              kSizedBoxWidthBG,
              ProjectExpenceTrack(
                expence: 'Expenses',
                amount: 0.00,
              ),
              kSizedBoxWidthBG,
              ProjectExpenceTrack(
                expence: 'Earnings',
                amount: 0.00,
              ),
              kSizedBoxWidthBG,
              ProjectExpenceTrack(
                expence: 'Profit',
                amount: 0.00,
              ),
              kSizedBoxWidthBG
            ],
          ),
        ),
        kSizedBoxBG,
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    width: isSmallScreen(context)
                        ? double.infinity
                        : isLargeScreen(context)
                            ? ((media.width - 300) / 3) - 40
                            : 326,
                    child: Row(
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
                        kSizedBoxWidth,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const MyText(
                                "Good Morning",
                                weight: 800,
                                size: 11,
                              ),
                              kSizedBoxSM,
                              const MyText(
                                "Dr. Cassy Melina",
                                weight: 800,
                                size: 18,
                                maxLines: 1,
                              ),
                              kSizedBoxSM,
                              MyElevatedButton(
                                // width: 220,
                                child: "5 Appointments",
                                onTap: () {},
                                bgColor: AppColors.darkBlue2,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    width: isSmallScreen(context)
                        ? double.infinity
                        : isLargeScreen(context)
                            ? ((media.width - 300) / 3) - 40
                            : 326,
                    height: 268,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const MyText(
                              "Revenue Chart",
                              weight: 800,
                              size: 14,
                            ),
                            kSizedBoxWidth,
                            SvgPicture.asset("assets/svg/star-chart.svg"),
                          ],
                        ),
                        kSizedBox,
                        const Expanded(
                          child: RevenueLineChart(),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    width: isSmallScreen(context)
                        ? double.infinity
                        : isLargeScreen(context)
                            ? ((media.width - 300) / 3) - 40
                            : 326,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const MyText(
                              "Outstanding Amount",
                              weight: 800,
                              size: 14,
                            ),
                            kSizedBoxWidth,
                            SvgPicture.asset("assets/svg/pattern.svg"),
                          ],
                        ),
                        kSizedBox,
                        Center(
                          child: CircularPercentIndicator(
                            startAngle: 310,
                            percent: 0.33,
                            radius: 240 / 2.0,
                            lineWidth: 40.0,
                            circularStrokeCap: CircularStrokeCap.round,
                            center: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                MyText(
                                  'Amount Paid',
                                  size: 11,
                                  weight: 800,
                                  color: AppColors.darkBlue,
                                ),
                                MyText(
                                  '\$883',
                                  size: 34,
                                  weight: 4700,
                                  color: AppColors.darkBlue2,
                                ),
                                MyText(
                                  'of \$2,340',
                                  size: 12,
                                  weight: 400,
                                  color: AppColors.black,
                                ),
                              ],
                            ),
                            linearGradient: const LinearGradient(
                              colors: [
                                AppColors.darkBlue2,
                                AppColors.darkBlue2,
                                AppColors.darkBlue2
                              ],
                              stops: [0.0, 0.5, 1.0],
                            ),
                            rotateLinearGradient: true,
                            backgroundColor: AppColors.lightBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    width: isSmallScreen(context)
                        ? double.infinity
                        : isLargeScreen(context)
                            ? ((media.width - 300) / 3) - 40
                            : 326,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const MyText(
                              "Available Doctors List",
                              weight: 800,
                              size: 14,
                            ),
                            kSizedBoxWidth,
                            SvgPicture.asset("assets/svg/people.svg"),
                          ],
                        ),
                        kSizedBox,
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          separatorBuilder: (context, index) => kSizedBoxSM,
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.grey5,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.asset(
                                        "assets/image/man-demo.png",
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  kSizedBoxWidth,
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyText(
                                          "Dr. Fred Israc",
                                          weight: 600,
                                          size: 14,
                                          color: AppColors.black,
                                        ),
                                        MyText(
                                          "Endocrinologists | FCPS",
                                          weight: 500,
                                          size: 11,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SvgPicture.asset(
                                    "assets/svg/arrow-right.svg",
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.black,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkBlue2,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    width: isSmallScreen(context)
                        ? double.infinity
                        : isLargeScreen(context)
                            ? ((media.width - 300) / 3) - 40
                            : 326,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const MyText(
                              "Total Patient Count",
                              weight: 800,
                              size: 14,
                              color: AppColors.white,
                            ),
                            kSizedBoxWidth,
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: SvgPicture.asset(
                                "assets/svg/arrow-top-right.svg",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    width: isSmallScreen(context)
                        ? double.infinity
                        : isLargeScreen(context)
                            ? ((media.width - 300) / 3) - 40
                            : 326,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const MyText(
                              "Total Patient Count",
                              weight: 800,
                              size: 14,
                            ),
                            kSizedBoxWidth,
                            SvgPicture.asset("assets/svg/steps.svg"),
                          ],
                        ),
                        kSizedBoxSM,
                        const MyText(
                          "689",
                          weight: 700,
                          size: 46,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}

class RevenueLineChart extends StatelessWidget {
  const RevenueLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 4,
        minY: 100,
        maxY: 400,
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: Colors.black,
            barWidth: 3,
            dotData: const FlDotData(
              show: true,

              // dotColor: Colors.black,
              // dotSize: 4,
            ),
            spots: const [
              FlSpot(0, 180), // Sun
              FlSpot(1, 230), // Mon
              FlSpot(2, 380), // Tue
              FlSpot(3, 200), // Wed
              FlSpot(4, 260), // Thu
            ],
            belowBarData: BarAreaData(show: false),
          ),
        ],
        gridData: FlGridData(
          show: true,
          horizontalInterval: 100,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
              dashArray: [6, 6],
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              reservedSize: 40,
              showTitles: true,
              interval: 100,
              getTitlesWidget: (value, _) {
                return Text(
                  '${value.toInt()}K',
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, _) {
                const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu'];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: MyText(
                    days[value.toInt()],
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        extraLinesData: const ExtraLinesData(
          horizontalLines: [
            // HorizontalLine(
            //   y: 300,
            //   color: Colors.orange.withValues(alpha: 0.4),
            //   strokeWidth: 2,
            //   dashArray: [6, 3],
            //   label: HorizontalLineLabel(
            //     show: true,
            //     labelResolver: (_) => '300K',
            //     style: TextStyle(
            //       backgroundColor: Colors.orange.shade100,
            //       color: Colors.black,
            //       fontWeight: FontWeight.bold,
            //     ),
            //     alignment: Alignment.topLeft,
            //     padding: const EdgeInsets.only(right: 4),
            //   ),
            // ),
          ],
          verticalLines: [
            // VerticalLine(
            //   x: 4,
            //   color: Colors.black,
            //   strokeWidth: 1,
            //   label: VerticalLineLabel(
            //     show: true,
            //     alignment: Alignment.topRight,
            //     labelResolver: (_) => '-15%',
            //     style: const TextStyle(
            //       color: Colors.white,
            //       fontSize: 12,
            //       backgroundColor: Colors.orange,
            //     ),
            //     padding: const EdgeInsets.only(left: 4, bottom: 4),
            //   ),
            // ),
          ],
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.black12),
        ),
      ),
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
          border: Border.all(width: 1, color: AppColors.border),
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
