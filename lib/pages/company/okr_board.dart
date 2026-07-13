import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controllers/role_okr_controller.dart';
import 'widget/okr_dialogs.dart';

class OkrBoardPage extends StatelessWidget {
  const OkrBoardPage({super.key});

  static const List<String> _quarters = ['Q1', 'Q2', 'Q3', 'Q4'];

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(RoleOkrController());
    final now = DateTime.now();

    return PageScaffold(
      header: PageHeader(
        title: 'OKR Board',
        subtitle: 'Track Objectives and Key Results across role templates.',
        trailing: MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle, color: AppColors.white, size: 18),
          child: 'New OKR',
          onTap: () => showDialog(
            context: context,
            builder: (_) => CreateEditOkrDialog(ctrl: ctrl),
          ),
        ),
      ),
      children: [
        // ── Filter Bar ──────────────────────────────────────────────────
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          elevation: AppCardElevation.sm,
          child: Row(
            children: [
              // Quarter filter
              const Text('Quarter:', style: AppTextStyles.label),
              const SizedBox(width: 8),
              ..._quarters.asMap().entries.map((e) {
                final q = e.key + 1;
                final isActive = ctrl.filterQuarter == q;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(e.value),
                    selected: isActive,
                    onSelected: (_) {
                      ctrl.filterQuarter = isActive ? null : q;
                      ctrl.fetchOkrs(refresh: true);
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isActive ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                );
              }),
              const SizedBox(width: 16),
              // Status filter
              const Text('Status:', style: AppTextStyles.label),
              const SizedBox(width: 8),
              ...['active', 'completed', 'draft'].map((s) {
                final isActive = ctrl.filterStatus == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(s[0].toUpperCase() + s.substring(1)),
                    selected: isActive,
                    onSelected: (_) {
                      ctrl.filterStatus = isActive ? '' : s;
                      ctrl.fetchOkrs(refresh: true);
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isActive ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        // ── OKR Cards Grid ──────────────────────────────────────────────
        Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (ctrl.okrs.isEmpty) {
            return const EmptyState(
              icon: Iconsax.flag,
              title: 'No OKRs yet',
              subtitle:
                  'Create Objectives and Key Results for each role template to align the team.',
            );
          }

          return LayoutBuilder(builder: (context, constraints) {
            final crossCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 280,
              ),
              itemCount: ctrl.okrs.length,
              itemBuilder: (_, index) {
                final okr = ctrl.okrs[index];
                return _OkrCard(
                  okr: okr,
                  ctrl: ctrl,
                  currentYear: now.year,
                  onEdit: () => showDialog(
                    context: context,
                    builder: (_) => CreateEditOkrDialog(ctrl: ctrl, okr: okr),
                  ),
                  onDelete: () => _confirmDelete(context, ctrl, okr.id!),
                );
              },
            );
          });
        }),
      ],
    );
  }

  void _confirmDelete(BuildContext context, RoleOkrController ctrl, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete OKR'),
        content: const Text(
            'Are you sure you want to delete this OKR? All key results will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ctrl.deleteOkr(context, id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _OkrCard extends StatelessWidget {
  final dynamic okr;
  final RoleOkrController ctrl;
  final int currentYear;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OkrCard({
    required this.okr,
    required this.ctrl,
    required this.currentYear,
    required this.onEdit,
    required this.onDelete,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green.shade600;
      case 'completed':
        return AppColors.primary;
      case 'cancelled':
        return AppColors.danger;
      default:
        return Colors.grey.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = okr.overallProgress;
    final progressColor = progress >= 80
        ? Colors.green.shade600
        : progress >= 50
            ? Colors.amber.shade700
            : AppColors.danger;

    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Q${okr.quarter} ${okr.year}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _statusColor(okr.status)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            okr.status[0].toUpperCase() +
                                okr.status.substring(1),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _statusColor(okr.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (okr.roleName.isNotEmpty)
                      Text(
                        okr.roleName,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete',
                          style: TextStyle(color: AppColors.danger))),
                ],
                child: const Icon(Icons.more_vert,
                    size: 20, color: AppColors.textMuted),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Objective ────────────────────────────────────────────
          Text(
            okr.objective,
            style: AppTextStyles.bodyMd
                .copyWith(fontWeight: FontWeight.w700),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const Spacer(),

          // ── Progress ─────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress', style: AppTextStyles.caption),
              Text(
                '${progress.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 8,
              backgroundColor: AppColors.borderSubtle,
              valueColor: AlwaysStoppedAnimation(progressColor),
            ),
          ),
          const SizedBox(height: 12),

          // ── Key Results count ─────────────────────────────────────
          Row(
            children: [
              const Icon(Iconsax.key, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                '${okr.keyResults.length} Key Result${okr.keyResults.length == 1 ? '' : 's'}',
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
