import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:flutter/material.dart';

class UploadDocumentDialog extends StatefulWidget {
  const UploadDocumentDialog({super.key});

  @override
  State<UploadDocumentDialog> createState() => _UploadDocumentDialogState();
}

class _UploadDocumentDialogState extends State<UploadDocumentDialog> {
  final TextEditingController _docNameCtrl = TextEditingController();
  String _selectedType = "Select a Type";

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
                    const MyText('Upload document', size: 18, weight: 700),
                    const SizedBox(height: 4),
                    MyText('Upload a new building drawing to the drawing bank',
                        size: 12, color: Colors.grey.shade600),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
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

            const MyText('Upload File (optional)*', size: 13, weight: 600),
            const SizedBox(height: 8),
            _buildUploadZone(),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyElevatedButton(
                  child: 'Create',
                  bgColor: const Color(0xFF0055FF),
                  onTap: () {
                    // TODO: Implement Upload Logic
                    Navigator.pop(context);
                  },
                ),
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
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: ["Select a Type", "Contract", "ID Card", "License", "Training"]
              .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14))))
              .toList(),
          onChanged: (val) => setState(() => _selectedType = val!),
        ),
      ),
    );
  }

  Widget _buildUploadZone() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF0055FF).withOpacity(0.3),
          style: BorderStyle.solid, // Should be dashed ideally
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0055FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 12, color: Colors.black87),
              children: [
                TextSpan(text: "Drag & Drop or ", style: TextStyle(fontWeight: FontWeight.w600)),
                TextSpan(text: "choose file", style: TextStyle(color: Color(0xFF0055FF), fontWeight: FontWeight.bold)),
                TextSpan(text: " to upload", style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text("Supported formats: doc, pdf", style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}