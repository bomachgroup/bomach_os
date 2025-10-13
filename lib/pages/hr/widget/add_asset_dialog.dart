import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';

class AddAssetDialog extends StatefulWidget {
  const AddAssetDialog({super.key});

  @override
  State<AddAssetDialog> createState() => _AddAssetDialogState();
}

class _AddAssetDialogState extends State<AddAssetDialog> {
  final _formKey = GlobalKey<FormState>();
  String? selectedAssetType;
  String? selectedBranch;
  String? selectedStatus;

  final List<String> assetTypes = [
    'Laptop',
    'Printer',
    'Vehicle',
    'Furniture',
    'Equipment',
    'IT Equipment',
  ];

  final List<String> branches = [
    'Enugu Branch',
    'Lagos Branch',
    'Abuja Branch',
  ];

  final List<String> statuses = [
    'Available',
    'In Use',
    'Maintenance',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const MyText(
                      'Add New Asset',
                      size: 20,
                      weight: 600,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Asset Information Section
                const MyText(
                  'Asset Information',
                  size: 16,
                  weight: 600,
                ),
                const SizedBox(height: 16),
                const MyTextFormField(
                  hintText: 'Asset Name',
                ),
                kSizedBoxSM,
                DropdownButtonFormField<String>(
                  value: selectedAssetType,
                  decoration: const InputDecoration(
                    labelText: 'Asset Type',
                    border: OutlineInputBorder(),
                  ),
                  items: assetTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: MyText(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAssetType = value;
                    });
                  },
                ),
                kSizedBoxSM,
                const MyTextFormField(
                  hintText: 'Serial Number',
                ),
                kSizedBoxSM,
                const MyTextFormField(
                  hintText: 'Manufacturer',
                ),
                const SizedBox(height: 24),

                // Location & Assignment Section
                const MyText(
                  'Location & Assignment',
                  size: 16,
                  weight: 600,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedBranch,
                  decoration: const InputDecoration(
                    labelText: 'Branch',
                    border: OutlineInputBorder(),
                  ),
                  items: branches.map((branch) {
                    return DropdownMenuItem(
                      value: branch,
                      child: MyText(branch),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBranch = value;
                    });
                  },
                ),
                kSizedBoxSM,
                const MyTextFormField(
                  hintText: 'Assigned To (Name)',
                ),
                kSizedBoxSM,
                const MyTextFormField(
                  hintText: 'Email Address',
                ),
                kSizedBoxSM,
                const MyTextFormField(
                  hintText: 'Department',
                ),
                const SizedBox(height: 24),

                // Financial Information Section
                const MyText(
                  'Financial Information',
                  size: 16,
                  weight: 600,
                ),
                const SizedBox(height: 16),
                const MyTextFormField(
                  hintText: 'Purchase Date',
                ),
                kSizedBoxSM,
                const MyTextFormField(
                  hintText: 'Asset Value',
                ),
                kSizedBoxSM,
                const MyTextFormField(
                  hintText: 'Vendor/Supplier',
                ),
                kSizedBoxSM,
                const MyTextFormField(
                  hintText: 'Invoice Number',
                ),
                const SizedBox(height: 24),

                // Status & Warranty Section
                const MyText(
                  'Status & Warranty',
                  size: 16,
                  weight: 600,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: statuses.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: MyText(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                    });
                  },
                ),
                kSizedBoxSM,
                const MyTextFormField(
                  hintText: 'Warranty Expiry Date',
                ),
                kSizedBoxSM,
                const MyTextFormField(
                  hintText: 'Additional Notes',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Documents Section
                const MyText(
                  'Documents',
                  size: 16,
                  weight: 600,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.upload_file,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      MyText(
                        'Upload Documents',
                        size: 14,
                        weight: 400,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        'Invoice, Warranty, Manual, etc.',
                        size: 12,
                        weight: 300,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const MyText(
                        'Cancel',
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    MyElevatedButton(
                      child: 'Add Asset',
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          // Handle form submission
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
