import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../pages/hr/models/training_program_model.dart';
import '../controller/training_program_controller.dart';
import 'add_program_dialog.dart';

class ViewProgramDialog extends StatelessWidget {
  final TrainingProgram program;
  final String token;

  const ViewProgramDialog(
      {super.key, required this.program, required this.token});

  @override
  Widget build(BuildContext context) {
    final TrainingProgramController controller = Get.find();

    return DialogScaffold(
      title: 'Program details',
      subtitle: program.programName,
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryBanner(program),
          const SizedBox(height: 16),
          _buildSection(
            title: 'General information',
            children: [
              _detailRow('Provider',
                  program.provider.isEmpty ? '—' : program.provider),
              _detailRow('Cost', '\$${program.cost}'),
              _detailRow(
                  'Target Audience',
                  program.targetAudience.isEmpty
                      ? '—'
                      : program.targetAudience),
              _detailRow('Is Mandatory', program.isMandatory ? 'Yes' : 'No'),
              _detailRow('Duration', '${program.durationDays} days'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Schedule',
            children: [
              _detailRow('Start Date', _fmtDate(program.startDate)),
              _detailRow('End Date', _fmtDate(program.endDate)),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Description / Syllabus',
            children: [
              Text(
                program.description.isNotEmpty
                    ? program.description
                    : 'No description provided.',
                style: AppText.bodyMd
                    .copyWith(color: AppColors.textPrimary, height: 1.5),
              ),
            ],
          ),
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
          child: 'Delete program',
          height: 44,
          onTap: () async {
            final confirm =
                await _showDeleteConfirmation(context, program.programName);
            if (confirm == true && context.mounted) {
              await controller.deleteProgram(program.id);
              if (!context.mounted) return;
              Navigator.pop(context);
              AppToast.error(context, 'Program Deleted');
            }
          },
          textColor: AppColors.danger,
          borderColor: AppColors.danger,
        ),
        MyElevatedButton(
          width: 140,
          height: 44,
          child: 'Edit program',
          icon: const Icon(Iconsax.edit,
              size: 18, color: AppColors.textOnPrimary),
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (_) =>
                  AddProgramDialog(token: token, programToEdit: program),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryBanner(TrainingProgram program) {
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
            child: const Icon(Iconsax.teacher,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(program.programName, style: AppText.h3),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (program.status.isNotEmpty)
                      StatusChip(
                        label: _statusLabel(program.status),
                        tone: _statusTone(program.status),
                      ),
                    if (program.provider.isNotEmpty)
                      _metaChip(
                          icon: Iconsax.user, label: program.provider),
                    _metaChip(
                      icon: Iconsax.calendar,
                      label:
                          '${_fmtDate(program.startDate)} – ${_fmtDate(program.endDate)}',
                    ),
                    if (program.isMandatory)
                      _metaChip(
                          icon: Iconsax.warning_2, label: 'Mandatory'),
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
            width: 160,
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

  String _statusLabel(String status) {
    if (status.isEmpty) return 'Unknown';
    return toBeginningOfSentenceCase(status) ?? status;
  }

  StatusTone _statusTone(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return StatusTone.success;
      case 'in_progress':
      case 'in progress':
      case 'active':
        return StatusTone.info;
      case 'completed':
        return StatusTone.primary;
      case 'cancelled':
      case 'canceled':
        return StatusTone.danger;
      case 'upcoming':
      case 'scheduled':
        return StatusTone.warning;
      default:
        return StatusTone.neutral;
    }
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '—';
    return DateFormat('dd MMM, yyyy').format(d);
  }

  Future<bool?> _showDeleteConfirmation(
      BuildContext context, String name) async {
    return DialogScaffold.show<bool>(
      context,
      title: 'Delete program',
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
          width: 140,
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
