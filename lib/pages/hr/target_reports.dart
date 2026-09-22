import 'dart:async';

import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/target_report_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controller/target_report_controller.dart';

class TargetReportsPage extends StatefulWidget {
  const TargetReportsPage({super.key});

  @override
  State<TargetReportsPage> createState() => _TargetReportsPageState();
}

class _TargetReportsPageState extends State<TargetReportsPage> {
  late final TargetReportController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TargetReportController());
    controller.fetchMine();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'My Target Reports',
        subtitle:
            'Submit progress against assigned targets and track review status.',
        trailing: MyElevatedButton(
          height: 44,
          child: 'Submit progress',
          icon:
              const Icon(Iconsax.add, size: 16, color: AppColors.textOnPrimary),
          onTap: () => _showCreateDialog(context),
        ),
      ),
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Iconsax.search_normal,
                  size: 18, color: AppColors.textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search target reports',
                    border: InputBorder.none,
                  ),
                  onSubmitted: controller.setSearch,
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String?>(
                value: controller.selectedStatus.value,
                hint: const Text('All statuses'),
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem<String?>(
                      value: null, child: Text('All statuses')),
                  DropdownMenuItem(value: 'draft', child: Text('Draft')),
                  DropdownMenuItem(
                      value: 'submitted', child: Text('Submitted')),
                  DropdownMenuItem(value: 'approved', child: Text('Approved')),
                  DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                ],
                onChanged: controller.setStatus,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage.value.isNotEmpty) {
            return _TargetReportsError(
              message: controller.errorMessage.value,
              onRetry: controller.fetchMine,
            );
          }
          if (controller.reports.isEmpty) {
            return EmptyState(
              icon: Iconsax.chart_success,
              title: 'No target reports found',
              subtitle:
                  'Submit progress when you have an update for an assigned target.',
              action: MyElevatedButton(
                height: 40,
                child: 'Submit progress',
                onTap: () => _showCreateDialog(context),
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.reports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) => _TargetReportCard(
              report: controller.reports[index],
            ),
          );
        }),
      ],
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    int? selectedTargetId;
    final summary = TextEditingController();
    final progress = TextEditingController();
    final formKey = GlobalKey<FormState>();
    unawaited(controller.fetchMyAssignedTargets());

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Submit target progress'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() {
                    if (controller.isLoadingTargets.value) {
                      return const InputDecorator(
                        decoration:
                            InputDecoration(labelText: 'Assigned target'),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 10),
                            Text('Loading assigned targets...'),
                          ],
                        ),
                      );
                    }

                    if (controller.targetLoadError.value.isNotEmpty) {
                      return InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Assigned target',
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text('Could not load assigned targets.'),
                            ),
                            TextButton(
                              onPressed: () => unawaited(
                                controller.fetchMyAssignedTargets(),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (controller.assignedTargets.isEmpty) {
                      return const InputDecorator(
                        decoration:
                            InputDecoration(labelText: 'Assigned target'),
                        child: Text('No active assigned targets found.'),
                      );
                    }

                    return DropdownButtonFormField<int>(
                      initialValue: selectedTargetId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Assigned target',
                      ),
                      items: controller.assignedTargets
                          .map(
                            (target) => DropdownMenuItem<int>(
                              value: target.id,
                              child: Text(
                                target.optionLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setDialogState(
                        () => selectedTargetId = value,
                      ),
                      validator: (value) =>
                          value == null ? 'Select an assigned target' : null,
                    );
                  }),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: progress,
                    decoration:
                        const InputDecoration(labelText: 'Progress value'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) =>
                        double.tryParse(value?.trim() ?? '') == null
                            ? 'Enter a numeric value'
                            : null,
                  ),
                  TextFormField(
                    controller: summary,
                    decoration: const InputDecoration(labelText: 'Summary'),
                    maxLines: 4,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Summary is required'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            MyOutlinedButton(
              height: 40,
              child: 'Cancel',
              onTap: () => Navigator.pop(dialogContext, false),
            ),
            MyElevatedButton(
              height: 40,
              child: 'Submit',
              onTap: () async {
                if (!(formKey.currentState?.validate() ?? false) ||
                    selectedTargetId == null) {
                  return;
                }
                final result = await controller.createReport(
                  employeeTargetId: selectedTargetId!,
                  summary: summary.text.trim(),
                  progressValue: double.parse(progress.text.trim()),
                );
                if (result && dialogContext.mounted) {
                  Navigator.pop(dialogContext, true);
                }
              },
            ),
          ],
        ),
      ),
    );

    summary.dispose();
    progress.dispose();
    if (saved == true && mounted) setState(() {});
  }
}

class _TargetReportCard extends StatelessWidget {
  final TargetReport report;

  const _TargetReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final color = switch (report.status) {
      'approved' => AppColors.success,
      'rejected' => AppColors.danger,
      'submitted' => AppColors.info,
      _ => AppColors.warning,
    };
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(report.targetTitle,
                    style: AppTextStyles.bodyLg
                        .copyWith(fontWeight: FontWeight.w700)),
              ),
              Chip(
                label: Text(report.status),
                backgroundColor: color.withValues(alpha: 0.1),
                labelStyle: TextStyle(color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(report.summary, style: AppTextStyles.bodyMd),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              Text(
                  'Progress: ${report.progressValue}${report.targetUnit.isEmpty ? '' : ' ${report.targetUnit}'}'),
              if (report.targetPeriod.isNotEmpty)
                Text('Period: ${report.targetPeriod}'),
              if (report.employeeCode.isNotEmpty)
                Text('Employee: ${report.employeeCode}'),
            ],
          ),
          if (report.rejectionReason.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('Review feedback: ${report.rejectionReason}',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.danger)),
          ],
        ],
      ),
    );
  }
}

class _TargetReportsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _TargetReportsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Iconsax.warning_2, size: 48, color: AppColors.danger),
              const SizedBox(height: 12),
              const Text('Error loading target reports'),
              const SizedBox(height: 8),
              Text(message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              MyOutlinedButton(height: 40, child: 'Retry', onTap: onRetry),
            ],
          ),
        ),
      );
}
