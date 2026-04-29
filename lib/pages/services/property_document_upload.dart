import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
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
    return PageScaffold(
      maxContentWidth: 900,
      header: const PageHeader(
        title: 'Land Purchase Document Upload',
        subtitle:
            'Upload the required documents to verify and complete your land purchase process.',
      ),
      children: [
        AppCard(
          padding: const EdgeInsets.all(20),
          elevation: AppCardElevation.sm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Required Documents', style: AppTextStyles.h4),
              const SizedBox(height: 16),
              ..._documents.entries
                  .map((entry) => _buildDocumentRow(entry.key, entry.value)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MyElevatedButton(
              height: 48,
              icon: const Icon(Iconsax.document_upload,
                  size: 18, color: AppColors.textOnPrimary),
              child: 'Submit Documents',
              onTap: () {},
              disable: !_allRequiredUploaded,
            ),
            if (!_allRequiredUploaded)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Iconsax.info_circle,
                        size: 15, color: AppColors.danger),
                    const SizedBox(width: 6),
                    Text(
                      'Please upload all required documents',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentRow(String title, XFile? file) {
    final hasFile = file != null;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        border: Border.all(color: AppColors.borderSubtle),
        borderRadius: AppRadii.brMd,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hasFile
                  ? AppColors.successSubtle
                  : AppColors.primarySubtle,
              borderRadius: AppRadii.brSm,
            ),
            child: Icon(
              Iconsax.document_text,
              size: 18,
              color: hasFile ? AppColors.success : AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasFile ? file.name : 'No file selected',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          MyOutlinedButton(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
            textColor: AppColors.primary,
            borderColor: AppColors.primary,
            child: hasFile ? 'Change' : 'Upload',
            onTap: () => _pickFile(title),
          ),
        ],
      ),
    );
  }
}
