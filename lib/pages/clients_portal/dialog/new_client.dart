import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/src/constants/colors.dart';
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
            'Add Client',
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
        _buildFormLabel('Client Name'),
        _buildTextInput(hint: ''),
        const SizedBox(height: 16),
        _buildFormLabel('Email'),
        _buildTextInput(
            hint: '', keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        _buildFormLabel('Company'),
        _buildTextInput(hint: ''),
        const SizedBox(height: 16),
        _buildFormLabel('Access Level'),
        _buildDropdown(
          value: 'Standard',
          items: const ['Standard', 'Admin', 'View Only'],
        ),
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
      {String? hint, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
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

  Widget _buildDropdown({required String value, required List<String> items}) {
    return MyDropdown(
      hintText: value,
      items: items,
      onChanged: (String? newValue) {},
    );
  }
}
