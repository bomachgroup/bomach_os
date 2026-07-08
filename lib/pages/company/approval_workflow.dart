import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/paginate/my_paginator.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/shadows.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/approval_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'controllers/approval_controller.dart';
import 'widget/approval_workflow_dialogs.dart';

const List<String> _approvalTabs = ['Workflows', 'Approval Requests'];

class ApprovalWorkflowPage extends StatelessWidget {
  const ApprovalWorkflowPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ApprovalController controller = Get.put(ApprovalController());

    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Approval Workflow',
        subtitle:
            'Configure multi-level approval workflows and specify approvers '
            'for different actions and requests.',
        trailing: Obx(() => _buildHeaderAction(context, controller)),
      ),
      children: [
        Obx(() => _buildTabBar(controller)),
        Obx(() {
          switch (controller.currentTab.value) {
            case 'Workflows':
              return _WorkflowsTab(controller: controller);
            case 'Approval Requests':
              return _RequestsTab(controller: controller);
            default:
              return const SizedBox.shrink();
          }
        }),
      ],
    );
  }

  Widget _buildHeaderAction(
      BuildContext context, ApprovalController controller) {
    switch (controller.currentTab.value) {
      case 'Workflows':
        return MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'New Workflow',
          onTap: () => showDialog(
            context: context,
            builder: (_) => const CreateEditWorkflowDialog(),
          ),
        );
      case 'Approval Requests':
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTabBar(ApprovalController controller) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _approvalTabs
              .map((label) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _buildTabButton(controller, label),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTabButton(ApprovalController controller, String label) {
    final isActive = controller.currentTab.value == label;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadii.brMd,
        onTap: () => controller.currentTab.value = label,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.surface : Colors.transparent,
            borderRadius: AppRadii.brMd,
            boxShadow: isActive ? AppShadows.sm : const <BoxShadow>[],
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyMd.copyWith(
              color:
                  isActive ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SHARED HELPERS
// ═══════════════════════════════════════════════════════════════════

Widget _buildToolbar({
  required String searchHint,
  required ValueChanged<String> onSearchChanged,
}) {
  return AppCard(
    padding: const EdgeInsets.all(16),
    elevation: AppCardElevation.sm,
    child: MyTextFormField(
      hintText: searchHint,
      height: 48,
      onChanged: onSearchChanged,
      leading: const Icon(Iconsax.search_normal,
          size: 18, color: AppColors.textMuted),
    ),
  );
}

Widget _buildTableCard({
  required String title,
  required String subtitle,
  Widget? headerTrailing,
  required Widget body,
  Widget? footer,
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
                    Text(title, style: AppTextStyles.h3),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (headerTrailing != null) headerTrailing,
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderSubtle),
        body,
        if (footer != null) ...[
          const Divider(height: 1, color: AppColors.borderSubtle),
          footer,
        ],
      ],
    ),
  );
}



Widget _tablePaginator(Widget child) {
  return Container(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
    child: child,
  );
}



StatusTone _flowStatusTone(String status) {
  switch (status.toLowerCase()) {
    case 'active':
      return StatusTone.success;
    case 'inactive':
      return StatusTone.neutral;
    default:
      return StatusTone.neutral;
  }
}

StatusTone _requestStatusTone(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
    case 'completed':
      return StatusTone.success;
    case 'pending':
    case 'in review':
      return StatusTone.warning;
    case 'rejected':
      return StatusTone.danger;
    case 'cancelled':
    case 'canceled':
      return StatusTone.neutral;
    case 'in progress':
      return StatusTone.info;
    default:
      return StatusTone.neutral;
  }
}

// ═══════════════════════════════════════════════════════════════════
//  WORKFLOWS TAB
// ═══════════════════════════════════════════════════════════════════

class _WorkflowsTab extends StatelessWidget {
  final ApprovalController controller;
  const _WorkflowsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildToolbar(
          searchHint: 'Search workflows by name or action',
          onSearchChanged: controller.onFlowSearchChanged,
        ),
        const SizedBox(height: 16),
        Obx(() {
          final loading = controller.isLoadingFlows.value &&
              controller.flowList.isEmpty;
          final isEmpty = !controller.isLoadingFlows.value &&
              controller.flowList.isEmpty;

          return _buildTableCard(
            title: 'Workflows register',
            subtitle: loading
                ? 'Loading workflows...'
                : '${controller.flowTotalItems.value} workflows configured',
            headerTrailing: const StatusChip(
              label: 'Governance automation',
              tone: StatusTone.primary,
              icon: Iconsax.tick_square,
            ),
            body: loading
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: LoadingSkeleton.listRows(count: 5),
                  )
                : isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: EmptyState(
                          icon: Iconsax.tick_square,
                          title: 'No workflows yet',
                          subtitle:
                              'Create a new approval workflow to get started.',
                          action: MyOutlinedButton(
                            child: 'New Workflow',
                            icon: const Icon(Iconsax.add_circle,
                                size: 18, color: AppColors.primary),
                            onTap: () => showDialog(
                              context: context,
                              builder: (_) => const CreateEditWorkflowDialog(),
                            ),
                          ),
                        ),
                      )
                    : _buildFlowTable(context),
            footer: _tablePaginator(
              Obx(() => PaginatorFooter(
                    totalItems: controller.flowTotalItems.value,
                    limit: controller.flowLimit.value,
                    currentPage: controller.flowCurrentPage.value,
                    onPageChanged: controller.flowGoToPage,
                    onLimitChanged: controller.flowSetLimit,
                  )),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFlowTable(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: controller.flowList.map((flow) => _buildFlowMobileCard(context, flow)).toList(),
      ),
    );
  }

  Widget _buildFlowMobileCard(BuildContext context, ApprovalFlow flow) {
    final approvers = flow.approverDisplays.isNotEmpty
        ? flow.approverDisplays
        : flow.approvers;
    final statusLabel =
        flow.statusDisplay.isNotEmpty ? flow.statusDisplay : flow.status;

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
              Expanded(
                child: Text(
                  flow.name,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              StatusChip(
                label: statusLabel.isEmpty ? 'Unknown' : statusLabel,
                tone: _flowStatusTone(statusLabel),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Action: ${flow.actionDisplay.isNotEmpty ? flow.actionDisplay : flow.action}',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${flow.levels} Level${flow.levels != 1 ? 's' : ''}',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Approvers',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: approvers
                .map((a) => StatusChip(
                      label: a,
                      tone: StatusTone.primary,
                      dense: true,
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => ViewWorkflowDialog(flow: flow),
                ),
                icon: const Icon(Iconsax.eye, size: 16),
                label: const Text('View'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.borderStrong),
                  minimumSize: const Size(0, 42),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: const RoundedRectangleBorder(
                      borderRadius: AppRadii.brMd),
                ),
              ),
              const SizedBox(width: 8),
              MyElevatedButton(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                icon: const Icon(Iconsax.edit,
                    size: 16, color: AppColors.textOnPrimary),
                child: 'Edit',
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => CreateEditWorkflowDialog(flow: flow),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }




}

// ═══════════════════════════════════════════════════════════════════
//  APPROVAL REQUESTS TAB
// ═══════════════════════════════════════════════════════════════════

class _RequestsTab extends StatelessWidget {
  final ApprovalController controller;
  const _RequestsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildToolbar(
          searchHint: 'Search requests by workflow, type, or requester',
          onSearchChanged: controller.onRequestSearchChanged,
        ),
        const SizedBox(height: 16),
        Obx(() {
          final loading = controller.isLoadingRequests.value &&
              controller.requestList.isEmpty;
          final isEmpty = !controller.isLoadingRequests.value &&
              controller.requestList.isEmpty;

          return _buildTableCard(
            title: 'Approval Requests',
            subtitle: loading
                ? 'Loading requests...'
                : '${controller.requestTotalItems.value} approval requests on record',
            headerTrailing: const StatusChip(
              label: 'Request queue',
              tone: StatusTone.primary,
              icon: Iconsax.task_square,
            ),
            body: loading
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: LoadingSkeleton.listRows(count: 5),
                  )
                : isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: EmptyState(
                          icon: Iconsax.task_square,
                          title: 'No approval requests',
                          subtitle:
                              'Approval requests will appear here when submitted.',
                        ),
                      )
                    : _buildRequestTable(context),
            footer: _tablePaginator(
              Obx(() => PaginatorFooter(
                    totalItems: controller.requestTotalItems.value,
                    limit: controller.requestLimit.value,
                    currentPage: controller.requestCurrentPage.value,
                    onPageChanged: controller.requestGoToPage,
                    onLimitChanged: controller.requestSetLimit,
                  )),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRequestTable(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: controller.requestList.map((req) => _buildRequestMobileCard(context, req)).toList(),
      ),
    );
  }

  Widget _buildRequestMobileCard(BuildContext context, ApprovalRequest req) {
    String displayDate = req.createdAt;
    try {
      final parsed = DateTime.parse(req.createdAt);
      displayDate = DateFormat('MMM d, yyyy').format(parsed);
    } catch (_) {}

    final isPending = req.status.toLowerCase() == 'pending';
    final statusLabel =
        req.statusDisplay.isNotEmpty ? req.statusDisplay : req.status;

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
              Expanded(
                child: Text(
                  req.flowName.isNotEmpty ? req.flowName : 'Flow #${req.flowId}',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              StatusChip(
                label: statusLabel.isEmpty ? 'Unknown' : statusLabel,
                tone: _requestStatusTone(statusLabel),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Type: ${req.requestTypeDisplay.isNotEmpty ? req.requestTypeDisplay : req.requestType}',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'By: ${req.requestedByName.isNotEmpty ? req.requestedByName : req.requestedBy}',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                displayDate,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.borderSubtle),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () =>
                      controller.approveRequest(context, req.id),
                  icon: const Icon(Iconsax.tick_circle,
                      size: 16, color: AppColors.success),
                  label: const Text('Approve'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.success,
                    side: const BorderSide(color: AppColors.success),
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: const RoundedRectangleBorder(
                        borderRadius: AppRadii.brMd),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final reason = await _showRejectReasonDialog(context);
                    if (reason != null && context.mounted) {
                      controller.rejectRequest(context, req.id,
                          reason: reason);
                    }
                  },
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
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }



  Future<String?> _showRejectReasonDialog(BuildContext context) async {
    final TextEditingController reasonCtrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => DialogScaffold(
        title: 'Reject Request',
        subtitle: 'Please provide a reason for rejecting this request.',
        size: DialogSize.sm,
        body: MyTextFormField(
          controller: reasonCtrl,
          title: 'Reason',
          hintText: 'e.g. Insufficient budget or incorrect details',
          maxLines: 3,
        ),
        actions: [
          MyOutlinedButton(
            child: 'Cancel',
            height: 44,
            onTap: () => Navigator.pop(context),
            textColor: AppColors.textSecondary,
            borderColor: AppColors.borderStrong,
          ),
          MyElevatedButton(
            width: 120,
            height: 44,
            child: 'Reject',
            bgColor: AppColors.danger,
            onTap: () => Navigator.pop(context, reasonCtrl.text.trim()),
          ),
        ],
      ),
    );
  }
}
