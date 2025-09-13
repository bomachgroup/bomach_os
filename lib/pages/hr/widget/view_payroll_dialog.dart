import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/checkbox_text.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';

class ViewPayrollDialog extends StatefulWidget {
  const ViewPayrollDialog({super.key});

  @override
  State<ViewPayrollDialog> createState() => _ViewPayrollDialogState();
}

class _ViewPayrollDialogState extends State<ViewPayrollDialog> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildDetailRow(String label, String value, {bool isBlue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846),

        // width: MediaQuery.of(context).size.width * 0.9,
        // height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
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
                    'Payroll Details',
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
                        Icons.close,
                        size: 24,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE5E5E5)),

            // Scrollable Content
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Employee ID', 'HGGHJH22'),
                      _buildDetailRow('Employee ID', 'John Michael'),
                      _buildDetailRow('Payroll Period', '15, July 2025'),
                      _buildDetailRow('Gross Salary', '150,000'),
                      kSizedBoxSM,

                      Row(
                        children: [
                          SizedBox(
                            width: 200,
                            child: MyText(
                              "Allowances",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Wrap(
                              runSpacing: 12,
                              spacing: 12,
                              children: [
                                CheckboxText(text: "Housing"),
                                CheckboxText(text: "Car"),
                                CheckboxText(text: "Transport"),
                                CheckboxText(text: "Feeding"),
                                CheckboxText(text: "Electricity"),
                                CheckboxText(text: "Water"),
                                CheckboxText(text: "Internet"),
                                CheckboxText(text: "Healthcare"),
                                CheckboxText(text: "Insurance"),
                                CheckboxText(text: "Education"),
                                CheckboxText(text: "Entertainment"),
                                CheckboxText(text: "Clothing"),
                                CheckboxText(text: "Savings"),
                              ],
                            ),
                          ),
                        ],
                      ),

                      kSizedBox,

                      Row(
                        children: [
                          SizedBox(
                            width: 200,
                            child: MyText(
                              "Deductions",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Wrap(
                              runSpacing: 12,
                              spacing: 12,
                              children: [
                                CheckboxText(text: "Tax"),
                                CheckboxText(text: "Pension"),
                                CheckboxText(text: "Loan"),
                              ],
                            ),
                          ),
                        ],
                      ),
                      kSizedBoxSM,

                      _buildDetailRow('Net Salary', '450,000'),
                      _buildDetailRow('Disbursement Date', '29, July 2025'),
                      _buildDetailRow('Status', 'Pending'),

                      const SizedBox(height: 100), // Space for bottom buttons
                    ],
                  ),
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
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      alignment: WrapAlignment.end,
                      children: [
                        MyElevatedButton(
                          bgColor: AppColors.red,
                          child: 'Delete',
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        MyElevatedButton(
                          child: 'Edit',
                          onTap: () {},
                        ),
                      ],
                    ),
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
