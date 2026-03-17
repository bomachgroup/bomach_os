
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/applicant_controller.dart';
import '../models/applicant_model.dart';
import 'add_candidate_dialog.dart';

class ViewJobApplicantDialog extends StatelessWidget {
  final Applicant applicant;
  const ViewJobApplicantDialog({super.key, required this.applicant});

  @override
  Widget build(BuildContext context) {
    final ApplicantController controller = Get.find<ApplicantController>();
    final stage = applicant.stage.toLowerCase();

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800, // Wider for the 2-column layout
        height: 600,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue.shade100,
                        child: Text(applicant.firstName[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText('${applicant.firstName} ${applicant.lastName}', size: 18, weight: 700),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(4)),
                                child: MyText(applicant.stage.toUpperCase(), size: 10, color: Colors.pink, weight: 600),
                              ),
                              const SizedBox(width: 8),
                              MyText("Applied: ${applicant.createdAt?.toString().split(' ')[0] ?? '-'}", size: 12, color: Colors.grey),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, color: Colors.grey)),
                ],
              ),
            ),

            // Tabs (Visual Only for now)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
              child: Row(
                children: [
                  _buildTab("Overview", true),
                  _buildTab("Interview", false),
                  _buildTab("Offer", false),
                ],
              ),
            ),

            // Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT COLUMN (Info & Notes)
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const MyText("Candidate Information", size: 14, weight: 700),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildInfoItem("Email", applicant.email)),
                              Expanded(child: _buildInfoItem("Phone", applicant.phone)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildInfoItem("Experience", "5 Years")), // Mock
                              Expanded(child: _buildInfoItem("Source", "LinkedIn")), // Mock/Mapped
                            ],
                          ),
                          const SizedBox(height: 32),
                          const MyText("Notes", size: 14, weight: 700),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: MyText(applicant.notes ?? "No notes available.", size: 13, color: Colors.grey.shade700),
                          )
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 24),
                    
                    // RIGHT COLUMN (Actions & Documents)
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const MyText("Actions", size: 14, weight: 700),
                          const SizedBox(height: 12),
                          
                          // Dynamic Action Buttons
                          if (stage == 'applied') ...[
                            _buildActionButton("Shortlist Candidate", const Color(0xFF0055FF), () => controller.moveApplicantToStage(context, applicant.id, 'shortlisted')),
                            const SizedBox(height: 8),
                            _buildActionButton("Reject", AppColors.red, () => controller.rejectApplicant(context, applicant.id)),
                          ] else if (stage == 'shortlisted' || stage == 'screening') ...[
                            _buildActionButton("Schedule Interview", Colors.orange, () => controller.moveApplicantToStage(context, applicant.id, 'interview')),
                            const SizedBox(height: 8),
                            _buildActionButton("Reject", AppColors.red, () => controller.rejectApplicant(context, applicant.id)),
                          ] else if (stage == 'interview' || stage == 'interviewed') ...[
                            _buildActionButton("Hire Candidate", Colors.green, () => controller.moveApplicantToStage(context, applicant.id, 'hired')),
                            const SizedBox(height: 8),
                            _buildActionButton("Reject", AppColors.red, () => controller.rejectApplicant(context, applicant.id)),
                          ] else ...[
                             _buildActionButton("Edit Candidate", Colors.grey, () {
                               Navigator.pop(context);
                               showDialog(context: context, builder: (_) => AddCandidateDialog(applicant: applicant));
                             }),
                          ],

                          const SizedBox(height: 32),
                          const MyText("Documents", size: 14, weight: 700),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
                            child: const Row(
                              children: [
                                Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Expanded(child: MyText("Resume.pdf", size: 13, weight: 500)),
                                Icon(Icons.download, size: 18, color: Colors.grey),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(right: 24, top: 12, bottom: 12),
      child: Column(
        children: [
          MyText(title, size: 13, weight: isActive ? 600 : 400, color: isActive ? const Color(0xFF0055FF) : Colors.grey),
          if (isActive) Container(margin: const EdgeInsets.only(top: 4), height: 2, width: 20, color: const Color(0xFF0055FF))
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(label, size: 12, color: Colors.grey),
        const SizedBox(height: 4),
        MyText(value, size: 13, weight: 600),
      ],
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ),
    );
  }
}