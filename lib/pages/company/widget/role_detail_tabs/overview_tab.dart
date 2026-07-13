import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/role_model.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class OverviewTab extends StatelessWidget {
  final Role role;

  const OverviewTab({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            icon: Iconsax.direct_right,
            title: 'Mission',
            value: role.mission?.isNotEmpty == true ? role.mission! : 'Not defined',
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Iconsax.clipboard_text,
            title: 'Job Description',
            value: role.jobDescription?.isNotEmpty == true ? role.jobDescription! : 'Not defined',
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Iconsax.tick_square,
            title: 'Responsibilities',
            value: (role.responsibilities?.isNotEmpty == true)
                ? role.responsibilities!.join('\n')
                : 'Not defined',
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Iconsax.hierarchy,
            title: 'Reports To',
            value: role.reportsToRoleName?.isNotEmpty == true ? role.reportsToRoleName! : 'None',
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Iconsax.building,
            title: 'Branches',
            value: role.branches.isEmpty
                ? 'All Branches'
                : role.branches.map((b) => b.branchName).join(', '),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Iconsax.shield_tick,
            title: 'Permissions',
            value: '${role.totalPermissionCount} actions across ${role.permissions.length} resources',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.label),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
