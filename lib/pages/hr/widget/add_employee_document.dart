import 'dart:typed_data';
import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../controller/employees_controller.dart';

class UploadDocumentDialog extends StatefulWidget {
  final String userId;

  const UploadDocumentDialog({super.key, required this.userId});

  @override
  State<UploadDocumentDialog> createState() => _UploadDocumentDialogState();
}

class _UploadDocumentDialogState extends State<UploadDocumentDialog> {
  final EmployeeController controller = Get.find<EmployeeController>();
  final TextEditingController _docNameCtrl = TextEditingController();

  static const String _defaultType = 'Select a Type';
  static const List<String> _typeOptions = [
    'Contract',
    'ID Card',
    'License',
    'Training',
    'Certificate',
    'Other',
  ];

  String _selectedType = _defaultType;

  String? _fileName;
  Uint8List? _fileBytes;

  @override
  void dispose() {
    _docNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _fileName = result.files.first.name;
        _fileBytes = result.files.first.bytes;
      });
    }
  }

  void _onUpload() {
    if (_docNameCtrl.text.isEmpty) {
      AppToast.error(context, 'Please enter a document name');
      return;
    }

    if (_selectedType == _defaultType) {
      AppToast.error(context, 'Please select a document type');
      return;
    }

    final formData = dio.FormData.fromMap({
      'name': _docNameCtrl.text,
      'document_name': _docNameCtrl.text,
      'type': _selectedType.toLowerCase(),
      'document_type': _selectedType.toLowerCase(),
      if (_fileBytes != null && _fileName != null)
        'file': dio.MultipartFile.fromBytes(
          _fileBytes!,
          filename: _fileName!,
        ),
    });

    controller.uploadDocument(context, widget.userId, formData);
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: 'Upload Document',
      subtitle: 'Upload a document for this employee.',
      size: DialogSize.sm,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          MyTextFormField(
            controller: _docNameCtrl,
            title: 'Document Name',
            hintText: 'e.g. Signed offer letter',
          ),
          const SizedBox(height: 16),
          MyDropdown(
            title: 'Document Type',
            hintText: _selectedType,
            items: _typeOptions,
            initialSelection:
                _selectedType == _defaultType ? null : _selectedType,
            onChanged: (val) {
              if (val != null) setState(() => _selectedType = val);
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Upload File',
            style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _buildUploadZone(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        Obx(
          () => MyElevatedButton(
            child: controller.isSaving.value ? 'Uploading...' : 'Upload',
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            height: 44,
            onTap: controller.isSaving.value ? null : _onUpload,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadZone() {
    final hasFile = _fileName != null;

    return InkWell(
      onTap: _pickFile,
      borderRadius: AppRadii.brMd,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: AppRadii.brMd,
          border: Border.all(
            color: hasFile
                ? AppColors.success
                : AppColors.primary.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasFile) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.successSubtle,
                  borderRadius: AppRadii.brPill,
                ),
                child: const Icon(Iconsax.document,
                    color: AppColors.success, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                _fileName!,
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Tap to change file',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadii.brPill,
                ),
                child: const Icon(
                  Iconsax.document_upload,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  children: const [
                    TextSpan(text: 'Click to '),
                    TextSpan(
                      text: 'choose file',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(text: ' to upload'),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Supported formats: PDF, DOC, PNG, JPG',
                style:
                    AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
