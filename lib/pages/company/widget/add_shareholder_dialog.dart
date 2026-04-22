import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:bms_front_end/components/input/avatar_picker.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/model/company_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/company_controller.dart';

class AddShareholderDialog extends StatefulWidget {
  final Shareholder? shareholder;
  const AddShareholderDialog({super.key, this.shareholder});

  @override
  State<AddShareholderDialog> createState() => _AddShareholderDialogState();
}

class _AddShareholderDialogState extends State<AddShareholderDialog> {
  final CompanyController _controller = Get.find<CompanyController>();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _sharePercentageCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _passwordCtrl;

  String _selectedTitle = 'board_member';
  bool _isBoardMember = false;
  bool _isActive = true;
  XFile? _pickedAvatar;

  bool get isEdit => widget.shareholder != null;

  String _initials() {
    final f = _firstNameCtrl.text.trim();
    final l = _lastNameCtrl.text.trim();
    return '${f.isNotEmpty ? f[0] : ''}${l.isNotEmpty ? l[0] : ''}';
  }

  static const _titleOptions = [
    {'value': 'founder', 'label': 'Founder'},
    {'value': 'co_founder', 'label': 'Co-Founder'},
    {'value': 'board_member', 'label': 'Board Member'},
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.shareholder;
    _firstNameCtrl = TextEditingController(text: s?.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: s?.lastName ?? '');
    _emailCtrl = TextEditingController(text: s?.email ?? '');
    _phoneCtrl = TextEditingController(text: s?.phoneNumber ?? '');
    _sharePercentageCtrl =
        TextEditingController(text: s?.sharePercentage ?? '');
    _notesCtrl = TextEditingController(text: s?.notes ?? '');
    _passwordCtrl = TextEditingController();

    if (s != null) {
      _selectedTitle = s.title;
      _isBoardMember = s.isBoardMember;
      _isActive = s.isActive;
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _sharePercentageCtrl.dispose();
    _notesCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String _titleLabel(String value) {
    final match = _titleOptions
        .firstWhere((e) => e['value'] == value, orElse: () => const {});
    return match['label'] ?? value;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_firstNameCtrl.text.trim().isEmpty ||
        _lastNameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty) {
      AppToast.error(context, 'First name, last name, and email are required');
      return;
    }

    final data = <String, dynamic>{
      'first_name': _firstNameCtrl.text.trim(),
      'last_name': _lastNameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone_number': _phoneCtrl.text.trim(),
      'title': _selectedTitle,
      'share_percentage': _sharePercentageCtrl.text.trim().isNotEmpty
          ? _sharePercentageCtrl.text.trim()
          : '0',
      'is_board_member': _isBoardMember,
      'is_active': _isActive,
      if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
      if (_pickedAvatar != null) 'profile_picture_file': _pickedAvatar!.path,
    };

    if (!isEdit && _passwordCtrl.text.isNotEmpty) {
      data['password'] = _passwordCtrl.text;
    }

    if (isEdit) {
      _controller.updateShareholder(context, widget.shareholder!.id, data);
    } else {
      _controller.createShareholder(context, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => DialogScaffold(
          title: isEdit ? 'Edit Shareholder' : 'Add Shareholder',
          subtitle: isEdit
              ? 'Update shareholder profile, title, and ownership details.'
              : 'Register a new shareholder with profile and ownership details.',
          size: DialogSize.lg,
          body: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  title: 'Profile',
                  subtitle: 'Upload a photo and provide identifying information.',
                  child: Column(
                    children: [
                      Center(
                        child: AvatarPicker(
                          currentImageUrl: widget.shareholder?.profilePicture,
                          initials: _initials(),
                          pickedFile: _pickedAvatar,
                          onPicked: (f) =>
                              setState(() => _pickedAvatar = f),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              controller: _firstNameCtrl,
                              title: 'First Name',
                              hintText: 'e.g. John',
                              validator: (val) => (val == null || val.isEmpty)
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MyTextFormField(
                              controller: _lastNameCtrl,
                              title: 'Last Name',
                              hintText: 'e.g. Doe',
                              validator: (val) => (val == null || val.isEmpty)
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              controller: _emailCtrl,
                              title: 'Email',
                              hintText: 'e.g. john@company.com',
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) => (val == null || val.isEmpty)
                                  ? 'Required'
                                  : null,
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
                      if (!isEdit) ...[
                        const SizedBox(height: 16),
                        MyTextFormField(
                          controller: _passwordCtrl,
                          title: 'Password (optional)',
                          hintText:
                              'Creates a linked user account if provided',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Role & ownership',
                  subtitle:
                      'Set the shareholder title and their share percentage.',
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MyDropdown(
                              title: 'Title',
                              hintText: _titleLabel(_selectedTitle),
                              items: _titleOptions
                                  .map((t) => t['label']!)
                                  .toList(),
                              initialSelection: _titleLabel(_selectedTitle),
                              onChanged: (val) {
                                for (final t in _titleOptions) {
                                  if (t['label'] == val) {
                                    setState(() => _selectedTitle =
                                        t['value'] ?? 'board_member');
                                    break;
                                  }
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MyTextFormField(
                              controller: _sharePercentageCtrl,
                              title: 'Share Percentage',
                              hintText: 'e.g. 25.5',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadii.brMd,
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _isBoardMember,
                                  activeColor: AppColors.primary,
                                  onChanged: (v) => setState(
                                      () => _isBoardMember = v ?? false),
                                ),
                                Text(
                                  'Board Member',
                                  style: AppText.bodyMd.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Checkbox(
                                  value: _isActive,
                                  activeColor: AppColors.primary,
                                  onChanged: (v) =>
                                      setState(() => _isActive = v ?? true),
                                ),
                                Text(
                                  'Active',
                                  style: AppText.bodyMd.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
              child: _controller.isShareholdersLoading.value
                  ? 'Saving...'
                  : 'Save',
              onTap: _controller.isShareholdersLoading.value ? null : _submit,
              icon: _controller.isShareholdersLoading.value
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
          Text(title, style: AppText.h4),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppText.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
