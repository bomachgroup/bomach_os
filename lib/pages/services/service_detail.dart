import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class LandSurveyingWidget extends StatelessWidget {
  const LandSurveyingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        leading: Material(
          color: AppColors.surface,
          borderRadius: AppRadii.brMd,
          child: InkWell(
            borderRadius: AppRadii.brMd,
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: AppRadii.brMd,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: const Icon(
                Iconsax.arrow_left_2,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        title: 'Land Surveying',
        subtitle: 'Created 1/15/2024',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyOutlinedButton(
              height: 44,
              icon: const Icon(
                Iconsax.edit,
                size: 16,
                color: AppColors.primary,
              ),
              child: 'Edit',
              onTap: () {},
            ),
            const SizedBox(width: 12),
            MyElevatedButton(
              height: 44,
              bgColor: AppColors.danger,
              icon: const Icon(
                Iconsax.trash,
                size: 16,
                color: AppColors.white,
              ),
              child: 'Delete',
              onTap: () {},
            ),
          ],
        ),
      ),
      children: [
        AppCard(
          padding: const EdgeInsets.all(24),
          elevation: AppCardElevation.md,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: AppRadii.brSm,
                    ),
                    child: const Icon(
                      Iconsax.ruler,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Service Details', style: AppTextStyles.h3),
                  const Spacer(),
                  const StatusChip(
                    label: 'Active',
                    tone: StatusTone.success,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(height: 1, color: AppColors.borderSubtle),
              _buildInfoRow('Service Name', 'Land Surveying'),
              _buildInfoRow('Category', 'Surveying'),
              _buildInfoRow(
                'Description',
                'This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field.',
              ),
              _buildInfoRow('Base Price (NGN)', 'N 150,000.00'),
              _buildInfoRow('Duration', '2-3 Weeks'),
              _buildInfoRow('Status', 'Active'),
              _buildInfoRow('Created Date', '22th July 2025', isLast: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.borderSubtle),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMd.copyWith(
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
