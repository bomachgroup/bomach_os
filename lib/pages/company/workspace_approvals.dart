import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/permission/permission_gate.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/pages/hr/models/workspace_model.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/shadows.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:flutter/material.dart';
import 'package:bomach_os/src/helper/date_picker_helper.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controllers/workspace_approvals_controller.dart';
import 'widget/work_location_record_dialog.dart';

/// Admin work-location register and extension review.
///
/// Pending proposals, extension decisions, and the broader location register
/// are loaded from their corresponding backend endpoints.
///
/// Actions per row depend on status:
///   - PENDING  -> Approve (with optional radius override) / Reject (reason).
///   - APPROVED -> Edit, inspect the audit record, or reasoned revoke.
///   - REJECTED -> Inspect the retained record and its history.
class WorkspaceApprovalsPage extends StatelessWidget {
  const WorkspaceApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(WorkspaceApprovalsController());

    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Workspace Approvals',
        subtitle: 'Review employee-submitted work locations. Approve to enable '
            'clock-in, or reject with a reason the employee will see.',
        trailing: Obx(() => MyOutlinedButton(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              icon: const Icon(Iconsax.refresh,
                  size: 18, color: AppColors.primary),
              child: 'Refresh',
              isLoading: ctrl.isLoading.value,
              onTap: ctrl.fetch,
            )),
      ),
      children: [
        _ViewTabs(ctrl: ctrl),
        _ApprovalsToolbar(ctrl: ctrl),
        Obx(() {
          if (ctrl.view.value == ApprovalsView.extensions) {
            final loading =
                ctrl.isLoading.value && ctrl.extensionRequests.isEmpty;
            final rows = ctrl.filteredExtensions;
            return _buildTableCard(
              loading: loading,
              isEmpty: !loading && rows.isEmpty,
              hasError: ctrl.errorMessage.value.isNotEmpty,
              errorMessage: ctrl.errorMessage.value,
              view: ctrl.view.value,
              rowCount: rows.length,
              body: _ExtensionReviewTable(rows: rows, ctrl: ctrl),
            );
          }
          final loading = ctrl.isLoading.value && ctrl.submissions.isEmpty;
          final rows = ctrl.filtered;
          final isEmpty = !loading && rows.isEmpty;

          return _buildTableCard(
            loading: loading,
            isEmpty: isEmpty,
            hasError: ctrl.errorMessage.value.isNotEmpty,
            errorMessage: ctrl.errorMessage.value,
            view: ctrl.view.value,
            rowCount: rows.length,
            body: _ApprovalsTable(rows: rows, ctrl: ctrl),
          );
        }),
      ],
    );
  }

  static String _titleForView(ApprovalsView v) {
    switch (v) {
      case ApprovalsView.pending:
        return 'Pending Submissions';
      case ApprovalsView.approved:
        return 'Approved Locations';
      case ApprovalsView.extensions:
        return 'Extension Review';
      case ApprovalsView.rejected:
        return 'Rejected Submissions';
      case ApprovalsView.all:
        return 'All Work Locations';
    }
  }

  static String _subtitleForView(ApprovalsView v, int count, bool loading) {
    if (loading) return 'Loading submissions...';
    final labelSuffix = count == 1 ? '' : 's';
    switch (v) {
      case ApprovalsView.pending:
        return '$count submission$labelSuffix awaiting admin decision';
      case ApprovalsView.approved:
        return '$count active geofence$labelSuffix across the org';
      case ApprovalsView.extensions:
        return '$count extension request$labelSuffix awaiting a decision';
      case ApprovalsView.rejected:
        return '$count rejected submission$labelSuffix';
      case ApprovalsView.all:
        return '$count work location$labelSuffix on record';
    }
  }

  Widget _buildTableCard({
    required bool loading,
    required bool isEmpty,
    required bool hasError,
    required String errorMessage,
    required ApprovalsView view,
    required int rowCount,
    required Widget body,
  }) {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_titleForView(view), style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        _subtitleForView(view, rowCount, loading),
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusChip(
                  label: _headerChipLabel(view),
                  tone: _headerChipTone(view),
                  icon: _headerChipIcon(view),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          if (loading)
            Padding(
              padding: const EdgeInsets.all(20),
              child: LoadingSkeleton.listRows(count: 5),
            )
          else if (hasError)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Error loading workspace approvals: $errorMessage',
                style: const TextStyle(color: AppColors.danger),
              ),
            )
          else if (isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: _emptyStateFor(view),
            )
          else
            body,
        ],
      ),
    );
  }

  static String _headerChipLabel(ApprovalsView v) {
    switch (v) {
      case ApprovalsView.pending:
        return 'Review queue';
      case ApprovalsView.approved:
        return 'Active sites';
      case ApprovalsView.extensions:
        return 'Expiry review';
      case ApprovalsView.rejected:
        return 'Rejected log';
      case ApprovalsView.all:
        return 'Full register';
    }
  }

  static StatusTone _headerChipTone(ApprovalsView v) {
    switch (v) {
      case ApprovalsView.pending:
        return StatusTone.warning;
      case ApprovalsView.approved:
        return StatusTone.success;
      case ApprovalsView.extensions:
        return StatusTone.warning;
      case ApprovalsView.rejected:
        return StatusTone.danger;
      case ApprovalsView.all:
        return StatusTone.primary;
    }
  }

  static IconData _headerChipIcon(ApprovalsView v) {
    switch (v) {
      case ApprovalsView.pending:
        return Iconsax.timer;
      case ApprovalsView.approved:
        return Iconsax.location_tick;
      case ApprovalsView.extensions:
        return Iconsax.calendar_edit;
      case ApprovalsView.rejected:
        return Iconsax.close_circle;
      case ApprovalsView.all:
        return Iconsax.location;
    }
  }

  static Widget _emptyStateFor(ApprovalsView v) {
    switch (v) {
      case ApprovalsView.pending:
        return const EmptyState(
          icon: Iconsax.archive_1,
          title: 'All caught up',
          subtitle:
              'There are no workspace submissions awaiting review right now.',
        );
      case ApprovalsView.approved:
        return const EmptyState(
          icon: Iconsax.location_slash,
          title: 'No approved locations',
          subtitle:
              'Once you approve a pending submission it will appear here.',
        );
      case ApprovalsView.extensions:
        return const EmptyState(
          icon: Iconsax.calendar_tick,
          title: 'No extension requests',
          subtitle: 'Requests from employees will appear here for review.',
        );
      case ApprovalsView.rejected:
        return const EmptyState(
          icon: Iconsax.tick_circle,
          title: 'No rejections',
          subtitle: 'Nothing has been rejected — or employees have cleaned up.',
        );
      case ApprovalsView.all:
        return const EmptyState(
          icon: Iconsax.location,
          title: 'No work locations yet',
          subtitle: 'Once employees submit workspaces they will show up here.',
        );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Pill tab bar
// ═══════════════════════════════════════════════════════════════════════

class _ViewTabs extends StatelessWidget {
  final WorkspaceApprovalsController ctrl;
  const _ViewTabs({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
              children: ApprovalsView.values
                  .map((v) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _buildTabButton(v),
                      ))
                  .toList(),
            )),
      ),
    );
  }

  Widget _buildTabButton(ApprovalsView v) {
    final isActive = ctrl.view.value == v;
    final count = _countFor(v);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadii.brMd,
        onTap: () => ctrl.setView(v),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.surface : Colors.transparent,
            borderRadius: AppRadii.brMd,
            boxShadow: isActive ? AppShadows.sm : const <BoxShadow>[],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                v.label,
                style: AppTextStyles.bodyMd.copyWith(
                  color: isActive
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        isActive ? AppColors.primarySubtle : AppColors.surface,
                    borderRadius: AppRadii.brPill,
                    border: Border.all(
                      color: isActive
                          ? AppColors.primarySubtle
                          : AppColors.borderSubtle,
                    ),
                  ),
                  child: Text(
                    '$count',
                    style: AppTextStyles.caption.copyWith(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Count for the tab badge. Only shows a count when the tab is the one
  /// currently loaded (otherwise the backend slice doesn't include those
  /// rows so the number would be misleading).
  int? _countFor(ApprovalsView v) {
    if (ctrl.view.value != v) return null;
    return v == ApprovalsView.extensions
        ? ctrl.extensionRequests.length
        : ctrl.submissions.length;
  }
}

class _ExtensionReviewTable extends StatelessWidget {
  const _ExtensionReviewTable({required this.rows, required this.ctrl});

  final List<WorkLocationExtension> rows;
  final WorkspaceApprovalsController ctrl;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: rows
              .map((request) => _card(context, request))
              .toList(growable: false),
        ),
      );

  Widget _card(BuildContext context, WorkLocationExtension request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Iconsax.calendar_edit,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(request.locationName,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    )),
              ),
              const StatusChip(
                label: 'Awaiting review',
                tone: StatusTone.warning,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 24,
            runSpacing: 10,
            children: [
              _value('Employee', request.requestedByName),
              _value('Current expiry', _formatDate(request.expiryAtRequest)),
              _value(
                  'Requested through', _formatDate(request.requestedExpiresAt)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: AppRadii.brMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reason',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(request.reason,
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.textPrimary)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PermissionGate(
                require: Perms.workLocationsView,
                child: OutlinedButton.icon(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => WorkLocationRecordDialog(
                      locationId: request.workLocationId,
                    ),
                  ),
                  icon: const Icon(Iconsax.document_text, size: 16),
                  label: const Text('View location record'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.borderStrong),
                    shape: const RoundedRectangleBorder(
                        borderRadius: AppRadii.brMd),
                  ),
                ),
              ),
              PermissionGate(
                anyOf: const [
                  Perms.workLocationsApproveExtension,
                  Perms.workLocationsRejectExtension,
                ],
                child: Obx(() => MyElevatedButton(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      bgColor: AppColors.primary,
                      icon: const Icon(Iconsax.tick_circle,
                          size: 16, color: AppColors.textOnPrimary),
                      child: 'Review request',
                      disable: ctrl.isMutating.value,
                      onTap: () => _review(context, request),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _value(String label, String value) => SizedBox(
        width: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 3),
            Text(value,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      );

  Future<void> _review(
      BuildContext context, WorkLocationExtension request) async {
    final expiryCtrl = TextEditingController(
      text: _formatDate(request.requestedExpiresAt),
    );
    final reasonCtrl = TextEditingController();
    String? expiryIso = request.requestedExpiresAt;
    bool showExpiryError = false;
    bool showReasonError = false;

    final decision = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          Future<void> pickExpiry() async {
            final initial = _tryParseDate(expiryIso ?? '') ??
                DateTime.now().add(const Duration(days: 30));
            final picked = await showDatePopover(
              dialogContext,
              initialDate: initial,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
            );
            if (picked == null) return;
            final endOfDay = DateTime(
              picked.year,
              picked.month,
              picked.day,
              23,
              59,
              59,
            );
            setDialogState(() {
              expiryIso = endOfDay.toUtc().toIso8601String();
              expiryCtrl.text = _formatDate(expiryIso);
              showExpiryError = false;
            });
          }

          return DialogScaffold(
            title: 'Review extension request',
            subtitle: request.locationName,
            size: DialogSize.md,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _reviewDetail('Requested by', request.requestedByName),
                _reviewDetail(
                    'Current expiry', _formatDate(request.expiryAtRequest)),
                _reviewDetail('Requested expiry',
                    _formatDate(request.requestedExpiresAt)),
                const SizedBox(height: 12),
                Text('Employee reason',
                    style: AppTextStyles.label.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(request.reason,
                    style: AppTextStyles.bodyMd.copyWith(height: 1.45)),
                const SizedBox(height: 18),
                Text('Effective expiry if approved',
                    style: AppTextStyles.label.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                MyTextFormField(
                  controller: expiryCtrl,
                  readOnly: true,
                  onTap: pickExpiry,
                  leading: const Icon(Iconsax.calendar_1,
                      size: 18, color: AppColors.textMuted),
                  validator: (_) => showExpiryError
                      ? 'Select a future effective expiry date.'
                      : null,
                ),
                if (showExpiryError) ...[
                  const SizedBox(height: 4),
                  Text('Select a future effective expiry date.',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.danger)),
                ],
                const SizedBox(height: 6),
                Text(
                  'Approval may restore a location disabled by expiry. It will not undo an administrator revocation.',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 16),
                Text('Decision reason (required to reject)',
                    style: AppTextStyles.label.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                MyTextFormField(
                  controller: reasonCtrl,
                  hintText: 'Explain why the request is being rejected',
                  maxLines: 3,
                ),
                if (showReasonError) ...[
                  const SizedBox(height: 4),
                  Text('A reason is required to reject this request.',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.danger)),
                ],
                const SizedBox(height: 10),
                Text(
                  'A rejection does not deactivate the current location. It remains usable until its expiry unless an administrator revokes it.',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            actions: [
              MyOutlinedButton(
                child: 'Cancel',
                height: 44,
                onTap: () => Navigator.pop(dialogContext),
                textColor: AppColors.textSecondary,
                borderColor: AppColors.borderStrong,
              ),
              PermissionGate(
                require: Perms.workLocationsRejectExtension,
                child: MyOutlinedButton(
                  child: 'Reject',
                  height: 44,
                  textColor: AppColors.danger,
                  borderColor: AppColors.danger,
                  onTap: () {
                    if (reasonCtrl.text.trim().isEmpty) {
                      setDialogState(() => showReasonError = true);
                      return;
                    }
                    Navigator.pop(dialogContext, 'reject');
                  },
                ),
              ),
              PermissionGate(
                require: Perms.workLocationsApproveExtension,
                child: MyElevatedButton(
                  height: 44,
                  child: 'Approve',
                  onTap: () {
                    final expiry = _tryParseDate(expiryIso ?? '');
                    if (expiry == null || !expiry.isAfter(DateTime.now())) {
                      setDialogState(() => showExpiryError = true);
                      return;
                    }
                    Navigator.pop(dialogContext, 'approve');
                  },
                ),
              ),
            ],
          );
        },
      ),
    );

    if (decision == null || !context.mounted) return;
    final approved = decision == 'approve';
    final ok = await ctrl.reviewExtension(
      request.id,
      approve: approved,
      expiresAt: approved ? expiryIso : null,
      reason: approved ? null : reasonCtrl.text.trim(),
    );
    if (!context.mounted) return;
    AppToast.info(
      context,
      ok ? ctrl.successMessage.value : ctrl.errorMessage.value,
    );
  }

  Widget _reviewDetail(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            SizedBox(
              width: 140,
              child: Text(label,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textSecondary)),
            ),
            Expanded(
              child: Text(value,
                  style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );

  static String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'Permanent';
    try {
      final date = DateTime.parse(raw).toLocal();
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return raw;
    }
  }

  static DateTime? _tryParseDate(String raw) {
    try {
      return DateTime.parse(raw).toLocal();
    } catch (_) {
      return null;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Toolbar
// ═══════════════════════════════════════════════════════════════════════

class _ApprovalsToolbar extends StatelessWidget {
  final WorkspaceApprovalsController ctrl;
  const _ApprovalsToolbar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: MyTextFormField(
        hintText: 'Search by name, employee, branch, or reason',
        height: 48,
        leading: const Icon(Iconsax.search_normal,
            size: 18, color: AppColors.textMuted),
        onChanged: (v) => ctrl.searchQuery.value = v,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Table
// ═══════════════════════════════════════════════════════════════════════

class _ApprovalsTable extends StatelessWidget {
  final List<WorkspaceConfig> rows;
  final WorkspaceApprovalsController ctrl;
  const _ApprovalsTable({required this.rows, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: rows.map((w) => _buildMobileCard(context, w)).toList(),
      ),
    );
  }

  Widget _buildMobileCard(BuildContext context, WorkspaceConfig w) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.sm,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusChip(
                label: w.lifecycleLabel,
                tone: _lifecycleTone(w),
                icon: _statusIcon(w.status),
                dense: true,
              ),
              Text(
                _formatDate(w.createdAt),
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            w.employeeName ?? 'Employee #${w.employeeId ?? '—'}',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (w.branchName != null && w.branchName!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              w.branchName!,
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Iconsax.building,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  w.workspaceName,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (w.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                w.notes,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Iconsax.gps, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    _prettyType(w.locationType),
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•  ${w.radiusMeters}m',
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              Text(
                '${w.latitude.toStringAsFixed(4)}, ${w.longitude.toStringAsFixed(4)}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 12),
          _buildActions(context, w),
        ],
      ),
    );
  }

  /// Mutations preserve the record; removal from service is an auditable
  /// deactivation rather than a normal hard-delete action.
  Widget _buildActions(BuildContext context, WorkspaceConfig w) {
    if (w.status == WorkspaceStatus.pending) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PermissionGate(
            require: Perms.workLocationsApprove,
            child: Obx(() => MyElevatedButton(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  bgColor: AppColors.primary,
                  icon: const Icon(Iconsax.tick_circle,
                      size: 16, color: AppColors.textOnPrimary),
                  child: 'Approve',
                  disable: ctrl.isMutating.value,
                  onTap: () => _openApproveDialog(context, w),
                )),
          ),
          const SizedBox(width: 8),
          PermissionGate(
            require: Perms.workLocationsReject,
            child: Obx(() => OutlinedButton.icon(
                  onPressed: ctrl.isMutating.value
                      ? null
                      : () => _openRejectDialog(context, w),
                  icon: const Icon(Iconsax.close_circle,
                      size: 16, color: AppColors.danger),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: const RoundedRectangleBorder(
                        borderRadius: AppRadii.brMd),
                  ),
                )),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (w.id != null)
          PermissionGate(
            require: Perms.workLocationsView,
            child: OutlinedButton.icon(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => WorkLocationRecordDialog(locationId: w.id!),
              ),
              icon: const Icon(Iconsax.document_text,
                  size: 16, color: AppColors.textPrimary),
              label: const Text('Record'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.borderStrong),
                minimumSize: const Size(0, 42),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape:
                    const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
              ),
            ),
          ),
        if (w.status == WorkspaceStatus.approved) ...[
          PermissionGate(
            require: Perms.workLocationsManage,
            child: Obx(() => OutlinedButton.icon(
                  onPressed: ctrl.isMutating.value
                      ? null
                      : () => _openEditDialog(context, w),
                  icon: const Icon(Iconsax.edit,
                      size: 16, color: AppColors.textPrimary),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.borderStrong),
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: const RoundedRectangleBorder(
                        borderRadius: AppRadii.brMd),
                  ),
                )),
          ),
          if (w.isActive)
            PermissionGate(
              require: Perms.workLocationsManage,
              child: Obx(() => OutlinedButton.icon(
                    onPressed: ctrl.isMutating.value
                        ? null
                        : () => _openDeactivateDialog(context, w),
                    icon: const Icon(Iconsax.location_slash,
                        size: 16, color: AppColors.danger),
                    label: const Text('Revoke'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      minimumSize: const Size(0, 42),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: const RoundedRectangleBorder(
                          borderRadius: AppRadii.brMd),
                    ),
                  )),
            )
          else if (!w.isExpired)
            PermissionGate(
              require: Perms.workLocationsManage,
              child: Obx(() => OutlinedButton.icon(
                    onPressed: ctrl.isMutating.value
                        ? null
                        : () => _openReactivateDialog(context, w),
                    icon: const Icon(Iconsax.refresh,
                        size: 16, color: AppColors.success),
                    label: const Text('Reactivate'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: const BorderSide(color: AppColors.success),
                      minimumSize: const Size(0, 42),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: const RoundedRectangleBorder(
                          borderRadius: AppRadii.brMd),
                    ),
                  )),
            ),
        ],
      ],
    );
  }

  static String _prettyType(String raw) {
    if (raw.isEmpty) return '—';
    return raw
        .split('_')
        .map((s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1))
        .join(' ');
  }

  static String _formatDate(String? raw) {
    if (raw == null) return '—';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final d = '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      final t = '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
      return '$d\n$t';
    } catch (_) {
      return raw;
    }
  }

  static StatusTone _lifecycleTone(WorkspaceConfig w) {
    switch (w.lifecycleLabel) {
      case 'Active':
        return StatusTone.success;
      case 'Pending approval':
        return StatusTone.warning;
      case 'Rejected':
      case 'Expired':
      case 'Revoked':
        return StatusTone.danger;
      default:
        return StatusTone.neutral;
    }
  }

  static IconData _statusIcon(WorkspaceStatus s) {
    switch (s) {
      case WorkspaceStatus.approved:
        return Iconsax.tick_circle;
      case WorkspaceStatus.pending:
        return Iconsax.timer;
      case WorkspaceStatus.rejected:
        return Iconsax.close_circle;
      case WorkspaceStatus.unknown:
        return Iconsax.info_circle;
    }
  }

  // ── Dialogs ───────────────────────────────────────────────────────

  Future<void> _openApproveDialog(
      BuildContext context, WorkspaceConfig w) async {
    final radiusCtrl = TextEditingController(
      text: (w.radiusMeters > 0 ? w.radiusMeters : 100).toString(),
    );
    final expiryCtrl = TextEditingController(
      text: w.expiresAt == null ? '' : _formatDate(w.expiresAt),
    );
    String? effectiveExpiry = w.expiresAt;
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) {
        Future<void> pickExpiry() async {
          final initial = _tryParseDate(effectiveExpiry ?? '') ??
              DateTime.now().add(const Duration(days: 30));
          final picked = await showDatePopover(
            ctx,
            initialDate: initial,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
          );
          if (picked == null) return;
          final endOfDay = DateTime(
            picked.year,
            picked.month,
            picked.day,
            23,
            59,
            59,
          );
          setDialogState(() {
            effectiveExpiry = endOfDay.toUtc().toIso8601String();
            expiryCtrl.text = _formatDate(effectiveExpiry);
          });
        }

        return DialogScaffold(
          title: 'Approve workspace?',
          subtitle: 'Approving "${w.workspaceName}" will let '
              '${w.employeeName ?? 'this employee'} clock in when inside the '
              'geofence.',
          size: DialogSize.sm,
          body: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Allowed radius (meters)',
                    style: AppTextStyles.label.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                MyTextFormField(
                  controller: radiusCtrl,
                  keyboardType: TextInputType.number,
                  hintText: '100',
                  validator: _radiusValidator,
                ),
                const SizedBox(height: 6),
                Text(
                  'Employees can only clock in when inside this radius.',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 18),
                Text('Effective expiry',
                    style: AppTextStyles.label.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: MyTextFormField(
                        controller: expiryCtrl,
                        readOnly: true,
                        onTap: pickExpiry,
                        hintText: 'Permanent / no expiry',
                        leading: const Icon(Iconsax.calendar_1,
                            size: 18, color: AppColors.textMuted),
                        validator: (_) => w.isExpired && effectiveExpiry == null
                            ? 'Set a future expiry to approve an expired location'
                            : null,
                      ),
                    ),
                    if (effectiveExpiry != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Clear expiry',
                        onPressed: () => setDialogState(() {
                          effectiveExpiry = null;
                          expiryCtrl.clear();
                        }),
                        icon: const Icon(Iconsax.close_circle, size: 18),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'The requested expiry is prefilled. Set a different date, or leave blank for a permanent location.',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          actions: [
            MyOutlinedButton(
              child: 'Cancel',
              height: 44,
              textColor: AppColors.textSecondary,
              borderColor: AppColors.borderStrong,
              onTap: () => Navigator.pop(ctx, false),
            ),
            MyElevatedButton(
              height: 44,
              bgColor: AppColors.primary,
              child: 'Approve',
              onTap: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx, true);
                }
              },
            ),
          ],
        );
      }),
    );

    if (confirmed != true || !context.mounted) return;
    final radius = int.tryParse(radiusCtrl.text.trim());
    final ok = await ctrl.approve(
      w.id!,
      allowedRadiusMeters: radius,
      expiresAt: effectiveExpiry,
      clearExpiry: effectiveExpiry == null && w.expiresAt != null,
    );
    if (!context.mounted) return;
    _snack(context, ok);
  }

  Future<void> _openRejectDialog(
      BuildContext context, WorkspaceConfig w) async {
    final reasonCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => DialogScaffold(
        title: 'Reject workspace?',
        subtitle: 'Rejecting "${w.workspaceName}". The employee will see your '
            'reason and can then delete and resubmit.',
        size: DialogSize.sm,
        body: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reason *',
                  style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              MyTextFormField(
                controller: reasonCtrl,
                hintText: 'e.g., Location is outside company premises',
                maxLines: 4,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'A reason is required'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          MyOutlinedButton(
            child: 'Cancel',
            height: 44,
            textColor: AppColors.textSecondary,
            borderColor: AppColors.borderStrong,
            onTap: () => Navigator.pop(ctx, false),
          ),
          MyElevatedButton(
            height: 44,
            bgColor: AppColors.danger,
            child: 'Reject',
            onTap: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(ctx, true);
              }
            },
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    final ok = await ctrl.reject(w.id!, reason: reasonCtrl.text.trim());
    if (!context.mounted) return;
    _snack(context, ok);
  }

  /// Edit an already-approved location. Only fields the admin actually
  /// touches (initialValue ≠ submitted value) are sent on PATCH.
  Future<void> _openEditDialog(BuildContext context, WorkspaceConfig w) async {
    final nameCtrl = TextEditingController(text: w.workspaceName);
    final radiusCtrl = TextEditingController(text: '${w.radiusMeters}');
    final notesCtrl = TextEditingController(text: w.notes);
    final expiryCtrl = TextEditingController(text: w.expiresAt ?? '');
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<_EditResult>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        Future<void> pickExpiry() async {
          final initial = _tryParseDate(expiryCtrl.text) ??
              DateTime.now().add(const Duration(days: 30));
          final picked = await showDatePopover(
            context,
            initialDate: initial,
            firstDate: DateTime.now().subtract(const Duration(days: 1)),
            lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
          );
          if (picked != null) {
            // Backend expects ISO-8601; use end-of-day so the admin's
            // picked date stays valid through the full local day.
            final iso = DateTime(
              picked.year,
              picked.month,
              picked.day,
              23,
              59,
              59,
            ).toUtc().toIso8601String();
            setState(() => expiryCtrl.text = iso);
          }
        }

        return DialogScaffold(
          title: 'Edit workspace',
          subtitle:
              'Editing "${w.workspaceName}". Leave a field unchanged if you '
              "don't want to touch it.",
          size: DialogSize.md,
          body: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _fieldLabel('Name'),
                const SizedBox(height: 8),
                MyTextFormField(
                  controller: nameCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name cannot be empty'
                      : null,
                ),
                const SizedBox(height: 16),
                _fieldLabel('Allowed radius (meters)'),
                const SizedBox(height: 8),
                MyTextFormField(
                  controller: radiusCtrl,
                  keyboardType: TextInputType.number,
                  validator: _radiusValidator,
                ),
                const SizedBox(height: 16),
                _fieldLabel('Expires at'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: MyTextFormField(
                        controller: expiryCtrl,
                        readOnly: true,
                        onTap: pickExpiry,
                        hintText: 'No expiry set',
                        leading: const Icon(
                          Iconsax.calendar_1,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    if (expiryCtrl.text.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Clear expiry',
                        icon: const Icon(Iconsax.close_circle, size: 18),
                        onPressed: () => setState(() => expiryCtrl.text = ''),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                _fieldLabel('Notes'),
                const SizedBox(height: 8),
                MyTextFormField(
                  controller: notesCtrl,
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            MyOutlinedButton(
              child: 'Cancel',
              height: 44,
              textColor: AppColors.textSecondary,
              borderColor: AppColors.borderStrong,
              onTap: () => Navigator.pop(ctx, null),
            ),
            MyElevatedButton(
              height: 44,
              child: 'Save',
              onTap: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                Navigator.pop(
                  ctx,
                  _EditResult(
                    name: nameCtrl.text.trim(),
                    radius: int.tryParse(radiusCtrl.text.trim()),
                    expiresAt: expiryCtrl.text.trim().isEmpty
                        ? null
                        : expiryCtrl.text.trim(),
                    clearExpiry:
                        expiryCtrl.text.trim().isEmpty && w.expiresAt != null,
                    notes: notesCtrl.text.trim(),
                  ),
                );
              },
            ),
          ],
        );
      }),
    );

    if (result == null || !context.mounted) return;

    // Only include fields that actually changed to keep the PATCH payload
    // minimal and avoid clobbering server-side defaults.
    final ok = await ctrl.adminUpdate(
      w.id!,
      name: result.name != w.workspaceName ? result.name : null,
      allowedRadiusMeters:
          result.radius != null && result.radius != w.radiusMeters
              ? result.radius
              : null,
      expiresAt: result.expiresAt != w.expiresAt ? result.expiresAt : null,
      clearExpiry: result.clearExpiry,
      notes: result.notes != w.notes ? result.notes : null,
    );
    if (!context.mounted) return;
    _snack(context, ok);
  }

  Future<void> _openDeactivateDialog(
      BuildContext context, WorkspaceConfig w) async {
    final reasonCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => DialogScaffold(
        title: 'Revoke this work location?',
        subtitle:
            'The location record and its history will be retained. The employee will no longer be able to use it for attendance.',
        size: DialogSize.sm,
        body: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reason for revocation',
                  style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              MyTextFormField(
                controller: reasonCtrl,
                hintText: 'Enter a reason for the employee record',
                maxLines: 4,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'A reason is required'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          MyOutlinedButton(
            child: 'Cancel',
            height: 44,
            textColor: AppColors.textSecondary,
            borderColor: AppColors.borderStrong,
            onTap: () => Navigator.pop(ctx, false),
          ),
          MyElevatedButton(
              height: 44,
              bgColor: AppColors.danger,
              child: 'Revoke',
              onTap: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx, true);
                }
              }),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final ok = await ctrl.adminUpdate(
      w.id!,
      isActive: false,
      reason: reasonCtrl.text.trim(),
    );
    if (!context.mounted) return;
    _snack(context, ok);
  }

  Future<void> _openReactivateDialog(
      BuildContext context, WorkspaceConfig w) async {
    final confirmed = await DialogScaffold.show<bool>(
      context,
      title: 'Reactivate work location?',
      subtitle:
          'This will allow ${w.employeeName ?? 'the employee'} to use it again if it has not expired and its branch remains active.',
      size: DialogSize.sm,
      body: Text(
        'The original deactivation remains in the audit history.',
        style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          onTap: () => Navigator.pop(context, false),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        MyElevatedButton(
          height: 44,
          child: 'Reactivate',
          onTap: () => Navigator.pop(context, true),
        ),
      ],
    );
    if (confirmed != true || !context.mounted) return;
    final ok = await ctrl.adminUpdate(w.id!, isActive: true);
    if (!context.mounted) return;
    _snack(context, ok);
  }

  // ── Shared dialog bits ────────────────────────────────────────────

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.label.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String? _radiusValidator(String? v) {
    final n = int.tryParse(v?.trim() ?? '');
    if (n == null || n <= 0) return 'Enter a positive number';
    if (n > 5000) return 'Radius cannot exceed 5000m';
    return null;
  }

  DateTime? _tryParseDate(String raw) {
    try {
      return DateTime.parse(raw).toLocal();
    } catch (_) {
      return null;
    }
  }

  void _snack(BuildContext context, bool ok) {
    AppToast.info(
      context,
      ok ? ctrl.successMessage.value : ctrl.errorMessage.value,
    );
  }
}

/// Result carrier for the edit dialog — kept out of the controller so the
/// dialog can pop with a value only when the admin actually hit Save.
class _EditResult {
  final String name;
  final int? radius;
  final String? expiresAt;
  final bool clearExpiry;
  final String notes;
  _EditResult({
    required this.name,
    required this.radius,
    required this.expiresAt,
    required this.clearExpiry,
    required this.notes,
  });
}
