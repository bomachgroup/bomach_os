import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/permission/permission_gate.dart';
import 'package:bms_front_end/components/section/responsive_widget.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/permissions.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/model/role_model.dart';
import 'package:bms_front_end/src/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'company.dart';
import 'controllers/company_controller.dart';
import 'controllers/roles_controller.dart';

// ═══════════════════════════════════════════════════════════════════════
//  ROLES PAGE
// ═══════════════════════════════════════════════════════════════════════

class RolesPage extends StatelessWidget {
  const RolesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CompanyController companyController = Get.put(CompanyController());
    final RolesController ctrl = Get.put(RolesController());

    Widget body = SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText('Roles & Permissions', style: AppText.black_600_32),
          const SizedBox(height: 8),
          const Text(
            'Manage organizational roles and access control',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Stats Row
          _buildStatsSection(companyController, ctrl),
          const SizedBox(height: 32),

          // Subheader — Search + Create
          ResponsiveSubheader(
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText('All Roles', style: AppText.black_600_16),
                SizedBox(height: 2),
                Text(
                  'Bomach Group of Companies',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
              ],
            ),
            search: MyTextFormField(
              hintText: 'Search roles',
              leading: const Icon(Icons.search, color: Colors.grey, size: 20),
              onChanged: ctrl.onSearchChanged,
            ),
            action: PermissionGate(
              require: Perms.rolesCreate,
              child: MyElevatedButton(
                height: 40,
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                child: 'Create Role',
                onTap: () => _showCreateEditRoleDialog(context, ctrl),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Table
          Obx(() {
            if (ctrl.isLoading.value && ctrl.roles.isEmpty) {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(),
              ));
            }
            if (ctrl.roles.isEmpty) return _buildEmptyState(context, ctrl);
            return _buildRolesTable(context, ctrl);
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

  // ─── Stats ─────────────────────────────────────────────────────────
  Widget _buildStatsSection(
      CompanyController companyController, RolesController ctrl) {
    return Obx(() {
      final stats = companyController.dashboardStats.value;
      return ResponsiveStatRow(
        cards: [
          DashboardStatCard(
            title: 'Total Roles',
            count: '${ctrl.rolesCount.value}',
            borderColor: const Color(0xFF1976D2),
            countColor: const Color(0xFF1976D2),
          ),
          DashboardStatCard(
            title: 'Total Employees',
            count: stats != null ? '${stats.totalEmployees}' : '–',
            borderColor: Colors.green,
            countColor: Colors.green,
          ),
          DashboardStatCard(
            title: 'Pending Approvals',
            count: stats != null ? '${stats.pendingApprovals}' : '–',
            borderColor: const Color(0xFFC27803),
            countColor: const Color(0xFFC27803),
          ),
        ],
      );
    });
  }

  // ─── Table ─────────────────────────────────────────────────────────
  Widget _buildRolesTable(BuildContext context, RolesController ctrl) {
    return Obx(() {
      final roles = ctrl.roles;

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
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        child: Text('Role Name',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B)))),
                    Expanded(
                        flex: 2,
                        child: Text('Scope',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B)))),
                    Expanded(
                        flex: 2,
                        child: Text('Permissions',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B)))),
                    Expanded(
                        flex: 1,
                        child: Text('Status',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B)))),
                    SizedBox(
                        width: 48,
                        child: Text('Action',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B)))),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Rows
              ...roles.map((role) => _buildRoleRow(context, ctrl, role)),

              // Pagination
              Padding(
                padding: const EdgeInsets.all(8.0),
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
        ),
      );
    });
  }

  Widget _buildRoleRow(BuildContext context, RolesController ctrl, Role role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 40),

          // Role name
          Expanded(
            flex: 2,
            child: Text(
              role.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Scope (branches)
          Expanded(
            flex: 2,
            child: role.branches.isEmpty
                ? const Text('All Branches',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)))
                : Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: role.branches.map((b) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          b.branchName,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF475569)),
                        ),
                      );
                    }).toList(),
                  ),
          ),

          // Permissions count
          Expanded(
            flex: 2,
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${role.totalPermissionCount} permissions',
                    style: const TextStyle(
                      color: AppColors.blue,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Status badge
          Expanded(
            flex: 1,
            child: _buildStatusBadge('active'),
          ),

          // Action
          SizedBox(
            width: 48,
            child: _buildActionMenu(context, ctrl, role),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final bool isActive = status.toLowerCase() == 'active';
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
            Text(
              isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionMenu(
      BuildContext context, RolesController ctrl, Role role) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            _showCreateEditRoleDialog(context, ctrl, role: role);
            break;
          case 'delete':
            _confirmDeleteRole(context, ctrl, role);
            break;
        }
      },
      itemBuilder: (_) {
        final perms = Get.find<PermissionService>();
        return [
          if (perms.has(Perms.rolesUpdate))
            const PopupMenuItem(
              value: 'edit',
              child: Row(children: [
                Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                SizedBox(width: 8),
                Text('Edit'),
              ]),
            ),
          if (perms.has(Perms.rolesDelete))
            const PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                Icon(Icons.delete_outline, size: 18, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: Colors.red)),
              ]),
            ),
        ];
      },
    );
  }

  // ─── Dialogs ───────────────────────────────────────────────────────

  void _showCreateEditRoleDialog(BuildContext context, RolesController ctrl,
      {Role? role}) {
    showDialog(
      context: context,
      builder: (_) => _CreateEditRoleDialog(ctrl: ctrl, role: role),
    );
  }

  void _confirmDeleteRole(
      BuildContext context, RolesController ctrl, Role role) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Role'),
        content: Text('Are you sure you want to delete "${role.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      ctrl.deleteRole(context, role.id);
    }
  }

  Widget _buildEmptyState(BuildContext context, RolesController ctrl) {
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
              child: const Icon(Icons.admin_panel_settings_outlined,
                  size: 48, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 20),
            const Text('No roles found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text(
              'Create a new role to manage permissions and access control.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            MyElevatedButton(
              child: 'Create Role',
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              onTap: () => _showCreateEditRoleDialog(context, ctrl),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  CREATE / EDIT ROLE DIALOG
// ═══════════════════════════════════════════════════════════════════════

class _CreateEditRoleDialog extends StatefulWidget {
  final RolesController ctrl;
  final Role? role;

  const _CreateEditRoleDialog({required this.ctrl, this.role});

  @override
  State<_CreateEditRoleDialog> createState() => _CreateEditRoleDialogState();
}

class _CreateEditRoleDialogState extends State<_CreateEditRoleDialog> {
  late final TextEditingController _nameCtrl;
  final TextEditingController _permSearchCtrl = TextEditingController();

  // Branch multi-select
  late Set<int> _selectedBranchIds;

  // permissions: resource -> Set of selected actions
  late Map<String, Set<String>> _selectedPermissions;

  // Permission search & pagination
  String _permSearch = '';
  int _permPage = 0;
  static const int _permPageSize = 8;

  @override
  void initState() {
    super.initState();
    final role = widget.role;
    _nameCtrl = TextEditingController(text: role?.name ?? '');

    _selectedBranchIds = {};
    if (role != null) {
      _selectedBranchIds = role.branches.map((b) => b.id).toSet();
    }

    _selectedPermissions = {};
    if (role != null) {
      role.permissions.forEach((resource, actions) {
        _selectedPermissions[resource] = Set<String>.from(actions);
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _permSearchCtrl.dispose();
    super.dispose();
  }

  int get _totalSelectedCount =>
      _selectedPermissions.values.fold(0, (sum, s) => sum + s.length);

  List<MapEntry<String, List<String>>> get _filteredPermEntries {
    final query = _permSearch.toLowerCase();
    return widget.ctrl.permissionsMap.entries.where((entry) {
      if (query.isEmpty) return true;
      final resourceLabel = entry.key.replaceAll('_', ' ').toLowerCase();
      if (resourceLabel.contains(query)) return true;
      return entry.value
          .any((a) => a.replaceAll('_', ' ').toLowerCase().contains(query));
    }).toList();
  }

  Map<String, List<String>> _buildPermissionsPayload() {
    final result = <String, List<String>>{};
    _selectedPermissions.forEach((resource, actions) {
      if (actions.isNotEmpty) {
        result[resource] = actions.toList();
      }
    });
    return result;
  }

  void _onSave() async {
    if (_nameCtrl.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Role name is required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final permissions = _buildPermissionsPayload();
    final isEdit = widget.role != null;
    bool success;

    if (isEdit) {
      success = await widget.ctrl.updateRole(
        context,
        roleId: widget.role!.id,
        name: _nameCtrl.text.trim(),
        branchIds: _selectedBranchIds.toList(),
        permissions: permissions,
      );
    } else {
      success = await widget.ctrl.createRole(
        context,
        name: _nameCtrl.text.trim(),
        branchIds: _selectedBranchIds.toList(),
        permissions: permissions,
      );
    }

    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.role != null;
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 700,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEdit ? 'Edit Role' : 'Create New Role',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isEdit
                              ? 'Update role details and permissions.'
                              : 'Define a new role with branch scoping and permissions.',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Body — single scrollable page
            Expanded(
              child: Obx(() {
                if (widget.ctrl.isDepsLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filtered = _filteredPermEntries;
                final totalPages = (filtered.length / _permPageSize).ceil();
                // Clamp page
                if (_permPage >= totalPages && totalPages > 0) {
                  _permPage = totalPages - 1;
                }
                final pageStart = _permPage * _permPageSize;
                final pageEntries =
                    filtered.skip(pageStart).take(_permPageSize).toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Role Details section ──
                      _label('Role Name'),
                      MyTextFormField(
                        controller: _nameCtrl,
                        hintText: 'e.g. Branch Manager',
                      ),
                      const SizedBox(height: 20),

                      _label('Branches'),
                      const Text(
                        'Select which branches this role applies to (at least one required)',
                        style:
                            TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      _buildBranchChips(),

                      const SizedBox(height: 28),
                      const Divider(),
                      const SizedBox(height: 16),

                      // ── Permissions section ──
                      // Search bar + Select/Unselect All
                      Row(
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              controller: _permSearchCtrl,
                              hintText: 'Search permissions...',
                              leading: const Icon(Icons.search,
                                  color: Colors.grey, size: 20),
                              onChanged: (v) => setState(() {
                                _permSearch = v;
                                _permPage = 0;
                              }),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _totalSelectedCount > 0
                              ? TextButton.icon(
                                  onPressed: () => setState(
                                      () => _selectedPermissions.clear()),
                                  icon: const Icon(Icons.deselect, size: 18),
                                  label: const Text('Unselect All'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red.shade600,
                                  ),
                                )
                              : TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      widget.ctrl.permissionsMap
                                          .forEach((resource, actions) {
                                        _selectedPermissions[resource] =
                                            Set<String>.from(actions);
                                      });
                                    });
                                  },
                                  icon: const Icon(Icons.select_all, size: 18),
                                  label: const Text('Select All'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.blue,
                                  ),
                                ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (_totalSelectedCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            '$_totalSelectedCount permissions selected',
                            style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        ),

                      // Permission modules for current page
                      if (filtered.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text('No matching permissions found',
                                style: TextStyle(color: Color(0xFF94A3B8))),
                          ),
                        )
                      else ...[
                        ...pageEntries.map((entry) =>
                            _buildPermissionCategory(entry.key, entry.value)),

                        // Pagination controls
                        if (totalPages > 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: _permPage > 0
                                      ? () => setState(() => _permPage--)
                                      : null,
                                  icon: const Icon(Icons.chevron_left),
                                  iconSize: 20,
                                ),
                                ...List.generate(totalPages, (i) {
                                  final isActive = i == _permPage;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(6),
                                      onTap: () =>
                                          setState(() => _permPage = i),
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? AppColors.blue
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${i + 1}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: isActive
                                                ? Colors.white
                                                : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                IconButton(
                                  onPressed: _permPage < totalPages - 1
                                      ? () => setState(() => _permPage++)
                                      : null,
                                  icon: const Icon(Icons.chevron_right),
                                  iconSize: 20,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ],
                  ),
                );
              }),
            ),

            const Divider(height: 1),

            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.red.shade600),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      MyElevatedButton(
                        height: 40,
                        child: widget.ctrl.isSaving.value
                            ? 'Saving...'
                            : (isEdit ? 'Save Changes' : 'Create Role'),
                        onTap: widget.ctrl.isSaving.value ? null : _onSave,
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
    );
  }

  // ─── Branch multi-select chips ──────────────────────────────────────

  Widget _buildBranchChips() {
    final branches = widget.ctrl.branches;
    if (branches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Text('No branches available',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: branches.map((branch) {
        final isSelected = _selectedBranchIds.contains(branch.id);
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedBranchIds.remove(branch.id);
              } else {
                _selectedBranchIds.add(branch.id);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.blue.withValues(alpha: 0.1)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.blue : const Color(0xFFE2E8F0),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  size: 16,
                  color: isSelected ? AppColors.blue : const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 6),
                Text(
                  branch.branchName,
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        isSelected ? AppColors.blue : const Color(0xFF334155),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Permission category grid ───────────────────────────────────────

  Widget _buildPermissionCategory(String resource, List<String> actions) {
    final selected = _selectedPermissions[resource] ?? <String>{};
    final allSelected =
        actions.isNotEmpty && actions.every((a) => selected.contains(a));

    final label = resource
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '')
        .join(' ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header with select-all
          InkWell(
            onTap: () {
              setState(() {
                if (allSelected) {
                  _selectedPermissions.remove(resource);
                } else {
                  _selectedPermissions[resource] = Set<String>.from(actions);
                }
              });
            },
            child: Row(
              children: [
                Icon(
                  allSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 20,
                  color: allSelected ? AppColors.blue : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: actions.map((action) {
              final isSelected = selected.contains(action);
              final actionLabel = action
                  .replaceAll('_', ' ')
                  .split(' ')
                  .map((w) =>
                      w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '')
                  .join(' ');

              return InkWell(
                onTap: () {
                  setState(() {
                    final s = _selectedPermissions.putIfAbsent(
                        resource, () => <String>{});
                    if (isSelected) {
                      s.remove(action);
                      if (s.isEmpty) _selectedPermissions.remove(resource);
                    } else {
                      s.add(action);
                    }
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.blue.withValues(alpha: 0.1)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.blue : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        size: 14,
                        color: isSelected ? AppColors.blue : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        actionLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? AppColors.blue
                              : const Color(0xFF64748B),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
