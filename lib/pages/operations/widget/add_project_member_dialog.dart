import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

class AddProjectMemberDialog extends StatefulWidget {
  const AddProjectMemberDialog({super.key});

  @override
  State<AddProjectMemberDialog> createState() => AddProjectMemberDialogState();
}

class AddProjectMemberDialogState extends State<AddProjectMemberDialog> {
  final detailsCtrl = TextEditingController();
  String? _selectedEmployee;

  @override
  void dispose() {
    detailsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: 'Add Member',
      subtitle: 'Assign a team member to this project',
      size: DialogSize.md,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'Member details',
            child: Column(
              children: [
                MyDropdown(
                  hintText: 'Select employee',
                  title: 'Employee',
                  initialSelection: _selectedEmployee,
                  items: const [
                    'John Agbo',
                    'Emeka Carlos',
                    'Calistos Mba',
                  ],
                  onChanged: (val) =>
                      setState(() => _selectedEmployee = val),
                ),
                const SizedBox(height: 16),
                MyTextFormField(
                  controller: detailsCtrl,
                  maxLines: 4,
                  hintText: 'Add notes about this assignment...',
                  title: 'Details',
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          onTap: () => Navigator.pop(context),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        MyElevatedButton(
          width: 140,
          height: 44,
          child: 'Save Member',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h4),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
