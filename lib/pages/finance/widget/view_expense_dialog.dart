import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/pages/finance/controllers/expense_controller.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/spaces.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/utils/number_formatting.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bomach_os/src/utils/app_date_format.dart';

import '../models/expense_model.dart';

class ViewExpenseDialog extends StatefulWidget {
  final Expense expense;
  const ViewExpenseDialog({super.key, required this.expense});

  @override
  State<ViewExpenseDialog> createState() => _ViewExpenseDialogState();
}

class _ViewExpenseDialogState extends State<ViewExpenseDialog> {
  final ExpenseController _ctrl = Get.find<ExpenseController>();
  final TextEditingController _rejectionReasonCtrl = TextEditingController();

  @override
  void dispose() {
    _rejectionReasonCtrl.dispose();
    super.dispose();
  }

  void _confirmReject() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Expense'),
        content: MyTextFormField(
          controller: _rejectionReasonCtrl,
          title: 'Reason for rejection (optional)',
          hintText: 'Add notes',
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _ctrl.rejectExpense(context, widget.expense.id);
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.expense;
    final isPending = e.status.toLowerCase() == 'pending';

    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Expense Details', style: AppTextStyles.displayMd),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row('Amount', e.amount.toNaira(), isBold: true),
                    _row('Category', e.category),
                    _row('Description', e.description),
                    _row('Date', formatAppDateValue(e.date, fallback: e.date)),
                    _row('Department', e.department.name),
                    _row('Status', e.status),
                    kSizedBoxSM,
                    Row(
                      children: [
                        StatusChip.fromStatus(e.status),
                      ],
                    ),
                    if (e.attachment != null && e.attachment!.isNotEmpty) ...[
                      kSizedBoxSM,
                      _row('Attachment', e.attachment!),
                    ],
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                    child: 'Close',
                    height: 40,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    onTap: () => Navigator.pop(context),
                    textColor: AppColors.textSecondary,
                    borderColor: AppColors.borderStrong,
                  ),
                  if (isPending) ...[
                    kSizedBoxWidth,
                    Obx(() => MyOutlinedButton(
                          child: 'Reject',
                          height: 40,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          icon: const Icon(Iconsax.close_circle,
                              size: 16, color: AppColors.danger),
                          onTap: _ctrl.isSaving.value ? () {} : _confirmReject,
                          textColor: AppColors.danger,
                          borderColor: AppColors.danger,
                        )),
                    kSizedBoxWidth,
                    Obx(() => MyElevatedButton(
                          height: 40,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          bgColor: AppColors.success,
                          isLoading: _ctrl.isSaving.value,
                          icon: const Icon(Iconsax.tick_circle,
                              size: 16, color: AppColors.textOnPrimary),
                          child: 'Approve',
                          onTap: _ctrl.isSaving.value
                              ? () {}
                              : () => _ctrl.approveExpense(context, e.id),
                        )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                  color: AppColors.textPrimary,
                )),
          ),
        ],
      ),
    );
  }
}
