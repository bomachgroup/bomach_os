import 'package:bomach_os/components/input/upload_file.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ProjectFiles extends StatelessWidget {
  const ProjectFiles({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Project Files', style: AppTextStyles.h3),
        SizedBox(height: 4),
        Text(
          'Upload and manage files associated with this project.',
          style: AppTextStyles.bodySm,
        ),
        SizedBox(height: 20),
        EmptyState(
          icon: Iconsax.document_text,
          title: 'No files uploaded',
          subtitle: 'Files added to this project will appear here.',
          compact: true,
        ),
        SizedBox(height: 20),
        UploadFile(),
      ],
    );
  }
}
