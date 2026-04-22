import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/jobposting_control.dart';
import '../models/job_posting.dart';
import 'add_job_post_dialog.dart';

class ViewJobPostDialog extends StatelessWidget {
  final JobPosting job;
  const ViewJobPostDialog({super.key, required this.job});

  Widget _buildDetailRow(String label, String value, {bool isBlue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: TextStyle(
                fontSize: 14,
                color: isBlue ? AppColors.primary : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatEnum(String text) {
    if (text.isEmpty) return 'N/A';
    return text
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final JobPostController controller = Get.find<JobPostController>();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Job Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Iconsax.close_circle,
                        size: 24,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.neutral200),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Job Title', job.title),
                    _buildDetailRow('Department', job.departmentId),
                    _buildDetailRow('Branch ID', job.branchId),
                    _buildDetailRow('Job Type', _formatEnum(job.jobType)),
                    _buildDetailRow('Salary Range', job.salaryRange),
                    _buildDetailRow(
                        'Application Deadline', _formatDate(job.deadline)),
                    const SizedBox(height: 16),
                    _buildDetailRow('Description', job.description),
                    _buildDetailRow('Responsibilities', job.responsibilities),
                    _buildDetailRow('Requirements', job.requirements),
                    _buildDetailRow('Status', _formatEnum(job.status),
                        isBlue: true),
                    _buildDetailRow(
                        'Applicants Count', job.applicantsCount.toString()),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Obx(() => MyElevatedButton(
                        bgColor: AppColors.danger,
                        child: controller.isLoading.value
                            ? 'Deleting...'
                            : 'Delete',
                        onTap: controller.isLoading.value
                            ? () {}
                            : () => controller.deleteJob(context, job.id),
                      )),
                  const SizedBox(width: 15),
                  MyElevatedButton(
                    child: 'Edit',
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (_) => AddJobPostDialog(job: job),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
