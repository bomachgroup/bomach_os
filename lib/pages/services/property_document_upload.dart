import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class LandDocumentUploadPage extends StatefulWidget {
  const LandDocumentUploadPage({super.key});

  @override
  State<LandDocumentUploadPage> createState() => _LandDocumentUploadPageState();
}

class _LandDocumentUploadPageState extends State<LandDocumentUploadPage> {
  final picker = ImagePicker();

  final Map<String, XFile?> _documents = {
    "Certificate of Occupancy (C of O)": null,
    "Survey Plan": null,
    "Deed of Assignment": null,
    "Proof of Payment": null,
    "Government Consent (if available)": null,
  };

  Future<void> _pickFile(String key) async {
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _documents[key] = file);
    }
  }

  bool get _allRequiredUploaded {
    return _documents.entries
        .where((e) => !e.key.contains("if available"))
        .every((e) => e.value != null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            "Land Purchase Document Upload",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Upload the required documents to verify and complete your land purchase process.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Card for document uploads
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              children: _documents.entries.map((entry) {
                final file = entry.value;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xffe5e7eb)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    leading: const Icon(Icons.description_outlined,
                        color: Colors.green),
                    title: Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      file == null ? "No file selected" : file.name,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: TextButton(
                      onPressed: () => _pickFile(entry.key),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xffe8f5e9),
                        foregroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(file == null ? "Upload" : "Change"),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),
          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _allRequiredUploaded ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                disabledBackgroundColor: Colors.grey[400],
              ),
              icon: const Icon(Icons.cloud_upload),
              label: const Text(
                "Submit Documents",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          if (!_allRequiredUploaded)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                "*Please upload all required documents",
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}
