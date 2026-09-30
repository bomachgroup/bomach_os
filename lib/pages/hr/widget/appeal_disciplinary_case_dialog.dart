import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../controller/disciplinary_controller.dart';
import '../models/disciplinary_cases_model.dart';
import 'add_disciplinary_case_dialog.dart';

class ViewDisciplinaryCaseDialog extends StatelessWidget {
  final DisciplinaryCase kase;
  final String token;

  const ViewDisciplinaryCaseDialog({
    super.key,
    required this.kase,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final DisciplinaryController controller = Get.find();

    return DialogScaffold(
      title: kase.violationTitle.isNotEmpty
          ? kase.violationTitle
          : 'Disciplinary Case',
      subtitle: 'Case details and action history',
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryBanner(kase),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Case information',
            children: [
              _detailRow('Employee ID', kase.employeeId),
              _detailRow(
                  'Violation Title',
                  kase.violationTitle.isNotEmpty
                      ? kase.violationTitle
                      : '—'),
              _detailRow(
                  'Category',
                  kase.violationCategory.isNotEmpty
                      ? kase.violationCategory
                      : '—'),
              _detailRow('Action Type',
                  kase.actionType.isNotEmpty ? kase.actionType : '—'),
              _detailRow(
                'Action Date',
                kase.actionDate != null
                    ? DateFormat('dd-MM-yyyy').format(kase.actionDate!)
                    : '—',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Description',
            children: [
              Text(
                kase.violationDescription.isNotEmpty
                    ? kase.violationDescription
                    : 'No description provided',
                style: AppTextStyles.bodyMd,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Investigation Details',
            children: [
              Text(
                (kase.investigationDetails != null &&
                        kase.investigationDetails!.isNotEmpty)
                    ? kase.investigationDetails!
                    : 'None provided',
                style: AppTextStyles.bodyMd,
              ),
            ],
          ),
          if (kase.severancePaymentDue) ...[
            const SizedBox(height: 16),
            _buildSection(
              title: 'Severance',
              children: [
                _detailRow(
                  'Severance Amount',
                  kase.severanceAmount?.toStringAsFixed(2) ?? '0.00',
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        MyOutlinedButton(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textColor: AppColors.danger,
          borderColor: AppColors.danger,
          child: 'Delete',
          onTap: () async {
            final confirm = await DialogScaffold.show<bool>(
              context,
              title: 'Delete Case',
              size: DialogSize.sm,
              body: const Text(
                'Are you sure you want to delete this disciplinary case? This action cannot be undone.',
                style: AppTextStyles.bodyMd,
              ),
              actions: [
                MyOutlinedButton(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                  textColor: AppColors.textSecondary,
                  borderColor: AppColors.borderStrong,
                  child: 'No',
                  onTap: () => Navigator.pop(context, false),
                ),
                MyElevatedButton(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                  bgColor: AppColors.danger,
                  child: 'Yes, Delete',
                  onTap: () => Navigator.pop(context, true),
                ),
              ],
            );

            if (confirm == true) {
              await controller.deleteCase(token, kase.id);
              if (context.mounted) Navigator.pop(context);
            }
          },
        ),
        MyElevatedButton(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: 'Edit',
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (c) => AddDisciplinaryCaseDialog(
                  token: token, caseToEdit: kase),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryBanner(DisciplinaryCase c) {
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
              color: AppColors.warningSubtle,
              borderRadius: AppRadii.brLg,
            ),
            child: const Icon(Iconsax.warning_2,
                color: AppColors.warning, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.violationTitle.isNotEmpty
                      ? c.violationTitle
                      : 'Disciplinary case',
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (c.actionType.isNotEmpty)
                      StatusChip(
                        label: c.actionType,
                        tone: _actionTone(c.actionType),
                        icon: Iconsax.shield_tick,
                      ),
                    if (c.violationCategory.isNotEmpty)
                      StatusChip(
                        label: c.violationCategory,
                        tone: _severityTone(c.violationCategory),
                        icon: Iconsax.tag,
                      ),
                  ],
                ),
              ],
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
          Text(title, style: AppTextStyles.h4),
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
            width: 160,
            child: Text(
              label,
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
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

  StatusTone _actionTone(String actionType) {
    final s = actionType.toLowerCase();
    if (s.contains('verbal')) return StatusTone.info;
    if (s.contains('final')) return StatusTone.danger;
    if (s.contains('written')) return StatusTone.warning;
    if (s.contains('suspension')) return StatusTone.warning;
    if (s.contains('termination') || s.contains('dismissal')) {
      return StatusTone.danger;
    }
    return StatusTone.neutral;
  }

  StatusTone _severityTone(String category) {
    final s = category.toLowerCase();
    if (s.contains('gross')) return StatusTone.danger;
    if (s.contains('misconduct') || s.contains('performance')) {
      return StatusTone.warning;
    }
    if (s.contains('attendance')) return StatusTone.info;
    return StatusTone.neutral;
  }
}
