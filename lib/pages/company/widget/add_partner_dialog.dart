import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/model/partner_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/board_controller.dart';

class AddPartnerDialog extends StatefulWidget {
  final Partner? partner;
  const AddPartnerDialog({super.key, this.partner});

  @override
  State<AddPartnerDialog> createState() => _AddPartnerDialogState();
}

class _AddPartnerDialogState extends State<AddPartnerDialog> {
  final BoardController _controller = Get.find<BoardController>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _notesCtrl;

  String _selectedCategory = 'other';
  String _selectedStatus = 'inactive';

  bool get isEdit => widget.partner != null;

  static const _categoryOptions = [
    {'value': 'technology', 'label': 'Technology'},
    {'value': 'finance', 'label': 'Finance'},
    {'value': 'marketing', 'label': 'Marketing'},
    {'value': 'legal', 'label': 'Legal'},
    {'value': 'consulting', 'label': 'Consulting'},
    {'value': 'logistics', 'label': 'Logistics'},
    {'value': 'real_estate', 'label': 'Real Estate'},
    {'value': 'construction', 'label': 'Construction'},
    {'value': 'other', 'label': 'Other'},
  ];

  static const _statusOptions = [
    {'value': 'active', 'label': 'Active'},
    {'value': 'inactive', 'label': 'Inactive'},
    {'value': 'suspended', 'label': 'Suspended'},
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.partner;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _emailCtrl = TextEditingController(text: p?.email ?? '');
    _phoneCtrl = TextEditingController(text: p?.phone ?? '');
    _addressCtrl = TextEditingController(text: p?.address ?? '');
    _notesCtrl = TextEditingController(text: p?.notes ?? '');

    if (p != null) {
      _selectedCategory = p.category.isNotEmpty ? p.category : 'other';
      _selectedStatus = p.status.isNotEmpty ? p.status : 'inactive';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty) {
      AppToast.error(context, 'Partner name is required');
      return;
    }

    final data = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'category': _selectedCategory,
      'status': _selectedStatus,
      'notes': _notesCtrl.text.trim(),
    };

    if (isEdit) {
      _controller.updatePartner(context, widget.partner!.id, data);
    } else {
      _controller.createPartner(context, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Colors.grey.shade300))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText(isEdit ? 'Edit Partner' : 'Add Partner',
                      style: AppText.h2),
                  IconButton(
                      icon: const Icon(Iconsax.close_circle),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyTextFormField(
                        title: 'Partner Name *',
                        controller: _nameCtrl,
                        hintText: 'e.g. ABC Technologies Ltd'),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                          child: MyTextFormField(
                              title: 'Email',
                              controller: _emailCtrl,
                              hintText: 'contact@partner.com')),
                      const SizedBox(width: 16),
                      Expanded(
                          child: MyTextFormField(
                              title: 'Phone',
                              controller: _phoneCtrl,
                              hintText: '+234...')),
                    ]),
                    const SizedBox(height: 16),
                    MyTextFormField(
                        title: 'Address',
                        controller: _addressCtrl,
                        hintText: 'Partner address'),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const MyText('Category',
                                style: AppText.h4),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedCategory,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: AppColors.neutral300)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: AppColors.neutral300)),
                              ),
                              items: _categoryOptions
                                  .map((c) => DropdownMenuItem<String>(
                                      value: c['value'],
                                      child: Text(c['label']!)))
                                  .toList(),
                              onChanged: (v) => setState(
                                  () => _selectedCategory = v ?? 'other'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const MyText('Status', style: AppText.h4),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedStatus,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: AppColors.neutral300)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: AppColors.neutral300)),
                              ),
                              items: _statusOptions
                                  .map((s) => DropdownMenuItem<String>(
                                      value: s['value'],
                                      child: Text(s['label']!)))
                                  .toList(),
                              onChanged: (v) => setState(
                                  () => _selectedStatus = v ?? 'inactive'),
                            ),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    MyTextFormField(
                        title: 'Notes',
                        controller: _notesCtrl,
                        maxLines: 3,
                        hintText: 'Additional notes...'),
                  ],
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                      child: 'Cancel',
                      textColor: Colors.black54,
                      onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 16),
                  Obx(() => MyElevatedButton(
                        child: _controller.isSavingPartner.value
                            ? 'Saving...'
                            : (isEdit ? 'Update' : 'Create'),
                        onTap:
                            _controller.isSavingPartner.value ? () {} : _submit,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
