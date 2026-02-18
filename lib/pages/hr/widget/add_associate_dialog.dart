import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Associate added successfully"), backgroundColor: Colors.green));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to add associate"), backgroundColor: Colors.red));
      }
    } else if (_selectedRole == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a role"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
             Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyText('Add New Associate', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),

             Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: MyTextFormField(title: 'First Name', controller: _firstNameCtrl)),
                          const SizedBox(width: 16),
                          Expanded(child: MyTextFormField(title: 'Last Name', controller: _lastNameCtrl)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      MyTextFormField(title: 'Email', controller: _emailCtrl),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: MyTextFormField(title: 'Phone', controller: _phoneCtrl)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MyDropdown(
                              title: 'Role',
                              items: _associateRoles,
                              hintText: _selectedRole ?? 'Select Role',
                              onChanged: (val) => setState(() => _selectedRole = val),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      MyTextFormField(title: 'Address', controller: _addressCtrl),
                      const SizedBox(height: 16),
                      MyTextFormField(title: 'Contract Value / Salary', controller: _grossSalaryCtrl, keyboardType: TextInputType.number),
                    ],
                  ),
                ),
              ),
            ),

             Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade300))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                    textColor: AppColors.darkGrey1,
                    child: 'Cancel',
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  Obx(() => MyElevatedButton(
                    icon: SvgPicture.asset("assets/svg/check.svg", colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn)),
                    child: controller.isSaving.value ? 'Saving...' : 'Add Associate',
                    onTap: controller.isSaving.value ? () {} : _submit,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}