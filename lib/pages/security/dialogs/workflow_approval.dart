import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';

class CreateApprovalWorkflowDialog extends StatelessWidget {
  const CreateApprovalWorkflowDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    final double dialogWidth = isSmallScreen ? screenWidth * 0.9 : 500;

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
                    'Create Approval Workflow',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Iconsax.close_circle, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.neutral200),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: _buildFormContent(),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.neutral200),
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
        _buildLabel('Workflow Name'),
        _buildTextFormField(
          initialValue: 'High-Value Transaction Approval',
          hint: 'Enter workflow name',
        ),
        const SizedBox(height: 24),
        _buildLabel('Description'),
        _buildTextFormField(
          hint: 'Describe when this workflow should be triggered',
          minLines: 3,
        ),
        const SizedBox(height: 24),
        _buildLabel('Trigger Condition'),
        _buildTextFormField(
          initialValue: 'Transaction amount',
          hint: 'Enter trigger condition',
        ),
        const SizedBox(height: 24),
        _buildLabel('Approver Role'),
        MyDropdown(
          hintText: 'Manager',
          items: const [
            'Manager',
            'Director',
            'System Admin',
            'Financial Officer'
          ],
          onChanged: (String? newValue) {},
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

  Widget _buildTextFormField(
      {String? initialValue, required String hint, int minLines = 1}) {
    return TextFormField(
      initialValue: initialValue,
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
            child: const Text('Create Workflow',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
