import 'package:web/web.dart' as web;
import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/models/invoice_model.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

class ApprovePaymentDialog extends StatefulWidget {
  final Payment payment;
  final Function(Payment approvedPayment) onApprove;
  final Function(Payment rejectedPayment, String reason) onReject;

  const ApprovePaymentDialog({
    super.key,
    required this.payment,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<ApprovePaymentDialog> createState() => _ApprovePaymentDialogState();
}

class _ApprovePaymentDialogState extends State<ApprovePaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _rejectionReasonController = TextEditingController();
  bool _showRejectionReason = false;

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  Widget _buildDetailRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: highlight ? AppColors.blue : Colors.black87,
                fontWeight: highlight ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;

    switch (widget.payment.approvalStatus) {
      case PaymentApprovalStatus.pending:
        color = Colors.orange;
        text = 'Pending Approval';
        break;
      case PaymentApprovalStatus.approved:
        color = Colors.green;
        text = 'Approved';
        break;
      case PaymentApprovalStatus.rejected:
        color = Colors.red;
        text = 'Rejected';
        break;
      case PaymentApprovalStatus.underReview:
        color = Colors.blue;
        text = 'Under Review';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _approvePayment() {
    final approvedPayment = widget.payment.copyWith(
      approvalStatus: PaymentApprovalStatus.approved,
      approvedBy: 'Current User', // Replace with actual user
      approvedDate: DateTime.now(),
    );
    widget.onApprove(approvedPayment);
    Navigator.of(context).pop();
  }

  void _rejectPayment() {
    if (_formKey.currentState?.validate() ?? false) {
      final rejectedPayment = widget.payment.copyWith(
        approvalStatus: PaymentApprovalStatus.rejected,
        rejectedBy: 'Current User', // Replace with actual user
        rejectedDate: DateTime.now(),
        rejectionReason: _rejectionReasonController.text,
      );
      widget.onReject(rejectedPayment, _rejectionReasonController.text);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canApprove =
        widget.payment.approvalStatus == PaymentApprovalStatus.pending ||
            widget.payment.approvalStatus == PaymentApprovalStatus.underReview;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.05),
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
                        const Text(
                          'Payment Approval',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Payment ID: ${widget.payment.id}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey1,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildStatusBadge(),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.close, size: 28),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Payment Details Section
                      _buildSectionHeader('Payment Information'),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              'Amount',
                              '₦${_formatAmount(widget.payment.amount)}',
                              highlight: true,
                            ),
                            _buildDetailRow(
                              'Payment Date',
                              _formatDate(widget.payment.paymentDate),
                            ),
                            _buildDetailRow(
                              'Payment Method',
                              widget.payment.method.name.toUpperCase(),
                            ),
                            if (widget.payment.transactionReference != null)
                              _buildDetailRow(
                                'Transaction Ref',
                                widget.payment.transactionReference!,
                              ),
                            if (widget.payment.receiptNumber != null)
                              _buildDetailRow(
                                'Receipt Number',
                                widget.payment.receiptNumber!,
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Bank/Depositor Information (for cash/bank transfers)
                      if (widget.payment.method == PaymentMethod.cash ||
                          widget.payment.method ==
                              PaymentMethod.bankTransfer) ...[
                        _buildSectionHeader('Deposit Information'),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              if (widget.payment.depositorName != null)
                                _buildDetailRow(
                                  'Depositor Name',
                                  widget.payment.depositorName!,
                                ),
                              if (widget.payment.bankName != null)
                                _buildDetailRow(
                                  'Bank Name',
                                  widget.payment.bankName!,
                                ),
                              if (widget.payment.accountNumber != null)
                                _buildDetailRow(
                                  'Account Number',
                                  widget.payment.accountNumber!,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Proof of Payment
                      if (widget.payment.proofOfPayment.isNotEmpty) ...[
                        _buildSectionHeader('Proof of Payment'),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              ...widget.payment.proofOfPayment.map((proof) {
                                return ListTile(
                                  leading: const Icon(
                                    Icons.attach_file,
                                    color: AppColors.blue,
                                  ),
                                  title: Text(proof.split('/').last),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.visibility),
                                    onPressed: () {
                                      web.window.open(proof, '_blank');
                                    },
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Notes
                      if (widget.payment.notes != null) ...[
                        _buildSectionHeader('Notes'),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Text(
                            widget.payment.notes!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Approval/Rejection Information
                      if (widget.payment.approvalStatus ==
                          PaymentApprovalStatus.approved) ...[
                        _buildSectionHeader('Approval Details'),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.green.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            children: [
                              if (widget.payment.approvedBy != null)
                                _buildDetailRow(
                                  'Approved By',
                                  widget.payment.approvedBy!,
                                ),
                              if (widget.payment.approvedDate != null)
                                _buildDetailRow(
                                  'Approved On',
                                  _formatDate(widget.payment.approvedDate!),
                                ),
                            ],
                          ),
                        ),
                      ],

                      if (widget.payment.approvalStatus ==
                          PaymentApprovalStatus.rejected) ...[
                        _buildSectionHeader('Rejection Details'),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.red.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            children: [
                              if (widget.payment.rejectedBy != null)
                                _buildDetailRow(
                                  'Rejected By',
                                  widget.payment.rejectedBy!,
                                ),
                              if (widget.payment.rejectedDate != null)
                                _buildDetailRow(
                                  'Rejected On',
                                  _formatDate(widget.payment.rejectedDate!),
                                ),
                              if (widget.payment.rejectionReason != null)
                                _buildDetailRow(
                                  'Reason',
                                  widget.payment.rejectionReason!,
                                ),
                            ],
                          ),
                        ),
                      ],

                      // Rejection Reason Input (when rejecting)
                      if (_showRejectionReason) ...[
                        const SizedBox(height: 24),
                        _buildSectionHeader('Rejection Reason'),
                        const SizedBox(height: 16),
                        MyTextFormField(
                          controller: _rejectionReasonController,
                          hintText: 'Enter reason for rejection...',
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please provide a reason for rejection';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Action Buttons
              if (canApprove)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!_showRejectionReason) ...[
                        MyOutlinedButton(
                          textColor: Colors.red,
                          borderColor: Colors.red,
                          child: 'Reject Payment',
                          onTap: () {
                            setState(() {
                              _showRejectionReason = true;
                            });
                          },
                        ),
                        const SizedBox(width: 16),
                        MyElevatedButton(
                          bgColor: Colors.green,
                          icon: const Icon(Icons.check_circle,
                              color: Colors.white),
                          child: 'Approve Payment',
                          onTap: _approvePayment,
                        ),
                      ] else ...[
                        MyOutlinedButton(
                          textColor: AppColors.darkGrey1,
                          borderColor: null,
                          child: 'Cancel',
                          onTap: () {
                            setState(() {
                              _showRejectionReason = false;
                              _rejectionReasonController.clear();
                            });
                          },
                        ),
                        const SizedBox(width: 16),
                        MyElevatedButton(
                          bgColor: Colors.red,
                          icon: const Icon(Icons.cancel, color: Colors.white),
                          child: 'Confirm Rejection',
                          onTap: _rejectPayment,
                        ),
                      ],
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MyElevatedButton(
                        child: 'Close',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
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
            color: AppColors.blue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
