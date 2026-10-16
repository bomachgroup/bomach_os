import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/permission/permission_gate.dart';
import 'package:bomach_os/pages/auth/controller.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../controller/leave_request_controller.dart';
import '../models/leave_request_model.dart';

class ViewLeaveRequestDialog extends StatefulWidget {
  final LeaveRequest request;
  const ViewLeaveRequestDialog({super.key, required this.request});

  @override
  State<ViewLeaveRequestDialog> createState() => _ViewLeaveRequestDialogState();
}

class _ViewLeaveRequestDialogState extends State<ViewLeaveRequestDialog> {
  final LeaveRequestController _ctrl = Get.find<LeaveRequestController>();

  void _confirmReject(BuildContext context, int requestId) {
    final reasonCtrl = TextEditingController();
    String? reasonError;
    late StateSetter updateForm;
    DialogScaffold.show<void>(
      context,
      title: 'Reject Request',
      subtitle:
          'A reason is required so the employee understands the decision.',
      size: DialogSize.sm,
      body: StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          updateForm = setDialogState;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to reject this request?',
                style: AppTextStyles.bodyMd,
              ),
              const SizedBox(height: 16),
              MyTextFormField(
                controller: reasonCtrl,
                title: 'Reason for rejection',
                hintText: 'Explain why this request is being declined',
                maxLines: 3,
                onChanged: (_) {
                  if (reasonError != null) {
                    setDialogState(() => reasonError = null);
                  }
                },
              ),
              if (reasonError != null) ...[
                const SizedBox(height: 6),
                Text(
                  reasonError!,
                  style:
                      AppTextStyles.caption.copyWith(color: AppColors.danger),
                ),
              ],
            ],
          );
        },
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          onTap: () => Navigator.pop(context),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        PermissionGate(
          require: Perms.leaveRequestsReject,
          allOf: const [Perms.leaveRequestsList, Perms.leaveRequestsReject],
          explicit: true,
          child: MyElevatedButton(
            child: 'Reject',
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            bgColor: AppColors.danger,
            icon: const Icon(Iconsax.close_circle,
                size: 18, color: AppColors.textOnPrimary),
            onTap: () {
              if (reasonCtrl.text.trim().length < 3) {
                updateForm(() => reasonError =
                    'Enter a brief reason of at least 3 characters.');
                return;
              }
              final reason = reasonCtrl.text.trim();
              Navigator.pop(context);
              _ctrl.updateLeaveStatus(context, requestId, 'rejected',
                  requestEmployeeId: widget.request.employeeId,
                  rejectionReason: reason);
            },
          ),
        ),
      ],
    ).whenComplete(reasonCtrl.dispose);
  }

  StatusTone _statusTone(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'approved':
        return StatusTone.success;
      case 'rejected':
        return StatusTone.danger;
      case 'pending':
        return StatusTone.warning;
      case 'cancelled':
      case 'canceled':
        return StatusTone.neutral;
      default:
        return StatusTone.neutral;
    }
  }

  String _statusLabel(String? status) {
    if (status == null || status.isEmpty) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '-';
    return DateFormat('dd-MM-yyyy').format(d);
  }

  String _fmtDateTime(DateTime? d) {
    if (d == null) return '-';
    return DateFormat('dd MMM yyyy, h:mm a').format(d);
  }

  String _requestKindLabel(LeaveRequest request) {
    switch (request.requestKind) {
      case 'absence':
        return 'Absence request';
      case 'running_late':
        return 'Late-arrival report';
      default:
        return '${_formatLeaveType(request.leaveType)} request';
    }
  }

  String _formatLeaveType(String type) {
    if (type.isEmpty) return '—';
    return type
        .split('_')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final currentEmployeeId = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>().currentUser.value?.id
        : null;
    final isOwnRequest = LeaveRequestController.isOwnRequest(
      currentEmployeeRecordId: currentEmployeeId,
      requestEmployeeId: r.employeeId,
    );
    final canAct = (r.status ?? '').toLowerCase() == 'pending' &&
        r.id != null &&
        currentEmployeeId != null &&
        currentEmployeeId > 0 &&
        !isOwnRequest;

    final isLate = r.requestKind == 'running_late';
    final employeeLabel = r.employeeName?.isNotEmpty == true
        ? r.employeeName!
        : (r.employeeId.isEmpty ? 'Employee' : r.employeeId);

    return DialogScaffold(
      title: _requestKindLabel(r),
      subtitle: 'Request from $employeeLabel',
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryBanner(r),
          if (isOwnRequest && (r.status ?? '').toLowerCase() == 'pending') ...[
            const SizedBox(height: 14),
            _buildSelfReviewNotice(),
          ],
          const SizedBox(height: 20),
          _buildDetailSection(
            title: isLate ? 'Late-arrival information' : 'Request information',
            children: [
              if (r.requestKind == 'leave')
                _detailRow('Leave type', _formatLeaveType(r.leaveType)),
              if (isLate)
                _detailRow('Reported for', _fmtDate(r.startDate))
              else ...[
                _detailRow('First day', _fmtDate(r.startDate)),
                _detailRow('Last day', _fmtDate(r.endDate)),
                _detailRow(
                  'Duration',
                  r.durationDays != null ? '${r.durationDays} day(s)' : '—',
                ),
              ],
              _detailRow('Submitted', _fmtDateTime(r.createdAt)),
              if ((r.employeeCode ?? '').isNotEmpty)
                _detailRow('Employee code', r.employeeCode!),
              if ((r.branchName ?? '').isNotEmpty)
                _detailRow('Branch', r.branchName!),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailSection(
            title: isLate
                ? 'Reason for delay'
                : r.requestKind == 'absence'
                    ? 'Reason for absence'
                    : 'Reason for leave',
            children: [
              Text(
                r.reason == null || r.reason!.isEmpty
                    ? 'No reason provided.'
                    : r.reason!,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailSection(
            title: 'Approval',
            children: [
              _detailRow(
                'Reviewed by',
                (r.approverName == null || r.approverName!.isEmpty)
                    ? ((r.approverId == null || r.approverId!.isEmpty)
                        ? '—'
                        : r.approverId!)
                    : r.approverName!,
              ),
              _detailRow('Approval Date', _fmtDate(r.approvalDate)),
              if ((r.rejectionReason ?? '').isNotEmpty)
                _detailRow('Rejection Reason', r.rejectionReason!),
            ],
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Close',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          onTap: () => Navigator.pop(context),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        if (canAct) ...[
          PermissionGate(
            require: Perms.leaveRequestsReject,
            allOf: const [Perms.leaveRequestsList, Perms.leaveRequestsReject],
            explicit: true,
            child: Obx(() => MyOutlinedButton(
                  child: 'Reject',
                  height: 44,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  icon: const Icon(Iconsax.close_circle,
                      size: 18, color: AppColors.danger),
                  onTap: _ctrl.isSaving.value
                      ? null
                      : () => _confirmReject(context, r.id!),
                  textColor: AppColors.danger,
                  borderColor: AppColors.danger,
                )),
          ),
          PermissionGate(
            require: Perms.leaveRequestsApprove,
            allOf: const [Perms.leaveRequestsList, Perms.leaveRequestsApprove],
            explicit: true,
            child: Obx(() => MyElevatedButton(
                  height: 44,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  bgColor: AppColors.success,
                  isLoading: _ctrl.isSaving.value,
                  icon: const Icon(Iconsax.tick_circle,
                      size: 18, color: AppColors.textOnPrimary),
                  child: _ctrl.isSaving.value ? 'Saving...' : 'Approve',
                  onTap: _ctrl.isSaving.value
                      ? null
                      : () => _ctrl.updateLeaveStatus(
                            context,
                            r.id!,
                            'approved',
                            requestEmployeeId: r.employeeId,
                          ),
                )),
          ),
        ],
      ],
    );
  }

  Widget _buildSelfReviewNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.infoSubtle,
        borderRadius: AppRadii.brMd,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Iconsax.shield_tick, size: 18, color: AppColors.info),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'You submitted this request. Another authorised reviewer must make the decision.',
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBanner(LeaveRequest r) {
    final employeeName = r.employeeName?.isNotEmpty == true
        ? r.employeeName!
        : (r.employeeId.isEmpty ? 'Unknown employee' : r.employeeId);
    final initial = employeeName[0].toUpperCase();
    final isLate = r.requestKind == 'running_late';
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
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: AppTextStyles.h2.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employeeName,
                  style: AppTextStyles.h3,
                ),
                if ((r.employeeCode ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(r.employeeCode!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      )),
                ],
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusChip(
                      label: _statusLabel(r.status),
                      tone: _statusTone(r.status),
                    ),
                    _buildMetaChip(
                      icon: isLate ? Iconsax.clock : Iconsax.calendar_1,
                      label: isLate
                          ? 'Reported ${_fmtDate(r.startDate)}'
                          : '${_fmtDate(r.startDate)} → ${_fmtDate(r.endDate)}',
                    ),
                    if (!isLate && r.durationDays != null)
                      _buildMetaChip(
                        icon: Iconsax.clock,
                        label: '${r.durationDays} day(s)',
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

  Widget _buildMetaChip({required IconData icon, required String label}) {
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

  Widget _buildDetailSection({
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
            width: 160,
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
}
