import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../controller/pay_roll_controller.dart';
import '../models/payroll_model.dart';

class AddPayRollDialog extends StatefulWidget {
  final Payroll? payrollToEdit;
  const AddPayRollDialog({super.key, this.payrollToEdit});

  @override
  State<AddPayRollDialog> createState() => _AddPayRollDialogState();
}

class _AddPayRollDialogState extends State<AddPayRollDialog> {
  final PayrollController controller = Get.find();

  late TextEditingController employeeIdCtrl;
  late TextEditingController payrollPeriodCtrl;
  late TextEditingController grossSalaryCtrl;
  late TextEditingController netSalaryCtrl;
  late TextEditingController totalDeductionsCtrl;
  late TextEditingController totalAllowancesCtrl;
  late TextEditingController disbursementDateCtrl;
  late TextEditingController statusCtrl;

  final Map<String, bool> allowancesMap = {
    "Housing": false,
    "Car": false,
    "Transport": false,
    "Feeding": false,
    "Electricity": false,
    "Water": false,
    "Internet": false,
    "Healthcare": false,
    "Insurance": false,
    "Education": false,
    "Entertainment": false,
    "Clothing": false,
    "Savings": false
  };

  final Map<String, bool> deductionsMap = {
    "Tax": false,
    "Pension": false,
    "Loan": false
  };

  @override
  void initState() {
    super.initState();
    final p = widget.payrollToEdit;

    employeeIdCtrl = TextEditingController(text: p?.employeeId ?? '');
    payrollPeriodCtrl = TextEditingController(text: p?.payrollPeriod ?? '');
    grossSalaryCtrl =
        TextEditingController(text: p?.grossSalary.toString() ?? '');
    netSalaryCtrl = TextEditingController(text: p?.netSalary.toString() ?? '');
    totalDeductionsCtrl =
        TextEditingController(text: p?.totalDeductions.toString() ?? '');
    totalAllowancesCtrl =
        TextEditingController(text: p?.totalAllowances.toString() ?? '');
    statusCtrl = TextEditingController(text: p?.status ?? 'pending');
    disbursementDateCtrl = TextEditingController(
        text: p?.disbursementDate != null
            ? DateFormat('yyyy-MM-dd').format(p!.disbursementDate!)
            : '');

    if (p?.additions != null) {
      p!.additions!.forEach((key, value) {
        if (allowancesMap.containsKey(key)) allowancesMap[key] = true;
      });
    }
    if (p?.deductions != null) {
      p!.deductions!.forEach((key, value) {
        if (deductionsMap.containsKey(key)) deductionsMap[key] = true;
      });
    }
  }

  @override
  void dispose() {
    employeeIdCtrl.dispose();
    payrollPeriodCtrl.dispose();
    grossSalaryCtrl.dispose();
    netSalaryCtrl.dispose();
    totalDeductionsCtrl.dispose();
    totalAllowancesCtrl.dispose();
    disbursementDateCtrl.dispose();
    statusCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      disbursementDateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {});
    }
  }

  void _save() async {
    Map<String, dynamic> finalAdditions = {};
    allowancesMap.forEach((key, value) {
      if (value) finalAdditions[key] = true;
    });

    Map<String, dynamic> finalDeductions = {};
    deductionsMap.forEach((key, value) {
      if (value) finalDeductions[key] = true;
    });

    final newPayroll = Payroll(
      id: widget.payrollToEdit?.id ?? '',
      employeeId: employeeIdCtrl.text,
      payrollPeriod: payrollPeriodCtrl.text,
      status: statusCtrl.text.isEmpty ? 'pending' : statusCtrl.text,
      grossSalary: double.tryParse(grossSalaryCtrl.text) ?? 0,
      netSalary: double.tryParse(netSalaryCtrl.text) ?? 0,
      totalDeductions: double.tryParse(totalDeductionsCtrl.text) ?? 0,
      totalAllowances: double.tryParse(totalAllowancesCtrl.text) ?? 0,
      disbursementDate: DateTime.tryParse(disbursementDateCtrl.text),
      deductions: finalDeductions,
      additions: finalAdditions,
    );

    bool success;
    if (widget.payrollToEdit != null) {
      success =
          await controller.updatePayroll(widget.payrollToEdit!.id, newPayroll);
    } else {
      success = await controller.createPayroll(newPayroll);
    }

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      AppToast.success(context, 'Payroll saved successfully');
    } else {
      AppToast.error(context, 'Failed to save payroll');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.payrollToEdit != null;
    return DialogScaffold(
      title: isEdit ? 'Edit Payroll' : 'New Payroll',
      subtitle: isEdit
          ? 'Update payroll details, allowances, and deductions.'
          : 'Capture a payroll record with allowances, deductions, and disbursement.',
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSection(
            title: 'Employee & Period',
            child: Column(
              children: [
                MyTextFormField(
                  title: 'Employee ID',
                  controller: employeeIdCtrl,
                  hintText: 'Enter Employee ID',
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: MyTextFormField(
                        title: 'Payroll Period',
                        controller: payrollPeriodCtrl,
                        hintText: 'e.g. 2025-07',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MyTextFormField(
                        title: 'Status',
                        controller: statusCtrl,
                        hintText: 'pending / paid',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Salary Breakdown',
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: MyTextFormField(
                        title: 'Gross Salary',
                        controller: grossSalaryCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MyTextFormField(
                        title: 'Net Salary',
                        controller: netSalaryCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: MyTextFormField(
                        title: 'Total Allowances',
                        controller: totalAllowancesCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MyTextFormField(
                        title: 'Total Deductions',
                        controller: totalDeductionsCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Allowances',
            subtitle: 'Check the allowances that are active',
            child: _buildCheckboxGroup(allowancesMap),
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Deductions',
            subtitle: 'Check the deductions that apply',
            child: _buildCheckboxGroup(deductionsMap),
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Disbursement',
            child: _buildDateField(
              label: 'Disbursement Date',
              value: DateTime.tryParse(disbursementDateCtrl.text),
              onTap: _selectDate,
            ),
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
        Obx(() => MyElevatedButton(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              isLoading: controller.isSaving.value,
              icon: SvgPicture.asset(
                "assets/svg/check.svg",
                colorFilter: const ColorFilter.mode(
                    AppColors.white, BlendMode.srcIn),
              ),
              child: 'Save',
              onTap: controller.isSaving.value ? () {} : _save,
            )),
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

  Widget _buildCheckboxGroup(Map<String, bool> map) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brMd,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Wrap(
        runSpacing: 8,
        spacing: 12,
        children: map.keys.map((key) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: map[key],
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() {
                    map[key] = val ?? false;
                  });
                },
              ),
              Text(key, style: AppTextStyles.bodyMd),
            ],
          );
        }).toList(),
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
                      : 'Select date',
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
}
