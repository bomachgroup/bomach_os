import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../src/model/employees_model.dart';

class ViewAssociateDialog extends StatelessWidget {
  final Employee associate;

  const ViewAssociateDialog({super.key, required this.associate});

  @override
  Widget build(BuildContext context) {
    final fullName = '${associate.firstName} ${associate.lastName}'.trim();
    final hasPicture =
        associate.profilePicture != null && associate.profilePicture!.isNotEmpty;
    final initial =
        associate.firstName.isNotEmpty ? associate.firstName[0].toUpperCase() : '?';

    return DialogScaffold(
      title: 'Associate Details',
      subtitle: fullName.isEmpty ? 'Associate profile' : fullName,
      size: DialogSize.md,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: AppRadii.brLg,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primarySubtle,
                  backgroundImage: hasPicture
                      ? NetworkImage(associate.profilePicture!)
                      : null,
                  child: !hasPicture
                      ? Text(
                          initial,
                          style: AppText.h2.copyWith(color: AppColors.primary),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName.isEmpty ? 'Unknown' : fullName,
                        style: AppText.h3,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        associate.employmentType ?? 'Associate',
                        style: AppText.bodySm
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      StatusChip(
                        label: associate.isActive ? 'Active' : 'Inactive',
                        tone: associate.isActive
                            ? StatusTone.success
                            : StatusTone.neutral,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Contact information',
            children: [
              _detailRow('Email', associate.email),
              _detailRow('Phone', associate.phoneNumber ?? '-'),
              _detailRow('Address', associate.address ?? '-'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Engagement',
            children: [
              _detailRow('Role', associate.employmentType ?? '-'),
              _detailRow('Status', associate.isActive ? 'Active' : 'Inactive'),
              _detailRow(
                'Contract Value',
                associate.grossSalary != null
                    ? '₦${associate.grossSalary}'
                    : '-',
              ),
            ],
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Close',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          icon: const Icon(Iconsax.close_circle,
              size: 18, color: AppColors.textSecondary),
          onTap: () => Navigator.pop(context),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.h4),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppText.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: AppText.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
