import 'package:bms_front_end/src/constants/colors.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';

import 'client_tile.dart';

class ClientDetailsCard extends StatelessWidget {
  final Client client;

  const ClientDetailsCard({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Client Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade300,
                  child: Text(
                    client.initials,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 24),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  client.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  client.company,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatusTag('Active', AppColors.primary),
                    const SizedBox(width: 4),
                    _buildAccessTag(client.accessType),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          _buildDetailRow('Email', client.email),
          _buildDetailRow('Projects', client.projects.toString()),
          _buildDetailRow('Joined', client.joined),
          _buildDetailRow('Last Login', client.lastLogin),
          const Divider(),
          const SizedBox(height: 24),
          const Text(
            'Permissions',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: client.permissions
                .map((p) => Chip(
                      label: Text(p),
                      backgroundColor: AppColors.neutral100,
                      labelStyle: const TextStyle(fontSize: 12),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Row(
                    children: [
                      Text('Message'),
                      Spacer(),
                      Icon(Iconsax.message_text,
                          size: 20, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Icon(Iconsax.edit,
                    size: 20, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAccessTag(String access) {
    Color bgColor =
        access == 'full' ? AppColors.infoSubtle : const Color(0xFFF0F4C3);
    Color textColor =
        access == 'full' ? Colors.cyan.shade900 : Colors.lime.shade900;
    if (access == 'limited') {
      bgColor = AppColors.dangerSubtle;
      textColor = Colors.deepOrange.shade900;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        access,
        style: TextStyle(
            color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
