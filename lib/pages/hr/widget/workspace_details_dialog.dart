import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/biometrics_controller.dart';
import '../models/workspace_model.dart';

/// Read-only view of a single workspace submission. No edit affordance —
/// per product rules, workspaces are view-only after submission. The only
/// mutation available here is **Delete**, which is allowed at any status.
class WorkspaceDetailsDialog extends StatelessWidget {
  final String token;
  final WorkspaceConfig workspace;
  const WorkspaceDetailsDialog({
    super.key,
    required this.token,
    required this.workspace,
  });

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusBg, statusIcon) = _statusStyles(workspace.status);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 620),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.location_on_rounded,
                          color: AppColors.blue, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const MyText(
                      'Workspace Details',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24),

            // Body
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          const SizedBox(width: 6),
                          Text(
                            workspace.status.label.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name
                    Text(
                      workspace.workspaceName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (workspace.branchName != null &&
                        workspace.branchName!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        workspace.branchName!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Fields
                    _kv('Coordinates',
                        '${workspace.latitude.toStringAsFixed(6)}, '
                            '${workspace.longitude.toStringAsFixed(6)}'),
                    if (workspace.createdAt != null)
                      _kv('Submitted', _formatDate(workspace.createdAt!)),
                    if (workspace.status == WorkspaceStatus.approved) ...[
                      if (workspace.verifiedByName != null)
                        _kv('Approved by', workspace.verifiedByName!),
                      if (workspace.verifiedAt != null)
                        _kv('Approved at', _formatDate(workspace.verifiedAt!)),
                      if (workspace.expiresAt != null)
                        _kv('Expires', _formatDate(workspace.expiresAt!)),
                    ],
                    if (workspace.status == WorkspaceStatus.rejected &&
                        workspace.rejectionReason != null &&
                        workspace.rejectionReason!.isNotEmpty)
                      _kv('Rejection reason', workspace.rejectionReason!,
                          valueColor: const Color(0xFFDC2626)),
                    if (workspace.notes.isNotEmpty)
                      _kv('Notes', workspace.notes),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Actions
            Obx(() {
              final deleting = Get.find<BiometricsController>()
                  .isDeletingWorkspace
                  .value;
              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          deleting ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          deleting ? null : () => _confirmDelete(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFDC2626)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: deleting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFDC2626),
                              ),
                            )
                          : const Icon(Icons.delete_outline, size: 18),
                      label: const Text(
                        'Delete',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete workspace?'),
        content: Text(
          'Remove "${workspace.workspaceName}" from your submissions? '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (workspace.id == null) return;

    final controller = Get.find<BiometricsController>();
    final success = await controller.deleteWorkspace(token, workspace.id!);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success
          ? controller.successMessage.value
          : controller.errorMessage.value),
      backgroundColor: success ? Colors.green : Colors.red,
    ));
  }

  (Color, Color, IconData) _statusStyles(WorkspaceStatus s) {
    switch (s) {
      case WorkspaceStatus.approved:
        return (
          const Color(0xFF10B981),
          const Color(0xFF10B981).withValues(alpha: 0.1),
          Icons.check_circle_rounded,
        );
      case WorkspaceStatus.pending:
        return (
          const Color(0xFFF59E0B),
          const Color(0xFFF59E0B).withValues(alpha: 0.1),
          Icons.hourglass_top_rounded,
        );
      case WorkspaceStatus.rejected:
        return (
          const Color(0xFFEF4444),
          const Color(0xFFEF4444).withValues(alpha: 0.1),
          Icons.cancel_rounded,
        );
      case WorkspaceStatus.unknown:
        return (
          const Color(0xFF64748B),
          const Color(0xFF64748B).withValues(alpha: 0.1),
          Icons.help_outline_rounded,
        );
    }
  }

  Widget _kv(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? const Color(0xFF0F172A),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final d = '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      final t = '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
      return '$d, $t';
    } catch (_) {
      return raw;
    }
  }
}
