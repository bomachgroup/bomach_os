import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/pay_roll_controller.dart';
import '../models/payroll_model.dart';
import 'add_payroll_dialog.dart';

class ViewPayrollDialog extends StatelessWidget {
  final Payroll payroll;
  const ViewPayrollDialog({super.key, required this.payroll});

  @override
  Widget build(BuildContext context) {
    final PayrollController controller = Get.find();
    final ScrollController scrollController = ScrollController();

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Payroll Details',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                      _buildDetailRow('Employee ID', payroll.employeeId),
                      _buildDetailRow('Payroll Period', payroll.payrollPeriod),
                      _buildDetailRow('Status', payroll.status, isBlue: true),
                      _buildDetailRow(
                          'Gross Salary', payroll.grossSalary.toString()),
                      kSizedBoxSM,
                      if (payroll.additions != null &&
                          payroll.additions!.isNotEmpty) ...[
                        const MyText("Allowances Included:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: payroll.additions!.keys
                              .map((k) => Chip(label: Text(k)))
                              .toList(),
                        ),
                        kSizedBox,
                      ],
                      if (payroll.deductions != null &&
                          payroll.deductions!.isNotEmpty) ...[
                        const MyText("Deductions Included:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: payroll.deductions!.keys
                              .map((k) => Chip(label: Text(k)))
                              .toList(),
                        ),
                        kSizedBox,
                      ],
                      _buildDetailRow('Total Allowances',
                          payroll.totalAllowances.toString()),
                      _buildDetailRow('Total Deductions',
                          payroll.totalDeductions.toString()),
                      _buildDetailRow(
                          'Net Salary', payroll.netSalary.toString(),
                          isBlue: true),
                      _buildDetailRow(
                          'Disbursement Date',
                          payroll.disbursementDate != null
                              ? DateFormat('yyyy-MM-dd')
                                  .format(payroll.disbursementDate!)
                              : 'N/A'),
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
                                title: const Text('Delete Payroll'),
                                content: const Text('Are you sure?'),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(c, false),
                                      child: const Text('No')),
                                  TextButton(
                                      onPressed: () => Navigator.pop(c, true),
                                      child: const Text('Yes')),
                                ],
                              ));

                      if (confirm == true) {
                        await controller.deletePayroll(payroll.id);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Payroll deleted"),
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
                        builder: (c) =>
                            AddPayRollDialog(payrollToEdit: payroll),
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

  Widget _buildDetailRow(String label, String value, {bool isBlue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(label, style: TextStyle(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isBlue ? const Color(0xFF007AFF) : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
