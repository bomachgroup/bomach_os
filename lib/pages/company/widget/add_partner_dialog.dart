import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/partner_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../controllers/board_controller.dart';

class AddPartnerDialog extends StatefulWidget {
  final Partner? partner;
  const AddPartnerDialog({super.key, this.partner});

  @override
  State<AddPartnerDialog> createState() => _AddPartnerDialogState();
}

class _AddPartnerDialogState extends State<AddPartnerDialog> {
  final BoardController _controller = Get.find<BoardController>();
  final _formKey = GlobalKey<FormState>();

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

  String _categoryLabel(String value) {
    final match = _categoryOptions
        .firstWhere((e) => e['value'] == value, orElse: () => const {});
    return match['label'] ?? value;
  }

  String _statusLabel(String value) {
    final match = _statusOptions
        .firstWhere((e) => e['value'] == value, orElse: () => const {});
    return match['label'] ?? value;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
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
    return Obx(() => DialogScaffold(
          title: isEdit ? 'Edit Partner' : 'Add Partner',
          subtitle: isEdit
              ? 'Update partner details, category, and status.'
              : 'Register a new business partner with contact and category details.',
          size: DialogSize.lg,
          body: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  title: 'Partner information',
                  subtitle: 'Identify the partner and its contact details.',
                  child: Column(
                    children: [
                      MyTextFormField(
                        controller: _nameCtrl,
                        title: 'Partner Name',
                        hintText: 'e.g. ABC Technologies Ltd',
                        validator: (val) => (val == null || val.isEmpty)
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              controller: _emailCtrl,
                              title: 'Email',
                              hintText: 'contact@partner.com',
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MyTextFormField(
                              controller: _phoneCtrl,
                              title: 'Phone',
                              hintText: '+234...',
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      MyTextFormField(
                        controller: _addressCtrl,
                        title: 'Address',
                        hintText: 'Partner address',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Category & status',
                  subtitle:
                      'Classify the partnership and track its current state.',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: MyDropdown(
                          title: 'Category',
                          hintText: _categoryLabel(_selectedCategory),
                          items: _categoryOptions
                              .map((c) => c['label']!)
                              .toList(),
                          initialSelection: _categoryLabel(_selectedCategory),
                          onChanged: (val) {
                            for (final c in _categoryOptions) {
                              if (c['label'] == val) {
                                setState(() =>
                                    _selectedCategory = c['value'] ?? 'other');
                                break;
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MyDropdown(
                          title: 'Status',
                          hintText: _statusLabel(_selectedStatus),
                          items: _statusOptions
                              .map((s) => s['label']!)
                              .toList(),
                          initialSelection: _statusLabel(_selectedStatus),
                          onChanged: (val) {
                            for (final s in _statusOptions) {
                              if (s['label'] == val) {
                                setState(() =>
                                    _selectedStatus = s['value'] ?? 'inactive');
                                break;
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Notes',
                  child: MyTextFormField(
                    controller: _notesCtrl,
                    title: 'Additional Information',
                    hintText: 'Additional notes...',
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            MyOutlinedButton(
              child: 'Cancel',
              height: 44,
              onTap: () => Navigator.pop(context),
              textColor: AppColors.textSecondary,
              borderColor: AppColors.borderStrong,
            ),
            MyElevatedButton(
              width: 120,
              height: 44,
              child: _controller.isSavingPartner.value ? 'Saving...' : 'Save',
              onTap: _controller.isSavingPartner.value ? null : _submit,
              icon: _controller.isSavingPartner.value
                  ? null
                  : const Icon(Iconsax.tick_circle,
                      size: 18, color: AppColors.textOnPrimary),
            ),
          ],
        ));
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
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
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
