import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:flutter/material.dart';
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

      final success = await controller.createAssociate(
        widget.token,
        newAssociate,
        password: 'Password123!',
      );

      if (success && mounted) {
        Navigator.pop(context);
        AppToast.success(context, 'Associate added successfully');
      } else if (mounted) {
        AppToast.error(context, 'Failed to add associate');
      }
    } else if (_selectedRole == null) {
      AppToast.error(context, 'Please select a role');
    }
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
