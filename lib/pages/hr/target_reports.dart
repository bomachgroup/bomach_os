import 'dart:async';

import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/model/target_report_model.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controller/target_report_controller.dart';
import 'widget/employee_performance_plan_section.dart';

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
        _assignedPlanSection(),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final search = TextField(
                decoration: const InputDecoration(
                  hintText: 'Search target reports',
                  prefixIcon: Icon(Iconsax.search_normal, size: 18),
                ),
                onSubmitted: controller.setSearch,
              );
              final status = DropdownButtonFormField<String?>(
                initialValue: controller.selectedStatus.value,
                decoration: const InputDecoration(labelText: 'Status'),
                isExpanded: true,
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
              );
              if (constraints.maxWidth < 620) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    search,
                    const SizedBox(height: 12),
                    status,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(flex: 3, child: search),
                  const SizedBox(width: 16),
                  Expanded(flex: 1, child: status),
                ],
              );
            },
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

  Widget _assignedPlanSection() {
    if (!Get.isRegistered<PermissionService>()) return const SizedBox.shrink();
    final permissions = Get.find<PermissionService>();
    return Obx(() {
      permissions.version;
      final canReadOwn = permissions.hasAll(const [
        Perms.employeeKpisListOwn,
        Perms.employeeTargetsListOwn,
      ]);
      final canReadBroad = permissions.hasAll(const [
        Perms.employeeKpisList,
        Perms.employeeTargetsList,
      ]);
      if (!canReadOwn && !canReadBroad) return const SizedBox.shrink();
      return const Padding(
        padding: EdgeInsets.only(bottom: 18),
        child: EmployeePerformancePlanSection(readOnly: true),
      );
    });
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    int? selectedTargetId;
    final summary = TextEditingController();
    final progress = TextEditingController();
    final formKey = GlobalKey<FormState>();
    unawaited(controller.fetchMyAssignedTargets());
    var submitting = false;
    var formError = '';

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => PopScope(
          canPop: !submitting,
          child: DialogScaffold(
            title: 'Submit target progress',
            subtitle: 'Record progress against one of your assigned targets.',
            size: DialogSize.md,
            showCloseButton: false,
            body: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (formError.isNotEmpty) ...[
                    _ReportFormError(message: formError),
                    const SizedBox(height: 12),
                  ],
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
                      return _TargetPickerMessage(
                        title: 'Targets could not be loaded',
                        detail: 'Try again to load your active targets.',
                        action: TextButton.icon(
                          onPressed: () => unawaited(
                            controller.fetchMyAssignedTargets(),
                          ),
                          icon: const Icon(Iconsax.refresh, size: 16),
                          label: const Text('Retry'),
                        ),
                      );
                    }

                    if (controller.assignedTargets.isEmpty) {
                      return const _TargetPickerMessage(
                        title: 'No active targets assigned',
                        detail:
                            'A progress report can be submitted after a target is assigned to you.',
                      );
                    }

                    return DropdownButtonFormField<int>(
                      initialValue: selectedTargetId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Target',
                        helperText:
                            'Choose the assigned target this update relates to.',
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
                      onChanged: (value) => setDialogState(() {
                        selectedTargetId = value;
                        formError = '';
                      }),
                      validator: (value) =>
                          value == null ? 'Select an assigned target' : null,
                    );
                  }),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: progress,
                    decoration: const InputDecoration(
                      labelText: 'Progress achieved',
                      hintText: 'Enter the amount completed',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) {
                      if (formError.isNotEmpty) {
                        setDialogState(() => formError = '');
                      }
                    },
                    validator: (value) {
                      final parsed = double.tryParse(value?.trim() ?? '');
                      if (parsed == null || !parsed.isFinite) {
                        return 'Enter a valid number.';
                      }
                      if (parsed < 0) return 'Progress cannot be negative.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: summary,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Progress summary',
                      hintText: 'Describe the work completed or evidence',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    onChanged: (_) {
                      if (formError.isNotEmpty) {
                        setDialogState(() => formError = '');
                      }
                    },
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Add a short summary of your progress.'
                        : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: submitting
                    ? null
                    : () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              Obx(() => FilledButton.icon(
                    onPressed: submitting ||
                            controller.isLoadingTargets.value ||
                            controller.targetLoadError.value.isNotEmpty ||
                            controller.assignedTargets.isEmpty ||
                            selectedTargetId == null
                        ? null
                        : () async {
                            if (!(formKey.currentState?.validate() ?? false) ||
                                selectedTargetId == null) {
                              return;
                            }
                            setDialogState(() {
                              submitting = true;
                              formError = '';
                            });
                            final result = await controller.createReport(
                              employeeTargetId: selectedTargetId!,
                              summary: summary.text.trim(),
                              progressValue: double.parse(progress.text.trim()),
                            );
                            if (result && dialogContext.mounted) {
                              Navigator.pop(dialogContext, true);
                            } else if (dialogContext.mounted) {
                              setDialogState(() {
                                submitting = false;
                                formError = _cleanUiError(
                                    controller.errorMessage.value);
                              });
                            }
                          },
                    icon: submitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Iconsax.send_2, size: 17),
                    label: Text(submitting ? 'Submitting…' : 'Submit report'),
                  )),
            ],
          ),
        ),
      ),
    );

    summary.dispose();
    progress.dispose();
    if (saved == true && mounted) {
      setState(() {});
      AppToast.success(context, 'Progress report submitted.');
    }
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
    final ratio = report.targetValue != null && report.targetValue! > 0
        ? (report.progressValue / report.targetValue!).clamp(0.0, 1.0)
        : null;
    final unit = report.targetUnit.isEmpty ? '' : ' ${report.targetUnit}';
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                ),
                child: const Icon(Iconsax.flag,
                    size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(report.targetTitle,
                    style: AppTextStyles.bodyLg
                        .copyWith(fontWeight: FontWeight.w700)),
              ),
              _ReportStatus(label: _statusLabel(report.status), color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(report.summary,
              style: AppTextStyles.bodyMd,
              maxLines: 4,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 14),
          if (ratio != null) ...[
            LayoutBuilder(
              builder: (context, constraints) {
                final value =
                    '${_formatValue(report.progressValue)}$unit / ${_formatValue(report.targetValue!)}$unit';
                if (constraints.maxWidth < 420) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Progress against target',
                          style: AppTextStyles.caption),
                      const SizedBox(height: 3),
                      Text(
                        value,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySm
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    const Expanded(
                      child: Text('Progress against target',
                          style: AppTextStyles.caption),
                    ),
                    Flexible(
                      child: Text(
                        value,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: AppTextStyles.bodySm
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 7),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: AppColors.neutral100,
                color: color,
              ),
            ),
          ] else
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _ReportMetric(
                  label: 'Progress submitted',
                  value: '${_formatValue(report.progressValue)}$unit',
                ),
                if (report.targetValue != null)
                  _ReportMetric(
                    label: 'Target',
                    value: '${_formatValue(report.targetValue!)}$unit',
                  ),
              ],
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              if (report.targetPeriod.isNotEmpty)
                _ReportMetadata(
                    icon: Iconsax.calendar_1,
                    text: _prettyPeriod(report.targetPeriod)),
              if (report.createdAt != null)
                _ReportMetadata(
                    icon: Iconsax.clock,
                    text: 'Submitted ${_formatDate(report.createdAt!)}'),
              if (report.employeeCode.isNotEmpty)
                _ReportMetadata(icon: Iconsax.user, text: report.employeeCode),
            ],
          ),
          if (report.rejectionReason.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.dangerSubtle,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Iconsax.message_text_1,
                      size: 17, color: AppColors.danger),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Review feedback',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.danger,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Text(report.rejectionReason,
                            style: AppTextStyles.bodySm),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TargetPickerMessage extends StatelessWidget {
  final String title;
  final String detail;
  final Widget? action;

  const _TargetPickerMessage({
    required this.title,
    required this.detail,
    this.action,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          border: Border.all(color: AppColors.borderSubtle),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Iconsax.info_circle,
                size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.bodySm
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(detail,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary)),
                  if (action != null) ...[
                    const SizedBox(height: 7),
                    Align(alignment: Alignment.centerLeft, child: action!),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
}

class _ReportFormError extends StatelessWidget {
  final String message;

  const _ReportFormError({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.dangerSubtle,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Iconsax.warning_2, size: 17, color: AppColors.danger),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message,
                  style:
                      AppTextStyles.bodySm.copyWith(color: AppColors.danger)),
            ),
          ],
        ),
      );
}

class _ReportStatus extends StatelessWidget {
  final String label;
  final Color color;

  const _ReportStatus({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: AppTextStyles.caption
                .copyWith(color: color, fontWeight: FontWeight.w600)),
      );
}

class _ReportMetric extends StatelessWidget {
  final String label;
  final String value;

  const _ReportMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 3),
          Text(value,
              style:
                  AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600)),
        ],
      );
}

class _ReportMetadata extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ReportMetadata({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      );
}

String _statusLabel(String status) => switch (status) {
      'submitted' => 'Submitted',
      'approved' => 'Approved',
      'rejected' => 'Needs revision',
      'draft' => 'Draft',
      _ => status.isEmpty ? 'Pending' : status,
    };

String _formatValue(double value) =>
    value.toStringAsFixed(value % 1 == 0 ? 0 : 2);

String _prettyPeriod(String period) {
  if (period == 'yearly') return 'Annual';
  return period
      .split('_')
      .map((part) =>
          part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _cleanUiError(String value) => value
    .replaceFirst(RegExp(r'^Exception: '), '')
    .replaceFirst(RegExp(r'^API Error: \d+ - '), '');

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
