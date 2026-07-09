import 'dart:convert';
import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:bomach_os/src/helper/date_picker_helper.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:bomach_os/src/helper/responsive_breakpoints.dart';

import '../../../src/services/auth_service.dart';
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
  late final TextEditingController _imeiCtrl;
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

  // Custom asset type state
  bool _isCustomAssetType = false;
  late final TextEditingController _customAssetTypeCtrl;

  // File upload state
  List<Map<String, String>> _uploadedFiles = [];
  String _selectedUploadType = 'Image'; // Dropdown: Image, Document
  bool _isUploadingFile = false;

  bool get isEdit => widget.asset != null;

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
    _imeiCtrl = TextEditingController(text: a?.imei ?? '');

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
    _customAssetTypeCtrl = TextEditingController();
    if (_selectedAssetType != null && !controller.assetTypes.contains(_selectedAssetType)) {
      _isCustomAssetType = true;
      _customAssetTypeCtrl.text = _selectedAssetType!;
      _selectedAssetType = 'Other';
    }

    _selectedBranch = a?.branch.isNotEmpty == true ? a!.branch : null;
    _selectedDepartmentId =
        a?.departmentId.isNotEmpty == true ? a!.departmentId : null;
    _selectedStatus = a?.status.isNotEmpty == true ? a!.status : 'available';

    // Load existing uploaded files
    if (a != null && a.documents != null && a.documents!.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(a.documents!);
        _uploadedFiles = decoded.map((item) => Map<String, String>.from(item)).toList();
      } catch (_) {
        if (a.documents!.startsWith('http')) {
          _uploadedFiles = [
            {
              'name': 'Document',
              'url': a.documents!,
              'type': a.documents!.toLowerCase().endsWith('.jpg') ||
                      a.documents!.toLowerCase().endsWith('.png') ||
                      a.documents!.toLowerCase().endsWith('.jpeg')
                  ? 'Image'
                  : 'Document'
            }
          ];
        }
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _serialCtrl.dispose();
    _imeiCtrl.dispose();
    _manufacturerCtrl.dispose();
    _purchaseDateCtrl.dispose();
    _valueCtrl.dispose();
    _vendorCtrl.dispose();
    _invoiceCtrl.dispose();
    _warrantyDateCtrl.dispose();
    _notesCtrl.dispose();
    _customAssetTypeCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController ctrl) async {
    DateTime? picked = await showDatePopover(
      context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      ctrl.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _pickAndUploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: _selectedUploadType == 'Image' ? FileType.image : FileType.any,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) return;

      setState(() => _isUploadingFile = true);

      final token = await controller.getToken();
      if (token == null) {
        setState(() => _isUploadingFile = false);
        return;
      }

      final url = await AuthService().uploadFile(token, bytes, file.name);

      setState(() {
        _uploadedFiles.add({
          'name': file.name,
          'url': url,
          'type': _selectedUploadType,
        });
        _isUploadingFile = false;
      });
      if (mounted) {
        AppToast.success(context, 'File uploaded successfully');
      }
    } catch (e) {
      setState(() => _isUploadingFile = false);
      if (mounted) {
        AppToast.error(context, 'Failed to upload file: $e');
      }
    }
  }

  void _onSave() {
    if (_nameCtrl.text.trim().isEmpty) return;

    final finalAssetType = _selectedAssetType == 'Other'
        ? _customAssetTypeCtrl.text.trim()
        : (_selectedAssetType ?? '');

    final data = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'asset_type': finalAssetType,
      'serial_number': _serialCtrl.text.trim(),
      'imei': _imeiCtrl.text.trim().isNotEmpty ? _imeiCtrl.text.trim() : null,
      'manufacturer': _manufacturerCtrl.text.trim(),
      'branch': _selectedBranch ?? '',
      'assigned_to_id': (_selectedAssignedTo != null && _selectedAssignedTo!.isNotEmpty)
          ? int.tryParse(_selectedAssignedTo!)
          : null,
      'department_id': (_selectedDepartmentId != null && _selectedDepartmentId!.isNotEmpty)
          ? int.tryParse(_selectedDepartmentId!)
          : null,
      'purchase_date': _purchaseDateCtrl.text.trim().isNotEmpty ? _purchaseDateCtrl.text.trim() : null,
      'value': double.tryParse(_valueCtrl.text.trim()) ?? 0.0,
      'vendor': _vendorCtrl.text.trim().isNotEmpty ? _vendorCtrl.text.trim() : null,
      'invoice_number': _invoiceCtrl.text.trim().isNotEmpty ? _invoiceCtrl.text.trim() : null,
      'warranty_expiry_date': _warrantyDateCtrl.text.trim().isNotEmpty ? _warrantyDateCtrl.text.trim() : null,
      'status': _selectedStatus ?? 'available',
      'notes': _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      'documents': _uploadedFiles.isEmpty ? null : jsonEncode(_uploadedFiles),
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
              Obx(() {
                final typeItems = [...controller.assetTypes, 'Other'];
                return MyDropdown(
                  title: 'Asset Type',
                  hintText: _selectedAssetType ?? 'Select type',
                  initialSelection: _selectedAssetType,
                  spaceBetweenText: 8,
                  items: typeItems,
                  onChanged: (val) {
                    setState(() {
                      _selectedAssetType = val;
                      _isCustomAssetType = val == 'Other';
                    });
                  },
                );
              }),
              if (_isCustomAssetType) ...[
                const SizedBox(height: 16),
                MyTextFormField(
                  title: 'Custom Asset Type',
                  hintText: 'Enter asset type',
                  spaceBetweenText: 8,
                  controller: _customAssetTypeCtrl,
                ),
              ],
              const SizedBox(height: 16),
              ResponsiveRow(
                children: [
                  MyTextFormField(
                    title: 'Serial Number',
                    hintText: 'Enter serial number',
                    spaceBetweenText: 8,
                    controller: _serialCtrl,
                  ),
                  MyTextFormField(
                    title: 'IMEI',
                    hintText: 'Enter IMEI',
                    spaceBetweenText: 8,
                    controller: _imeiCtrl,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              MyTextFormField(
                title: 'Manufacturer',
                hintText: 'e.g. Apple',
                spaceBetweenText: 8,
                controller: _manufacturerCtrl,
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
              ResponsiveRow(
                children: [
                  MyTextFormField(
                    title: 'Purchase Date',
                    hintText: 'YYYY-MM-DD',
                    spaceBetweenText: 8,
                    controller: _purchaseDateCtrl,
                    readOnly: true,
                    trailing: const Icon(Iconsax.calendar_1,
                        size: 18, color: AppColors.textMuted),
                    onTap: () => _selectDate(_purchaseDateCtrl),
                  ),
                  MyTextFormField(
                    title: 'Asset Value',
                    hintText: '0.00',
                    spaceBetweenText: 8,
                    controller: _valueCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ResponsiveRow(
                children: [
                  MyTextFormField(
                    title: 'Vendor',
                    hintText: 'e.g. Bestbuy',
                    spaceBetweenText: 8,
                    controller: _vendorCtrl,
                  ),
                  MyTextFormField(
                    title: 'Invoice Number',
                    hintText: 'INV-XXXXX',
                    spaceBetweenText: 8,
                    controller: _invoiceCtrl,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Status & warranty',
            children: [
              ResponsiveRow(
                children: [
                  MyDropdown(
                    title: 'Status',
                    hintText: _selectedStatus ?? 'Select status',
                    initialSelection: _selectedStatus,
                    spaceBetweenText: 8,
                    items: _statuses,
                    onChanged: (val) =>
                        setState(() => _selectedStatus = val),
                  ),
                  MyTextFormField(
                    title: 'Warranty Expiry Date',
                    hintText: 'YYYY-MM-DD',
                    spaceBetweenText: 8,
                    controller: _warrantyDateCtrl,
                    readOnly: true,
                    trailing: const Icon(Iconsax.calendar_1,
                        size: 18, color: AppColors.textMuted),
                    onTap: () => _selectDate(_warrantyDateCtrl),
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
          const SizedBox(height: 16),
          _buildSection(
            title: 'Documents & Images',
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 2,
                    child: MyDropdown(
                      title: 'Upload Type',
                      hintText: _selectedUploadType,
                      initialSelection: _selectedUploadType,
                      spaceBetweenText: 8,
                      items: const ['Image', 'Document'],
                      onChanged: (val) =>
                          setState(() => _selectedUploadType = val ?? 'Image'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: _isUploadingFile
                        ? const Center(child: CircularProgressIndicator())
                        : MyElevatedButton(
                            height: 48,
                            icon: const Icon(Iconsax.document_upload,
                                size: 18, color: AppColors.textOnPrimary),
                            child: 'Upload $_selectedUploadType',
                            onTap: _pickAndUploadFile,
                          ),
                  ),
                ],
              ),
              if (_uploadedFiles.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(color: AppColors.borderSubtle),
                const SizedBox(height: 8),
                ..._uploadedFiles.asMap().entries.map((entry) {
                  final index = entry.key;
                  final file = entry.value;
                  final isImg = file['type'] == 'Image';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadii.brMd,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isImg ? Iconsax.image : Iconsax.document,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            file['name'] ?? 'File',
                            style: AppTextStyles.bodyMd.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Iconsax.trash,
                              color: AppColors.danger, size: 18),
                          onPressed: () {
                            setState(() {
                              _uploadedFiles.removeAt(index);
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: 18,
                        ),
                      ],
                    ),
                  );
                }),
              ],
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
          Text(title, style: AppTextStyles.h4),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
