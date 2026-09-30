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

import '../controller/jobposting_control.dart';
import '../models/job_posting.dart';
import 'add_job_post_dialog.dart';

class ViewJobPostDialog extends StatelessWidget {
  final JobPosting job;
  const ViewJobPostDialog({super.key, required this.job});

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd-MM-yyyy').format(date);
  }

  String _formatEnum(String text) {
    if (text.isEmpty) return 'N/A';
    return text
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  StatusTone _statusTone(String status) {
    switch (status.toLowerCase()) {
      case 'open':
      case 'active':
        return StatusTone.success;
      case 'draft':
        return StatusTone.neutral;
      case 'closed':
      case 'filled':
        return StatusTone.primary;
      case 'paused':
        return StatusTone.warning;
      case 'expired':
        return StatusTone.danger;
      default:
        return StatusTone.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final JobPostController controller = Get.find<JobPostController>();

    return DialogScaffold(
      title: 'Job Details',
      subtitle: job.title.isEmpty ? 'Job posting overview' : job.title,
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryBanner(),
          const SizedBox(height: 20),
          _buildDetailSection(
            title: 'Posting information',
            children: [
              _detailRow('Job Title', job.title),
              _detailRow('Department', job.departmentId),
              _detailRow('Branch ID', job.branchId),
              _detailRow('Job Type', _formatEnum(job.jobType)),
              _detailRow('Salary Range', job.salaryRange),
              _detailRow(
                  'Application Deadline', _formatDate(job.deadline)),
              _detailRow('Applicants Count', job.applicantsCount.toString()),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailSection(
            title: 'Description',
            children: [
              _longTextRow(job.description),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailSection(
            title: 'Responsibilities',
            children: [
              _longTextRow(job.responsibilities),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailSection(
            title: 'Requirements',
            children: [
              _longTextRow(job.requirements),
            ],
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Close',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          onTap: () => Navigator.pop(context),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        Obx(() => MyOutlinedButton(
              child: controller.isLoading.value ? 'Deleting...' : 'Delete',
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              icon: const Icon(Iconsax.trash,
                  size: 18, color: AppColors.danger),
              onTap: controller.isLoading.value
                  ? () {}
                  : () => controller.deleteJob(context, job.id),
              textColor: AppColors.danger,
              borderColor: AppColors.danger,
            )),
        MyElevatedButton(
          child: 'Edit',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          icon: const Icon(Iconsax.edit,
              size: 18, color: AppColors.textOnPrimary),
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (_) => AddJobPostDialog(job: job),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryBanner() {
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
            child: const Icon(Iconsax.briefcase,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.title.isEmpty ? 'Untitled Job' : job.title,
                    style: AppTextStyles.h3),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusChip(
                      label: _formatEnum(job.status),
                      tone: _statusTone(job.status),
                    ),
                    if (job.jobType.isNotEmpty)
                      _buildMetaChip(
                        icon: Iconsax.clock,
                        label: _formatEnum(job.jobType),
                      ),
                    _buildMetaChip(
                      icon: Iconsax.profile_2user,
                      label: '${job.applicantsCount} applicants',
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

  Widget _buildMetaChip({required IconData icon, required String label}) {
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
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection({
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
            width: 180,
            child: Text(
              label,
              style: AppTextStyles.bodySm
                  .copyWith(color: AppColors.textSecondary),
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

  Widget _longTextRow(String value) {
    return Text(
      value.isEmpty ? '—' : value,
      style: AppTextStyles.bodyMd.copyWith(
        color: AppColors.textPrimary,
        height: 1.5,
      ),
    );
  }
}
