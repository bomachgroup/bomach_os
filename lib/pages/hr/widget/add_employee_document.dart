import 'dart:typed_data';
import 'package:bms_front_end/src/constants/colors.dart';

import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  String _selectedType = "Select a Type";

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

    if (_selectedType == "Select a Type") {
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
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MyText('Upload Document', size: 18, weight: 700),
                    const SizedBox(height: 4),
                    MyText('Upload a document for this employee',
                        size: 12, color: Colors.grey.shade600),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Iconsax.close_circle, size: 20, color: Colors.grey),
                )
              ],
            ),
            const Divider(height: 30),

            // Form
            const MyText('Document Name', size: 13, weight: 600),
            const SizedBox(height: 8),
            MyTextFormField(
              controller: _docNameCtrl,
              hintText: 'Type',
            ),
            const SizedBox(height: 16),

            const MyText('Document Type', size: 13, weight: 600),
            const SizedBox(height: 8),
            _buildDropdown(),
            const SizedBox(height: 16),

            const MyText('Upload File', size: 13, weight: 600),
            const SizedBox(height: 8),
            _buildUploadZone(),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Obx(() => MyElevatedButton(
                      child:
                          controller.isSaving.value ? 'Uploading...' : 'Upload',
                      bgColor: AppColors.primary,
                      onTap: controller.isSaving.value ? null : _onUpload,
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedType,
          isExpanded: true,
          icon: const Icon(Iconsax.arrow_down_1, color: Colors.grey),
          items: [
            "Select a Type",
            "Contract",
            "ID Card",
            "License",
            "Training",
            "Certificate",
            "Other"
          ]
              .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 14))))
              .toList(),
          onChanged: (val) => setState(() => _selectedType = val!),
        ),
      ),
    );
  }

  Widget _buildUploadZone() {
    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_fileName != null) ...[
              const Icon(Iconsax.document,
                  color: AppColors.primary, size: 28),
              const SizedBox(height: 8),
              Text(
                _fileName!,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text("Tap to change file",
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Iconsax.document_upload,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(height: 12),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                  children: [
                    TextSpan(
                        text: "Click to ",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    TextSpan(
                        text: "choose file",
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: " to upload",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text("Supported formats: doc, pdf, png, jpg",
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            ],
          ],
        ),
      ),
    );
  }
}
