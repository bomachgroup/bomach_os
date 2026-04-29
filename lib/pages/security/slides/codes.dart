import 'package:bomach_os/components/text/my_text.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model.dart';

class SecurityCodes extends StatelessWidget {
  final bool isMobile;

  const SecurityCodes({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.key, color: Colors.black, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: MyText(
                  'Security Codes (${mockSecurityCodes.length})',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          MyText(
            'Manage access and authorization codes',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mockSecurityCodes.length,
              itemBuilder: (context, index) {
                return SecurityCodeTile(code: mockSecurityCodes[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SecurityCodeTile extends StatelessWidget {
  final SecurityCode code;

  const SecurityCodeTile({super.key, required this.code});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Inactive':
        return Colors.grey;
      case 'Expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(code.status);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      code.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(width: 8),
                    _buildTag(code.accessType, Colors.grey.shade600),
                    const SizedBox(width: 8),
                    _buildTag(code.status, statusColor),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Code: ${code.code}  •  Assigned to: ${code.assignedTo}  •  Expires: ${code.expires}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.4),
                            width: 1),
                        borderRadius: BorderRadius.circular(7))),
                icon: const Icon(
                  Iconsax.eye,
                  size: 20,
                ),
                onPressed: () {},
                tooltip: 'View Code',
              ),
              IconButton(
                icon: const Icon(
                  Iconsax.edit,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.4),
                            width: 1),
                        borderRadius: BorderRadius.circular(7))),
                onPressed: () {},
                tooltip: 'Edit Code',
              ),
              IconButton(
                icon: const Icon(
                  CupertinoIcons.trash,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.4),
                            width: 1),
                        borderRadius: BorderRadius.circular(7))),
                onPressed: () {},
                tooltip: 'Delete Code',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
