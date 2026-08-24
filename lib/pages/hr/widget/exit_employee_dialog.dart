import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../src/model/employees_model.dart';
import '../controller/employees_controller.dart';

class ExitEmployeeDialog extends StatefulWidget {
  final Employee employee;

  const ExitEmployeeDialog({super.key, required this.employee});

  @override
  State<ExitEmployeeDialog> createState() => _ExitEmployeeDialogState();
}

class _ExitEmployeeDialogState extends State<ExitEmployeeDialog> {
  final EmployeeController controller = Get.find<EmployeeController>();
  final _reasonCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _dateCtrl.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Audit B5 fix: pop ONLY on success; failure shows an error toast and
    // keeps the form open (the old `.then(pop)` closed the error dialog).
    final ok = await controller.exitEmployee(
      context,
      widget.employee.id,
      exitDate: _dateCtrl.text.trim(),
      reason: _reasonCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      AppToast.success(context, 'Employee offboarded successfully');
    } else {
      AppToast.error(context, controller.errorMessage.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: 'Offboard / Exit Employee',
      subtitle: 'Process employee departure and transition to alumni records.',
      size: DialogSize.sm,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.08),
                borderRadius: AppRadii.brMd,
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.warning_2,
                      color: AppColors.danger, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exit Confirmation',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'You are about to exit ${widget.employee.fullName}. This will update their status to offboarded.',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Exit Date',
              style: AppTextStyles.label.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickDate,
              borderRadius: AppRadii.brMd,
              child: IgnorePointer(
                child: MyTextFormField(
                  controller: _dateCtrl,
                  hintText: 'YYYY-MM-DD',
                  leading: const Icon(Iconsax.calendar,
                      size: 18, color: AppColors.textMuted),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Exit date is required';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Reason for Exit',
              style: AppTextStyles.label.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            MyTextFormField(
              controller: _reasonCtrl,
              hintText: 'e.g. Resignation, Contract End, Relocation, Termination...',
              maxLines: 3,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Reason for exit is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          onTap: () => Navigator.pop(context),
        ),
        Obx(() => MyElevatedButton(
              isLoading: controller.isSaving.value,
              child: 'Confirm Exit',
              bgColor: AppColors.danger,
              onTap: _onSubmit,
            )),
      ],
    );
  }
}

