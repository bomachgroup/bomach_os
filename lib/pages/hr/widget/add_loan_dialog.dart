import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/loans_controller.dart';
import '../models/loans_model.dart';

class AddLoanDialog extends StatefulWidget {
  final LoanRequest? loanToEdit;

  const AddLoanDialog({super.key, this.loanToEdit});

  @override
  State<AddLoanDialog> createState() => _AddLoanDialogState();
}

class _AddLoanDialogState extends State<AddLoanDialog> {
  final LoanController controller = Get.find();

  // Controllers
  late TextEditingController employeeCtrl;
  late TextEditingController amountCtrl;
  late TextEditingController repaymentDateCtrl;
  late TextEditingController reasonCtrl;
  late TextEditingController emergencyNameCtrl;
  late TextEditingController emergencyPhoneCtrl;

  @override
  void initState() {
    super.initState();
    final l = widget.loanToEdit;
    employeeCtrl = TextEditingController(text: l?.employeeName ?? '');
    amountCtrl = TextEditingController(text: l?.amount.toString() ?? '');
    repaymentDateCtrl = TextEditingController(
        text: l?.repaymentDate != null
            ? DateFormat('yyyy-MM-dd').format(l!.repaymentDate)
            : '');
    reasonCtrl = TextEditingController(text: l?.reason ?? '');
    // Assuming model has these fields, otherwise empty
    emergencyNameCtrl = TextEditingController(text: 'Evelyn Chisom');
    emergencyPhoneCtrl = TextEditingController(text: '0803 1265 4789');
  }

  @override
  void dispose() {
    employeeCtrl.dispose();
    amountCtrl.dispose();
    repaymentDateCtrl.dispose();
    reasonCtrl.dispose();
    emergencyNameCtrl.dispose();
    emergencyPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      repaymentDateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _submit() {
    // Basic Validation
    if (amountCtrl.text.isEmpty ||
        repaymentDateCtrl.text.isEmpty ||
        reasonCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Please fill in all required fields",
          ),
          backgroundColor: Colors.red));
      return;
    }

    // Since we are using dummy data in controller, we just close dialog and show snackbar
    // In real app, call controller.createLoan(...) here
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Loan Application Submitted"),
          backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyText(
                    'Loan Application',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            // --- Form ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Employee Name
                    MyTextFormField(
                      title: 'Employee Name',
                      controller: employeeCtrl,
                      hintText: 'Select',
                      spaceBetweenText: 8,
                    ),
                    const SizedBox(height: 20),

                    // Loan Amount
                    MyTextFormField(
                      title: 'Loan Amount',
                      controller: amountCtrl,
                      hintText: '₦100,000',
                      spaceBetweenText: 8,
                    ),
                    const SizedBox(height: 20),

                    // Repayment Date
                    InkWell(
                      onTap: _selectDate,
                      child: IgnorePointer(
                        child: MyTextFormField(
                          title: 'Repayment Date',
                          controller: repaymentDateCtrl,
                          hintText: 'dd/mm/yyyy',
                          spaceBetweenText: 8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Reason
                    MyTextFormField(
                      title: 'Reason For Loan',
                      controller: reasonCtrl,
                      maxLines: 4,
                      hintText: 'Provide a brief Explanation',
                      spaceBetweenText: 8,
                    ),
                    const SizedBox(height: 20),

                    // Emergency Contacts
                    Row(
                      children: [
                        Expanded(
                          child: MyTextFormField(
                            title: 'Emergency Contact Name',
                            controller: emergencyNameCtrl,
                            hintText: 'Type Name',
                            spaceBetweenText: 8,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MyTextFormField(
                            title: 'Emergency Contact Phone',
                            controller: emergencyPhoneCtrl,
                            hintText: 'Phone Number',
                            spaceBetweenText: 8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Attachment Upload
                    const MyText("Attachment (Evidence or proof, etc.)",
                        weight: 600, size: 14),
                    const SizedBox(height: 8),
                    _buildUploadZone(),
                  ],
                ),
              ),
            ),

            // --- Footer ---
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 120,
                    child: MyOutlinedButton(
                      textColor: Colors.black87,
                      child: 'Cancel',
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 120,
                    child: MyElevatedButton(
                      bgColor: const Color(0xFF1976D2),
                      child: 'Apply',
                      onTap: _submit,
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

  Widget _buildUploadZone() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFF448AFF), style: BorderStyle.none),
      ),
      child: CustomPaint(
        painter: _DashedBorderPainter(color: const Color(0xFF448AFF)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                  color: Color(0xFF1976D2), shape: BoxShape.circle),
              child: const Icon(Icons.cloud_upload_outlined,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(height: 12),
            RichText(
              text: const TextSpan(
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                  children: [
                    TextSpan(
                        text: "Drag & Drop or ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: "choose file",
                        style: TextStyle(
                            color: Color(0xFF1976D2),
                            fontWeight: FontWeight.bold)),
                    TextSpan(text: " to upload"),
                  ]),
            ),
            const SizedBox(height: 4),
            const Text("Supported formats :doc, pdf",
                style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// Reuse the dashed painter
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  _DashedBorderPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double dashWidth = 6;
    const double dashSpace = 4;
    final Path path = Path();

    // Simple rect path logic for brevity
    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12)));

    // Note: To draw true dashes on RRect requires PathMetric or a loop.
    // For this snippet, we draw a solid line for stability or assume standard DottedBorder package is used.
    // Use 'dotted_border' package in production.
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
