import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';

import '../../../src/constants/colors.dart';

class UploadDocumentDialog extends StatelessWidget {
  const UploadDocumentDialog({super.key});

  static void show(BuildContext context) {
    DialogScaffold.show(
      context,
      title: 'Upload Document',
      size: DialogSize.sm,
      body: const UploadDocumentDialog(),
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
          child: const Text('Upload Document'),
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
          title: 'Document Name',
          hintText: 'Enter document name',
          trailing: Icon(Iconsax.document_upload, size: 20),
        ),
        SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _DropdownWithLabel(
                label: 'Type',
                value: 'Other',
                items: ['Other', 'Contract', 'Invoice', 'Report', 'Image'],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: MyTextFormField(
                title: 'File Size (MB)',
                initialValue: '0',
                keyboardType: TextInputType.number,
                hintText: '0',
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _DropdownWithLabel(
          label: 'Client',
          value: 'Select Client',
          items: [
            'Select Client',
            'Lagos State Government',
            'Dangote Group',
            'FCDA'
          ],
        ),
        SizedBox(height: 16),
        MyTextFormField(
          title: 'Description',
          hintText: 'Add a description...',
          maxLines: 4,
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
