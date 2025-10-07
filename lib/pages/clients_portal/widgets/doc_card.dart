import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

import '../model/doc_model.dart';

class DocumentCard extends StatelessWidget {
  final Document document;

  const DocumentCard({super.key, required this.document});

  Color _getRestrictionColor(String restriction) {
    return restriction == 'Available' ? AppColors.blue : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final restrictionColor = _getRestrictionColor(document.restriction);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      document.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    MyText(
                      document.category,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: restrictionColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: MyText(
              document.restriction,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          MyText(
            document.description,
            style: const TextStyle(fontSize: 13),
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: MyText(
                  document.client,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
              Expanded(
                  child: MyText(
                document.size,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.end,
              ))
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: MyText(
                maxLines: 1,
                document.uploadedBy,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              )),
              Expanded(
                  child: MyText(
                maxLines: 1,
                document.uploadedDate,
                textAlign: TextAlign.end,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ))
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: MyText(
                maxLines: 1,
                '${document.downloads} downloads',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              )),
              Expanded(
                  child: MyText(
                maxLines: 1,
                'Last:  ${document.lastModified}',
                textAlign: TextAlign.end,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ))
            ],
          ),
          const Spacer(),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                  child: _buildActionButton(
                      'View', Icons.visibility_outlined, () {})),
              _buildActionButton('', Icons.file_download_outlined, () {}),
              _buildActionButton('', Icons.ios_share, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    if (label.isEmpty) {
      return IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        color: Colors.grey.shade700,
      );
    }
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
      icon: Icon(icon, size: 18),
      label: MyText(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
