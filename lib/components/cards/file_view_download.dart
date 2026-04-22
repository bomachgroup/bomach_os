import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FileViewDownloadCard extends StatelessWidget {
  final String fileName;
  final String fileType;
  final String fileSize;

  const FileViewDownloadCard({
    super.key,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Document Icon + PDF tag
          SvgPicture.asset("assets/svg/pdf2.svg"),

          const SizedBox(width: 12),

          // File details
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fileName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '$fileType   $fileSize',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _iconButton(Iconsax.eye),
              const SizedBox(width: 12),
              _iconButton(Iconsax.export),
              const SizedBox(width: 12),
              _iconButton(Iconsax.document_download),
            ],
          )
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        icon,
        color: Colors.grey.shade700,
        size: 20,
      ),
    );
  }
}
