import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/cards/file_view_download.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/applicant_controller.dart';
import '../models/applicant_model.dart';
import 'add_job_applicant_dialog.dart';

class ViewJobApplicantDialog extends StatelessWidget {
  final Applicant applicant;
  const ViewJobApplicantDialog({super.key, required this.applicant});

  Widget _buildDetailRow(String label, String value, {bool isBlue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: MyText(label,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400)),
          ),
          Expanded(
            child: MyText(value,
                style: TextStyle(
                    fontSize: 14,
                    color: isBlue ? const Color(0xFF007AFF) : Colors.black87,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ApplicantController controller = Get.find<ApplicantController>();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText('${applicant.firstName} ${applicant.lastName}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child:
                          Icon(Icons.close, size: 24, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E5E5)),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Job ID', applicant.jobPostingId),
                    _buildDetailRow('First Name', applicant.firstName),
                    _buildDetailRow('Last Name', applicant.lastName),
                    _buildDetailRow('Email', applicant.email),
                    _buildDetailRow('Phone', applicant.phone),

                    // Resume Mock
                    Row(
                      children: [
                        SizedBox(
                            width: 200,
                            child: MyText("Uploaded Resume",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[600]))),
                        const Expanded(
                            child: FileViewDownloadCard(
                                fileName: 'Resume',
                                fileType: 'PDF',
                                fileSize: '200KB')),
                      ],
                    ),
                    const SizedBox(height: 10),

                    _buildDetailRow(
                        'Linkedin Profile', applicant.linkedinUrl ?? 'N/A'),
                    _buildDetailRow(
                        'Portfolio', applicant.portfolioUrl ?? 'N/A'),
                    _buildDetailRow('Status', applicant.status),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Obx(() => MyElevatedButton(
                        bgColor: AppColors.red,
                        child: controller.isLoading.value
                            ? 'Deleting...'
                            : 'Delete',
                        onTap: controller.isLoading.value
                            ? () {}
                            : () => controller.deleteApplicant(
                                context, applicant.id),
                      )),
                  const SizedBox(width: 15),
                  MyElevatedButton(
                    child: 'Edit',
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (_) =>
                            AddJobApplicantDialog(applicant: applicant),
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
