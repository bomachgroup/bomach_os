import 'package:bomach_os/src/constants/colors.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';

import '../dialog/new_document.dart';
import '../model/doc_model.dart';
import '../widgets/doc_card.dart';

class SharedDocumentsScreen extends StatelessWidget {
  final bool isMobile;

  const SharedDocumentsScreen({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderAndActions(context, isMobile),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    mainAxisExtent: 300,
                    crossAxisSpacing: 20.0,
                    mainAxisSpacing: 20.0,
                    childAspectRatio: 1.5),
                itemCount: mockDocuments.length,
                itemBuilder: (context, index) {
                  return DocumentCard(document: mockDocuments[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderAndActions(context, bool isMobile) {
    List<Widget> children = [
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shared Documents',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'Documents accessible to clients through the portal',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
      const Spacer(),
      SizedBox(
        width: 250,
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search documents...',
            prefixIcon: const Icon(Iconsax.search_normal, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: AppColors.neutral100,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          ),
        ),
      ),
      const SizedBox(width: 10),
      ElevatedButton.icon(
        onPressed: () {
          UploadDocumentDialog.show(context);
        },
        icon: const Icon(Iconsax.document_upload, size: 20),
        label: const Text('Upload Document',
            style: TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    ];
    if (isMobile) {
      return Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
