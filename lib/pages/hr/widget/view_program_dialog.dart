import 'package:bms_front_end/components/button/my_elevated_button.dart';
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
    final ScrollController scrollController = ScrollController();

    Widget buildDetailRow(String label, String value, {bool isBlue = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 200,
              child: Text(label,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: isBlue ? const Color(0xFF007AFF) : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Program Details',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child:
                        const Icon(Icons.close, size: 24, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E5E5)),
            Expanded(
              child: Scrollbar(
                controller: scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildDetailRow('Program Name', program.programName),
                      buildDetailRow('Provider', program.provider),
                      buildDetailRow(
                          'Start Date',
                          program.startDate != null
                              ? DateFormat('yyyy-MM-dd')
                                  .format(program.startDate!)
                              : '-'),
                      buildDetailRow(
                          'End Date',
                          program.endDate != null
                              ? DateFormat('yyyy-MM-dd')
                                  .format(program.endDate!)
                              : '-'),
                      buildDetailRow(
                          'Duration', '${program.durationDays} Days'),
                      buildDetailRow('Description', program.description),
                      buildDetailRow('Cost', program.cost.toString()),
                      buildDetailRow('Target Audience', program.targetAudience),
                      buildDetailRow(
                          'Is Mandatory', program.isMandatory ? 'Yes' : 'No'),
                      buildDetailRow('Status', program.status, isBlue: true),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyElevatedButton(
                    bgColor: AppColors.red,
                    child: 'Delete',
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          title: const Text("Delete Program"),
                          content: const Text("Are you sure?"),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(c, false),
                                child: const Text("No")),
                            TextButton(
                                onPressed: () => Navigator.pop(c, true),
                                child: const Text("Yes")),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await controller.deleteProgram(token, program.id);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Program Deleted"),
                                  backgroundColor: Colors.red));
                        }
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                  MyElevatedButton(
                    child: 'Edit',
                    onTap: () {
                      Navigator.pop(context);
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
}
