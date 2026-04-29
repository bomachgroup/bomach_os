import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../models/service_invoice_model.dart';

class ViewInvoiceDialog extends StatefulWidget {
  final ServiceInvoice invoice;

  const ViewInvoiceDialog({
    super.key,
    required this.invoice,
  });

  @override
  State<ViewInvoiceDialog> createState() => _ViewInvoiceDialogState();
}

class _ViewInvoiceDialogState extends State<ViewInvoiceDialog> {
  late TextEditingController paymentAmountController;

  @override
  void initState() {
    super.initState();
    paymentAmountController = TextEditingController();
  }

  String _formatCurrency(double amount) {
    return 'NGN ${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  StatusTone _invoiceStatusTone(ServiceInvoiceStatus status) {
    switch (status) {
      case ServiceInvoiceStatus.draft:
        return StatusTone.neutral;
      case ServiceInvoiceStatus.sent:
        return StatusTone.info;
      case ServiceInvoiceStatus.viewed:
        return StatusTone.primary;
      case ServiceInvoiceStatus.overdue:
        return StatusTone.danger;
      case ServiceInvoiceStatus.cancelled:
      case ServiceInvoiceStatus.void_:
        return StatusTone.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoice = widget.invoice;

    return DialogScaffold(
      title: invoice.invoiceNumber,
      subtitle: 'Issued ${_formatDate(invoice.issueDate)}',
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusBanner(invoice),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Client information',
            children: [_buildClientInfo(invoice)],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Service details',
            children: [_buildServiceDetails(invoice)],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Invoice items',
            children: [_buildInvoiceItems(invoice)],
          ),
          const SizedBox(height: 16),
          _buildFinancialSummary(invoice),
          if (invoice.paymentStatus != ServicePaymentStatus.paid) ...[
            const SizedBox(height: 16),
            _buildPaymentStatus(invoice),
          ],
          if (invoice.payments.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSection(
              title: 'Payment history',
              children: [_buildPaymentHistory(invoice)],
            ),
          ],
          if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSection(
              title: 'Notes',
              children: [
                Text(
                  invoice.notes!,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Close',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
          onTap: () => Navigator.pop(context),
        ),
        MyOutlinedButton(
          child: 'Download PDF',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          icon: const Icon(Iconsax.document_download,
              size: 18, color: AppColors.primary),
          onTap: () {
            AppToast.info(context, 'PDF download coming soon');
          },
        ),
        MyElevatedButton(
          child: 'Print Invoice',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          icon: const Icon(Iconsax.printer,
              size: 18, color: AppColors.textOnPrimary),
          onTap: () {
            AppToast.info(context, 'Print functionality coming soon');
          },
        ),
      ],
    );
  }

  Widget _buildStatusBanner(ServiceInvoice invoice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySubtle,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.primarySoft),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: AppRadii.brSm,
            ),
            child: const Icon(Iconsax.receipt_2,
                color: AppColors.textOnPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invoice.invoiceNumber, style: AppTextStyles.h4),
                const SizedBox(height: 2),
                Text(
                  _formatCurrency(invoice.totalAmount),
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          StatusChip(
            label: invoice.status.toDisplayString(),
            tone: _invoiceStatusTone(invoice.status),
          ),
        ],
      ),
    );
  }

  Widget _buildClientInfo(ServiceInvoice invoice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                invoice.clientName,
                style: AppTextStyles.bodyMd
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (invoice.leadId.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: const BoxDecoration(
                  color: AppColors.infoSubtle,
                  borderRadius: AppRadii.brPill,
                ),
                child: Text(
                  'Lead: ${invoice.leadId}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          invoice.clientEmail ?? 'N/A',
          style: AppTextStyles.bodySm
              .copyWith(color: AppColors.textSecondary),
        ),
        if (invoice.clientPhone != null) ...[
          const SizedBox(height: 4),
          Text(
            invoice.clientPhone!,
            style: AppTextStyles.bodySm
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
        if (invoice.clientAddress != null) ...[
          const SizedBox(height: 4),
          Text(
            invoice.clientAddress!,
            style: AppTextStyles.bodySm
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }

  Widget _buildServiceDetails(ServiceInvoice invoice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _metaRow('Service Type', invoice.serviceType),
        if (invoice.propertyAddress != null) ...[
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Property/Address',
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                invoice.propertyAddress!,
                style: AppTextStyles.bodyMd
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _metaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySm
              .copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildInvoiceItems(ServiceInvoice invoice) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderSubtle),
        borderRadius: AppRadii.brMd,
      ),
      child: Column(
        children: List.generate(
          invoice.items.length,
          (index) {
            final item = invoice.items[index];
            final isLast = index == invoice.items.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.description,
                        style: AppTextStyles.bodyMd
                            .copyWith(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item.quantity} x ${_formatCurrency(item.unitPrice)}',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            _formatCurrency(item.amount),
                            style: AppTextStyles.bodyMd
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(
                    height: 1,
                    color: AppColors.borderSubtle,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFinancialSummary(ServiceInvoice invoice) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primarySubtle,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.primarySoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Financial summary', style: AppTextStyles.h4),
          const SizedBox(height: 16),
          _summaryRow('Subtotal', _formatCurrency(invoice.subtotal)),
          const SizedBox(height: 12),
          _summaryRow(
            'Tax (${invoice.taxRate.toStringAsFixed(1)}%)',
            _formatCurrency(invoice.taxAmount),
          ),
          if (invoice.discount > 0) ...[
            const SizedBox(height: 12),
            _summaryRow(
              'Discount',
              '-${_formatCurrency(invoice.discount)}',
              valueColor: AppColors.danger,
            ),
          ],
          const SizedBox(height: 16),
          const Divider(color: AppColors.borderSubtle, height: 1),
          const SizedBox(height: 16),
          _summaryRow(
            'Total',
            _formatCurrency(invoice.totalAmount),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool isTotal = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.h4
              : AppTextStyles.bodyMd
                  .copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.h4.copyWith(color: AppColors.primary)
              : AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
        ),
      ],
    );
  }

  Widget _buildPaymentStatus(ServiceInvoice invoice) {
    final progress = invoice.totalAmount == 0
        ? 0.0
        : (invoice.amountPaid / invoice.totalAmount).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warningSubtle,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.warningSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.money_send,
                  size: 18, color: AppColors.warning),
              const SizedBox(width: 8),
              const Text(
                'Payment status',
                style: AppTextStyles.h4,
              ),
              const SizedBox(width: 8),
              StatusChip(
                label: invoice.paymentStatus.toDisplayString(),
                tone: StatusTone.warning,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _summaryRow('Amount paid', _formatCurrency(invoice.amountPaid)),
          const SizedBox(height: 12),
          _summaryRow(
            'Balance',
            _formatCurrency(invoice.balance),
            valueColor: AppColors.danger,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surface,
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory(ServiceInvoice invoice) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderSubtle),
        borderRadius: AppRadii.brMd,
      ),
      child: Column(
        children: List.generate(
          invoice.payments.length,
          (index) {
            final payment = invoice.payments[index];
            final isLast = index == invoice.payments.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              payment.paymentMethod,
                              style: AppTextStyles.bodyMd.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(payment.paymentDate),
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatCurrency(payment.amount),
                            style: AppTextStyles.bodyMd.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          StatusChip(
                            label: payment.status,
                            tone: StatusTone.success,
                            dense: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(
                    height: 1,
                    color: AppColors.borderSubtle,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
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
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  @override
  void dispose() {
    paymentAmountController.dispose();
    super.dispose();
  }
}
