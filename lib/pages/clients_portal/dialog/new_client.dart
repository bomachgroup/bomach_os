import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:flutter/material.dart';

class AddPortalClientDialog extends StatelessWidget {
  const AddPortalClientDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddPortalClientDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final double dialogWidth = isMobile ? screenWidth * 0.9 : 450;
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        'Add Portal Client',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 16.0, 16.0),
      actionsPadding: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
      content: SingleChildScrollView(
        child: SizedBox(
          width: dialogWidth,
          child: Column(
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      actions: <Widget>[
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
            backgroundColor: AppColors.blue,
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
