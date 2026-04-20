import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/permission/permission_gate.dart';
import 'package:bms_front_end/components/section/responsive_widget.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/company/company.dart'
    show DashboardStatCard, ResponsiveStatRow, ResponsiveSubheader;
import 'package:bms_front_end/pages/hr/models/workspace_model.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/permissions.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/workspace_approvals_controller.dart';

/// Admin workspace approvals page.
///
/// Four-tab view (Pending / Approved / Rejected / All) backed by the two
/// backend endpoints that surface work locations to admins: `/pending` for
/// the Pending tab and the broad `/whitelisted` for everything else.
///
/// Actions per row depend on status:
///   - PENDING → Approve (with optional radius override) / Reject (reason).
///   - APPROVED → Edit (radius, expiry, active, notes) / Force delete.
///   - REJECTED → Force delete only.
class WorkspaceApprovalsPage extends StatelessWidget {
  const WorkspaceApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(WorkspaceApprovalsController());

    final body = SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText('Workspace Approvals', style: AppText.black_600_32),
          const SizedBox(height: 8),
          const Text(
            'Review employee-submitted work locations. Approve to enable '
            'clock-in, or reject with a reason the employee will see.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
          const SizedBox(height: 24),

          _StatsSection(ctrl: ctrl),
          const SizedBox(height: 24),

          _ViewTabs(ctrl: ctrl),
          const SizedBox(height: 16),

          ResponsiveSubheader(
            title: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      _titleForView(ctrl.view.value),
                      style: AppText.black_600_16,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitleForView(ctrl.view.value),
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 13),
                    ),
                  ],
                )),
            search: MyTextFormField(
              hintText: 'Search by name, employee, or branch',
              leading:
                  const Icon(Icons.search, color: Colors.grey, size: 20),
              onChanged: (v) => ctrl.searchQuery.value = v,
            ),
            action: OutlinedButton.icon(
              onPressed: ctrl.fetch,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Refresh'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Obx(() {
            if (ctrl.isLoading.value && ctrl.submissions.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(60),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final rows = ctrl.filtered;
            if (rows.isEmpty) return _EmptyState(view: ctrl.view.value);
            return _ApprovalsTable(rows: rows, ctrl: ctrl);
          }),
        ],
      ),
    );

    return ResponsiveWidget(
      largeScreen: body,
      mediumScreen: body,
      smallScreen: body,
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

  static String _subtitleForView(ApprovalsView v) {
    switch (v) {
      case ApprovalsView.pending:
        return 'Awaiting admin decision';
      case ApprovalsView.approved:
        return 'Active geofences across the org';
      case ApprovalsView.rejected:
        return 'Employees can delete and resubmit these';
      case ApprovalsView.all:
        return 'Every submitted work location, any status';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Tabs
// ═══════════════════════════════════════════════════════════════════════

class _ViewTabs extends StatelessWidget {
  final WorkspaceApprovalsController ctrl;
  const _ViewTabs({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: ApprovalsView.values.map((v) {
            final selected = ctrl.view.value == v;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                onTap: () => ctrl.setView(v),
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color:
                                  Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    v.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Stats
// ═══════════════════════════════════════════════════════════════════════

class _StatsSection extends StatelessWidget {
  final WorkspaceApprovalsController ctrl;
  const _StatsSection({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = ctrl.submissions;
      final total = list.length;
      final approved = list
          .where((w) => w.status == WorkspaceStatus.approved)
          .length;
      final pending = list
          .where((w) => w.status == WorkspaceStatus.pending)
          .length;
      final rejected = list
          .where((w) => w.status == WorkspaceStatus.rejected)
          .length;

      // In Pending view, stats are pending-specific; otherwise they show
      // the mix across the broader list.
      final cards = ctrl.view.value == ApprovalsView.pending
          ? <DashboardStatCard>[
              DashboardStatCard(
                title: 'Pending Reviews',
                count: '$total',
                borderColor: const Color(0xFFC27803),
                countColor: const Color(0xFFC27803),
              ),
              DashboardStatCard(
                title: 'Employees Waiting',
                count: '${_uniqueEmployees(list)}',
                borderColor: AppColors.blue,
                countColor: AppColors.blue,
              ),
              DashboardStatCard(
                title: 'Oldest Pending',
                count: _oldestLabel(list),
                borderColor: const Color(0xFFDC2626),
                countColor: const Color(0xFFDC2626),
              ),
            ]
          : <DashboardStatCard>[
              DashboardStatCard(
                title: 'Approved',
                count: '$approved',
                borderColor: const Color(0xFF10B981),
                countColor: const Color(0xFF10B981),
              ),
              DashboardStatCard(
                title: 'Pending',
                count: '$pending',
                borderColor: const Color(0xFFC27803),
                countColor: const Color(0xFFC27803),
              ),
              DashboardStatCard(
                title: 'Rejected',
                count: '$rejected',
                borderColor: const Color(0xFFDC2626),
                countColor: const Color(0xFFDC2626),
              ),
              DashboardStatCard(
                title: 'Total',
                count: '$total',
                borderColor: AppColors.blue,
                countColor: AppColors.blue,
              ),
            ];

      return ResponsiveStatRow(cards: cards);
    });
  }

  static int _uniqueEmployees(List<WorkspaceConfig> list) =>
      list.map((w) => w.employeeId).whereType<int>().toSet().length;

  static String _oldestLabel(List<WorkspaceConfig> list) {
    final oldest = list
        .map((w) => _tryParse(w.createdAt))
        .whereType<DateTime>()
        .fold<DateTime?>(null, (a, b) => a == null || b.isBefore(a) ? b : a);
    if (oldest == null) return '–';
    final d = DateTime.now().difference(oldest);
    if (d.inDays >= 1) return '${d.inDays}d';
    if (d.inHours >= 1) return '${d.inHours}h';
    if (d.inMinutes >= 1) return '${d.inMinutes}m';
    return 'now';
  }

  static DateTime? _tryParse(String? raw) {
    if (raw == null) return null;
    try {
      return DateTime.parse(raw).toLocal();
    } catch (_) {
      return null;
    }
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF475569),
            fontSize: 12,
            letterSpacing: 0.5,
          ),
          headingRowColor:
              WidgetStateProperty.all(const Color(0xFFF8FAFC)),
          dataRowMinHeight: 56,
          dataRowMaxHeight: 68,
          columnSpacing: 28,
          columns: const [
            DataColumn(label: Text('STATUS')),
            DataColumn(label: Text('EMPLOYEE')),
            DataColumn(label: Text('WORKSPACE')),
            DataColumn(label: Text('TYPE')),
            DataColumn(label: Text('RADIUS')),
            DataColumn(label: Text('COORDINATES')),
            DataColumn(label: Text('SUBMITTED')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: rows.map((w) => _buildRow(context, w)).toList(),
        ),
      ),
    );
  }

  DataRow _buildRow(BuildContext context, WorkspaceConfig w) {
    final (statusColor, statusBg, statusIcon) = _statusStyles(w.status);
    return DataRow(cells: [
      DataCell(Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: statusBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, size: 11, color: statusColor),
            const SizedBox(width: 5),
            Text(
              w.status.label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: statusColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      )),
      DataCell(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            w.employeeName ?? 'Employee #${w.employeeId ?? '—'}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
              fontSize: 13,
            ),
          ),
          if (w.branchName != null && w.branchName!.isNotEmpty)
            Text(
              w.branchName!,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
            ),
        ],
      )),
      DataCell(SizedBox(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              w.workspaceName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (w.notes.isNotEmpty)
              Text(
                w.notes,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
          ],
        ),
      )),
      DataCell(Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          _prettyType(w.locationType),
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.blue,
            fontWeight: FontWeight.w600,
          ),
        ),
      )),
      DataCell(Text(
        '${w.radiusMeters}m',
        style: const TextStyle(fontSize: 12),
      )),
      DataCell(Text(
        '${w.latitude.toStringAsFixed(5)},\n${w.longitude.toStringAsFixed(5)}',
        style: const TextStyle(fontSize: 12, height: 1.3),
      )),
      DataCell(Text(
        _formatDate(w.createdAt),
        style: const TextStyle(fontSize: 12),
      )),
      DataCell(_buildActions(context, w)),
    ]);
  }

  /// Actions depend on status: pending gets approve/reject, approved gets
  /// edit/force-delete, rejected gets force-delete only.
  Widget _buildActions(BuildContext context, WorkspaceConfig w) {
    final buttons = <Widget>[];

    if (w.status == WorkspaceStatus.pending) {
      buttons.add(PermissionGate(
        require: Perms.workLocationsApprove,
        child: Obx(() => TextButton.icon(
              onPressed: ctrl.isMutating.value
                  ? null
                  : () => _openApproveDialog(context, w),
              icon: const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF10B981), size: 16),
              label: const Text(
                'Approve',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )),
      ));
      buttons.add(const SizedBox(width: 4));
      buttons.add(PermissionGate(
        require: Perms.workLocationsReject,
        child: Obx(() => TextButton.icon(
              onPressed: ctrl.isMutating.value
                  ? null
                  : () => _openRejectDialog(context, w),
              icon: const Icon(Icons.cancel_rounded,
                  color: Color(0xFFDC2626), size: 16),
              label: const Text(
                'Reject',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )),
      ));
    } else {
      // Approved or rejected row — admin can edit (approved only) and
      // force-delete any status.
      if (w.status == WorkspaceStatus.approved) {
        buttons.add(PermissionGate(
          require: Perms.workLocationsUpdate,
          child: Obx(() => TextButton.icon(
                onPressed: ctrl.isMutating.value
                    ? null
                    : () => _openEditDialog(context, w),
                icon: const Icon(Icons.edit_rounded,
                    color: AppColors.blue, size: 16),
                label: const Text(
                  'Edit',
                  style: TextStyle(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
        ));
        buttons.add(const SizedBox(width: 4));
      }
      buttons.add(PermissionGate(
        require: Perms.workLocationsDelete,
        child: Obx(() => TextButton.icon(
              onPressed: ctrl.isMutating.value
                  ? null
                  : () => _openForceDeleteDialog(context, w),
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFDC2626), size: 16),
              label: const Text(
                'Delete',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )),
      ));
    }

    return Row(mainAxisSize: MainAxisSize.min, children: buttons);
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

  static (Color, Color, IconData) _statusStyles(WorkspaceStatus s) {
    switch (s) {
      case WorkspaceStatus.approved:
        return (
          const Color(0xFF10B981),
          const Color(0xFF10B981).withValues(alpha: 0.12),
          Icons.check_circle_rounded,
        );
      case WorkspaceStatus.pending:
        return (
          const Color(0xFFF59E0B),
          const Color(0xFFF59E0B).withValues(alpha: 0.12),
          Icons.hourglass_top_rounded,
        );
      case WorkspaceStatus.rejected:
        return (
          const Color(0xFFEF4444),
          const Color(0xFFEF4444).withValues(alpha: 0.12),
          Icons.cancel_rounded,
        );
      case WorkspaceStatus.unknown:
        return (
          const Color(0xFF64748B),
          const Color(0xFF64748B).withValues(alpha: 0.12),
          Icons.help_outline_rounded,
        );
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
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: _dialogTitle(
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF10B981),
          text: 'Approve workspace?',
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Approving "${w.workspaceName}" will let '
                '${w.employeeName ?? 'this employee'} clock in when within '
                'the geofence.',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF475569),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              _fieldLabel('Allowed radius (meters)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: radiusCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  suffixText: 'm',
                ),
                validator: _radiusValidator,
              ),
              const SizedBox(height: 6),
              const Text(
                'Employees can only clock in when inside this radius.',
                style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(ctx, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve'),
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
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: _dialogTitle(
          icon: Icons.cancel_rounded,
          color: const Color(0xFFDC2626),
          text: 'Reject workspace?',
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rejecting "${w.workspaceName}". The employee will see your '
                'reason and can then delete and resubmit.',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF475569),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              _fieldLabel('Reason *'),
              const SizedBox(height: 6),
              TextFormField(
                controller: reasonCtrl,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  hintText: 'e.g., Location is outside company premises',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'A reason is required'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(ctx, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
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
          final picked = await showDatePicker(
            context: ctx,
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

        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          title: _dialogTitle(
            icon: Icons.edit_rounded,
            color: AppColors.blue,
            text: 'Edit workspace',
          ),
          content: SizedBox(
            width: 440,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Editing "${w.workspaceName}". Leave a field unchanged '
                      "if you don't want to touch it.",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _fieldLabel('Name'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Name cannot be empty'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    _fieldLabel('Allowed radius (meters)'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: radiusCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        suffixText: 'm',
                      ),
                      validator: _radiusValidator,
                    ),
                    const SizedBox(height: 14),
                    _fieldLabel('Expires at'),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: expiryCtrl,
                            readOnly: true,
                            onTap: pickExpiry,
                            decoration: const InputDecoration(
                              hintText: 'No expiry set',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              prefixIcon:
                                  Icon(Icons.calendar_today_rounded, size: 18),
                            ),
                          ),
                        ),
                        if (expiryCtrl.text.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Clear expiry',
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () =>
                                setState(() => expiryCtrl.text = ''),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 14),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      subtitle: const Text(
                        'When off, employees cannot clock in from this '
                        'location even though it stays APPROVED.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      value: isActive,
                      onChanged: (v) => setState(() => isActive = v),
                    ),
                    const SizedBox(height: 8),
                    _fieldLabel('Notes'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: notesCtrl,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
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
      allowedRadiusMeters: result.radius != null && result.radius != w.radiusMeters
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
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: _dialogTitle(
          icon: Icons.delete_outline_rounded,
          color: const Color(0xFFDC2626),
          text: 'Delete workspace?',
        ),
        content: Text(
          'Permanently remove "${w.workspaceName}" owned by '
          '${w.employeeName ?? 'this employee'}? This cannot be undone. '
          'The employee will need to submit a new workspace if they want '
          'to clock in.',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF475569),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
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

  Widget _dialogTitle(
      {required IconData icon,
      required Color color,
      required String text}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Flexible(child: Text(text)),
      ],
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF64748B),
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        ok ? ctrl.successMessage.value : ctrl.errorMessage.value,
      ),
      backgroundColor: ok ? Colors.green : Colors.red,
    ));
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

// ═══════════════════════════════════════════════════════════════════════
//  Empty state
// ═══════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final ApprovalsView view;
  const _EmptyState({required this.view});

  @override
  Widget build(BuildContext context) {
    final (icon, title, subtitle, tint) = _copy();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: tint, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style:
                const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  (IconData, String, String, Color) _copy() {
    switch (view) {
      case ApprovalsView.pending:
        return (
          Icons.inbox_rounded,
          'All caught up',
          'There are no workspace submissions awaiting review.',
          const Color(0xFF10B981),
        );
      case ApprovalsView.approved:
        return (
          Icons.location_off_rounded,
          'No approved locations',
          'Once you approve a pending submission it will appear here.',
          AppColors.blue,
        );
      case ApprovalsView.rejected:
        return (
          Icons.check_circle_outline_rounded,
          'No rejections',
          'Nothing has been rejected — or the employees have cleaned up.',
          const Color(0xFF10B981),
        );
      case ApprovalsView.all:
        return (
          Icons.location_searching_rounded,
          'No work locations yet',
          'Once employees submit workspaces they will show up here.',
          AppColors.blue,
        );
    }
  }
}
