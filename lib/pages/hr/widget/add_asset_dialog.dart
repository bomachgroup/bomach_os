import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../controller/assets_controller.dart';
import '../models/assets_model.dart';

// ═══════════════════════════════════════════════════════════════════════
//  CREATE / EDIT ASSET DIALOG
// ═══════════════════════════════════════════════════════════════════════

class AddAssetDialog extends StatefulWidget {
  final Asset? asset;
  const AddAssetDialog({super.key, this.asset});

  @override
  State<AddAssetDialog> createState() => _AddAssetDialogState();
}

class _AddAssetDialogState extends State<AddAssetDialog> {
  final AssetController controller = Get.find<AssetController>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _serialCtrl;
  late final TextEditingController _manufacturerCtrl;
  String? _selectedAssignedTo;
  late final TextEditingController _purchaseDateCtrl;
  late final TextEditingController _valueCtrl;
  late final TextEditingController _vendorCtrl;
  late final TextEditingController _invoiceCtrl;
  late final TextEditingController _warrantyDateCtrl;
  late final TextEditingController _notesCtrl;

  String? _selectedAssetType;
  String? _selectedBranch;
  String? _selectedDepartmentId;
  String? _selectedStatus;

  bool get isEdit => widget.asset != null;

  final List<String> _assetTypes = [
    'Laptop',
    'Printer',
    'Vehicle',
    'Furniture',
    'Equipment',
    'IT Equipment',
  ];
  final List<String> _statuses = [
    'available',
    'in-use',
    'maintenance',
    'retired',
  ];

  @override
  void initState() {
    super.initState();
    final a = widget.asset;
    _nameCtrl = TextEditingController(text: a?.name ?? '');
    _serialCtrl = TextEditingController(text: a?.serialNumber ?? '');
    _manufacturerCtrl = TextEditingController(text: a?.manufacturer ?? '');
    if (a != null && a.assignedToId.isNotEmpty) {
      _selectedAssignedTo = a.assignedToId;
    }
    _purchaseDateCtrl = TextEditingController(
        text: a != null ? DateFormat('yyyy-MM-dd').format(a.purchaseDate) : '');
    _valueCtrl =
        TextEditingController(text: a != null ? a.value.toString() : '');
    _vendorCtrl = TextEditingController(text: a?.vendor ?? '');
    _invoiceCtrl = TextEditingController(text: a?.invoiceNumber ?? '');
    _warrantyDateCtrl = TextEditingController(
        text: a != null
            ? DateFormat('yyyy-MM-dd').format(a.warrantyExpiryDate)
            : '');
    _notesCtrl = TextEditingController(text: a?.notes ?? '');

    _selectedAssetType = a?.assetType.isNotEmpty == true ? a!.assetType : null;
    _selectedBranch = a?.branch.isNotEmpty == true ? a!.branch : null;
    _selectedDepartmentId =
        a?.departmentId.isNotEmpty == true ? a!.departmentId : null;
    _selectedStatus = a?.status.isNotEmpty == true ? a!.status : 'available';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _serialCtrl.dispose();
    _manufacturerCtrl.dispose();
    // _selectedAssignedTo is not a controller, no dispose needed
    _purchaseDateCtrl.dispose();
    _valueCtrl.dispose();
    _vendorCtrl.dispose();
    _invoiceCtrl.dispose();
    _warrantyDateCtrl.dispose();
    _notesCtrl.dispose();
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

  void _onSave() {
    if (_nameCtrl.text.trim().isEmpty) return;

    final data = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'asset_type': _selectedAssetType ?? '',
      'serial_number': _serialCtrl.text.trim(),
      'manufacturer': _manufacturerCtrl.text.trim(),
      'branch': _selectedBranch ?? '',
      if (_selectedAssignedTo != null) 'assigned_to_id': _selectedAssignedTo,
      'department_id': _selectedDepartmentId ?? '',
      'purchase_date': _purchaseDateCtrl.text.trim(),
      'value': double.tryParse(_valueCtrl.text.trim()) ?? 0.0,
      'vendor': _vendorCtrl.text.trim(),
      'invoice_number': _invoiceCtrl.text.trim(),
      'warranty_expiry_date': _warrantyDateCtrl.text.trim(),
      'status': _selectedStatus ?? 'available',
      'notes': _notesCtrl.text.trim(),
    };

    if (isEdit) {
      controller.updateAsset(context, widget.asset!.id, data);
    } else {
      controller.createAsset(context, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: isEdit ? 'Edit Asset' : 'New Asset',
      subtitle: isEdit
          ? 'Update the details for this company asset.'
          : 'Capture the details of a new company asset.',
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'Asset information',
            children: [
              MyTextFormField(
                title: 'Asset Name',
                hintText: 'e.g. MacBook Pro 14"',
                spaceBetweenText: 8,
                controller: _nameCtrl,
              ),
              const SizedBox(height: 16),
              MyDropdown(
                title: 'Asset Type',
                hintText: _selectedAssetType ?? 'Select type',
                initialSelection: _selectedAssetType,
                spaceBetweenText: 8,
                items: _assetTypes,
                onChanged: (val) => setState(() => _selectedAssetType = val),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: MyTextFormField(
                      title: 'Serial Number',
                      hintText: 'Enter serial number',
                      spaceBetweenText: 8,
                      controller: _serialCtrl,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MyTextFormField(
                      title: 'Manufacturer',
                      hintText: 'e.g. Apple',
                      spaceBetweenText: 8,
                      controller: _manufacturerCtrl,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Location & assignment',
            children: [
              MyDropdown(
                title: 'Branch',
                hintText: _selectedBranch ?? 'Select branch',
                initialSelection: _selectedBranch,
                spaceBetweenText: 8,
                items:
                    controller.branches.where((b) => b != 'All').toList(),
                onChanged: (val) => setState(() => _selectedBranch = val),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final employees = controller.allEmployees;
                final ids = employees.map((e) => e.id.toString()).toList();
                final labels = employees
                    .map((e) => '${e.firstName} ${e.lastName}')
                    .toList();
                final currentLabel = _selectedAssignedTo == null
                    ? null
                    : (() {
                        final idx = ids.indexOf(_selectedAssignedTo!);
                        return idx >= 0 ? labels[idx] : null;
                      })();
                return MyDropdown(
                  title: 'Assigned To',
                  hintText: currentLabel ?? 'Select employee',
                  initialSelection: currentLabel,
                  spaceBetweenText: 8,
                  items: labels,
                  onChanged: (val) {
                    if (val == null) return;
                    final idx = labels.indexOf(val);
                    setState(() {
                      _selectedAssignedTo = idx >= 0 ? ids[idx] : null;
                    });
                  },
                );
              }),
              const SizedBox(height: 16),
              Obx(() {
                final depts = controller.departments
                    .where((d) => d['id'] != 'All')
                    .toList();
                final ids =
                    depts.map((d) => d['id']!).toList(growable: false);
                final names =
                    depts.map((d) => d['name']!).toList(growable: false);
                final currentLabel = _selectedDepartmentId == null
                    ? null
                    : (() {
                        final idx = ids.indexOf(_selectedDepartmentId!);
                        return idx >= 0 ? names[idx] : null;
                      })();
                return MyDropdown(
                  title: 'Department',
                  hintText: currentLabel ?? 'Select department',
                  initialSelection: currentLabel,
                  spaceBetweenText: 8,
                  items: names,
                  onChanged: (val) {
                    if (val == null) return;
                    final idx = names.indexOf(val);
                    setState(() {
                      _selectedDepartmentId = idx >= 0 ? ids[idx] : null;
                    });
                  },
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Financial information',
            children: [
              Row(
                children: [
                  Expanded(
                    child: MyTextFormField(
                      title: 'Purchase Date',
                      hintText: 'YYYY-MM-DD',
                      spaceBetweenText: 8,
                      controller: _purchaseDateCtrl,
                      readOnly: true,
                      trailing: const Icon(Iconsax.calendar_1,
                          size: 18, color: AppColors.textMuted),
                      onTap: () => _selectDate(_purchaseDateCtrl),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MyTextFormField(
                      title: 'Asset Value',
                      hintText: '0.00',
                      spaceBetweenText: 8,
                      controller: _valueCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: MyTextFormField(
                      title: 'Vendor',
                      hintText: 'e.g. Bestbuy',
                      spaceBetweenText: 8,
                      controller: _vendorCtrl,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MyTextFormField(
                      title: 'Invoice Number',
                      hintText: 'INV-XXXXX',
                      spaceBetweenText: 8,
                      controller: _invoiceCtrl,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Status & warranty',
            children: [
              Row(
                children: [
                  Expanded(
                    child: MyDropdown(
                      title: 'Status',
                      hintText: _selectedStatus ?? 'Select status',
                      initialSelection: _selectedStatus,
                      spaceBetweenText: 8,
                      items: _statuses,
                      onChanged: (val) =>
                          setState(() => _selectedStatus = val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MyTextFormField(
                      title: 'Warranty Expiry Date',
                      hintText: 'YYYY-MM-DD',
                      spaceBetweenText: 8,
                      controller: _warrantyDateCtrl,
                      readOnly: true,
                      trailing: const Icon(Iconsax.calendar_1,
                          size: 18, color: AppColors.textMuted),
                      onTap: () => _selectDate(_warrantyDateCtrl),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              MyTextFormField(
                title: 'Notes',
                hintText: 'Additional notes about this asset',
                spaceBetweenText: 8,
                controller: _notesCtrl,
                maxLines: 3,
              ),
            ],
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
          onTap: () => Navigator.pop(context),
        ),
        Obx(() => MyElevatedButton(
              height: 44,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              icon: controller.isSaving.value
                  ? null
                  : const Icon(Iconsax.tick_circle,
                      size: 18, color: AppColors.textOnPrimary),
              child: controller.isSaving.value
                  ? 'Saving...'
                  : (isEdit ? 'Save' : 'Create'),
              onTap: controller.isSaving.value ? null : _onSave,
            )),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.h4),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
