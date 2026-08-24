import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/utils/password_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../src/model/employees_model.dart';
import '../controller/associate_controller.dart';

class AddAssociateDialog extends StatefulWidget {
  final String token;
  const AddAssociateDialog({super.key, required this.token});

  @override
  State<AddAssociateDialog> createState() => _AddAssociateDialogState();
}

class _AddAssociateDialogState extends State<AddAssociateDialog> {
  final AssociatesController controller = Get.find();
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _grossSalaryCtrl = TextEditingController();

  String? _selectedRole;

  final List<String> _associateRoles = [
    'surveyor-associate',
    'lawyer-associate',
    'architect-associate',
    'engineer-associate'
  ];

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _grossSalaryCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _selectedRole != null) {
      final newAssociate = Employee(
        id: '',
        email: _emailCtrl.text,
        firstName: _firstNameCtrl.text,
        lastName: _lastNameCtrl.text,
        phoneNumber: _phoneCtrl.text,
        address: _addressCtrl.text,
        employmentType: _selectedRole,
        grossSalary: double.tryParse(_grossSalaryCtrl.text),
        isActive: true,
      );

      // Audit V2: generate a unique strong password per associate instead
      // of shipping a known default inside the app bundle.
      final generatedPassword = generateStrongPassword();

      final success = await controller.createAssociate(
        widget.token,
        newAssociate,
        password: generatedPassword,
      );

      if (success && mounted) {
        await _showCredentialsDialog(generatedPassword);
        if (!mounted) return;
        Navigator.pop(context);
        AppToast.success(context, 'Associate added successfully');
      } else if (mounted) {
        AppToast.error(context, 'Failed to add associate');
      }
    } else if (_selectedRole == null) {
      AppToast.error(context, 'Please select a role');
    }
  }

  /// Show-once credentials dialog (audit V2). The password is displayed
  /// exactly here; the associate changes it after first login.
  Future<void> _showCredentialsDialog(String password) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => DialogScaffold(
        title: 'Associate created',
        subtitle:
            'Share these credentials with ${_firstNameCtrl.text.trim()} — '
            'they will not be shown again.',
        size: DialogSize.sm,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _credentialRow(
              label: 'Email',
              value: _emailCtrl.text.trim(),
              context: context,
            ),
            const SizedBox(height: 12),
            _credentialRow(
              label: 'Temporary password',
              value: password,
              context: context,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.info_circle,
                      color: AppColors.warning, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This password is shown once. Copy it now and ask '
                      'the associate to change it after first login.',
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          MyElevatedButton(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: 'Done',
            onTap: () => Navigator.pop(dialogContext),
          ),
        ],
      ),
    );
  }

  Widget _credentialRow({
    required String label,
    required String value,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value,
                    style: AppTextStyles.bodyMd
                        .copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Copy',
            icon: const Icon(Iconsax.copy, size: 18),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: value));
              if (context.mounted) AppToast.success(context, 'Copied');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: 'New Associate',
      subtitle: 'Add an external partner to the directory.',
      size: DialogSize.lg,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: MyTextFormField(
                    title: 'First Name*',
                    hintText: 'Enter first name',
                    controller: _firstNameCtrl,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MyTextFormField(
                    title: 'Last Name*',
                    hintText: 'Enter last name',
                    controller: _lastNameCtrl,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            MyTextFormField(
              title: 'Email*',
              hintText: 'email@example.com',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: MyTextFormField(
                    title: 'Phone',
                    hintText: '+234...',
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MyDropdown(
                    title: 'Role*',
                    items: _associateRoles,
                    hintText: _selectedRole ?? 'Select role',
                    onChanged: (val) =>
                        setState(() => _selectedRole = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            MyTextFormField(
              title: 'Address',
              hintText: 'Street, city, state',
              controller: _addressCtrl,
            ),
            const SizedBox(height: 20),
            MyTextFormField(
              title: 'Contract Value / Salary',
              hintText: 'e.g. 500000',
              controller: _grossSalaryCtrl,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
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
        Obx(() => MyElevatedButton(
              height: 44,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              icon: const Icon(Iconsax.tick_circle,
                  size: 18, color: AppColors.textOnPrimary),
              isLoading: controller.isSaving.value,
              child: 'Add Associate',
              onTap: controller.isSaving.value ? () {} : _submit,
            )),
      ],
    );
  }
}
