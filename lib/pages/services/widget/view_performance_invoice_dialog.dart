import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/text/app_text.dart';
import 'package:bms_front_end/pages/services/models/performance_invoice_model.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

class ViewPerformanceInvoiceDialog extends StatelessWidget {
  final PerformanceInvoice invoice;

  const ViewPerformanceInvoiceDialog({
    super.key,
    required this.invoice,
  });

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  Widget _buildDetailRow(String label, String value, {bool isBlue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: AppText.bodyMd(
              label,
              color: AppColors.neutral500,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: AppText.bodyMd(
              value,
              color: isBlue ? AppColors.primary : AppColors.neutral800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Paid':
        color = Colors.green;
        break;
      case 'Pending':
        color = Colors.orange;
        break;
      case 'Partial':
        color = Colors.blue;
        break;
      case 'Failed':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color, width: 1.5),
      ),
      child: AppText.bodySm(
        status,
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.h3('Invoice Details'),
                      const SizedBox(height: 4),
                      AppText.bodyMd(
                        invoice.invoiceNumber ?? 'N/A',
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildStatusBadge(invoice.paymentStatus),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Iconsax.close_circle, size: 28),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Invoice Information Section
                    _buildSectionHeader('Invoice Information'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.neutral50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.neutral200),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            'Invoice Number',
                            invoice.invoiceNumber ?? 'N/A',
                            isBlue: true,
                          ),
                          _buildDetailRow(
                            'Transaction Date',
                            _formatDate(invoice.transactionDate),
                          ),
                          _buildDetailRow(
                            'Created Date',
                            _formatDate(invoice.createdDate),
                          ),
                          _buildDetailRow(
                            'Transaction Type',
                            invoice.transactionType,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Estate & Property Information
                    _buildSectionHeader('Estate & Property Details'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.neutral50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.neutral200),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('Estate Name', invoice.estateName),
                          if (invoice.plotNumber != null)
                            _buildDetailRow('Plot Number', invoice.plotNumber!),
                          if (invoice.description != null)
                            _buildDetailRow(
                                'Description', invoice.description!),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Client Information
                    if (invoice.clientName != null ||
                        invoice.clientPhone != null ||
                        invoice.clientEmail != null) ...[
                      _buildSectionHeader('Client Information'),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.neutral50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.neutral200),
                        ),
                        child: Column(
                          children: [
                            if (invoice.clientName != null)
                              _buildDetailRow(
                                  'Client Name', invoice.clientName!),
                            if (invoice.clientPhone != null)
                              _buildDetailRow(
                                  'Phone Number', invoice.clientPhone!),
                            if (invoice.clientEmail != null)
                              _buildDetailRow('Email', invoice.clientEmail!),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Financial Summary
                    _buildSectionHeader('Financial Summary'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        children: [
                          _buildFinancialRow('Total Amount', invoice.amount),
                          if (invoice.amountPaid != null) ...[
                            Divider(height: 24, color: AppColors.primary.withValues(alpha: 0.1)),
                            _buildFinancialRow(
                                'Amount Paid', invoice.amountPaid!,
                                color: Colors.green),
                          ],
                          if (invoice.balance != null &&
                              invoice.balance! > 0) ...[
                            Divider(height: 24, color: AppColors.primary.withValues(alpha: 0.1)),
                            _buildFinancialRow('Balance', invoice.balance!,
                                color: Colors.orange),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Payment Information
                    _buildSectionHeader('Payment Information'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.neutral50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.neutral200),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            'Payment Method',
                            invoice.paymentMethod,
                          ),
                          _buildDetailRow(
                            'Payment Status',
                            invoice.paymentStatus,
                          ),
                        ],
                      ),
                    ),

                    // Agent & Commission (if applicable)
                    if (invoice.agentName != null ||
                        invoice.commissionAmount != null) ...[
                      const SizedBox(height: 32),
                      _buildSectionHeader('Agent & Commission'),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.neutral50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.neutral200),
                        ),
                        child: Column(
                          children: [
                            if (invoice.agentName != null)
                              _buildDetailRow('Agent Name', invoice.agentName!),
                            if (invoice.commissionPercentage != null)
                              _buildDetailRow(
                                'Commission Rate',
                                '${invoice.commissionPercentage!.toStringAsFixed(1)}%',
                              ),
                            if (invoice.commissionAmount != null)
                              _buildFinancialRow(
                                'Commission Amount',
                                invoice.commissionAmount!,
                                color: Colors.purple,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.neutral300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyElevatedButton(
                    bgColor: AppColors.neutral600,
                    icon: const Icon(Iconsax.printer, color: AppColors.white),
                    child: 'Print Invoice',
                    onTap: () {
                      AppToast.info(context, 'Print functionality coming soon');
                    },
                  ),
                  Row(
                    children: [
                      MyElevatedButton(
                        bgColor: AppColors.primary,
                        icon:
                            const Icon(Iconsax.document_download, color: AppColors.white),
                        child: 'Download PDF',
                        onTap: () {
                          AppToast.info(context, 'PDF download functionality coming soon');
                        },
                      ),
                      const SizedBox(width: 12),
                      MyElevatedButton(
                        bgColor: Colors.green,
                        icon: const Icon(Iconsax.share, color: AppColors.white),
                        child: 'Share',
                        onTap: () {
                          AppToast.info(context, 'Share functionality coming soon');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        AppText.h4(
          title,
          color: AppColors.neutral800,
        ),
      ],
    );
  }

  Widget _buildFinancialRow(String label, double amount, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText.bodyLg(
            label,
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.neutral800,
          ),
          AppText.h3(
            '₦${_formatAmount(amount)}',
            color: color ?? AppColors.primary,
          ),
        ],
      ),
    );
  }
}
