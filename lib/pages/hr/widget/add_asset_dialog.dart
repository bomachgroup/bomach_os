import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/assets_controller.dart';
import '../models/assets_model.dart';

class AddAssetDialog extends StatefulWidget {
  final String token;
  final Asset? assetToEdit;

  const AddAssetDialog({super.key, required this.token, this.assetToEdit});

  @override
  State<AddAssetDialog> createState() => _AddAssetDialogState();
}

class _AddAssetDialogState extends State<AddAssetDialog> {
  final _formKey = GlobalKey<FormState>();
  final AssetController controller = Get.find();

  late TextEditingController nameCtrl;
  late TextEditingController serialCtrl;
  late TextEditingController manufacturerCtrl;
  late TextEditingController assignedToIdCtrl;
  late TextEditingController departmentIdCtrl;
  late TextEditingController purchaseDateCtrl;
  late TextEditingController valueCtrl;
  late TextEditingController vendorCtrl; // Added Vendor Controller
  late TextEditingController invoiceNumberCtrl;
  late TextEditingController warrantyDateCtrl;
  late TextEditingController notesCtrl;

  String? selectedAssetType;
  String? selectedBranch;
  String? selectedStatus;

  final List<String> assetTypes = [
    'Laptop',
    'Printer',
    'Vehicle',
    'Furniture',
    'Equipment',
    'IT Equipment'
  ];
  final List<String> branches = [
    'Enugu Branch',
    'Lagos Branch',
    'Abuja Branch'
  ];
  final List<String> statuses = [
    'available',
    'in-use',
    'maintenance',
    'retired'
  ];

  @override
  void initState() {
    super.initState();
    final a = widget.assetToEdit;

    nameCtrl = TextEditingController(text: a?.name ?? '');
    serialCtrl = TextEditingController(text: a?.serialNumber ?? '');
    manufacturerCtrl = TextEditingController(text: a?.manufacturer ?? '');
    assignedToIdCtrl = TextEditingController(text: a?.assignedToId ?? '');
    departmentIdCtrl = TextEditingController(text: a?.departmentId ?? '');
    purchaseDateCtrl = TextEditingController(
        text: a?.purchaseDate != null
            ? DateFormat('yyyy-MM-dd').format(a!.purchaseDate)
            : '');
    valueCtrl = TextEditingController(text: a?.value.toString() ?? '');
    vendorCtrl = TextEditingController(text: a?.vendor ?? '');
    invoiceNumberCtrl = TextEditingController(text: a?.invoiceNumber ?? '');
    warrantyDateCtrl = TextEditingController(
        text: a?.warrantyExpiryDate != null
            ? DateFormat('yyyy-MM-dd').format(a!.warrantyExpiryDate)
            : '');
    notesCtrl = TextEditingController(text: a?.notes ?? '');

    selectedAssetType = a?.assetType;
    selectedBranch = a?.branch;
    selectedStatus = a?.status;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    serialCtrl.dispose();
    manufacturerCtrl.dispose();
    assignedToIdCtrl.dispose();
    departmentIdCtrl.dispose();
    purchaseDateCtrl.dispose();
    valueCtrl.dispose();
    vendorCtrl.dispose();
    invoiceNumberCtrl.dispose();
    warrantyDateCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController ctrl) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      ctrl.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate Dropdowns manually if needed (assuming MyDropdown doesn't natively integrate with Form)
    if (selectedAssetType == null ||
        selectedBranch == null ||
        selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please select all dropdown options"),
          backgroundColor: Colors.red));
      return;
    }

    final newAsset = Asset(
      id: widget.assetToEdit?.id ?? '',
      name: nameCtrl.text,
      assetType: selectedAssetType!,
      branch: selectedBranch!,
      status: selectedStatus!,
      value: double.tryParse(valueCtrl.text) ?? 0.0,
      serialNumber: serialCtrl.text,
      manufacturer: manufacturerCtrl.text,
      assignedToId: assignedToIdCtrl.text,
      departmentId: departmentIdCtrl.text,
      purchaseDate: DateTime.parse(purchaseDateCtrl.text),
      vendor: vendorCtrl.text,
      invoiceNumber: invoiceNumberCtrl.text,
      warrantyExpiryDate: DateTime.parse(warrantyDateCtrl.text),
      notes: notesCtrl.text,
    );

    bool success;
    if (widget.assetToEdit != null) {
      success = await controller.updateAsset(
          widget.token, widget.assetToEdit!.id, newAsset);
    } else {
      success = await controller.createAsset(widget.token, newAsset);
    }

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Asset saved successfully"),
          backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Failed to save asset"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
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
                    MyText(
                        widget.assetToEdit == null
                            ? 'Add New Asset'
                            : 'Edit Asset',
                        size: 20,
                        weight: 600),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 24),
                const MyText('Asset Information', size: 16, weight: 600),
                const SizedBox(height: 16),
                MyTextFormField(
                    hintText: 'Asset Name',
                    controller: nameCtrl,
                    validator: _requiredValidator),
                kSizedBoxSM,
                MyDropdown(
                  title: 'Asset Type',
                  hintText: selectedAssetType ?? 'Select Type',
                  items: assetTypes,
                  onChanged: (value) =>
                      setState(() => selectedAssetType = value),
                ),
                kSizedBoxSM,
                MyTextFormField(
                    hintText: 'Serial Number',
                    controller: serialCtrl,
                    validator: _requiredValidator),
                kSizedBoxSM,
                MyTextFormField(
                    hintText: 'Manufacturer',
                    controller: manufacturerCtrl,
                    validator: _requiredValidator),
                const SizedBox(height: 24),
                const MyText('Location & Assignment', size: 16, weight: 600),
                const SizedBox(height: 16),
                MyDropdown(
                  title: "Branch",
                  hintText: selectedBranch ?? "Select Branch",
                  items: branches,
                  onChanged: (value) => setState(() => selectedBranch = value),
                ),
                kSizedBoxSM,
                MyTextFormField(
                    hintText: 'Assigned To ID',
                    controller: assignedToIdCtrl,
                    validator: _requiredValidator),
                kSizedBoxSM,
                MyTextFormField(
                    hintText: 'Department ID',
                    controller: departmentIdCtrl,
                    validator: _requiredValidator),
                const SizedBox(height: 24),
                const MyText('Financial Information', size: 16, weight: 600),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(purchaseDateCtrl),
                  child: IgnorePointer(
                      child: MyTextFormField(
                          hintText: 'Purchase Date (YYYY-MM-DD)',
                          controller: purchaseDateCtrl,
                          validator: _requiredValidator)),
                ),
                kSizedBoxSM,
                MyTextFormField(
                    hintText: 'Asset Value',
                    controller: valueCtrl,
                    validator: _requiredValidator,
                    keyboardType: TextInputType.number),
                kSizedBoxSM,
                MyTextFormField(
                    hintText: 'Vendor',
                    controller: vendorCtrl,
                    validator: _requiredValidator),
                kSizedBoxSM,
                MyTextFormField(
                    hintText: 'Invoice Number',
                    controller: invoiceNumberCtrl,
                    validator: _requiredValidator),
                const SizedBox(height: 24),
                const MyText('Status & Warranty', size: 16, weight: 600),
                const SizedBox(height: 16),
                MyDropdown(
                  title: 'Status',
                  hintText: selectedStatus ?? 'Select Status',
                  items: statuses,
                  onChanged: (value) => setState(() => selectedStatus = value),
                ),
                kSizedBoxSM,
                InkWell(
                  onTap: () => _selectDate(warrantyDateCtrl),
                  child: IgnorePointer(
                      child: MyTextFormField(
                          hintText: 'Warranty Expiry Date',
                          controller: warrantyDateCtrl,
                          validator: _requiredValidator)),
                ),
                kSizedBoxSM,
                MyTextFormField(
                    hintText: 'Additional Notes',
                    controller: notesCtrl,
                    maxLines: 3,
                    validator: _requiredValidator),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyOutlinedButton(
                        textColor: AppColors.darkGrey1,
                        child: 'Cancel',
                        onTap: () => Navigator.pop(context)),
                    const SizedBox(width: 12),
                    Obx(() => MyElevatedButton(
                          child: controller.isSaving.value
                              ? 'Saving...'
                              : 'Save Asset',
                          onTap: controller.isSaving.value ? () {} : _save,
                        )),
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
