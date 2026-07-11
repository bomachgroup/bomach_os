import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/paginate/my_paginator.dart';
import 'package:bomach_os/components/permission/permission_gate.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/role_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controllers/roles_controller.dart';
import 'widget/roles_dialogs.dart';

// ═══════════════════════════════════════════════════════════════════════
//  ROLES PAGE
// ═══════════════════════════════════════════════════════════════════════

class RolesPage extends StatelessWidget {
  const RolesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final RolesController ctrl = Get.put(RolesController());

    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Roles & Permissions',
        subtitle: 'Manage organizational roles and access control',
        trailing: PermissionGate(
          require: Perms.rolesCreate,
          child: MyElevatedButton(
            height: 48,
            icon: const Icon(Iconsax.add,
                color: AppColors.textOnPrimary, size: 18),
            child: 'Create Role',
            onTap: () => showDialog(
              context: context,
              builder: (_) => CreateEditRoleDialog(ctrl: ctrl),
            ),
          ),
        ),
      ),
      children: [
        _buildToolbar(ctrl),
        Obx(() {
          if (ctrl.isLoading.value && ctrl.roles.isEmpty) {
            return AppCard(
              padding: const EdgeInsets.all(24),
              child: LoadingSkeleton.listRows(count: 5),
            );
          }
          if (ctrl.roles.isEmpty) return _buildEmptyState(context, ctrl);
          return _buildRolesTable(context, ctrl);
        }),
      ],
    );
  }

  Widget _buildToolbar(RolesController ctrl) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: MyTextFormField(
        hintText: 'Search roles by name or scope...',
        height: 48,
        leading: const Icon(Iconsax.search_normal,
            color: AppColors.textMuted, size: 18),
        onChanged: ctrl.onSearchChanged,
      ),
    );
  }

  // ─── Table ─────────────────────────────────────────────────────────
  Widget _buildRolesTable(BuildContext context, RolesController ctrl) {
    return Obx(() {
      final roles = ctrl.roles;

      return AppCard(
        padding: EdgeInsets.zero,
        elevation: AppCardElevation.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              color: AppColors.surfaceMuted,
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  _buildHeaderCell('Role Name', flex: 2),
                  _buildHeaderCell('Mission', flex: 2),
                  _buildHeaderCell('Job Description', flex: 2),
                  _buildHeaderCell('Responsibilities', flex: 2),
                  _buildHeaderCell('Scope', flex: 2),
                  _buildHeaderCell('Permissions', flex: 2),
                  _buildHeaderCell('Status', flex: 1),
                  const SizedBox(
                      width: 120,
                      child: Text('Action',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ))),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderSubtle),

            // Rows
            ...roles.map((role) => _buildRoleRow(context, ctrl, role)),

            // Pagination
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: PaginatorFooter(
                totalItems: ctrl.rolesCount.value,
                limit: ctrl.limit.value,
                currentPage: ctrl.currentPage.value,
                onPageChanged: ctrl.onPageChanged,
                onLimitChanged: ctrl.onLimitChanged,
              ),
            ),
          ],
        ),
      );
    });
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

  Widget _buildRoleRow(BuildContext context, RolesController ctrl, Role role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 40),

          // Role name
          Expanded(
            flex: 2,
            child: Text(
              role.name,
              style: AppTextStyles.bodyMd.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Mission
          Expanded(
            flex: 2,
            child: Text(
              role.mission?.isNotEmpty == true ? role.mission! : '—',
              style: AppTextStyles.bodySm.copyWith(
                color: role.mission?.isNotEmpty == true
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
                fontStyle: role.mission?.isNotEmpty == true
                    ? FontStyle.normal
                    : FontStyle.italic,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),

          // Job Description
          Expanded(
            flex: 2,
            child: Text(
              role.jobDescription?.isNotEmpty == true ? role.jobDescription! : '—',
              style: AppTextStyles.bodySm.copyWith(
                color: role.jobDescription?.isNotEmpty == true
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
                fontStyle: role.jobDescription?.isNotEmpty == true
                    ? FontStyle.normal
                    : FontStyle.italic,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),

          // Responsibilities
          Expanded(
            flex: 2,
            child: Text(
              (role.responsibilities?.isNotEmpty == true)
                  ? role.responsibilities!.join('; ')
                  : '—',
              style: AppTextStyles.bodySm.copyWith(
                color: role.responsibilities?.isNotEmpty == true
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
                fontStyle: role.responsibilities?.isNotEmpty == true
                    ? FontStyle.normal
                    : FontStyle.italic,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),

          // Scope (branches)
          Expanded(
            flex: 2,
            child: role.branches.isEmpty
                ? Text('All Branches',
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted))
                : Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: role.branches.map((b) {
                      return StatusChip(
                        label: b.branchName,
                        tone: StatusTone.neutral,
                        dense: true,
                      );
                    }).toList(),
                  ),
          ),

          // Permissions count
          Expanded(
            flex: 2,
            child: Row(
              children: [
                StatusChip(
                  label: '${role.totalPermissionCount} permissions',
                  tone: StatusTone.info,
                  dense: true,
                ),
              ],
            ),
          ),

          // Status
          const Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                label: 'Active',
                tone: StatusTone.success,
                dense: true,
              ),
            ),
          ),

          // Action menu
          SizedBox(
            width: 120,
            child: _buildActionMenu(context, ctrl, role),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(
      BuildContext context, RolesController ctrl, Role role) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => CreateEditRoleDialog(ctrl: ctrl, role: role),
          ),
          icon:
              const Icon(Iconsax.edit, size: 18, color: AppColors.textPrimary),
          tooltip: 'Edit',
          splashRadius: 20,
        ),
        IconButton(
          onPressed: () => _confirmDeleteRole(context, ctrl, role),
          icon: const Icon(Iconsax.trash, size: 18, color: AppColors.danger),
          tooltip: 'Delete',
          splashRadius: 20,
        ),
      ],
    );
  }

  void _confirmDeleteRole(
      BuildContext context, RolesController ctrl, Role role) async {
    final confirmed = await DialogScaffold.show<bool>(
      context,
      title: 'Delete Role',
      size: DialogSize.sm,
      body: Text(
        'Are you sure you want to delete "${role.name}"? This action cannot be undone.',
        style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          onTap: () => Navigator.pop(context, false),
        ),
        MyElevatedButton(
          width: 120,
          height: 44,
          child: 'Delete',
          icon: const Icon(Iconsax.trash,
              size: 18, color: AppColors.textOnPrimary),
          onTap: () => Navigator.pop(context, true),
        ),
      ],
    );
    if (confirmed == true && context.mounted) {
      ctrl.deleteRole(context, role.id);
    }
  }

  Widget _buildEmptyState(BuildContext context, RolesController ctrl) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: EmptyState(
        icon: Iconsax.security_user,
        title: 'No roles found',
        subtitle: 'Create a new role to start managing permissions.',
        action: MyElevatedButton(
          width: 160,
          child: 'Create Role',
          icon:
              const Icon(Iconsax.add, size: 18, color: AppColors.textOnPrimary),
          onTap: () => showDialog(
            context: context,
            builder: (c) => CreateEditRoleDialog(ctrl: ctrl),
          ),
        ),
      ),
    );
  }
}
