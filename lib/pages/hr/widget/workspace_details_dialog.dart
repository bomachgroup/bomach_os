import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

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
    return DialogScaffold(
      title: 'Workspace details',
      subtitle: workspace.workspaceName,
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryBanner(workspace),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Location',
            children: [
              _detailRow(
                'Coordinates',
                '${workspace.latitude.toStringAsFixed(6)}, '
                    '${workspace.longitude.toStringAsFixed(6)}',
              ),
              if (workspace.branchName != null &&
                  workspace.branchName!.isNotEmpty)
                _detailRow('Branch', workspace.branchName!),
              if (workspace.createdAt != null)
                _detailRow('Submitted', _formatDate(workspace.createdAt!)),
            ],
          ),
          if (workspace.status == WorkspaceStatus.approved) ...[
            const SizedBox(height: 16),
            _buildSection(
              title: 'Approval',
              children: [
                if (workspace.verifiedByName != null)
                  _detailRow('Approved by', workspace.verifiedByName!),
                if (workspace.verifiedAt != null)
                  _detailRow('Approved at', _formatDate(workspace.verifiedAt!)),
                if (workspace.expiresAt != null)
                  _detailRow('Expires', _formatDate(workspace.expiresAt!)),
              ],
            ),
          ],
          if (workspace.status == WorkspaceStatus.rejected &&
              workspace.rejectionReason != null &&
              workspace.rejectionReason!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSection(
              title: 'Rejection reason',
              children: [
                Text(
                  workspace.rejectionReason!,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.danger,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ],
          if (workspace.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSection(
              title: 'Notes',
              children: [
                Text(
                  workspace.notes,
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.textPrimary, height: 1.5),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        Obx(() {
          final deleting = Get.find<BiometricsController>()
              .isDeletingWorkspace
              .value;
          return MyOutlinedButton(
            child: 'Close',
            height: 44,
            onTap: deleting ? null : () => Navigator.pop(context),
            textColor: AppColors.textSecondary,
            borderColor: AppColors.borderStrong,
          );
        }),
        Obx(() {
          final deleting = Get.find<BiometricsController>()
              .isDeletingWorkspace
              .value;
          return MyElevatedButton(
            width: 140,
            height: 44,
            child: deleting ? 'Deleting...' : 'Delete',
            icon: deleting
                ? null
                : const Icon(Iconsax.trash,
                    size: 18, color: AppColors.textOnPrimary),
            bgColor: AppColors.danger,
            onTap: deleting ? null : () => _confirmDelete(context),
          );
        }),
      ],
    );
  }

  Widget _buildSummaryBanner(WorkspaceConfig workspace) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: AppRadii.brLg,
            ),
            child: const Icon(Iconsax.location,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workspace.workspaceName, style: AppTextStyles.h3),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusChip(
                      label: workspace.status.label,
                      tone: _statusTone(workspace.status),
                      icon: _statusIcon(workspace.status),
                    ),
                    if (workspace.locationType.isNotEmpty)
                      _metaChip(
                        icon: Iconsax.tag,
                        label: workspace.locationType,
                      ),
                    if (workspace.branchName != null &&
                        workspace.branchName!.isNotEmpty)
                      _metaChip(
                        icon: Iconsax.building,
                        label: workspace.branchName!,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brPill,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h4),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await DialogScaffold.show<bool>(
      context,
      title: 'Delete workspace?',
      subtitle: 'This action cannot be undone.',
      size: DialogSize.sm,
      body: Text(
        'Remove "${workspace.workspaceName}" from your submissions?',
        style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
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
          width: 140,
          height: 44,
          child: 'Delete',
          icon: const Icon(Iconsax.trash,
              size: 18, color: AppColors.textOnPrimary),
          bgColor: AppColors.danger,
          onTap: () => Navigator.pop(context, true),
        ),
      ],
    );
    if (confirmed != true) return;
    if (workspace.id == null) return;

    final controller = Get.find<BiometricsController>();
    final success = await controller.deleteWorkspace(token, workspace.id!);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    AppToast.info(
      context,
      success
          ? controller.successMessage.value
          : controller.errorMessage.value,
    );
  }

  StatusTone _statusTone(WorkspaceStatus s) {
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

  IconData _statusIcon(WorkspaceStatus s) {
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
