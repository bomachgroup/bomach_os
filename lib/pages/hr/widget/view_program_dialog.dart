import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 850, maxHeight: 700),
        child: Column(
          children: [
            // --- Header ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Program Details',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Iconsax.close_circle, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.neutral100),

            // --- Body ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Info Block
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                              color: AppColors.infoSubtle,
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Iconsax.teacher,
                              color: AppColors.primary),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(program.programName,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(program.provider,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                        const Spacer(),
                        _buildStatusBadge(program.status),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Grid Details
                    const Text("General Information",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: AppColors.neutral50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.neutral100)),
                      child: Column(
                        children: [
                          _buildGridRow("Cost", "\$${program.cost}",
                              "Target Audience", program.targetAudience),
                          const SizedBox(height: 20),
                          _buildGridRow(
                              "Is Mandatory",
                              program.isMandatory ? "Yes" : "No",
                              "Duration",
                              "${program.durationDays} Days"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Schedule Section
                    const Text("Schedule",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: AppColors.primarySubtle, // Light Blue tint
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.infoSubtle)),
                      child: Row(
                        children: [
                          const Icon(Iconsax.calendar_1,
                              size: 20, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text(
                            "${_fmtDate(program.startDate)}  -  ${_fmtDate(program.endDate)}",
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description
                    const Text("Description / Syllabus",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    Text(
                      program.description.isNotEmpty
                          ? program.description
                          : "No description provided.",
                      style: const TextStyle(
                          fontSize: 14, height: 1.5, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),

            // --- Footer Actions ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade200))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyElevatedButton(
                    bgColor: AppColors.danger,
                    child: 'Delete Program',
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text("Delete Program"),
                          content: const Text(
                              "Are you sure you want to delete this program?"),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(c, false),
                                child: const Text("No")),
                            TextButton(
                                onPressed: () => Navigator.pop(c, true),
                                child: const Text("Yes",
                                    style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await controller.deleteProgram(program.id);
                        if (context.mounted) {
                          Navigator.pop(context);
                          AppToast.error(context, 'Program Deleted');
                        }
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  MyElevatedButton(
                    bgColor: AppColors.primary,
                    child: 'Edit Program',
                    onTap: () {
                      Navigator.pop(context); // Close View
                      showDialog(
                        context: context,
                        builder: (c) => AddProgramDialog(
                            token: token, programToEdit: program),
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

  Widget _buildGridRow(String l1, String v1, String l2, String v2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l1,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(v1,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l2,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(v2,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color dot;
    String s = status.toLowerCase();

    if (s == 'active' || s == 'scheduled') {
      bg = AppColors.successSubtle;
      dot = AppColors.success;
    } else if (s == 'completed') {
      bg = AppColors.infoSubtle;
      dot = AppColors.primary;
    } else {
      bg = AppColors.neutral100;
      dot = AppColors.neutral400;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(toBeginningOfSentenceCase(status) ?? status,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return "-";
    return DateFormat('dd MMM, yyyy').format(d);
  }
}
