import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/pages/finance/models/budget_model.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ViewBudgetDialog extends StatefulWidget {
  final Budget budget;
  const ViewBudgetDialog({super.key, required this.budget});

  @override
  State<ViewBudgetDialog> createState() => _ViewBudgetDialogState();
}

class _ViewBudgetDialogState extends State<ViewBudgetDialog> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.budget;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Budget Details',
                      style: AppTextStyles.displayMd),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Iconsax.close_circle,
                          size: 24, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.neutral200),
            Flexible(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _row('Branch', b.branchName),
                      _row('Department', b.departmentName),
                      _row('Fiscal Period', b.fiscalPeriod),
                      const Divider(height: 24),
                      _row('Amount', '₦${b.amount}', isBold: true),
                      _row('Current Spend', '₦${b.currentSpend}'),
                      _row('Remaining Budget', '₦${b.remainingBudget}'),
                    ],
                  ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    onTap: () => Navigator.pop(context),
                    textColor: AppColors.textSecondary,
                    borderColor: AppColors.borderStrong,
                  ),
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
            width: 140,
            child: Text(label,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
                  color: isBold ? AppColors.primary : AppColors.textPrimary,
                )),
          ),
        ],
      ),
    );
  }
}
