import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:bms_front_end/pages/hr/models/awards_model.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../controller/awards_controller.dart';
import 'add_award_widget.dart';

class ViewAwardDialog extends StatelessWidget {
  final Award award;
  final String token;

  const ViewAwardDialog({
    super.key,
    required this.award,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final AwardsController controller = Get.find();

    final dateLabel = award.dateAwarded != null
        ? DateFormat('MMMM dd, yyyy').format(award.dateAwarded!)
        : 'N/A';

    return DialogScaffold(
      title: 'Award details',
      subtitle: award.title,
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryBanner(award, dateLabel),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Award information',
            children: [
              _detailRow('Title', award.title),
              _detailRow(
                  'Category', award.category.isEmpty ? '—' : award.category),
              _detailRow(
                  'Rank / Level', award.rankLevel.isEmpty ? '—' : award.rankLevel),
              _detailRow('Date Awarded', dateLabel),
            ],
          ),
          if (award.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSection(
              title: 'Description',
              children: [
                Text(
                  award.description,
                  style: AppText.bodyMd
                      .copyWith(color: AppColors.textPrimary, height: 1.5),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Close',
          height: 44,
          onTap: () => Navigator.pop(context),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        MyOutlinedButton(
          child: 'Delete',
          height: 44,
          onTap: () async {
            final confirm = await _showDeleteConfirmation(context, award.title);
            if (confirm == true && context.mounted) {
              await controller.deleteAward(token, award.id);
              if (!context.mounted) return;
              Navigator.pop(context);
              AppToast.error(context, 'Award Deleted');
            }
          },
          textColor: AppColors.danger,
          borderColor: AppColors.danger,
        ),
        MyElevatedButton(
          width: 120,
          height: 44,
          child: 'Edit',
          icon: const Icon(Iconsax.edit,
              size: 18, color: AppColors.textOnPrimary),
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (_) =>
                  AddAwardDialog(token: token, awardToEdit: award),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryBanner(Award award, String dateLabel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: AppRadii.brLg,
            ),
            child: const Icon(Iconsax.award,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(award.title, style: AppText.h3),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (award.category.isNotEmpty)
                      StatusChip(
                        label: award.category,
                        tone: _categoryTone(award.category),
                      ),
                    if (award.rankLevel.isNotEmpty)
                      _metaChip(icon: Iconsax.medal, label: award.rankLevel),
                    _metaChip(icon: Iconsax.calendar, label: dateLabel),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brPill,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppText.bodySm.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
              style:
                  AppText.bodySm.copyWith(color: AppColors.textSecondary),
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

  StatusTone _categoryTone(String category) {
    final c = category.toLowerCase().replaceAll(' ', '_');
    if (c.contains('employee_of_month') || c.contains('employee of the month')) {
      return StatusTone.primary;
    }
    if (c.contains('excellence')) return StatusTone.success;
    if (c.contains('innovation')) return StatusTone.info;
    if (c.contains('leadership')) return StatusTone.warning;
    if (c.contains('service')) return StatusTone.neutral;
    return StatusTone.neutral;
  }

  Future<bool?> _showDeleteConfirmation(
      BuildContext context, String name) async {
    return DialogScaffold.show<bool>(
      context,
      title: 'Delete award',
      subtitle: 'This action cannot be undone.',
      size: DialogSize.sm,
      body: Text(
        'Are you sure you want to delete "$name"?',
        style: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
      ),
      actions: [
        MyOutlinedButton(
          child: 'No',
          height: 44,
          onTap: () => Navigator.pop(context, false),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        MyElevatedButton(
          width: 120,
          height: 44,
          child: 'Yes, delete',
          icon: const Icon(Iconsax.trash,
              size: 18, color: AppColors.textOnPrimary),
          onTap: () => Navigator.pop(context, true),
          bgColor: AppColors.danger,
        ),
      ],
    );
  }
}
