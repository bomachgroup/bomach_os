import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:flutter/material.dart';

class GenerateSecurityCodeDialog extends StatefulWidget {
  const GenerateSecurityCodeDialog({super.key});

  @override
  State<GenerateSecurityCodeDialog> createState() =>
      _GenerateSecurityCodeDialogState();
}

class _GenerateSecurityCodeDialogState
    extends State<GenerateSecurityCodeDialog> {
  String? _selectedCodeType;
  String? _selectedAssignedTo;
  String? _selectedExpiresIn;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final double dialogWidth = isMobile ? screenWidth * 0.9 : 450;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        width: dialogWidth,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Generate Security Code',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: _buildFormContent(),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Code Type'),
        MyDropdown(
          hintText: 'Access Code',
          items: const ['Access Code', 'API Key', 'Two-Factor Token'],
          onChanged: (val) => setState(() => _selectedCodeType = val),
        ),
        const SizedBox(height: 24),
        _buildLabel('Description'),
        _buildTextFormField(
          hint: 'Describe your Target Audience',
          minLines: 3,
        ),
        const SizedBox(height: 24),
        _buildLabel('Assigned To'),
        MyDropdown(
          hintText: 'Select Person',
          items: const ['John Doe', 'Sarah Okwu', 'System Admin'],
          onChanged: (val) => setState(() => _selectedAssignedTo = val),
        ),
        const SizedBox(height: 24),
        _buildLabel('Expires in (days)'),
        MyDropdown(
          hintText: '30 days',
          items: const ['7 days', '30 days', '90 days', 'Never'],
          onChanged: (val) => setState(() => _selectedExpiresIn = val),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
      ),
    );
  }

  Widget _buildTextFormField({required String hint, int minLines = 1}) {
    return TextFormField(
      minLines: minLines,
      maxLines: null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
            child: const Text('Generate Code',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
