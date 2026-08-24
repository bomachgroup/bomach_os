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

import '../../../src/model/employees_model.dart';
import '../controller/employees_controller.dart';

class SuspendEmployeeDialog extends StatefulWidget {
  final Employee employee;

  const SuspendEmployeeDialog({super.key, required this.employee});

  @override
  State<SuspendEmployeeDialog> createState() => _SuspendEmployeeDialogState();
}

class _SuspendEmployeeDialogState extends State<SuspendEmployeeDialog> {
  final EmployeeController controller = Get.find<EmployeeController>();
  final _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    // Audit B5 fix: pop ONLY on success. The old `.then(pop)` closed the
    // controller's error dialog one frame after it opened, leaving the
    // user with zero feedback on failure.
    final ok = await controller.suspendEmployee(
      context,
      widget.employee.id,
      reason: _reasonCtrl.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      AppToast.success(context, 'Employee suspended successfully');
    } else {
      AppToast.error(context, controller.errorMessage.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: 'Suspend Employee',
      subtitle: 'Temporarily suspend employee access and privileges.',
      size: DialogSize.sm,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: AppRadii.brMd,
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.info_circle,
                    color: AppColors.warning, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Suspension Notice',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Are you sure you want to suspend ${widget.employee.fullName}? Their account will be deactivated and marked as suspended.',
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
            'Reason / Notes (Optional)',
            style: AppTextStyles.label.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          MyTextFormField(
            controller: _reasonCtrl,
            hintText: 'Enter reason for suspension...',
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          onTap: () => Navigator.pop(context),
        ),
        Obx(() => MyElevatedButton(
              isLoading: controller.isSaving.value,
              child: 'Suspend Employee',
              bgColor: AppColors.warning,
              onTap: _onSubmit,
            )),
      ],
    );
  }
}

