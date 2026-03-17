import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/section/responsive_widget.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

import 'company.dart';
import 'controllers/company_controller.dart';
import 'package:get/get.dart';

// TODO: Replace dummy data with real API data when roles endpoints become available.
// TODO: Create RolesController with GetX for CRUD operations.
// TODO: Create RolesService with Dio for API calls.

/// Dummy role model — replace with real model from API.
class _DummyRole {
  final String id;
  final String name;
  final String description;
  final String department;
  final int usersAssigned;
  final List<String> permissions;
  final String status; // 'active' | 'inactive'
  final String createdAt;

  const _DummyRole({
    required this.id,
    required this.name,
    required this.description,
    required this.department,
    required this.usersAssigned,
    required this.permissions,
    required this.status,
    required this.createdAt,
  });
}

// ─── Dummy data ───────────────────────────────────────────────────────
const _dummyRoles = <_DummyRole>[
  _DummyRole(
    id: '1',
    name: 'Super Admin',
    description: 'Full access to all modules and settings',
    department: 'All Departments',
    usersAssigned: 3,
    permissions: [
      'manage_users',
      'manage_roles',
      'manage_company',
      'manage_hr',
      'manage_finance',
      'manage_operations',
      'manage_settings'
    ],
    status: 'active',
    createdAt: '2025-01-15',
  ),
  _DummyRole(
    id: '2',
    name: 'HR Manager',
    description: 'Manage employees, attendance, leaves, and recruitment',
    department: 'Human Resources',
    usersAssigned: 5,
    permissions: [
      'manage_employees',
      'manage_attendance',
      'manage_leaves',
      'manage_recruitment',
      'view_reports'
    ],
    status: 'active',
    createdAt: '2025-02-10',
  ),
  _DummyRole(
    id: '3',
    name: 'Finance Officer',
    description: 'Manage invoices, payments, expenses, and budgets',
    department: 'Finance',
    usersAssigned: 4,
    permissions: [
      'manage_invoices',
      'manage_payments',
      'manage_expenses',
      'manage_budget',
      'view_reports'
    ],
    status: 'active',
    createdAt: '2025-02-20',
  ),
  _DummyRole(
    id: '4',
    name: 'Project Manager',
    description: 'Manage projects, tasks, and worksites',
    department: 'Operations',
    usersAssigned: 8,
    permissions: [
      'manage_projects',
      'manage_tasks',
      'manage_worksites',
      'view_contracts',
      'view_reports'
    ],
    status: 'active',
    createdAt: '2025-03-01',
  ),
  _DummyRole(
    id: '5',
    name: 'Sales Representative',
    description: 'Manage leads, clients, and interactions',
    department: 'CRM',
    usersAssigned: 12,
    permissions: [
      'manage_leads',
      'manage_clients',
      'manage_interactions',
      'view_reports'
    ],
    status: 'active',
    createdAt: '2025-03-15',
  ),
  _DummyRole(
    id: '6',
    name: 'Branch Manager',
    description: 'Manage branch-level operations and staff',
    department: 'All Departments',
    usersAssigned: 6,
    permissions: [
      'manage_branch',
      'view_employees',
      'manage_attendance',
      'view_reports'
    ],
    status: 'active',
    createdAt: '2025-04-01',
  ),
  _DummyRole(
    id: '7',
    name: 'Auditor',
    description: 'View and audit company records and logs',
    department: 'Legal & Compliance',
    usersAssigned: 2,
    permissions: ['view_audit_logs', 'view_reports', 'view_compliance'],
    status: 'active',
    createdAt: '2025-04-10',
  ),
  _DummyRole(
    id: '8',
    name: 'Intern',
    description: 'Limited read-only access to assigned modules',
    department: 'All Departments',
    usersAssigned: 15,
    permissions: ['view_dashboard', 'view_tasks'],
    status: 'inactive',
    createdAt: '2025-05-01',
  ),
];

// ─── Permission categories for the create/edit dialog ─────────────────
const _permissionCategories = <String, List<String>>{
  'Company': [
    'manage_company',
    'manage_branches',
    'manage_departments',
    'view_audit_logs'
  ],
  'HR / Admin': [
    'manage_employees',
    'manage_attendance',
    'manage_leaves',
    'manage_recruitment',
    'manage_training',
    'manage_payroll'
  ],
  'Finance': [
    'manage_invoices',
    'manage_payments',
    'manage_expenses',
    'manage_budget'
  ],
  'Operations': [
    'manage_projects',
    'manage_tasks',
    'manage_worksites',
    'view_contracts'
  ],
  'CRM': ['manage_leads', 'manage_clients', 'manage_interactions'],
  'Settings': ['manage_users', 'manage_roles', 'manage_settings'],
};

// ═══════════════════════════════════════════════════════════════════════
//  ROLES PAGE
// ═══════════════════════════════════════════════════════════════════════

class RolesPage extends StatefulWidget {
  const RolesPage({super.key});

  @override
  State<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {
  // TODO: Replace with GetX controller state
  final List<_DummyRole> _roles = List.from(_dummyRoles);
  String _searchQuery = '';
  int _currentPage = 1;
  int _limit = 10;

  List<_DummyRole> get _filteredRoles {
    if (_searchQuery.isEmpty) return _roles;
    final q = _searchQuery.toLowerCase();
    return _roles
        .where((r) =>
            r.name.toLowerCase().contains(q) ||
            r.department.toLowerCase().contains(q) ||
            r.description.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final CompanyController companyController = Get.put(CompanyController());

    Widget body = SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const MyText('Roles & Permissions', style: AppText.black_600_32),
          const SizedBox(height: 8),
          const Text(
            'Manage organizational roles and access control',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Stats Row
          _buildStatsSection(companyController),

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
              leading:
                  const Icon(Icons.search, color: Colors.grey, size: 20),
              onChanged: (val) => setState(() {
                _searchQuery = val;
                _currentPage = 1;
              }),
            ),
            action: MyElevatedButton(
              height: 40,
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              child: 'Create Role',
              onTap: () => _showCreateEditRoleDialog(context),
            ),
          ),

          const SizedBox(height: 16),

          // Table
          _buildRolesTable(),
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
  Widget _buildStatsSection(CompanyController companyController) {
    return Obx(() {
      final stats = companyController.dashboardStats.value;
      return ResponsiveStatRow(
        cards: [
          DashboardStatCard(
            title: 'Total Roles',
            count: '${_roles.length}',
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
            title: 'Users Assigned',
            count:
                '${_roles.fold<int>(0, (sum, r) => sum + r.usersAssigned)}',
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
  Widget _buildRolesTable() {
    final filtered = _filteredRoles;

    if (filtered.isEmpty) {
      return _buildEmptyState();
    }

    // Pagination
    final totalItems = filtered.length;
    final startIndex = (_currentPage - 1) * _limit;
    final endIndex = (startIndex + _limit).clamp(0, totalItems);
    final pageItems = filtered.sublist(startIndex, endIndex);

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
                          color: Color(0xFF64748B))),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Department',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF64748B))),
                ),
                Expanded(
                  flex: 1,
                  child: Text('Users',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF64748B))),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Permissions',
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

          // Rows
          ...pageItems.map((role) => _buildRoleRow(role)),

          // Pagination
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PaginatorFooter(
              totalItems: totalItems,
              limit: _limit,
              currentPage: _currentPage,
              onPageChanged: (page) => setState(() => _currentPage = page),
              onLimitChanged: (newLimit) => setState(() {
                _limit = newLimit;
                _currentPage = 1;
              }),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildRoleRow(_DummyRole role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          // Checkbox
          SizedBox(
            width: 40,
            child: Checkbox(
              value: false,
              onChanged: (_) {},
              activeColor: AppColors.blue,
            ),
          ),

          // Role name + description
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  role.description,
                  style: const TextStyle(
                      color: Color(0xFF64748B), fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),

          // Department
          Expanded(
            flex: 2,
            child: Text(
              role.department,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Users
          Expanded(
            flex: 1,
            child: Row(
              children: [
                const Icon(Icons.people_outline,
                    size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text('${role.usersAssigned}',
                    style: const TextStyle(fontSize: 13)),
              ],
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${role.permissions.length} permissions',
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
            child: _buildStatusBadge(role.status),
          ),

          // Action
          SizedBox(
            width: 48,
            child: _buildActionMenu(role),
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
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionMenu(_DummyRole role) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        switch (value) {
          case 'view':
            _showViewRoleDialog(context, role);
            break;
          case 'edit':
            _showCreateEditRoleDialog(context, role: role);
            break;
          case 'delete':
            _confirmDeleteRole(role);
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

  // ─── Dialogs ───────────────────────────────────────────────────────

  void _showCreateEditRoleDialog(BuildContext context,
      {_DummyRole? role}) {
    showDialog(
      context: context,
      builder: (_) => _CreateEditRoleDialog(
        role: role,
        onSave: (name, description, department, permissions, isActive) {
          // TODO: Replace with API call via controller
          setState(() {
            if (role != null) {
              final index = _roles.indexWhere((r) => r.id == role.id);
              if (index != -1) {
                _roles[index] = _DummyRole(
                  id: role.id,
                  name: name,
                  description: description,
                  department: department,
                  usersAssigned: role.usersAssigned,
                  permissions: permissions,
                  status: isActive ? 'active' : 'inactive',
                  createdAt: role.createdAt,
                );
              }
            } else {
              _roles.add(_DummyRole(
                id: '${_roles.length + 1}',
                name: name,
                description: description,
                department: department,
                usersAssigned: 0,
                permissions: permissions,
                status: isActive ? 'active' : 'inactive',
                createdAt: DateTime.now().toString().split(' ')[0],
              ));
            }
          });
        },
      ),
    );
  }

  void _showViewRoleDialog(BuildContext context, _DummyRole role) {
    showDialog(
      context: context,
      builder: (_) => _ViewRoleDialog(role: role),
    );
  }

  void _confirmDeleteRole(_DummyRole role) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Role'),
        content: Text('Are you sure you want to delete "${role.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child:
                  const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      // TODO: Replace with API call via controller
      setState(() {
        _roles.removeWhere((r) => r.id == role.id);
      });
    }
  }

  Widget _buildEmptyState() {
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
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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
              onTap: () => _showCreateEditRoleDialog(context),
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
  final _DummyRole? role;
  final void Function(String name, String description, String department,
      List<String> permissions, bool isActive) onSave;

  const _CreateEditRoleDialog({this.role, required this.onSave});

  @override
  State<_CreateEditRoleDialog> createState() => _CreateEditRoleDialogState();
}

class _CreateEditRoleDialogState extends State<_CreateEditRoleDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late String _department;
  late bool _isActive;
  late Set<String> _selectedPermissions;

  final _departments = [
    'All Departments',
    'Human Resources',
    'Finance',
    'Operations',
    'CRM',
    'Legal & Compliance',
    'Marketing',
    'IT',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.role?.name ?? '');
    _descCtrl =
        TextEditingController(text: widget.role?.description ?? '');
    _department = widget.role?.department ?? 'All Departments';
    _isActive = widget.role?.status != 'inactive';
    _selectedPermissions =
        Set<String>.from(widget.role?.permissions ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_nameCtrl.text.trim().isEmpty) return;
    widget.onSave(
      _nameCtrl.text.trim(),
      _descCtrl.text.trim(),
      _department,
      _selectedPermissions.toList(),
      _isActive,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.role != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title bar
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isEdit ? 'Edit Role' : 'Create New Role',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Body — scrollable
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Role name
                    const Text('Role Name',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 6),
                    MyTextFormField(
                      controller: _nameCtrl,
                      hintText: 'e.g. Branch Manager',
                    ),
                    const SizedBox(height: 16),

                    // Description
                    const Text('Description',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 6),
                    MyTextFormField(
                      controller: _descCtrl,
                      hintText: 'Brief description of this role',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Department dropdown
                    const Text('Department',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _department,
                          items: _departments
                              .map((d) => DropdownMenuItem(
                                  value: d, child: Text(d)))
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _department = val!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Active toggle
                    Row(
                      children: [
                        const Text('Status',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13)),
                        const SizedBox(width: 16),
                        Switch(
                          value: _isActive,
                          activeThumbColor: AppColors.blue,
                          onChanged: (val) =>
                              setState(() => _isActive = val),
                        ),
                        Text(_isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: _isActive
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            )),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Permissions section
                    const Text('Permissions',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 4),
                    const Text(
                      'Select which permissions this role should have',
                      style: TextStyle(
                          color: Color(0xFF64748B), fontSize: 12),
                    ),
                    const SizedBox(height: 12),

                    ..._permissionCategories.entries.map((entry) {
                      return _buildPermissionCategory(
                          entry.key, entry.value);
                    }),
                  ],
                ),
              ),
            ),

            const Divider(height: 1),

            // Footer buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  MyElevatedButton(
                    height: 40,
                    child: isEdit ? 'Save Changes' : 'Create Role',
                    onTap: _onSave,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCategory(
      String category, List<String> permissions) {
    final allSelected =
        permissions.every((p) => _selectedPermissions.contains(p));

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
                  _selectedPermissions.removeAll(permissions);
                } else {
                  _selectedPermissions.addAll(permissions);
                }
              });
            },
            child: Row(
              children: [
                Icon(
                  allSelected
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  size: 20,
                  color: allSelected ? AppColors.blue : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  category,
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
            children: permissions.map((perm) {
              final isSelected = _selectedPermissions.contains(perm);
              final label = perm
                  .replaceAll('_', ' ')
                  .split(' ')
                  .map((w) =>
                      w[0].toUpperCase() + w.substring(1))
                  .join(' ');

              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedPermissions.remove(perm);
                    } else {
                      _selectedPermissions.add(perm);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.blue.withValues(alpha: 0.1)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.blue
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        size: 14,
                        color: isSelected
                            ? AppColors.blue
                            : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? AppColors.blue
                              : const Color(0xFF64748B),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
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

// ═══════════════════════════════════════════════════════════════════════
//  VIEW ROLE DIALOG
// ═══════════════════════════════════════════════════════════════════════

class _ViewRoleDialog extends StatelessWidget {
  final _DummyRole role;
  const _ViewRoleDialog({required this.role});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title bar
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(role.name,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(role.description,
                            style: const TextStyle(
                                color: Color(0xFF64748B), fontSize: 13)),
                      ],
                    ),
                  ),
                  _buildStatusBadge(role.status),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Department', role.department),
                    _buildDetailRow(
                        'Users Assigned', '${role.usersAssigned}'),
                    _buildDetailRow('Created', role.createdAt),
                    const SizedBox(height: 16),
                    const Text('Permissions',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: role.permissions.map((perm) {
                        final label = perm
                            .replaceAll('_', ' ')
                            .split(' ')
                            .map((w) =>
                                w[0].toUpperCase() + w.substring(1))
                            .join(' ');
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                AppColors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle,
                                  size: 14, color: AppColors.blue),
                              const SizedBox(width: 6),
                              Text(label,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.blue,
                                    fontWeight: FontWeight.w500,
                                  )),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final bool isActive = status.toLowerCase() == 'active';
    final Color color = isActive ? Colors.green : Colors.red;

    return Container(
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
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
