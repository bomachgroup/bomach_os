import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/components/section/responsive_stat_row.dart';
import 'package:bomach_os/pages/company/controllers/authority_limit_controller.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/authority_limit_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'widget/authority_limit_dialogs.dart';

class AuthorityLimitsPage extends StatelessWidget {
  const AuthorityLimitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthorityLimitController());

    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Authority Limits',
        subtitle: 'Configure approval authority limits for roles',
        trailing: Obx(() => MyElevatedButton(
              height: 48,
              icon: const Icon(Iconsax.add_circle,
                  color: AppColors.textOnPrimary, size: 18),
              child: 'New Authority Limit',
              onTap: () => _showCreateDialog(context, controller),
            )),
      ),
      children: [
        _buildSummaryCards(controller),
        const SizedBox(height: 20),
        _buildFilterBar(controller),
        const SizedBox(height: 16),
        Expanded(child: _buildAuthorityLimitsTable(context, controller)),
      ],
    );
  }

  Widget _buildSummaryCards(AuthorityLimitController controller) {
    return Obx(() {
      final total = controller.authorityLimits.length;
      final uniqueRoles =
          controller.authorityLimits.map((a) => a.roleId).toSet().length;
      final withMaxAmount =
          controller.authorityLimits.where((a) => a.maxAmount != null).length;
      final sequential = controller.authorityLimits
          .where((a) => a.requiresSequentialApproval)
          .length;

      return ResponsiveStatRow(
        cards: [
          _StatCard(
            title: 'Total Limits',
            count: '$total',
            icon: Iconsax.document_text_1,
            accent: const Color(0xFF6366F1),
          ),
          _StatCard(
            title: 'Roles Covered',
            count: '$uniqueRoles',
            icon: Iconsax.people,
            accent: const Color(0xFF10B981),
          ),
          _StatCard(
            title: 'With Amount Limits',
            count: '$withMaxAmount',
            icon: Iconsax.wallet_1,
            accent: const Color(0xFFF59E0B),
          ),
          _StatCard(
            title: 'Sequential Approval',
            count: '$sequential',
            icon: Iconsax.arrow_right_3,
            accent: const Color(0xFF8B5CF6),
          ),
        ],
      );
    });
  }

  Widget _buildFilterBar(AuthorityLimitController controller) {
    return Obx(() => AppCard(
          padding: const EdgeInsets.all(16),
          elevation: AppCardElevation.sm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filters', style: AppTextStyles.h4),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 280,
                    child: MyTextFormField(
                      hintText: 'Search by role...',
                      height: 48,
                      leading: const Icon(Iconsax.search_normal,
                          size: 18, color: AppColors.textMuted),
                      onChanged: (v) {
                        final term = v.trim().toLowerCase();
                        if (term.isEmpty) {
                          controller.onSearchChanged(roleId: '');
                        } else {
                          final matchedRole = controller.roles.firstWhereOrNull(
                            (r) => r.name.toLowerCase().contains(term),
                          );
                          if (matchedRole != null) {
                            controller.onSearchChanged(roleId: matchedRole.id.toString());
                          }
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: MyTextFormField(
                      hintText: 'Resource',
                      height: 48,
                      leading: const Icon(Iconsax.box_1,
                          size: 18, color: AppColors.textMuted),
                      onChanged: (v) => controller.onSearchChanged(resource: v),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    child: MyTextFormField(
                      hintText: 'Action',
                      height: 48,
                      leading: const Icon(Iconsax.flash_1,
                          size: 18, color: AppColors.textMuted),
                      onChanged: (v) => controller.onSearchChanged(action: v),
                    ),
                  ),
                  MyOutlinedButton(
                    child: 'Clear Filters',
                    height: 48,
                    onTap: () {
                      controller.onSearchChanged(
                        roleId: '',
                        resource: '',
                        action: '',
                      );
                    },
                    textColor: AppColors.textSecondary,
                    borderColor: AppColors.borderStrong,
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _buildAuthorityLimitsTable(
      BuildContext context, AuthorityLimitController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.authorityLimits.isEmpty) {
        return _buildLoadingState();
      }

      if (controller.authorityLimits.isEmpty) {
        return _buildEmptyState(controller);
      }

      return AppCard(
        padding: EdgeInsets.zero,
        elevation: AppCardElevation.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTableHeader(),
            const Divider(height: 1, color: AppColors.borderSubtle),
            _buildTableBody(context, controller),
            _buildPagination(controller),
          ],
        ),
      );
    });
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: AppColors.surfaceMuted,
      child: Row(
        children: [
          _buildHeaderCell('Role', flex: 2),
          _buildHeaderCell('Resource', flex: 2),
          _buildHeaderCell('Action', flex: 1),
          _buildHeaderCell('Max Amount', flex: 2),
          _buildHeaderCell('Max Qty', flex: 1),
          _buildHeaderCell('Approval Level', flex: 1),
          _buildHeaderCell('Approvers', flex: 2),
          _buildHeaderCell('Sequential', flex: 1),
          const SizedBox(
            width: 120,
            child: Text('Actions',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.textSecondary,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: AppTextStyles.bodySm.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTableBody(
      BuildContext context, AuthorityLimitController controller) {
    return Column(
      children: controller.authorityLimits.map((limit) {
        return _buildTableRow(context, limit);
      }).toList(),
    );
  }

  Widget _buildTableRow(BuildContext context, AuthorityLimit limit) {
    final controller = Get.find<AuthorityLimitController>();
    final roleName = controller.roles
            .firstWhereOrNull((r) => r.id.toString() == limit.roleId)
            ?.name ??
        'Role ${limit.roleId}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          // Role
          Expanded(
            flex: 2,
            child: Text(
              roleName,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Resource
          Expanded(
            flex: 2,
            child: Text(
              limit.resource,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Action
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                limit.action,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Max Amount
          Expanded(
            flex: 2,
            child: Text(
              limit.maxAmount != null
                  ? '${limit.currency ?? ''} ${limit.maxAmount!.toStringAsFixed(2)}'
                  : '—',
              style: AppTextStyles.bodySm.copyWith(
                color: limit.maxAmount != null
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Max Quantity
          Expanded(
            flex: 1,
            child: Text(
              limit.maxQuantity != null ? '${limit.maxQuantity}' : '—',
              style: AppTextStyles.bodySm.copyWith(
                color: limit.maxQuantity != null
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Approval Level
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getApprovalLevelColor(limit.approvalLevel ?? '')
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                limit.approvalLevel?.isNotEmpty == true
                    ? limit.approvalLevel!
                    : '—',
                style: AppTextStyles.bodySm.copyWith(
                  color: _getApprovalLevelColor(limit.approvalLevel ?? ''),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Approvers
          Expanded(
            flex: 2,
            child: Text(
              limit.requiredApproverRoleIds.isNotEmpty
                  ? '${limit.requiredApproverRoleIds.length} role(s)'
                  : '—',
              style: AppTextStyles.bodySm.copyWith(
                color: limit.requiredApproverRoleIds.isNotEmpty
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Sequential
          Expanded(
            flex: 1,
            child: Center(
              child: Icon(
                limit.requiresSequentialApproval
                    ? Iconsax.arrow_right_3
                    : Iconsax.minus,
                size: 18,
                color: limit.requiresSequentialApproval
                    ? AppColors.warning
                    : AppColors.textMuted,
              ),
            ),
          ),
          // Actions
          SizedBox(
            width: 120,
            child: _buildActionMenu(context, controller, limit),
          ),
        ],
      ),
    );
  }

  Color _getApprovalLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'manager':
        return AppColors.info;
      case 'director':
        return AppColors.warning;
      case 'vp':
        return AppColors.danger;
      case 'c-level':
        return AppColors.primary;
      default:
        return AppColors.textMuted;
    }
  }

  Widget _buildActionMenu(BuildContext context,
      AuthorityLimitController controller, AuthorityLimit limit) {
    return PopupMenuButton<String>(
      tooltip: 'Actions',
      icon: const Icon(Iconsax.more, size: 18, color: AppColors.textSecondary),
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
      onSelected: (value) async {
        if (value == 'edit') {
          showDialog(
            context: context,
            builder: (context) => CreateEditAuthorityLimitDialog(
              controller: controller,
              limit: limit,
            ),
          );
        } else if (value == 'delete') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Authority Limit'),
              content: const Text(
                  'Are you sure you want to delete this authority limit?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style:
                      TextButton.styleFrom(foregroundColor: AppColors.danger),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
          if (confirm == true) {
            controller.deleteAuthorityLimit(context, limit.id.toString());
          }
        } else if (value == 'view') {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Authority Limit Details', style: AppTextStyles.h3),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                          'Role',
                          controller.roles
                                  .firstWhereOrNull(
                                      (r) => r.id.toString() == limit.roleId)
                                  ?.name ??
                              limit.roleId),
                      _buildDetailRow('Resource', limit.resource),
                      _buildDetailRow('Action', limit.action),
                      _buildDetailRow(
                          'Max Amount',
                          limit.maxAmount != null
                              ? '${limit.currency ?? 'NGN'} ${limit.maxAmount}'
                              : 'No Limit'),
                      _buildDetailRow('Max Quantity',
                          limit.maxQuantity?.toString() ?? 'No Limit'),
                      _buildDetailRow(
                          'Approval Level', limit.approvalLevel ?? 'None'),
                      _buildDetailRow('Sequential Approval',
                          limit.requiresSequentialApproval ? 'Yes' : 'No'),
                      if (limit.conditions != null)
                        _buildDetailRow('Conditions', limit.conditions!),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: 'view',
          child: Row(
            children: [
              Icon(Iconsax.eye, size: 18, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Text('View Details'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Iconsax.edit, size: 18, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Iconsax.trash, size: 18, color: AppColors.danger),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: AppColors.danger)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildPagination(AuthorityLimitController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: controller.offset >= controller.limit
                ? () {
                    controller.offset -= controller.limit;
                    controller.fetchAuthorityLimits();
                  }
                : null,
            icon: const Icon(Iconsax.arrow_left_2, size: 18),
          ),
          Text(
            'Page ${(controller.offset / controller.limit).floor() + 1} of ${(controller.totalCount / controller.limit).ceil().clamp(1, 9999)}',
            style:
                AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
          ),
          IconButton(
            onPressed:
                (controller.offset + controller.limit) < controller.totalCount
                    ? () {
                        controller.offset += controller.limit;
                        controller.fetchAuthorityLimits();
                      }
                    : null,
            icon: const Icon(Iconsax.arrow_right_3, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Loading authority limits...',
                style:
                    AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AuthorityLimitController controller) {
    return Padding(
      padding: const EdgeInsets.all(60),
      child: EmptyState(
        icon: Iconsax.document_text_1,
        title: 'No Authority Limits',
        subtitle: controller.searchRoleId.isNotEmpty ||
                controller.searchResource.isNotEmpty ||
                controller.searchAction.isNotEmpty
            ? 'No authority limits match your filters.'
            : 'Create your first authority limit to define approval limits.',
        action: MyElevatedButton(
          height: 44,
          icon: const Icon(Iconsax.add_circle,
              size: 18, color: AppColors.textOnPrimary),
          child: controller.searchRoleId.isNotEmpty ||
                  controller.searchResource.isNotEmpty ||
                  controller.searchAction.isNotEmpty
              ? 'Clear Filters'
              : 'Create Authority Limit',
          onTap: controller.searchRoleId.isNotEmpty ||
                  controller.searchResource.isNotEmpty ||
                  controller.searchAction.isNotEmpty
              ? () => controller.onSearchChanged(
                  roleId: '', resource: '', action: '')
              : () => _showCreateDialog(
                  Get.context!, Get.find<AuthorityLimitController>()),
        ),
      ),
    );
  }

  void _showCreateDialog(
      BuildContext context, AuthorityLimitController controller) {
    showDialog(
      context: context,
      builder: (_) => CreateEditAuthorityLimitDialog(controller: controller),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color accent;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(18),
        elevation: AppCardElevation.sm,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: AppRadii.brMd,
              ),
              child: Icon(icon, size: 20, color: accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(count,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral800)),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.neutral400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
