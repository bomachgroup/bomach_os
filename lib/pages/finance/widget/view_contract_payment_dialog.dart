import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bomach_os/src/utils/app_date_format.dart';

class ViewContractPaymentDialog extends StatefulWidget {
  final String? vendorName;
  final String? amountDue;
  final String? dueDate;
  final String? status;
  final String? paymentMethod;
  final String? transactionRef;
  final String? notes;

  const ViewContractPaymentDialog({
    super.key,
    this.vendorName,
    this.amountDue,
    this.dueDate,
    this.status,
    this.paymentMethod,
    this.transactionRef,
    this.notes,
  });

  @override
  State<ViewContractPaymentDialog> createState() =>
      _ViewContractPaymentDialogState();
}

class _ViewContractPaymentDialogState extends State<ViewContractPaymentDialog> {
  @override
  Widget build(BuildContext context) {
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
                  const Text('Vendor Payment Details',
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
                    _row('Vendor Name', widget.vendorName ?? '—', isBold: true),
                    _row('Amount Due', '₦${widget.amountDue ?? '0'}',
                        isBold: true),
                    _row(
                        'Due Date',
                        formatAppDateValue(widget.dueDate,
                            fallback: widget.dueDate ?? '—')),
                    _row('Status', widget.status ?? '—'),
                    if (widget.paymentMethod != null)
                      _row('Payment Method', widget.paymentMethod!),
                    if (widget.transactionRef != null)
                      _row('Transaction Ref', widget.transactionRef!),
                    if (widget.notes != null) _row('Notes', widget.notes!),
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
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.textSecondary)),
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
