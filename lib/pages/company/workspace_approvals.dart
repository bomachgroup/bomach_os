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
/// Lists every PENDING submission from `GET /biometric/location/pending`
/// and lets the admin approve (with optional radius override) or reject
/// (reason required). The page does NOT try to show historical approved
/// or rejected submissions — those are already visible on each employee's
/// attendance page, and the backend has no cross-status admin list that
/// would make a tabbed view cheap.
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

          ResponsiveSubheader(
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText('Pending Submissions', style: AppText.black_600_16),
                SizedBox(height: 2),
                Text(
                  'Awaiting admin decision',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
              ],
            ),
            search: MyTextFormField(
              hintText: 'Search by name, employee, or branch',
              leading: const Icon(Icons.search, color: Colors.grey, size: 20),
              onChanged: (v) => ctrl.searchQuery.value = v,
            ),
            action: OutlinedButton.icon(
              onPressed: ctrl.fetchPending,
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
            if (ctrl.isLoading.value && ctrl.pending.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(60),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final rows = ctrl.filteredPending;
            if (rows.isEmpty) return const _EmptyState();
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
      final total = ctrl.pending.length;
      final uniqueEmployees =
          ctrl.pending.map((w) => w.employeeId).whereType<int>().toSet().length;
      // Oldest pending: useful pressure metric for admins.
      final oldest = ctrl.pending
          .map((w) => _tryParse(w.createdAt))
          .whereType<DateTime>()
          .fold<DateTime?>(null, (a, b) => a == null || b.isBefore(a) ? b : a);
      final oldestLabel = oldest == null
          ? '–'
          : _daysAgoLabel(DateTime.now().difference(oldest));

      return ResponsiveStatRow(
        cards: [
          DashboardStatCard(
            title: 'Pending Reviews',
            count: '$total',
            borderColor: const Color(0xFFC27803),
            countColor: const Color(0xFFC27803),
          ),
          DashboardStatCard(
            title: 'Employees Waiting',
            count: '$uniqueEmployees',
            borderColor: AppColors.blue,
            countColor: AppColors.blue,
          ),
          DashboardStatCard(
            title: 'Oldest Pending',
            count: oldestLabel,
            borderColor: const Color(0xFFDC2626),
            countColor: const Color(0xFFDC2626),
          ),
        ],
      );
    });
  }

  static DateTime? _tryParse(String? raw) {
    if (raw == null) return null;
    try {
      return DateTime.parse(raw).toLocal();
    } catch (_) {
      return null;
    }
  }

  static String _daysAgoLabel(Duration d) {
    if (d.inDays >= 1) return '${d.inDays}d';
    if (d.inHours >= 1) return '${d.inHours}h';
    if (d.inMinutes >= 1) return '${d.inMinutes}m';
    return 'now';
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
            DataColumn(label: Text('EMPLOYEE')),
            DataColumn(label: Text('WORKSPACE')),
            DataColumn(label: Text('TYPE')),
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
    return DataRow(cells: [
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
        '${w.latitude.toStringAsFixed(5)},\n${w.longitude.toStringAsFixed(5)}',
        style: const TextStyle(fontSize: 12, height: 1.3),
      )),
      DataCell(Text(
        _formatDate(w.createdAt),
        style: const TextStyle(fontSize: 12),
      )),
      DataCell(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PermissionGate(
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
          ),
          const SizedBox(width: 4),
          PermissionGate(
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
          ),
        ],
      )),
    ]);
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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF10B981), size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Approve workspace?'),
          ],
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
              const Text(
                'Allowed radius (meters)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
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
                validator: (v) {
                  final n = int.tryParse(v?.trim() ?? '');
                  if (n == null || n <= 0) return 'Enter a positive number';
                  if (n > 5000) return 'Radius cannot exceed 5000m';
                  return null;
                },
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        ok ? ctrl.successMessage.value : ctrl.errorMessage.value,
      ),
      backgroundColor: ok ? Colors.green : Colors.red,
    ));
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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.cancel_rounded,
                  color: Color(0xFFDC2626), size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Reject workspace?'),
          ],
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
              const Text(
                'Reason *',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        ok ? ctrl.successMessage.value : ctrl.errorMessage.value,
      ),
      backgroundColor: ok ? Colors.green : Colors.red,
    ));
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Empty state
// ═══════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
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
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox_rounded,
                color: Color(0xFF10B981), size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'All caught up',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'There are no workspace submissions awaiting review.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
