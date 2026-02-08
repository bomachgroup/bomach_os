import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const MyText('Case Details', size: 20, weight: 600),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildRow('Employee ID', kase.employeeId),
                    _buildRow('Violation Title', kase.violationTitle),
                    _buildRow('Category', kase.violationCategory),
                    _buildRow('Action Type', kase.actionType, isHighlight: true),
                    _buildRow('Action Date', kase.actionDate != null ? DateFormat('yyyy-MM-dd').format(kase.actionDate!) : '-'),
                    const SizedBox(height: 16),
                    _buildSection('Description', kase.violationDescription),
                    _buildSection('Investigation Details', kase.investigationDetails ?? 'None provided'),
                    if (kase.severancePaymentDue)
                      _buildRow('Severance Amount', kase.severanceAmount?.toStringAsFixed(2) ?? '0.00'),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade300))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyOutlinedButton(
                      textColor: AppColors.red,
                      child: 'Delete',
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text('Delete Case'),
                            content: const Text('Are you sure you want to delete this case?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('No')),
                              TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Yes')),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await controller.deleteCase(token, kase.id);
                          if (context.mounted) Navigator.pop(context);
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
                          builder: (c) => AddDisciplinaryCaseDialog(token: token, caseToEdit: kase),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: MyText(label, color: Colors.grey.shade600, size: 14),
          ),
          Expanded(
            child: MyText(
              value,
              size: 14,
              color: isHighlight ? AppColors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(title, size: 14),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: MyText(content, size: 14),
          ),
        ],
      ),
    );
  }
}