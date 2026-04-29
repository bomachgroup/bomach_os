import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:flutter/material.dart';

class AddPortalClientDialog extends StatelessWidget {
  const AddPortalClientDialog({super.key});

  static void show(BuildContext context) {
    DialogScaffold.show(
      context,
      title: 'Add Portal Client',
      size: DialogSize.sm,
      body: const AddPortalClientDialog(),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 0,
          ),
          child: const Text('Add Client'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        MyTextFormField(
          title: 'Client Name',
          hintText: 'Enter client name',
        ),
        SizedBox(height: 16),
        MyTextFormField(
          title: 'Email',
          hintText: 'client@example.com',
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16),
        MyTextFormField(
          title: 'Company',
          hintText: 'Company name',
        ),
        SizedBox(height: 16),
        _DropdownWithLabel(
          label: 'Access Level',
          value: 'Standard',
          items: ['Standard', 'Admin', 'View Only'],
        ),
      ],
    );
  }
}

class _DropdownWithLabel extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;

  const _DropdownWithLabel({
    required this.label,
    required this.value,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        MyDropdown(
          hintText: value,
          items: items,
          onChanged: (String? newValue) {},
        ),
      ],
    );
  }
}
