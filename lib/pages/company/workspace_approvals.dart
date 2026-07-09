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

/// Admin workspace approvals page.
///
/// Four-tab view (Pending / Approved / Rejected / All) backed by the two
/// backend endpoints that surface work locations to admins: `/pending` for
/// the Pending tab and the broad `/whitelisted` for everything else.
///
/// Actions per row depend on status:
///   - PENDING  -> Approve (with optional radius override) / Reject (reason).
///   - APPROVED -> Edit (radius, expiry, active, notes) / Force delete.
///   - REJECTED -> Force delete only.
class WorkspaceApprovalsPage extends StatelessWidget {
  const WorkspaceApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(WorkspaceApprovalsController());

    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Workspace Approvals',
        subtitle:
            'Review employee-submitted work locations. Approve to enable '
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
          final loading = ctrl.isLoading.value && ctrl.submissions.isEmpty;
          final rows = ctrl.filtered;
          final isEmpty = !loading && rows.isEmpty;

          return _buildTableCard(
            loading: loading,
            isEmpty: isEmpty,
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
      case ApprovalsView.rejected:
        return '$count rejected submission$labelSuffix';
      case ApprovalsView.all:
        return '$count work location$labelSuffix on record';
    }
  }

  Widget _buildTableCard({
    required bool loading,
    required bool isEmpty,
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
      case ApprovalsView.rejected:
        return const EmptyState(
          icon: Iconsax.tick_circle,
          title: 'No rejections',
          subtitle:
              'Nothing has been rejected — or employees have cleaned up.',
        );
      case ApprovalsView.all:
        return const EmptyState(
          icon: Iconsax.location,
          title: 'No work locations yet',
          subtitle:
              'Once employees submit workspaces they will show up here.',
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primarySubtle
                        : AppColors.surface,
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
    return ctrl.submissions.length;
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
        hintText: 'Search by name, employee, or branch',
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
                label: w.status.label,
                tone: _statusTone(w.status),
                icon: _statusIcon(w.status),
                dense: true,
              ),
              Text(
                _formatDate(w.createdAt),
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
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
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Iconsax.building, size: 14, color: AppColors.textMuted),
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
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
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
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•  ${w.radiusMeters}m',
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
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



  /// Actions depend on status: pending gets approve/reject, approved gets
  /// edit + force-delete, rejected gets force-delete only.
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
                  bgColor: AppColors.success,
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

    // Approved or rejected row.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (w.status == WorkspaceStatus.approved) ...[
          PermissionGate(
            require: Perms.workLocationsUpdate,
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
          const SizedBox(width: 8),
        ],
        PermissionGate(
          require: Perms.workLocationsDelete,
          child: Obx(() => IconButton(
                tooltip: 'Delete',
                onPressed: ctrl.isMutating.value
                    ? null
                    : () => _openForceDeleteDialog(context, w),
                icon: const Icon(Iconsax.trash,
                    size: 18, color: AppColors.danger),
                style: IconButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.brMd,
                    side: BorderSide(color: AppColors.borderSubtle),
                  ),
                  minimumSize: const Size(42, 42),
                ),
              )),
        ),
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

  static StatusTone _statusTone(WorkspaceStatus s) {
    switch (s) {
      case WorkspaceStatus.approved:
        return StatusTone.success;
      case WorkspaceStatus.pending:
        return StatusTone.warning;
      case WorkspaceStatus.rejected:
        return StatusTone.danger;
      case WorkspaceStatus.unknown:
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
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => DialogScaffold(
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
                style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
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
            bgColor: AppColors.success,
            child: 'Approve',
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
    final radius = int.tryParse(radiusCtrl.text.trim());
    final ok = await ctrl.approve(w.id!, allowedRadiusMeters: radius);
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
  Future<void> _openEditDialog(
      BuildContext context, WorkspaceConfig w) async {
    final nameCtrl = TextEditingController(text: w.workspaceName);
    final radiusCtrl = TextEditingController(text: '${w.radiusMeters}');
    final notesCtrl = TextEditingController(text: w.notes);
    final expiryCtrl = TextEditingController(text: w.expiresAt ?? '');
    bool isActive = w.isActive;
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
                        onPressed: () =>
                            setState(() => expiryCtrl.text = ''),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: AppRadii.brMd,
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Active',
                                style: AppTextStyles.bodyMd.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text(
                              'When off, employees cannot clock in from this '
                              'location even though it stays APPROVED.',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Switch(
                        value: isActive,
                        onChanged: (v) => setState(() => isActive = v),
                      ),
                    ],
                  ),
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
                    isActive: isActive,
                    expiresAt: expiryCtrl.text.trim().isEmpty
                        ? null
                        : expiryCtrl.text.trim(),
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
      isActive: result.isActive != w.isActive ? result.isActive : null,
      expiresAt: result.expiresAt != w.expiresAt ? result.expiresAt : null,
      notes: result.notes != w.notes ? result.notes : null,
    );
    if (!context.mounted) return;
    _snack(context, ok);
  }

  Future<void> _openForceDeleteDialog(
      BuildContext context, WorkspaceConfig w) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => DialogScaffold(
        title: 'Delete workspace?',
        subtitle: 'Permanently remove "${w.workspaceName}" owned by '
            '${w.employeeName ?? 'this employee'}. This cannot be undone. '
            'The employee will need to submit a new workspace if they want '
            'to clock in.',
        size: DialogSize.sm,
        body: const SizedBox.shrink(),
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
            child: 'Delete',
            onTap: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final ok = await ctrl.forceDelete(w.id!);
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
  final bool isActive;
  final String? expiresAt;
  final String notes;
  _EditResult({
    required this.name,
    required this.radius,
    required this.isActive,
    required this.expiresAt,
    required this.notes,
  });
}
