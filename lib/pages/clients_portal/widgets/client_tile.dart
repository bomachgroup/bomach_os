import 'package:bomach_os/src/constants/colors.dart';
import 'package:flutter/material.dart';

class ClientTile extends StatelessWidget {
  final Client client;
  final bool isSelected;
  final VoidCallback onTap;

  const ClientTile({
    super.key,
    required this.client,
    this.isSelected = false,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return AppColors.primary;
      case 'Pending':
        return Colors.orange;
      case 'Inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(client.status);

    return Material(
      color: isSelected ? AppColors.infoSubtle : Colors.white,
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3), width: 1)
                : Border.all(color: Colors.transparent),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                child: Text(
                  client.initials,
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      client.company,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      client.email,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      _buildStatusTag(client.status, statusColor),
                      const SizedBox(width: 4),
                      _buildAccessTag(client.accessType),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${client.projects} projects',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black)),
                  Text('Last login: ${client.lastLogin}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
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

// Dummy Client model if you choose to use this
class Client {
  final String initials;
  final String name;
  final String company;
  final String email;
  final String status; // Active, Pending, Inactive
  final String accessType; // full, standard, limited
  final int projects;
  final String lastLogin;
  final String joined;
  final List<String> permissions;

  Client({
    required this.initials,
    required this.name,
    required this.company,
    required this.email,
    required this.status,
    required this.accessType,
    required this.projects,
    required this.lastLogin,
    this.joined = 'N/A',
    this.permissions = const [],
  });
}
