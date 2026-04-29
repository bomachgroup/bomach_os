import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/pages/operations/models/models.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
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
        // Snapshot header
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Project Snapshot', style: AppTextStyles.h3),
                  SizedBox(height: 4),
                  Text(
                    'High-level view of progress, client and financials.',
                    style: AppTextStyles.bodySm,
                  ),
                ],
              ),
            ),
            if (project.status.isNotEmpty) ...[
              const SizedBox(width: 12),
              StatusChip.fromStatus(project.status),
            ],
          ],
        ),
        const SizedBox(height: 20),

        // Progress + Client cards
        LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;
          final cardWidth = isWide
              ? (constraints.maxWidth - 20) / 2
              : constraints.maxWidth;
          return Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              SizedBox(
                width: cardWidth,
                child: _ProgressCard(project: project, percent: percent),
              ),
              SizedBox(
                width: cardWidth,
                child: _ClientCard(project: project),
              ),
            ],
          );
        }),
        const SizedBox(height: 28),

        // Financial overview
        const Text('Financial Overview', style: AppTextStyles.h3),
        const SizedBox(height: 4),
        const Text(
          'Live tracking of budget, expenses and net position.',
          style: AppTextStyles.bodySm,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 780;
          const count = 3;
          final cardWidth = isWide
              ? (constraints.maxWidth - ((count - 1) * 16)) / count
              : (constraints.maxWidth >= 520
                  ? (constraints.maxWidth - 16) / 2
                  : constraints.maxWidth);
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: cardWidth,
                child: ProjectExpenseTrack(
                  label: 'Project Budget',
                  amount: project.budget,
                  icon: Iconsax.wallet_money,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(
                width: cardWidth,
                child: const ProjectExpenseTrack(
                  label: 'Total Expenses',
                  amount: 0.00,
                  icon: Iconsax.card_send,
                  color: AppColors.danger,
                ),
              ),
              SizedBox(
                width: cardWidth,
                child: const ProjectExpenseTrack(
                  label: 'Net Profit',
                  amount: 0.00,
                  icon: Iconsax.money_recive,
                  color: AppColors.success,
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 28),

        // Summary
        AppCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Project Summary', style: AppTextStyles.h4),
              const SizedBox(height: 12),
              Text(
                project.summary.isEmpty
                    ? 'No description provided.'
                    : project.summary,
                style: AppTextStyles.bodyMd.copyWith(height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final Project project;
  final double percent;
  const _ProgressCard({required this.project, required this.percent});

  @override
  Widget build(BuildContext context) {
    return AppCard(
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
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Project Progress',
                  style: AppTextStyles.overline,
                ),
                const SizedBox(height: 8),
                _buildDateRow(
                    Iconsax.calendar_1, 'Start', project.startDate),
                const SizedBox(height: 8),
                _buildDateRow(Iconsax.timer_1, 'End', project.deadline),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(IconData icon, String label, String date) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(
          '$label:',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            date.isEmpty ? 'N/A' : date,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ClientCard extends StatelessWidget {
  final Project project;
  const _ClientCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Primary Client', style: AppTextStyles.overline),
          const SizedBox(height: 12),
          Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primarySubtle,
                child: Icon(Iconsax.user, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Client ID: ${project.clientId}',
                      style: AppTextStyles.bodyLg
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Corporate Client',
                      style: AppTextStyles.bodySm,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.overline,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '\u20A6${amount.toStringAsFixed(2)}',
            style: AppTextStyles.h2.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
