import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/pages/finance/models/service_invoice_model_api.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/utils/number_formatting.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class InvoiceDetailsDialog extends StatefulWidget {
  final ServiceInvoice invoice;
  const InvoiceDetailsDialog({super.key, required this.invoice});

  @override
  State<InvoiceDetailsDialog> createState() => _InvoiceDetailsDialogState();
}

class _InvoiceDetailsDialogState extends State<InvoiceDetailsDialog> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inv = widget.invoice;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
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
                  Text('Invoice #${inv.invoiceNumber}',
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
                      _row('Invoice #', inv.invoiceNumber, isBold: true),
                      _row('Service', inv.service.name),
                      _row('Client ID', inv.clientId.toString()),
                      _row('Issue Date', inv.issueDate),
                      _row('Due Date', inv.dueDate),
                      _row('Status', inv.status),
                      if (inv.order != null)
                        _row('Order', inv.order!.orderNumber),
                      if (inv.lead != null) _row('Lead', inv.lead!.name),
                      const Divider(height: 24),
                      const Text('Financial Summary',
                          style: AppTextStyles.h4),
                      const SizedBox(height: 12),
                      _row('Subtotal', inv.subtotal.toNaira()),
                      _row('Tax (${inv.taxRate.toCommas()}%)', inv.taxAmount.toNaira()),
                      _row('Total', inv.totalAmount.toNaira(), isBold: true),
                      _row('Amount Paid', inv.amountPaid.toNaira()),
                      _row('Balance', inv.balance.toNaira(),
                          isBold: true, isDanger: true),
                      if (inv.notes.isNotEmpty) ...[
                        const Divider(height: 24),
                        const Text('Notes', style: AppTextStyles.h4),
                        const SizedBox(height: 8),
                        Text(inv.notes,
                            style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.textPrimary)),
                      ],
                      if (inv.items.isNotEmpty) ...[
                        const Divider(height: 24),
                        const Text('Items', style: AppTextStyles.h4),
                        const SizedBox(height: 12),
                        ...inv.items.map((item) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              color: AppColors.surfaceMuted,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Text(item.description,
                                            style: AppTextStyles.bodyMd)),
                                    Text('${item.quantity.toCount()} × ${item.unitPrice.toNaira()}',
                                        style: AppTextStyles.bodySm
                                            .copyWith(color: AppColors.textSecondary)),
                                    const SizedBox(width: 12),
                                    Text(item.total.toNaira(),
                                        style: AppTextStyles.bodyMd.copyWith(
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            )),
                      ],
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

  Widget _row(String label, String value,
      {bool isBold = false, bool isDanger = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
                  color: isDanger
                      ? AppColors.danger
                      : isBold
                          ? AppColors.primary
                          : AppColors.textPrimary,
                )),
          ),
        ],
      ),
    );
  }
}
