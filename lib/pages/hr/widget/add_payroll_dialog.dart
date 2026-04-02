import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Payroll saved successfully"),
            backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Failed to save payroll"),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText(
                    widget.payrollToEdit == null
                        ? 'New Payroll'
                        : 'Edit Payroll',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyTextFormField(
                        title: 'Employee ID', controller: employeeIdCtrl),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                          child: MyTextFormField(
                              title: 'Payroll Period (e.g. 2025-07)',
                              controller: payrollPeriodCtrl)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: MyTextFormField(
                              title: 'Status (pending/paid)',
                              controller: statusCtrl)),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                          child: MyTextFormField(
                              title: 'Gross Salary',
                              controller: grossSalaryCtrl)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: MyTextFormField(
                              title: 'Net Salary', controller: netSalaryCtrl)),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                          child: MyTextFormField(
                              title: 'Total Allowances',
                              controller: totalAllowancesCtrl)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: MyTextFormField(
                              title: 'Total Deductions',
                              controller: totalDeductionsCtrl)),
                    ]),
                    const SizedBox(height: 24),
                    const MyText("Allowances (Check active)"),
                    kSizedBoxSM,
                    _buildCheckboxGroup(allowancesMap),
                    kSizedBox,
                    const MyText("Deductions (Check active)"),
                    kSizedBoxSM,
                    _buildCheckboxGroup(deductionsMap),
                    kSizedBox,
                    InkWell(
                      onTap: _selectDate,
                      child: IgnorePointer(
                        child: MyTextFormField(
                            title: 'Disbursement Date',
                            controller: disbursementDateCtrl,
                            hintText: 'YYYY-MM-DD'),
                      ),
                    ),
                  ],
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
                  MyOutlinedButton(
                    textColor: AppColors.darkGrey1,
                    child: 'Cancel',
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  Obx(() => MyElevatedButton(
                        child: controller.isSaving.value ? 'Saving...' : 'Save',
                        onTap: controller.isSaving.value ? () {} : _save,
                        icon: SvgPicture.asset("assets/svg/check.svg",
                            colorFilter: const ColorFilter.mode(
                                AppColors.white, BlendMode.srcIn)),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxGroup(Map<String, bool> map) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.grey1.withValues(alpha: 0.3)),
      ),
      child: Wrap(
        runSpacing: 12,
        spacing: 12,
        children: map.keys.map((key) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: map[key],
                onChanged: (val) {
                  setState(() {
                    map[key] = val ?? false;
                  });
                },
              ),
              Text(key),
            ],
          );
        }).toList(),
      ),
    );
  }
}
