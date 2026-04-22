import 'dart:developer';
import 'package:iconsax/iconsax.dart';

import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/avatar_picker.dart';
import 'package:bms_front_end/components/input/my_date_field.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/pages/auth/controller.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/model/user_model.dart';
import 'package:bms_front_end/src/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// Modern edit-profile dialog. Uses the app's reusable input components so
/// styling stays consistent with the rest of the product. Backed by
/// [AuthService.updateMe]; the backend currently accepts username, phone,
/// address, DOB, gender, marital status — picture upload stored locally
/// until a dedicated endpoint exists.
class EditProfileDialog extends StatefulWidget {
  final User user;
  const EditProfileDialog({super.key, required this.user});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _storage = const FlutterSecureStorage();

  late final TextEditingController _usernameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _dobCtrl;

  String? _gender;
  String? _maritalStatus;
  XFile? _pickedAvatar;
  bool _saving = false;

  static const _genders = ['Male', 'Female', 'Other'];
  static const _maritalStatuses = ['Single', 'Married', 'Divorced', 'Widowed'];

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController(text: widget.user.username);
    _phoneCtrl = TextEditingController(text: widget.user.phoneNumber ?? '');
    _addressCtrl = TextEditingController(text: widget.user.address ?? '');
    _dobCtrl = TextEditingController(text: widget.user.dateOfBirth ?? '');
    _gender = _genders.contains(widget.user.gender) ? widget.user.gender : null;
    _maritalStatus = _maritalStatuses.contains(widget.user.maritalStatus)
        ? widget.user.maritalStatus
        : null;
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    return token.startsWith('Bearer ')
        ? token.replaceFirst('Bearer ', '')
        : token.replaceAll('"', '').trim();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    try {
      final token = await _getToken();
      if (token == null || !mounted) return;

      final updatedUser = await _authService.updateMe(
        accessToken: token,
        employeeId: widget.user.id,
        username: _usernameCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        dateOfBirth:
            _dobCtrl.text.trim().isNotEmpty ? _dobCtrl.text.trim() : null,
        gender: _gender,
        maritalStatus: _maritalStatus,
      );

      Get.find<AuthController>().currentUser.value = updatedUser;

      if (!mounted) return;
      Navigator.of(context).pop();
      AppToast.success(context, 'Profile updated successfully');
    } catch (e) {
      log('Update profile error: $e');
      if (mounted) {
        AppToast.error(context, 'Failed to update profile: $e');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _initials() {
    final f = widget.user.firstName.isNotEmpty
        ? widget.user.firstName[0]
        : '';
    final l = widget.user.lastName.isNotEmpty ? widget.user.lastName[0] : '';
    return '$f$l';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final twoColumn = width >= 720;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: AppColors.white,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: twoColumn ? 680 : 480,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral800,
                  ),
                ),
                IconButton(
                  icon: const Icon(Iconsax.close_circle),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24),
            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: AvatarPicker(
                          currentImageUrl: widget.user.profilePicture,
                          initials: _initials(),
                          pickedFile: _pickedAvatar,
                          onPicked: (f) => setState(() => _pickedAvatar = f),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _fieldRow(
                        twoColumn: twoColumn,
                        left: MyTextFormField(
                          title: 'Username',
                          controller: _usernameCtrl,
                          hintText: 'e.g. john.doe',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Username is required'
                              : null,
                        ),
                        right: MyTextFormField(
                          title: 'Phone Number',
                          controller: _phoneCtrl,
                          hintText: '+234...',
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(height: 14),
                      MyTextFormField(
                        title: 'Address',
                        controller: _addressCtrl,
                        hintText: 'Street, city',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 14),
                      _fieldRow(
                        twoColumn: twoColumn,
                        left: MyDateField(
                          controller: _dobCtrl,
                          title: 'Date of Birth',
                        ),
                        right: MyDropdown(
                          title: 'Gender',
                          hintText: 'Select gender',
                          items: _genders,
                          initialSelection: _gender,
                          onChanged: (v) => setState(() => _gender = v),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _fieldRow(
                        twoColumn: twoColumn,
                        left: MyDropdown(
                          title: 'Marital Status',
                          hintText: 'Select status',
                          items: _maritalStatuses,
                          initialSelection: _maritalStatus,
                          onChanged: (v) => setState(() => _maritalStatus = v),
                        ),
                        right: const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 120,
                  child: MyOutlinedButton(
                    child: 'Cancel',
                    onTap: _saving ? null : () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 160,
                  child: MyElevatedButton(
                    child: 'Save Changes',
                    isLoading: _saving,
                    onTap: _save,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldRow({
    required bool twoColumn,
    required Widget left,
    required Widget right,
  }) {
    if (!twoColumn) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          left,
          if (right is! SizedBox) ...[
            const SizedBox(height: 14),
            right,
          ],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }
}
