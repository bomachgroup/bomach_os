import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
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
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text(
            'Upload Document',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildFormLabel('Document Name'),
        _buildDocumentNameInput(),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildFormLabel('Type'),
                  _buildDropdown(
                    value: 'Other',
                    items: const [
                      'Other',
                      'Contract',
                      'Invoice',
                      'Report',
                      'Image'
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildFormLabel('File Size(MB)'),
                  _buildTextInput(
                      initialValue: '0',
                      keyboardType: TextInputType.number),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildFormLabel('Client'),
        _buildDropdown(
          value: 'Select Client',
          items: const [
            'Select Client',
            'Lagos State Government',
            'Dangote Group',
            'FCDA'
          ],
        ),
        const SizedBox(height: 16),
        _buildFormLabel('Description'),
        _buildMultiLineTextInput(hint: ''),
      ],
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  Widget _buildTextInput(
      {String? hint,
      String? initialValue,
      TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDocumentNameInput() {
    return TextFormField(
      decoration: InputDecoration(
        hintText: '',
        suffixIcon: IconButton(
          icon: const Icon(Iconsax.document_upload, color: Colors.black87),
          onPressed: () {},
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildMultiLineTextInput({String? hint}) {
    return TextFormField(
      maxLines: 4,
      minLines: 3,
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDropdown({required String value, required List<String> items}) {
    return MyDropdown(
      hintText: value,
      items: items,
      onChanged: (String? newValue) {},
    );
  }
}
