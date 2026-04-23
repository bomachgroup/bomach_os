import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/pages/operations/models/models.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:iconsax/iconsax.dart';

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
                  SizedBox(
                    width: isLargeScreen(context) ? 400 : double.infinity,
                    child: AppCard(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircularPercentIndicator(
                            startAngle: 180.0,
                            percent: percent,
                            radius: 42.0,
                            lineWidth: 10.0,
                            circularStrokeCap: CircularStrokeCap.round,
                            center: Text(
                              '${project.progress.toInt()}%',
                              style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                            ),
                            linearGradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryHover],
                            ),
                            rotateLinearGradient: true,
                            backgroundColor: AppColors.surfaceMuted,
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Project Progress', style: AppTextStyles.label),
                                const SizedBox(height: 12),
                                _buildDateRow(Iconsax.calendar_1, 'Start:', project.startDate),
                                const SizedBox(height: 8),
                                _buildDateRow(Iconsax.timer_1, 'End:', project.deadline),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: isLargeScreen(context) ? 400 : double.infinity,
                    child: AppCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Primary Client', style: AppTextStyles.label),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                child: const Icon(Iconsax.user, color: AppColors.primary),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Client ID: ${project.clientId}',
                                        style: AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w600)),
                                    const Text('Corporate Client',
                                        style: AppTextStyles.bodySm),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text('Financial Overview', style: AppTextStyles.h3),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ProjectExpenseTrack(
                  label: 'Project Budget',
                  amount: project.budget,
                  icon: Iconsax.wallet_money,
                  color: AppColors.primary),
              const SizedBox(width: 16),
              const ProjectExpenseTrack(
                  label: 'Total Expenses',
                  amount: 0.00,
                  icon: Iconsax.card_send,
                  color: AppColors.danger),
              const SizedBox(width: 16),
              const ProjectExpenseTrack(
                  label: 'Net Profit',
                  amount: 0.00,
                  icon: Iconsax.money_recive,
                  color: AppColors.success),
            ],
          ),
        ),
        const SizedBox(height: 32),
        AppCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Project Summary', style: AppTextStyles.h4),
              const SizedBox(height: 12),
              Text(
                project.summary.isEmpty ? "No description provided." : project.summary,
                style: AppTextStyles.bodyMd.copyWith(height: 1.5),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDateRow(IconData icon, String label, String date) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted)),
        const SizedBox(width: 4),
        Text(date.isEmpty ? 'N/A' : date, style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class ProjectExpenseTrack extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const ProjectExpenseTrack({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 10),
              Text(label, style: AppTextStyles.label.copyWith(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₦${amount.toStringAsFixed(2)}',
            style: AppTextStyles.h3.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
