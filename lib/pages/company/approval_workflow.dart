import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/section/responsive_widget.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/model/approval_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'controllers/approval_controller.dart';
import 'controllers/company_controller.dart';
import 'company.dart';
import 'widget/approval_workflow_dialogs.dart';

class ApprovalWorkflowPage extends StatelessWidget {
  const ApprovalWorkflowPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ApprovalController controller = Get.put(ApprovalController());
    final CompanyController companyController = Get.put(CompanyController());

    Widget body = SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const MyText('Approval Workflow', style: AppText.black_600_32),
          const SizedBox(height: 8),
          const Text(
            'Configure multi-level approval workflows and specify approvers for different actions and requests',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Stats Row
          _buildStatsSection(companyController),

          const SizedBox(height: 32),

          // Tabs
          Obx(() => _buildTabBar(controller)),

          const SizedBox(height: 24),

          // Tab Content
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
      ),
    );

    return ResponsiveWidget(
      largeScreen: body,
      mediumScreen: body,
      smallScreen: body,
    );
  }

  Widget _buildStatsSection(CompanyController companyController) {
    return Obx(() {
      final stats = companyController.dashboardStats.value;
      return ResponsiveStatRow(
        cards: [
          DashboardStatCard(
            title: 'Total Employees',
            count: stats != null ? '${stats.totalEmployees}' : '–',
            borderColor: Colors.green,
            countColor: Colors.green,
          ),
          DashboardStatCard(
            title: 'Total Branches',
            count: stats != null ? '${stats.totalBranches}' : '–',
            borderColor: const Color(0xFF1976D2),
            countColor: const Color(0xFF1976D2),
          ),
          DashboardStatCard(
            title: 'Pending Approvals',
            count: stats != null ? '${stats.pendingApprovals}' : '–',
            borderColor: const Color(0xFFC27803),
            countColor: const Color(0xFFC27803),
          ),
          DashboardStatCard(
            title: 'Asset Inventory',
            count: stats != null ? '${stats.assetInventory}' : '–',
            borderColor: Colors.green,
            countColor: Colors.green,
          ),
        ],
      );
    });
  }

  Widget _buildTabBar(ApprovalController controller) {
    final tabs = ['Workflows', 'Approval Requests'];
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Wrap(
        spacing: 8,
        children: tabs.map((tab) {
          final isSelected = controller.currentTab.value == tab;
          return InkWell(
            onTap: () => controller.currentTab.value = tab,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tab,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  WORKFLOWS TAB
// ═══════════════════════════════════════════════════════════════════════

class _WorkflowsTab extends StatelessWidget {
  final ApprovalController controller;
  const _WorkflowsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subheader
        ResponsiveSubheader(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText('Workflows', style: AppText.black_600_16),
              SizedBox(height: 2),
              Text('Bomach Group of Companies',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            ],
          ),
          search: MyTextFormField(
            hintText: 'Search',
            leading: const Icon(Icons.search, color: Colors.grey, size: 20),
            onChanged: controller.onFlowSearchChanged,
          ),
          action: MyElevatedButton(
            height: 40,
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            child: 'New workflow',
            onTap: () => showDialog(
              context: context,
              builder: (_) => const CreateEditWorkflowDialog(),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Table
        Obx(() {
          if (controller.isLoadingFlows.value && controller.flowList.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.flowList.isEmpty) {
            return _buildEmptyState(
              context,
              icon: Icons.approval_outlined,
              title: 'No workflows yet',
              subtitle: 'Create a new approval workflow to get started.',
              buttonLabel: 'New workflow',
              onAdd: () => showDialog(
                context: context,
                builder: (_) => const CreateEditWorkflowDialog(),
              ),
            );
          }

          return ResponsiveTableWrapper(
            child: Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 40),
                        Expanded(
                          flex: 2,
                          child: Text('Workflow Name',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF64748B))),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Action',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF64748B))),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text('Levels',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF64748B))),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text('Approvers',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF64748B))),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text('Status',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF64748B))),
                        ),
                        SizedBox(
                          width: 48,
                          child: Text('Action',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF64748B))),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ...controller.flowList
                      .map((flow) => _buildFlowRow(context, flow)),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Obx(() => PaginatorFooter(
                          totalItems: controller.flowTotalItems.value,
                          limit: controller.flowLimit.value,
                          currentPage: controller.flowCurrentPage.value,
                          onPageChanged: controller.flowGoToPage,
                          onLimitChanged: controller.flowSetLimit,
                        )),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFlowRow(BuildContext context, ApprovalFlow flow) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Checkbox(
              value: false,
              onChanged: (_) {},
              activeColor: AppColors.blue,
            ),
          ),
          // Workflow Name
          Expanded(
            flex: 2,
            child: Text(
              flow.name,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Action
          Expanded(
            flex: 2,
            child: Text(
              flow.actionDisplay.isNotEmpty ? flow.actionDisplay : flow.action,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Levels
          Expanded(
            flex: 1,
            child: Text(
              '${flow.levels} Level${flow.levels != 1 ? 's' : ''}',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          // Approvers chips
          Expanded(
            flex: 3,
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: (flow.approverDisplays.isNotEmpty
                      ? flow.approverDisplays
                      : flow.approvers)
                  .map((a) => _buildApproverChip(a))
                  .toList(),
            ),
          ),
          // Status
          Expanded(
            flex: 1,
            child: _buildStatusBadge(
              flow.statusDisplay.isNotEmpty ? flow.statusDisplay : flow.status,
            ),
          ),
          // Action menu
          SizedBox(
            width: 48,
            child: _buildActionMenu(context, flow),
          ),
        ],
      ),
    );
  }

  Widget _buildApproverChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.blue,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isActive = status.toLowerCase() == 'active';
    final Color color = isActive ? Colors.green : Colors.red;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 7, color: color),
            const SizedBox(width: 5),
            Text(status,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context, ApprovalFlow flow) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) async {
        switch (value) {
          case 'view':
            showDialog(
              context: context,
              builder: (_) => ViewWorkflowDialog(flow: flow),
            );
            break;
          case 'edit':
            showDialog(
              context: context,
              builder: (_) => CreateEditWorkflowDialog(flow: flow),
            );
            break;
          case 'delete':
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (c) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                title: const Text('Deactivate Workflow'),
                content:
                    Text('Are you sure you want to deactivate "${flow.name}"?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Deactivate',
                          style: TextStyle(color: Colors.red))),
                ],
              ),
            );
            if (confirmed == true && context.mounted) {
              controller.deleteFlow(context, flow.id);
            }
            break;
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(children: [
            Icon(Icons.visibility_outlined, size: 18, color: Colors.grey),
            SizedBox(width: 8),
            Text('View Details'),
          ]),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
            SizedBox(width: 8),
            Text('Edit'),
          ]),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline, size: 18, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete', style: TextStyle(color: Colors.red)),
          ]),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onAdd,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: const Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 20),
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(subtitle,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            MyElevatedButton(
              child: buttonLabel,
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              onTap: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  APPROVAL REQUESTS TAB
// ═══════════════════════════════════════════════════════════════════════

class _RequestsTab extends StatelessWidget {
  final ApprovalController controller;
  const _RequestsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subheader
        ResponsiveSubheader(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText('Approval Requests', style: AppText.black_600_16),
              SizedBox(height: 2),
              Text('Bomach Group of Companies',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            ],
          ),
          search: MyTextFormField(
            hintText: 'Search',
            leading: const Icon(Icons.search, color: Colors.grey, size: 20),
            onChanged: controller.onRequestSearchChanged,
          ),
        ),
        const SizedBox(height: 16),

        // Table
        Obx(() {
          if (controller.isLoadingRequests.value &&
              controller.requestList.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.requestList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.task_alt,
                          size: 48, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 20),
                    const Text('No approval requests',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const Text(
                      'Approval requests will appear here when submitted.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }

          return ResponsiveTableWrapper(
            child: Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 40),
                        Expanded(
                          flex: 2,
                          child: Text('Workflow',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF64748B))),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Request Type',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF64748B))),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Requested By',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF64748B))),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text('Status',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF64748B))),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Date',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF64748B))),
                        ),
                        SizedBox(
                          width: 100,
                          child: Text('Actions',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF64748B))),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ...controller.requestList
                      .map((req) => _buildRequestRow(context, req)),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Obx(() => PaginatorFooter(
                          totalItems: controller.requestTotalItems.value,
                          limit: controller.requestLimit.value,
                          currentPage: controller.requestCurrentPage.value,
                          onPageChanged: controller.requestGoToPage,
                          onLimitChanged: controller.requestSetLimit,
                        )),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRequestRow(BuildContext context, ApprovalRequest req) {
    String displayDate = '';
    try {
      final parsed = DateTime.parse(req.createdAt);
      displayDate = DateFormat('MMM d, yyyy').format(parsed);
    } catch (_) {
      displayDate = req.createdAt;
    }

    final isPending = req.status.toLowerCase() == 'pending';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Checkbox(
              value: false,
              onChanged: (_) {},
              activeColor: AppColors.blue,
            ),
          ),
          // Workflow name
          Expanded(
            flex: 2,
            child: Text(
              req.flowName.isNotEmpty ? req.flowName : 'Flow #${req.flowId}',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Request Type
          Expanded(
            flex: 2,
            child: Text(
              req.requestTypeDisplay.isNotEmpty
                  ? req.requestTypeDisplay
                  : req.requestType,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Requested By
          Expanded(
            flex: 2,
            child: Text(
              req.requestedByName.isNotEmpty
                  ? req.requestedByName
                  : req.requestedBy,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Status
          Expanded(
            flex: 1,
            child: _buildRequestStatusBadge(
              req.statusDisplay.isNotEmpty ? req.statusDisplay : req.status,
            ),
          ),
          // Date
          Expanded(
            flex: 2,
            child: Text(displayDate, style: const TextStyle(fontSize: 13)),
          ),
          // Actions
          SizedBox(
            width: 100,
            child: isPending
                ? Row(
                    children: [
                      InkWell(
                        onTap: () => controller.approveRequest(context, req.id),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Approve',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => controller.rejectRequest(context, req.id),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Reject',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ],
                  )
                : const Text('–', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'cancelled':
        color = Colors.grey;
        break;
      default:
        color = Colors.grey;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 7, color: color),
            const SizedBox(width: 5),
            Text(status,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
