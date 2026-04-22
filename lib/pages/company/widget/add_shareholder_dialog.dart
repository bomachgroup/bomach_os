import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/avatar_picker.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/model/company_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  void _submit() {
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
                  MyText(isEdit ? 'Edit Shareholder' : 'Add Shareholder',
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
                    Center(
                      child: AvatarPicker(
                        currentImageUrl: widget.shareholder?.profilePicture,
                        initials: _initials(),
                        pickedFile: _pickedAvatar,
                        onPicked: (f) => setState(() => _pickedAvatar = f),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(
                          child: MyTextFormField(
                              title: 'First Name *',
                              controller: _firstNameCtrl,
                              hintText: 'e.g. John')),
                      const SizedBox(width: 16),
                      Expanded(
                          child: MyTextFormField(
                              title: 'Last Name *',
                              controller: _lastNameCtrl,
                              hintText: 'e.g. Doe')),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                          child: MyTextFormField(
                              title: 'Email *',
                              controller: _emailCtrl,
                              hintText: 'e.g. john@company.com')),
                      const SizedBox(width: 16),
                      Expanded(
                          child: MyTextFormField(
                              title: 'Phone',
                              controller: _phoneCtrl,
                              hintText: '+234...')),
                    ]),
                    const SizedBox(height: 16),
                    if (!isEdit) ...[
                      MyTextFormField(
                          title: 'Password (optional)',
                          controller: _passwordCtrl,
                          hintText:
                              'Creates a linked user account if provided'),
                      const SizedBox(height: 16),
                    ],
                    Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const MyText('Title', style: AppText.h4),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedTitle,
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
                              items: _titleOptions
                                  .map((t) => DropdownMenuItem<String>(
                                      value: t['value'],
                                      child: Text(t['label']!)))
                                  .toList(),
                              onChanged: (v) => setState(
                                  () => _selectedTitle = v ?? 'board_member'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                          child: MyTextFormField(
                              title: 'Share Percentage',
                              controller: _sharePercentageCtrl,
                              keyboardType: TextInputType.number,
                              hintText: 'e.g. 25.5')),
                    ]),
                    const SizedBox(height: 16),
                    MyTextFormField(
                        title: 'Notes',
                        controller: _notesCtrl,
                        maxLines: 3,
                        hintText: 'Additional notes...'),
                    const SizedBox(height: 16),
                    Row(children: [
                      Checkbox(
                          value: _isBoardMember,
                          activeColor: AppColors.primary,
                          onChanged: (v) =>
                              setState(() => _isBoardMember = v ?? false)),
                      const MyText('Board Member', style: AppText.bodyMd),
                      const SizedBox(width: 24),
                      Checkbox(
                          value: _isActive,
                          activeColor: AppColors.primary,
                          onChanged: (v) =>
                              setState(() => _isActive = v ?? true)),
                      const MyText('Active', style: AppText.bodyMd),
                    ]),
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
                        child: _controller.isShareholdersLoading.value
                            ? 'Saving...'
                            : (isEdit ? 'Update' : 'Create'),
                        onTap: _controller.isShareholdersLoading.value
                            ? () {}
                            : _submit,
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
