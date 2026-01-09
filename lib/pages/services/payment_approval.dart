import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/models/invoice_model.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentApprovalPage extends StatefulWidget {
  const PaymentApprovalPage({super.key});

  @override
  State<PaymentApprovalPage> createState() => _PaymentApprovalPageState();
}

class _PaymentApprovalPageState extends State<PaymentApprovalPage> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  // Sample data - replace with actual data from your backend
  final List<Invoice> _sampleInvoices = [];

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    // Sample invoices with payments awaiting approval
    _sampleInvoices.addAll([
      Invoice(
        id: '1',
        invoiceNumber: 'INV-SVC-2024-001',
        clientId: 'client-1',
        clientName: 'Abuja Infrastructure Company',
        clientEmail: 'projects@abujainfra.ng',
        clientPhone: '+234 803 456 7890',
        serviceType: 'Land Survey',
        items: [
          InvoiceItem(
            id: 'item-1',
            description: 'Land Survey Services',
            quantity: 1,
            unitPrice: 650000,
            amount: 650000,
          ),
        ],
        subtotal: 650000,
        taxAmount: 48750,
        totalAmount: 698750,
        issueDate: DateTime.now().subtract(const Duration(days: 30)),
        dueDate: DateTime.now().subtract(const Duration(days: 5)),
        status: InvoiceStatus.sent,
        paymentStatus: PaymentStatus.partiallyPaid,
        payments: [
          Payment(
            id: 'payment-1',
            invoiceId: '1',
            amount: 300000,
            paymentDate: DateTime.now().subtract(const Duration(days: 2)),
            method: PaymentMethod.bankTransfer,
            approvalStatus: PaymentApprovalStatus.pending,
            transactionReference: 'TRX-20240125-001',
            bankName: 'First Bank',
            depositorName: 'Abuja Infrastructure Ltd',
            proofOfPayment: ['receipt_001.pdf'],
            createdBy: 'Client Portal',
            createdDate: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
        amountPaid: 0,
        balance: 698750,
        createdBy: 'Admin',
        createdDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Invoice(
        id: '2',
        invoiceNumber: 'INV-SVC-2024-002',
        clientId: 'client-2',
        clientName: 'Lagos Real Estate Ltd',
        clientEmail: 'info@lagosrealestate.com',
        serviceType: 'Real Estate',
        items: [
          InvoiceItem(
            id: 'item-2',
            description: 'Property Management Services',
            quantity: 1,
            unitPrice: 850000,
            amount: 850000,
          ),
        ],
        subtotal: 850000,
        taxAmount: 63750,
        totalAmount: 913750,
        issueDate: DateTime.now().subtract(const Duration(days: 20)),
        dueDate: DateTime.now().add(const Duration(days: 10)),
        status: InvoiceStatus.sent,
        paymentStatus: PaymentStatus.unpaid,
        payments: [
          Payment(
            id: 'payment-2',
            invoiceId: '2',
            amount: 913750,
            paymentDate: DateTime.now().subtract(const Duration(days: 1)),
            method: PaymentMethod.bankTransfer,
            approvalStatus: PaymentApprovalStatus.pending,
            transactionReference: 'TRX-20240126-002',
            bankName: 'GTBank',
            depositorName: 'Lagos Real Estate Limited',
            proofOfPayment: ['receipt_002.pdf'],
            notes: 'Full payment via bank transfer',
            createdBy: 'Client Portal',
            createdDate: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
        amountPaid: 0,
        balance: 913750,
        createdBy: 'Admin',
        createdDate: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ]);
  }

  List<Invoice> get _filteredInvoices {
    var invoices = _sampleInvoices.where((invoice) {
      // Check if invoice has pending payments
      final hasPendingPayments = invoice.payments
          .any((p) => p.approvalStatus == PaymentApprovalStatus.pending);
      if (!hasPendingPayments) return false;

      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return invoice.invoiceNumber.toLowerCase().contains(query) ||
            invoice.clientName.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    // Apply status filter
    if (_selectedFilter != 'All') {
      invoices = invoices.where((invoice) {
        final paymentStatus = _selectedFilter.toLowerCase().replaceAll(' ', '');
        return invoice.paymentStatus.name == paymentStatus;
      }).toList();
    }

    return invoices;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        kSizedBox,
        _buildStatsCards(),
        const SizedBox(height: 24),
        _buildFilters(),
        const SizedBox(height: 24),
        _buildPaymentsList(),
      ],
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          'Payment Approval',
          style: AppText.black_500_32,
        ),
        SizedBox(height: 4),
        MyText(
          'Review and approve pending payment submissions',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    final pendingPayments = _sampleInvoices.fold<int>(
      0,
      (sum, invoice) =>
          sum +
          invoice.payments
              .where((p) => p.approvalStatus == PaymentApprovalStatus.pending)
              .length,
    );

    final pendingAmount = _sampleInvoices.fold<double>(
      0,
      (sum, invoice) =>
          sum +
          invoice.payments
              .where((p) => p.approvalStatus == PaymentApprovalStatus.pending)
              .fold<double>(0, (pSum, payment) => pSum + payment.amount),
    );

    final todayPayments = _sampleInvoices.fold<int>(
      0,
      (sum, invoice) =>
          sum +
          invoice.payments
              .where((p) =>
                  p.approvalStatus == PaymentApprovalStatus.pending &&
                  p.createdDate.day == DateTime.now().day)
              .length,
    );

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard(
          'Pending Approvals',
          pendingPayments.toString(),
          Icons.pending_actions,
          AppColors.blue,
        ),
        _buildStatCard(
          'Total Amount',
          '₦${NumberFormat('#,###').format(pendingAmount)}',
          Icons.attach_money,
          Colors.green,
        ),
        _buildStatCard(
          'Today\'s Submissions',
          todayPayments.toString(),
          Icons.today,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      constraints: const BoxConstraints(minWidth: 180, minHeight: 140),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            radius: 20,
            child: Icon(icon, color: color, size: 20),
          ),
          kSizedBoxSM,
          MyText(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          MyText(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grey1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 280,
                child: MyTextFormField(
                  hintText: 'Search by invoice or client...',
                  leading: Icon(
                    Icons.search,
                    color: AppColors.grey1.withValues(alpha: 0.5),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value ?? "";
                    });
                  },
                ),
              ),
              SizedBox(
                width: 200,
                child: MyDropdown(
                  items: const [
                    'All',
                    'Unpaid',
                    'Partially Paid',
                    'Paid',
                  ],
                  hintText: _selectedFilter,
                  title: 'Filter by Status',
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value ?? 'All';
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentsList() {
    final filteredInvoices = _filteredInvoices;

    if (filteredInvoices.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No pending payments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All payments have been processed',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredInvoices.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildPaymentCard(filteredInvoices[index]);
      },
    );
  }

  Widget _buildPaymentCard(Invoice invoice) {
    // Get pending payments for this invoice
    final pendingPayments = invoice.payments
        .where((p) => p.approvalStatus == PaymentApprovalStatus.pending)
        .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Invoice Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          invoice.invoiceNumber,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildStatusBadge(invoice.paymentStatus),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      invoice.clientName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (invoice.serviceType != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        invoice.serviceType!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total: ${invoice.currency}${NumberFormat('#,###').format(invoice.totalAmount)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Balance: ${invoice.currency}${NumberFormat('#,###').format(invoice.balance)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Pending Payments Section
          const Text(
            'Pending Payments',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          ...pendingPayments
              .map((payment) => _buildPaymentItem(payment, invoice)),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(Payment payment, Invoice invoice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getPaymentMethodIcon(payment.method),
                          size: 18,
                          color: AppColors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatPaymentMethod(payment.method),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildPaymentDetail('Amount',
                        '₦${NumberFormat('#,###').format(payment.amount)}'),
                    _buildPaymentDetail('Date',
                        DateFormat('dd MMM yyyy').format(payment.paymentDate)),
                    if (payment.transactionReference != null)
                      _buildPaymentDetail(
                          'Reference', payment.transactionReference!),
                    if (payment.bankName != null)
                      _buildPaymentDetail('Bank', payment.bankName!),
                    if (payment.depositorName != null)
                      _buildPaymentDetail('Depositor', payment.depositorName!),
                    if (payment.notes != null && payment.notes!.isNotEmpty)
                      _buildPaymentDetail('Notes', payment.notes!),
                  ],
                ),
              ),
            ],
          ),
          if (payment.proofOfPayment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: payment.proofOfPayment.map((file) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.blue),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.attach_file,
                        size: 16,
                        color: AppColors.blue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        file,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.blue,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MyOutlinedButton(
                textColor: Colors.red,
                borderColor: Colors.red,
                child: 'Reject',
                onTap: () => _handleRejectPayment(payment, invoice),
              ),
              const SizedBox(width: 12),
              MyElevatedButton(
                icon: const Icon(Icons.check, color: Colors.white, size: 18),
                child: 'Approve',
                onTap: () => _handleApprovePayment(payment, invoice),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(PaymentStatus status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case PaymentStatus.paid:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        label = 'Paid';
        break;
      case PaymentStatus.partiallyPaid:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        label = 'Partially Paid';
        break;
      case PaymentStatus.unpaid:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        label = 'Unpaid';
        break;
      case PaymentStatus.refunded:
        backgroundColor = Colors.purple.shade100;
        textColor = Colors.purple.shade800;
        label = 'Refunded';
        break;
      case PaymentStatus.cancelled:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.payments;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.cheque:
        return Icons.description;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.mobileWallet:
        return Icons.phone_android;
      case PaymentMethod.other:
        return Icons.more_horiz;
    }
  }

  String _formatPaymentMethod(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash Payment';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.cheque:
        return 'Cheque';
      case PaymentMethod.card:
        return 'Card Payment';
      case PaymentMethod.mobileWallet:
        return 'Mobile Wallet';
      case PaymentMethod.other:
        return 'Other';
    }
  }

  void _handleApprovePayment(Payment payment, Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to approve this payment?'),
            const SizedBox(height: 16),
            Text(
              'Amount: ₦${NumberFormat('#,###').format(payment.amount)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text('Invoice: ${invoice.invoiceNumber}'),
            Text('Client: ${invoice.clientName}'),
          ],
        ),
        actions: [
          MyOutlinedButton(
            textColor: AppColors.darkGrey1,
            borderColor: null,
            child: 'Cancel',
            onTap: () => Navigator.pop(context),
          ),
          MyElevatedButton(
            child: 'Approve',
            onTap: () {
              // TODO: Implement approval logic here
              // Update payment approval status
              // Update invoice payment status and balance
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment approved successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              setState(() {
                // Refresh the list
              });
            },
          ),
        ],
      ),
    );
  }

  void _handleRejectPayment(Payment payment, Invoice invoice) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            MyTextFormField(
              controller: reasonController,
              hintText: 'Enter rejection reason',
              title: 'Reason',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Amount: ₦${NumberFormat('#,###').format(payment.amount)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text('Invoice: ${invoice.invoiceNumber}'),
          ],
        ),
        actions: [
          MyOutlinedButton(
            textColor: AppColors.darkGrey1,
            borderColor: null,
            child: 'Cancel',
            onTap: () => Navigator.pop(context),
          ),
          MyElevatedButton(
            bgColor: Colors.red,
            child: 'Reject',
            onTap: () {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason for rejection'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              // TODO: Implement rejection logic here
              // Update payment approval status to rejected
              // Store rejection reason
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment rejected'),
                  backgroundColor: Colors.red,
                ),
              );
              setState(() {
                // Refresh the list
              });
            },
          ),
        ],
      ),
    );
  }
}
