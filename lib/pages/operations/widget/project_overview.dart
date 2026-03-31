import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/operations/models/models.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ProjectOverview extends StatelessWidget {
  final Project project;
  const ProjectOverview({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final double percent =
        (project.progress > 100 ? 100 : project.progress) / 100;

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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const MyText('Project progress',
                                style: AppText.black_500_16),
                            const SizedBox(height: 10),
                            CircularPercentIndicator(
                              startAngle: 180.0,
                              percent: percent,
                              radius: 40.0,
                              lineWidth: 15.0,
                              circularStrokeCap: CircularStrokeCap.round,
                              center: MyText(
                                '${project.progress.toInt()}%',
                                size: 18,
                                weight: 400,
                                color: AppColors.orange,
                              ),
                              linearGradient: const LinearGradient(
                                colors: [Color(0xFFE8620F), Color(0xFFFFDC3D)],
                              ),
                              rotateLinearGradient: true,
                              backgroundColor: AppColors.grey2,
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Wrap(
                            spacing: 15,
                            runSpacing: 15,
                            children: [
                              _buildDateColumn('Start date', project.startDate),
                              _buildDateColumn('Deadline', project.deadline),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 160,
                    width: isLargeScreen(context) ? 400 : double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 18),
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: AppColors.border),
                        borderRadius: BorderRadius.circular(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MyText('Client', size: 16, weight: 500),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  AssetImage("assets/image/man-demo.png"),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText('Client ID: ${project.clientId}',
                                      size: 20, weight: 500),
                                  const MyText('Corporate Client',
                                      size: 14,
                                      weight: 400,
                                      color: AppColors.grey2),
                                ],
                              ),
                            ),
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
        const SizedBox(height: 32),
        const MyText('Statistics', size: 20, weight: 500),
        kSizedBoxBG,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ProjectExpenceTrack(
                  expence: 'Project budget', amount: project.budget),
              const SizedBox(width: 20),
              const ProjectExpenceTrack(expence: 'Expenses', amount: 0.00),
              const SizedBox(width: 20),
              const ProjectExpenceTrack(expence: 'Profit', amount: 0.00),
            ],
          ),
        ),
        kSizedBoxBG,
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MyText("Project Summary", weight: 800, size: 14),
              kSizedBox,
              MyText(
                  project.summary.isEmpty
                      ? "No description provided."
                      : project.summary,
                  weight: 400,
                  size: 14),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDateColumn(String label, String date) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(label, size: 12, weight: 400, color: AppColors.grey2),
        const SizedBox(height: 8),
        MyText(date.isEmpty ? 'N/A' : date, size: 16, weight: 500),
      ],
    );
  }
}

class ProjectExpenceTrack extends StatelessWidget {
  final String expence;
  final double amount;
  const ProjectExpenceTrack(
      {super.key, required this.expence, required this.amount});

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
          MyText(expence, size: 20, weight: 500),
          const SizedBox(height: 5),
          MyText(amount.toStringAsFixed(2), size: 20, weight: 500),
        ],
      ),
    );
  }
}
