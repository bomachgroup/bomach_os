import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:bomach_os/src/helper/date_picker_helper.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
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
  String? selectedEmployeeId;
  String? selectedEmployeeLabel;
  late TextEditingController amountCtrl;
  late TextEditingController repaymentDateCtrl;
  late TextEditingController reasonCtrl;
  late TextEditingController emergencyNameCtrl;
  late TextEditingController emergencyPhoneCtrl;

  @override
  void initState() {
    super.initState();
    final l = widget.loanToEdit;
    // Try to find matching employee by name for edit mode
    if (l != null && l.employeeName.isNotEmpty) {
      final match = controller.allEmployees.firstWhereOrNull(
          (e) => '${e.firstName} ${e.lastName}' == l.employeeName);
      selectedEmployeeId = match?.id;
      selectedEmployeeLabel = match != null
          ? '${match.firstName} ${match.lastName}'
          : null;
    }
    amountCtrl = TextEditingController(text: l?.loanAmount ?? '');
    repaymentDateCtrl = TextEditingController(text: l?.repaymentDate ?? '');
    reasonCtrl = TextEditingController(text: l?.reason ?? '');
    emergencyNameCtrl =
        TextEditingController(text: l?.emergencyContactName ?? '');
    emergencyPhoneCtrl =
        TextEditingController(text: l?.emergencyContactPhone ?? '');
  }

  @override
  void dispose() {
    // selectedEmployeeId is not a controller
    amountCtrl.dispose();
    repaymentDateCtrl.dispose();
    reasonCtrl.dispose();
    emergencyNameCtrl.dispose();
    emergencyPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePopover(
      context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      repaymentDateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {});
    }
  }

  void _submit() {
    // Basic Validation
    if (amountCtrl.text.isEmpty ||
        repaymentDateCtrl.text.isEmpty ||
        reasonCtrl.text.isEmpty ||
        emergencyNameCtrl.text.isEmpty ||
        emergencyPhoneCtrl.text.isEmpty) {
      AppToast.error(context, 'Please fill in all required fields');
      return;
    }

    // Populate controller form fields and call createLoan
    controller.loanAmountController.text = amountCtrl.text.replaceAll(',', '').trim();
    controller.repaymentDateController.text = repaymentDateCtrl.text.trim();
    controller.reasonController.text = reasonCtrl.text.trim();
    controller.emergencyContactNameController.text =
        emergencyNameCtrl.text.trim();
    controller.emergencyContactPhoneController.text =
        emergencyPhoneCtrl.text.trim();
    controller.createLoan(context);
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: 'Loan Application',
      subtitle:
          'Submit a loan request with repayment plan and emergency contacts.',
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSection(
            title: 'Applicant',
            child: Obx(() {
              final employees = controller.allEmployees;
              final items = employees
                  .map((e) => '${e.firstName} ${e.lastName}')
                  .toList();
              return MyDropdown(
                title: 'Employee Name',
                items: items,
                initialSelection: selectedEmployeeLabel,
                hintText: selectedEmployeeLabel ?? 'Select employee',
                onChanged: (val) {
                  final match = employees.firstWhereOrNull(
                      (e) => '${e.firstName} ${e.lastName}' == val);
                  setState(() {
                    selectedEmployeeId = match?.id;
                    selectedEmployeeLabel = val;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Loan Details',
            child: Column(
              children: [
                MyTextFormField(
                  title: 'Loan Amount',
                  controller: amountCtrl,
                  hintText: 'NGN 100,000',
                  isFormattedNumber: true,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildDateField(
                  label: 'Repayment Date',
                  value: DateTime.tryParse(repaymentDateCtrl.text),
                  onTap: _selectDate,
                ),
                const SizedBox(height: 16),
                MyTextFormField(
                  title: 'Reason For Loan',
                  controller: reasonCtrl,
                  maxLines: 4,
                  hintText: 'Provide a brief explanation',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Emergency Contact',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: MyTextFormField(
                    title: 'Contact Name',
                    controller: emergencyNameCtrl,
                    hintText: 'Type Name',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MyTextFormField(
                    title: 'Contact Phone',
                    controller: emergencyPhoneCtrl,
                    hintText: 'Phone Number',
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Attachment',
            subtitle: 'Optional supporting evidence or proof',
            child: _buildUploadZone(),
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
          child: 'Cancel',
          onTap: () => Navigator.pop(context),
        ),
        MyElevatedButton(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          bgColor: AppColors.primary,
          child: 'Apply',
          onTap: _submit,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
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
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: AppRadii.brMd,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.brMd,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.calendar_1,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Text(
                  value != null
                      ? DateFormat('MMM d, yyyy').format(value)
                      : 'dd/mm/yyyy',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: value != null
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadZone() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primarySubtle,
        borderRadius: AppRadii.brMd,
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Iconsax.document_upload,
                color: AppColors.white, size: 20),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textPrimary),
              children: [
                const TextSpan(
                    text: 'Drag & Drop or ',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                TextSpan(
                    text: 'choose file',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    )),
                const TextSpan(text: ' to upload'),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Supported formats: doc, pdf',
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
