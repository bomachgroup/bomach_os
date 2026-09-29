import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/pages/company/controllers/workspace_approvals_controller.dart';
import 'package:bomach_os/pages/hr/models/workspace_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class WorkLocationRecordDialog extends StatelessWidget {
  const WorkLocationRecordDialog({super.key, required this.locationId});

  final int locationId;

  Future<
      ({
        WorkspaceConfig location,
        List<WorkLocationExtension> extensions,
        List<WorkLocationAuditEvent> events,
        String? extensionsError,
        String? historyError,
      })> _load(WorkspaceApprovalsController controller) async {
    final location = await controller.loadLocationDetail(locationId);
    var extensions = <WorkLocationExtension>[];
    var events = <WorkLocationAuditEvent>[];
    String? extensionsError;
    String? historyError;
    try {
      extensions = await controller.loadLocationExtensions(locationId);
    } catch (error) {
      extensionsError = _errorMessage(error);
    }
    try {
      events = await controller.loadLocationHistory(locationId);
    } catch (error) {
      historyError = _errorMessage(error);
    }
    return (
      location: location,
      extensions: extensions,
      events: events,
      extensionsError: extensionsError,
      historyError: historyError,
    );
  }

  static String _errorMessage(Object error) =>
      error.toString().replaceFirst('Exception: ', '');

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WorkspaceApprovalsController>();
    return DialogScaffold(
      title: 'Work location record',
      subtitle:
          'Current configuration, extension decisions, and audit history.',
      size: DialogSize.lg,
      body: FutureBuilder(
        future: _load(controller),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 56),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return _Notice(
              icon: Iconsax.warning_2,
              message:
                  snapshot.error?.toString().replaceFirst('Exception: ', '') ??
                      'The work location record could not be loaded.',
              danger: true,
            );
          }
          final data = snapshot.data!;
          final location = data.location;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _summary(location),
              const SizedBox(height: 16),
              _section('Location and owner', [
                _detail('Employee', location.employeeName ?? 'Shared location'),
                _detail('Branch', location.branchName ?? 'Not branch-linked'),
                _detail('Type', _label(location.locationType)),
                _detail(
                  'Coordinates',
                  '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
                ),
                _detail('Allowed radius', '${location.radiusMeters} m'),
                _detail('Submitted', _date(location.createdAt)),
              ]),
              const SizedBox(height: 12),
              _section('Lifecycle', [
                _detail(
                  'Current expiry',
                  location.expiresAt == null
                      ? 'Permanent'
                      : _date(location.expiresAt),
                ),
                _detail('Approved by', location.verifiedByName ?? '—'),
                _detail('Approved at', _date(location.verifiedAt)),
                _detail('Deactivated at', _date(location.deactivatedAt)),
                if (location.deactivationReason.isNotEmpty)
                  _detail(
                      'Deactivation type', _label(location.deactivationReason)),
                if (location.deactivationNote.isNotEmpty)
                  _detail('Deactivation reason', location.deactivationNote),
                if (location.rejectionReason?.isNotEmpty == true)
                  _detail('Rejection reason', location.rejectionReason!),
                if (location.notes.isNotEmpty) _detail('Notes', location.notes),
              ]),
              const SizedBox(height: 12),
              _section(
                'Extension history',
                data.extensionsError != null
                    ? [
                        _Notice(
                          message:
                              'Extension history could not be loaded: ${data.extensionsError}',
                          danger: true,
                        ),
                      ]
                    : data.extensions.isEmpty
                        ? [
                            const _Notice(
                                message: 'No extension requests recorded.'),
                          ]
                        : data.extensions.map(_extension).toList(),
              ),
              const SizedBox(height: 12),
              _section(
                'Audit history',
                data.historyError != null
                    ? [
                        _Notice(
                          message:
                              'Audit history could not be loaded: ${data.historyError}',
                          danger: true,
                        ),
                      ]
                    : data.events.isEmpty
                        ? [
                            const _Notice(message: 'No audit events recorded.'),
                          ]
                        : data.events.map(_event).toList(),
              ),
            ],
          );
        },
      ),
      actions: [
        MyOutlinedButton(
          child: 'Close',
          height: 44,
          onTap: () => Navigator.pop(context),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
      ],
    );
  }

  Widget _summary(WorkspaceConfig location) {
    final tone = switch (location.lifecycleLabel) {
      'Active' => StatusTone.success,
      'Pending approval' => StatusTone.warning,
      'Revoked' || 'Expired' || 'Rejected' => StatusTone.danger,
      _ => StatusTone.neutral,
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.location, size: 22, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(location.workspaceName, style: AppTextStyles.h4),
          ),
          StatusChip(label: location.lifecycleLabel, tone: tone, dense: true),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brMd,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title,
              style:
                  AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _detail(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: Text(label,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textSecondary)),
            ),
            Expanded(
              child: Text(value,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textPrimary)),
            ),
          ],
        ),
      );

  Widget _extension(WorkLocationExtension request) {
    final status = _label(request.status);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _historyTile(
        title: '$status · ${_date(request.createdAt)}',
        subtitle: 'Requested through ${_date(request.requestedExpiresAt)}',
        detail: request.status == 'approved'
            ? 'Approved expiry: ${_date(request.approvedExpiresAt)}'
            : request.decisionReason.isNotEmpty
                ? request.decisionReason
                : request.reason,
        actor: request.reviewedByName ?? request.requestedByName,
      ),
    );
  }

  Widget _event(WorkLocationAuditEvent event) {
    final metadata = event.metadata.entries
        .where((entry) => entry.value != null && '${entry.value}'.isNotEmpty)
        .map((entry) => '${_label(entry.key)}: ${entry.value}')
        .join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _historyTile(
        title: '${_label(event.eventType)} · ${_date(event.createdAt)}',
        subtitle: event.reason,
        detail: metadata,
        actor: event.actorName ?? 'System',
      ),
    );
  }

  Widget _historyTile({
    required String title,
    required String subtitle,
    required String detail,
    required String actor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle,
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.textSecondary)),
          ],
          if (detail.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(detail,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 4),
          Text('By $actor',
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  String _date(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    try {
      final date = DateTime.parse(raw).toLocal();
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  String _label(String raw) => raw
      .replaceAll('_', ' ')
      .split(' ')
      .map((part) =>
          part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

class _Notice extends StatelessWidget {
  const _Notice({this.icon, required this.message, this.danger = false});
  final IconData? icon;
  final String message;
  final bool danger;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: danger ? AppColors.dangerSubtle : AppColors.surfaceMuted,
          borderRadius: AppRadii.brSm,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 18,
                  color: danger ? AppColors.danger : AppColors.textSecondary),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodySm.copyWith(
                  color: danger ? AppColors.danger : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
}
