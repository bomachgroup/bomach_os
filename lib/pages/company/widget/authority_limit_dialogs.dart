import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/pages/company/controllers/authority_limit_controller.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/authority_limit_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CreateEditAuthorityLimitDialog extends StatefulWidget {
  final AuthorityLimitController controller;
  final AuthorityLimit? limit;

  const CreateEditAuthorityLimitDialog({
    super.key,
    required this.controller,
    this.limit,
  });

  @override
  State<CreateEditAuthorityLimitDialog> createState() =>
      _CreateEditAuthorityLimitDialogState();
}

class _CreateEditAuthorityLimitDialogState
    extends State<CreateEditAuthorityLimitDialog> {
  // Text controllers for MyDropdown (string-based)
  late final TextEditingController _roleCtrl;
  late final TextEditingController _resourceCtrl;
  late final TextEditingController _actionCtrl;
  late final TextEditingController _currencyCtrl;
  late final TextEditingController _approvalLevelCtrl;

  // Text controllers for free-form fields
  late final TextEditingController _maxAmountCtrl;
  late final TextEditingController _maxQuantityCtrl;
  late final TextEditingController _conditionsCtrl;

  List<int> _selectedApproverRoleIds = [];
  bool _requiresSequentialApproval = false;

  // Tracks current approver role picker selection (int id as string)
  int? _pendingApproverRoleId;

  final List<String> _resources = [
    'expenses',
    'budgets',
    'payments',
    'contracts',
    'purchase_orders',
    'invoices',
    'leave_requests',
    'travel_requests',
    'reimbursements',
    'assets',
    'projects',
    'vendors',
  ];

  final List<String> _actions = [
    'create',
    'read',
    'update',
    'delete',
    'approve',
    'reject',
    'submit',
    'cancel',
    'view',
    'export',
  ];

  final List<String> _currencies = ['NGN', 'USD', 'EUR', 'GBP'];
  final List<String> _approvalLevels = [
    'supervisor',
    'manager',
    'director',
    'vp',
    'c-level',
  ];

  @override
  void initState() {
    super.initState();
    final limit = widget.limit;

    _roleCtrl = TextEditingController(
      text: limit != null ? _roleNameForId(limit.roleId) : null,
    );
    _resourceCtrl = TextEditingController(text: limit?.resource);
    _actionCtrl = TextEditingController(text: limit?.action);
    _currencyCtrl = TextEditingController(text: limit?.currency ?? 'NGN');
    _approvalLevelCtrl = TextEditingController(text: limit?.approvalLevel);
    _maxAmountCtrl =
        TextEditingController(text: limit?.maxAmount?.toString() ?? '');
    _maxQuantityCtrl =
        TextEditingController(text: limit?.maxQuantity?.toString() ?? '');
    _conditionsCtrl = TextEditingController(text: limit?.conditions ?? '');

    if (limit != null) {
      _selectedApproverRoleIds = List.from(limit.requiredApproverRoleIds);
      _requiresSequentialApproval = limit.requiresSequentialApproval;
    }
  }

  String _roleNameForId(String roleId) {
    return widget.controller.roles
            .firstWhereOrNull((r) => r.id.toString() == roleId)
            ?.name ??
        '';
  }

  String? get _selectedRoleId {
    final name = _roleCtrl.text.trim();
    if (name.isEmpty) return null;
    return widget.controller.roles
        .firstWhereOrNull((r) => r.name == name)
        ?.id
        .toString();
  }

  @override
  void dispose() {
    _roleCtrl.dispose();
    _resourceCtrl.dispose();
    _actionCtrl.dispose();
    _currencyCtrl.dispose();
    _approvalLevelCtrl.dispose();
    _maxAmountCtrl.dispose();
    _maxQuantityCtrl.dispose();
    _conditionsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.limit != null;
    final controller = widget.controller;

    return DialogScaffold(
      title: isEdit ? 'Edit Authority Limit' : 'Create Authority Limit',
      subtitle: isEdit
          ? 'Update authority limit configuration'
          : 'Define a new authority limit for a role',
      size: DialogSize.lg,
      body: Obx(() {
        if (controller.isLoading.value && controller.roles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Role & Action',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRoleDropdown(controller),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildResourceDropdown()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildActionDropdown()),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Financial Limits',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MyTextFormField(
                          controller: _maxAmountCtrl,
                          title: 'Maximum Amount',
                          hintText: 'e.g. 100000',
                          keyboardType: TextInputType.number,
                          height: 48,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: _buildCurrencyDropdown()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: MyTextFormField(
                          controller: _maxQuantityCtrl,
                          title: 'Maximum Quantity',
                          hintText: 'e.g. 10',
                          keyboardType: TextInputType.number,
                          height: 48,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: _buildApprovalLevelDropdown()),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Approval Configuration',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildApproverRoleSelector(controller),
                  const SizedBox(height: 16),
                  _buildSequentialApprovalToggle(),
                  const SizedBox(height: 16),
                  MyTextFormField(
                    controller: _conditionsCtrl,
                    title: 'Conditions (Optional)',
                    hintText:
                        'e.g. Only for amounts above threshold, specific departments, etc.',
                    maxLines: 3,
                  ),
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
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        MyElevatedButton(
          height: 44,
          isLoading: widget.controller.isSaving.value,
          child: isEdit ? 'Save Changes' : 'Create Authority Limit',
          onTap: _onSave,
        ),
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

  Widget _buildRoleDropdown(AuthorityLimitController controller) {
    return MyDropdown(
      controller: _roleCtrl,
      hintText: 'Select a role',
      title: 'Role *',
      initialSelection: _roleCtrl.text.isNotEmpty ? _roleCtrl.text : null,
      items: controller.roles.map((r) => r.name).toList(),
      onChanged: (_) => setState(() {}),
      validator: (v) => (v == null || v.isEmpty) ? 'Role is required' : null,
    );
  }

  Widget _buildResourceDropdown() {
    return MyDropdown(
      controller: _resourceCtrl,
      hintText: 'Select resource',
      title: 'Resource *',
      initialSelection:
          _resourceCtrl.text.isNotEmpty ? _resourceCtrl.text : null,
      items: _resources,
      leading: const Icon(Iconsax.box_1, size: 18, color: AppColors.textMuted),
    );
  }

  Widget _buildActionDropdown() {
    return MyDropdown(
      controller: _actionCtrl,
      hintText: 'Select action',
      title: 'Action *',
      initialSelection: _actionCtrl.text.isNotEmpty ? _actionCtrl.text : null,
      items: _actions,
      leading:
          const Icon(Iconsax.flash_1, size: 18, color: AppColors.textMuted),
    );
  }

  Widget _buildCurrencyDropdown() {
    return MyDropdown(
      controller: _currencyCtrl,
      hintText: 'Currency',
      title: 'Currency',
      initialSelection:
          _currencyCtrl.text.isNotEmpty ? _currencyCtrl.text : null,
      items: _currencies,
    );
  }

  Widget _buildApprovalLevelDropdown() {
    return MyDropdown(
      controller: _approvalLevelCtrl,
      hintText: 'Select Level',
      title: 'Approval Level',
      initialSelection:
          _approvalLevelCtrl.text.isNotEmpty ? _approvalLevelCtrl.text : null,
      items: _approvalLevels,
    );
  }

  Widget _buildApproverRoleSelector(AuthorityLimitController controller) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Required Approver Roles',
                  hintText: 'Select approver role',
                  border: OutlineInputBorder(borderRadius: AppRadii.brMd),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                initialValue: _pendingApproverRoleId,
                items: controller.roles
                    .map((r) => DropdownMenuItem<int>(
                          value: r.id,
                          child: Text(r.name),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null && !_selectedApproverRoleIds.contains(v)) {
                    setState(() {
                      _selectedApproverRoleIds.add(v);
                      _pendingApproverRoleId = null;
                    });
                  }
                },
              ),
            ),
            if (_selectedApproverRoleIds.isNotEmpty) ...[
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: () => setState(() {
                  _selectedApproverRoleIds.clear();
                  _pendingApproverRoleId = null;
                }),
                icon: const Icon(Iconsax.trash,
                    size: 16, color: AppColors.danger),
                label: const Text('Clear All',
                    style: TextStyle(color: AppColors.danger)),
              ),
            ],
          ],
        ),
        if (_selectedApproverRoleIds.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedApproverRoleIds.map((id) {
              final roleName =
                  controller.roles.firstWhereOrNull((r) => r.id == id)?.name ??
                      'Unknown';
              return Chip(
                label: Text(roleName),
                onDeleted: () =>
                    setState(() => _selectedApproverRoleIds.remove(id)),
                deleteIcon: const Icon(Iconsax.close_square, size: 16),
                backgroundColor: AppColors.primarySubtle,
                side: BorderSide.none,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSequentialApprovalToggle() {
    return Row(
      children: [
        Checkbox(
          value: _requiresSequentialApproval,
          onChanged: (v) =>
              setState(() => _requiresSequentialApproval = v ?? false),
          activeColor: AppColors.primary,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Requires Sequential Approval',
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Each approver must approve in sequence before the next can act',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onSave() async {
    final roleId = _selectedRoleId;
    if (roleId == null) {
      Get.snackbar('Validation', 'Please select a role',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final resource = _resourceCtrl.text.trim();
    final action = _actionCtrl.text.trim();
    if (resource.isEmpty || action.isEmpty) {
      Get.snackbar('Validation', 'Please select resource and action',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final isEdit = widget.limit != null;

    bool success;
    if (isEdit) {
      success = await widget.controller.updateAuthorityLimit(
        context,
        id: widget.limit!.id.toString(),
        resource: resource,
        action: action,
        maxAmount: _maxAmountCtrl.text.isNotEmpty
            ? double.tryParse(_maxAmountCtrl.text)
            : null,
        currency: _currencyCtrl.text.isNotEmpty ? _currencyCtrl.text : null,
        maxQuantity: _maxQuantityCtrl.text.isNotEmpty
            ? int.tryParse(_maxQuantityCtrl.text)
            : null,
        conditions:
            _conditionsCtrl.text.isNotEmpty ? _conditionsCtrl.text : null,
        approvalLevel:
            _approvalLevelCtrl.text.isNotEmpty ? _approvalLevelCtrl.text : null,
        requiredApproverRoleIds: _selectedApproverRoleIds,
        requiresSequentialApproval: _requiresSequentialApproval,
      );
    } else {
      success = await widget.controller.createAuthorityLimit(
        context,
        roleId: roleId,
        resource: resource,
        action: action,
        maxAmount: _maxAmountCtrl.text.isNotEmpty
            ? double.tryParse(_maxAmountCtrl.text)
            : null,
        currency: _currencyCtrl.text.isNotEmpty ? _currencyCtrl.text : null,
        maxQuantity: _maxQuantityCtrl.text.isNotEmpty
            ? int.tryParse(_maxQuantityCtrl.text)
            : null,
        conditions:
            _conditionsCtrl.text.isNotEmpty ? _conditionsCtrl.text : null,
        approvalLevel:
            _approvalLevelCtrl.text.isNotEmpty ? _approvalLevelCtrl.text : null,
        requiredApproverRoleIds: _selectedApproverRoleIds,
        requiresSequentialApproval: _requiresSequentialApproval,
      );
    }

    if (success && mounted) {
      Navigator.of(context).pop();
      Get.snackbar(
        'Success',
        isEdit ? 'Authority limit updated' : 'Authority limit created',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
      );
    }
  }
}
