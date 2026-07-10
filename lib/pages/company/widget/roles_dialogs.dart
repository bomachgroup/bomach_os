import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/role_model.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../controllers/roles_controller.dart';

class CreateEditRoleDialog extends StatefulWidget {
  final RolesController ctrl;
  final Role? role;

  const CreateEditRoleDialog({super.key, required this.ctrl, this.role});

  @override
  State<CreateEditRoleDialog> createState() => _CreateEditRoleDialogState();
}

class _CreateEditRoleDialogState extends State<CreateEditRoleDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _missionCtrl;
  final TextEditingController _permSearchCtrl = TextEditingController();

  late Set<int> _selectedBranchIds;
  late Map<String, Set<String>> _selectedPermissions;

  String _permSearch = '';
  int _permPage = 0;
  static const int _permPageSize = 8;

  Worker? _defaultsWorker;

  @override
  void initState() {
    super.initState();
    final role = widget.role;
    _nameCtrl = TextEditingController(text: role?.name ?? '');
    _missionCtrl = TextEditingController(text: role?.mission ?? '');

    _selectedBranchIds = {};
    if (role != null) {
      _selectedBranchIds = role.branches.map((b) => b.id).toSet();
    }

    _selectedPermissions = {};
    if (role != null) {
      role.permissions.forEach((resource, actions) {
        _selectedPermissions[resource] = Set<String>.from(actions);
      });
    } else {
      if (widget.ctrl.permissionsMap.isNotEmpty) {
        _seedDefaultPermissions();
      } else {
        _defaultsWorker = ever<Map<String, List<String>>>(
          widget.ctrl.permissionsMap,
          (map) {
            if (!mounted || map.isEmpty) return;
            setState(_seedDefaultPermissions);
            _defaultsWorker?.dispose();
            _defaultsWorker = null;
          },
        );
      }
    }
  }

  void _seedDefaultPermissions() {
    final available = widget.ctrl.permissionsMap;
    PermissionService.defaultEmployeePermissions.forEach((resource, actions) {
      final advertised = available[resource];
      if (advertised == null) return;
      final allowed = actions.where(advertised.contains).toSet();
      if (allowed.isNotEmpty) _selectedPermissions[resource] = allowed;
    });
  }

  @override
  void dispose() {
    _defaultsWorker?.dispose();
    _nameCtrl.dispose();
    _missionCtrl.dispose();
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

  void _onSave() async {
    if (_nameCtrl.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Role name is required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final permissions = <String, List<String>>{};
    _selectedPermissions.forEach((resource, actions) {
      if (actions.isNotEmpty) {
        permissions[resource] = actions.toList();
      }
    });

    final isEdit = widget.role != null;
    bool success;

    if (isEdit) {
      success = await widget.ctrl.updateRole(
        context,
        roleId: widget.role!.id,
        name: _nameCtrl.text.trim(),
        mission: _missionCtrl.text.trim(),
        branchIds: _selectedBranchIds.toList(),
        permissions: permissions,
      );
    } else {
      success = await widget.ctrl.createRole(
        context,
        name: _nameCtrl.text.trim(),
        mission: _missionCtrl.text.trim(),
        branchIds: _selectedBranchIds.toList(),
        permissions: permissions,
      );
    }

    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.role != null;

    return DialogScaffold(
      title: isEdit ? 'Edit Role' : 'Create New Role',
      subtitle: isEdit
          ? 'Update role details and permissions.'
          : 'Define a new role with branch scoping and permissions.',
      size: DialogSize.lg,
      body: Obx(() {
        if (widget.ctrl.isDepsLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final filtered = _filteredPermEntries;
        final totalPages = (filtered.length / _permPageSize).ceil();
        if (_permPage >= totalPages && totalPages > 0) {
          _permPage = totalPages - 1;
        }
        final pageStart = _permPage * _permPageSize;
        final pageEntries =
            filtered.skip(pageStart).take(_permPageSize).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Role Details',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Role Name', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  MyTextFormField(
                    controller: _nameCtrl,
                    hintText: 'e.g. Branch Manager',
                    height: 48,
                  ),
                  const SizedBox(height: 20),
                  const Text('Mission / Purpose', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  MyTextFormField(
                    controller: _missionCtrl,
                    hintText: 'e.g. Lead branch operations and drive revenue growth',
                    height: 72,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  const Text('Branches', style: AppTextStyles.label),
                  const Text(
                    'Select which branches this role applies to',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 12),
                  _buildBranchChips(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Permissions',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MyTextFormField(
                          controller: _permSearchCtrl,
                          hintText: 'Search permissions...',
                          height: 48,
                          leading: const Icon(Iconsax.search_normal,
                              color: AppColors.textMuted, size: 20),
                          onChanged: (v) => setState(() {
                            _permSearch = v;
                            _permPage = 0;
                          }),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _totalSelectedCount > 0
                          ? TextButton.icon(
                              onPressed: () =>
                                  setState(() => _selectedPermissions.clear()),
                              icon: const Icon(Iconsax.square, size: 18),
                              label: const Text('Unselect All'),
                              style: TextButton.styleFrom(
                                  foregroundColor: AppColors.danger),
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
                              icon: const Icon(Iconsax.tick_square, size: 18),
                              label: const Text('Select All'),
                              style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary),
                            ),
                    ],
                  ),
                  if (_totalSelectedCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Text(
                        '$_totalSelectedCount permissions selected',
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (filtered.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text('No matching permissions found',
                            style: TextStyle(color: AppColors.textMuted)),
                      ),
                    )
                  else ...[
                    ...pageEntries.map((entry) =>
                        _buildPermissionCategory(entry.key, entry.value)),
                    if (totalPages > 1) _buildPagination(totalPages),
                  ],
                ],
              ),
            ),
          ],
        );
      }),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          onTap: () => Navigator.pop(context),
        ),
        Obx(() => MyElevatedButton(
              width: 140,
              height: 44,
              onTap: widget.ctrl.isSaving.value ? null : _onSave,
              child: widget.ctrl.isSaving.value
                  ? 'Saving...'
                  : (isEdit ? 'Save Changes' : 'Create Role'),
            )),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: AppRadii.brLg,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildBranchChips() {
    final branches = widget.ctrl.branches;
    if (branches.isEmpty) {
      return Text('No branches available',
          style: AppTextStyles.caption.copyWith(color: AppColors.textMuted));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: branches.map((branch) {
        final isSelected = _selectedBranchIds.contains(branch.id);
        return InkWell(
          borderRadius: AppRadii.brMd,
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedBranchIds.remove(branch.id);
              } else {
                _selectedBranchIds.add(branch.id);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.surface,
              borderRadius: AppRadii.brMd,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.borderSubtle,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? Iconsax.tick_circle : Iconsax.record,
                  size: 16,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                ),
                const SizedBox(width: 8),
                Text(
                  branch.branchName,
                  style: AppTextStyles.bodySm.copyWith(
                    color:
                        isSelected ? AppColors.primary : AppColors.textPrimary,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brMd,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  allSelected ? Iconsax.tick_square : Iconsax.square,
                  size: 20,
                  color: allSelected ? AppColors.primary : AppColors.textMuted,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : AppColors.surfaceMuted,
                    borderRadius: AppRadii.brSm,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderSubtle,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? Iconsax.tick_circle : Iconsax.record,
                        size: 14,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        actionLabel,
                        style: AppTextStyles.caption.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
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

  Widget _buildPagination(int totalPages) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _permPage > 0 ? () => setState(() => _permPage--) : null,
            icon: const Icon(Iconsax.arrow_left_2),
            iconSize: 20,
          ),
          const SizedBox(width: 8),
          ...List.generate(totalPages, (i) {
            final isActive = i == _permPage;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: InkWell(
                onTap: () => setState(() => _permPage = i),
                borderRadius: AppRadii.brSm,
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : Colors.transparent,
                    borderRadius: AppRadii.brSm,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: AppTextStyles.bodySm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _permPage < totalPages - 1
                ? () => setState(() => _permPage++)
                : null,
            icon: const Icon(Iconsax.arrow_right_3),
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}
