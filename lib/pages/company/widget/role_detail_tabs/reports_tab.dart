import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/role_report_controller.dart';
import '../report_dialogs.dart';

class ReportsTab extends StatelessWidget {
  final int roleId;

  const ReportsTab({super.key, required this.roleId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RoleReportController>(
      tag: 'role_detail_$roleId',
      init: RoleReportController()
        ..scopedRoleId = roleId
        ..fetchReports(roleId: roleId),
      builder: (ctrl) {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.reports.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.document_text, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text('No reports defined for this role.',
                      style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: 16),
                  MyElevatedButton(
                    height: 40,
                    child: 'Add Report',
                    icon: const Icon(Iconsax.add, size: 16, color: AppColors.textOnPrimary),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) =>
                          CreateEditReportDialog(ctrl: ctrl, presetRoleId: roleId),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: ctrl.reports.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == ctrl.reports.length) {
              return Center(
                child: TextButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) =>
                        CreateEditReportDialog(ctrl: ctrl, presetRoleId: roleId),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Report'),
                ),
              );
            }

            final r = ctrl.reports[index];

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Iconsax.document_text,
                            color: AppColors.success, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.reportName,
                                style: AppTextStyles.bodyMd
                                    .copyWith(fontWeight: FontWeight.w600)),
                            if (r.description != null && r.description!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(r.description!,
                                    style: AppTextStyles.bodySm
                                        .copyWith(color: AppColors.textSecondary)),
                              ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (action) {
                          if (action == 'edit') {
                            showDialog(
                              context: context,
                              builder: (_) =>
                                  CreateEditReportDialog(ctrl: ctrl, report: r),
                            );
                          } else if (action == 'delete') {
                            ctrl.deleteReport(context, r.id!);
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete',
                                  style: TextStyle(color: AppColors.danger))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(r.reportType[0].toUpperCase() +
                            r.reportType.substring(1),
                            style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.info, fontSize: 11)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(r.format.toUpperCase(),
                            style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.primary, fontSize: 11)),
                      ),
                      if (r.frequency.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(r.frequency,
                            style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ],
                  ),
                  if (r.recipients.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: r.recipients
                          .map((rec) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.textSecondary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(rec,
                                    style: AppTextStyles.bodySm.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 11)),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
