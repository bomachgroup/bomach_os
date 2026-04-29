import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/input/upload_file.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AddLeadDialog extends StatefulWidget {
  const AddLeadDialog({super.key});

  @override
  State<AddLeadDialog> createState() => _AddLeadDialogState();
}

class _AddLeadDialogState extends State<AddLeadDialog> {
  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: 'New Lead',
      subtitle: 'Capture a new recruitment lead for the pipeline.',
      size: DialogSize.lg,
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: MyTextFormField(
                  hintText: 'Enter contact name',
                  title: 'Contact Name*',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: MyTextFormField(
                  hintText: 'Enter phone number',
                  title: 'Phone Number*',
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: MyTextFormField(
                  hintText: 'email@example.com',
                  title: 'Email Address',
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: MyDropdown(
                  hintText: 'Select owner',
                  title: 'Lead owner',
                  items: [],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: MyDropdown(
                  items: ['Real Estate'],
                  hintText: 'Select service',
                  title: 'Service',
                ),
              ),
              SizedBox(width: 16),
              Spacer(),
            ],
          ),
          SizedBox(height: 20),
          MyTextFormField(
            maxLines: 4,
            hintText: 'Enter any relevant notes for this lead',
            title: 'Details',
          ),
          SizedBox(height: 20),
          _UploadSection(),
        ],
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
        MyElevatedButton(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          icon: const Icon(Iconsax.tick_circle,
              size: 18, color: AppColors.textOnPrimary),
          child: 'Save',
          onTap: () {},
        ),
      ],
    );
  }
}

class _UploadSection extends StatelessWidget {
  const _UploadSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'File (optional)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        UploadFile(),
      ],
    );
  }
}
