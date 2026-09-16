import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/pages/finance/models/payment_model.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/utils/number_formatting.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ViewPaymentDialog extends StatefulWidget {
  final Payment payment;
  const ViewPaymentDialog({super.key, required this.payment});

  @override
  State<ViewPaymentDialog> createState() => _ViewPaymentDialogState();
}

class _ViewPaymentDialogState extends State<ViewPaymentDialog> {
  @override
  Widget build(BuildContext context) {
    final p = widget.payment;
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
                  const Text('Payment Details',
                      style: AppTextStyles.displayMd),
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
                    _row('Payment Reference', p.paymentReference, isBold: true),
                    _row('Invoice ID', p.invoiceId.toString()),
                    _row('Amount', p.amount.toNaira(), isBold: true),
                    _row('Payment Method', p.paymentMethod),
                    _row('Payment Date', p.paymentDate),
                    _row('Transaction Ref', p.transactionReference),
                    if (p.notes.isNotEmpty) _row('Notes', p.notes),
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
