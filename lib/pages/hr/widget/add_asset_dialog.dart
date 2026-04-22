import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: AppColors.neutral50,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isEdit ? 'Edit Asset' : 'New Asset',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Asset Information ──────────────────────
                    const Text('Asset Information',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 12),

                    const Text('Asset Name',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 6),
                    MyTextFormField(
                      controller: _nameCtrl,
                      hintText: 'Type here',
                    ),
                    const SizedBox(height: 16),

                    const Text('Asset Type',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 6),
                    _buildDropdown(
                      value: _selectedAssetType,
                      hint: 'Select type',
                      items: _assetTypes,
                      onChanged: (val) =>
                          setState(() => _selectedAssetType = val),
                    ),
                    const SizedBox(height: 16),

                    const Text('Serial Number',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 6),
                    MyTextFormField(
                      controller: _serialCtrl,
                      hintText: 'Type here',
                    ),
                    const SizedBox(height: 16),

                    const Text('Manufacturer',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 6),
                    MyTextFormField(
                      controller: _manufacturerCtrl,
                      hintText: 'Type here',
                    ),
                    const SizedBox(height: 24),

                    // ─── Location & Assignment ──────────────────
                    const Text('Location & Assignment',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 12),

                    const Text('Branch',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 6),
                    _buildDropdown(
                      value: _selectedBranch,
                      hint: 'Select branch',
                      items:
                          controller.branches.where((b) => b != 'All').toList(),
                      onChanged: (val) => setState(() => _selectedBranch = val),
                    ),
                    const SizedBox(height: 16),

                    const Text('Assigned To',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 6),
                    Obx(() {
                      final employees = controller.allEmployees;
                      return _buildDropdown(
                        value: _selectedAssignedTo,
                        hint: 'Select employee',
                        items: employees.map((e) => e.id.toString()).toList(),
                        labels: employees
                            .map((e) => '${e.firstName} ${e.lastName}')
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedAssignedTo = val),
                      );
                    }),
                    const SizedBox(height: 16),

                    const Text('Department',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 6),
                    Obx(() {
                      final depts = controller.departments
                          .where((d) => d['id'] != 'All')
                          .toList();
                      return _buildDropdown(
                        value: _selectedDepartmentId,
                        hint: 'Select department',
                        items: depts.map((d) => d['id']!).toList(),
                        labels: depts.map((d) => d['name']!).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedDepartmentId = val),
                      );
                    }),
                    const SizedBox(height: 24),

                    // ─── Financial Information ──────────────────
                    const Text('Financial Information',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 12),

                    const Text('Purchase Date',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => _selectDate(_purchaseDateCtrl),
                      child: IgnorePointer(
                        child: MyTextFormField(
                          controller: _purchaseDateCtrl,
                          hintText: 'YYYY-MM-DD',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('Asset Value',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 6),
                    MyTextFormField(
                      controller: _valueCtrl,
                      hintText: '0.00',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    const Text('Vendor',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 6),
                    MyTextFormField(
                      controller: _vendorCtrl,
                      hintText: 'Type here',
                    ),
                    const SizedBox(height: 16),

                    const Text('Invoice Number',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 6),
                    MyTextFormField(
                      controller: _invoiceCtrl,
                      hintText: 'Type here',
                    ),
                    const SizedBox(height: 24),

                    // ─── Status & Warranty ──────────────────────
                    const Text('Status & Warranty',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 12),

                    const Text('Status',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 6),
                    _buildDropdown(
                      value: _selectedStatus,
                      hint: 'Select status',
                      items: _statuses,
                      onChanged: (val) => setState(() => _selectedStatus = val),
                    ),
                    const SizedBox(height: 16),

                    const Text('Warranty Expiry Date',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => _selectDate(_warrantyDateCtrl),
                      child: IgnorePointer(
                        child: MyTextFormField(
                          controller: _warrantyDateCtrl,
                          hintText: 'YYYY-MM-DD',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('Notes',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13)),
                    const SizedBox(height: 6),
                    MyTextFormField(
                      controller: _notesCtrl,
                      hintText: 'Type here',
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 1),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  Obx(() => MyElevatedButton(
                        height: 40,
                        icon: controller.isSaving.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Iconsax.tick_circle,
                                size: 16, color: Colors.white),
                        child: isEdit ? 'Save' : 'Create',
                        onTap: controller.isSaving.value ? null : _onSave,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    List<String>? labels,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: items.contains(value) ? value : null,
          hint: Text(hint,
              style: const TextStyle(color: AppColors.neutral400, fontSize: 14)),
          items: List.generate(items.length, (i) {
            return DropdownMenuItem(
              value: items[i],
              child: Text(labels != null ? labels[i] : items[i]),
            );
          }),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
