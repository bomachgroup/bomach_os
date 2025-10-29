import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'models/service_invoice_model.dart';
import 'widgets/view_invoice_dialog.dart';

class ServiceInvoicesPage extends StatefulWidget {
  const ServiceInvoicesPage({super.key});

  @override
  State<ServiceInvoicesPage> createState() => _ServiceInvoicesPageState();
}

class _ServiceInvoicesPageState extends State<ServiceInvoicesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedStatus = "All";
  String _selectedPaymentStatus = "All";

  final List<ServiceInvoice> _invoices = [
    ServiceInvoice(
      id: 'INV-001',
      invoiceNumber: 'SRV-2025-01-87654321',
      leadId: 'SL-001',
      clientName: 'John Okafor',
      clientEmail: 'john.okafor@example.com',
      clientPhone: '+234 803 456 7890',
      clientAddress: 'Lagos, Nigeria',
      serviceType: 'Real Estate',
      propertyAddress: 'Land at Enugu - Independence Layout',
      items: [
        ServiceInvoiceItem(
          id: '1',
          description: 'Land Purchase - Enugu Independence Layout, 1500 sqm',
          quantity: 1,
          unitPrice: 25000000,
          unit: 'plot',
        ),
      ],
      subtotal: 25000000,
      taxRate: 7.5,
      taxAmount: 1875000,
      discount: 0,
      totalAmount: 26875000,
      issueDate: DateTime(2025, 1, 15),
      dueDate: DateTime(2025, 2, 14),
      status: ServiceInvoiceStatus.sent,
      paymentStatus: ServicePaymentStatus.unpaid,
      amountPaid: 0,
      balance: 26875000,
      createdBy: 'Admin',
      createdDate: DateTime(2025, 1, 15),
      termsAndConditions:
          'Payment is due within 30 days from the invoice date.',
    ),
    ServiceInvoice(
      id: 'INV-002',
      invoiceNumber: 'SRV-2025-01-87654322',
      leadId: 'SL-002',
      clientName: 'Ngozi Adeyemi',
      clientEmail: 'ngozi.adeyemi@example.com',
      clientPhone: '+234 801 234 5678',
      clientAddress: 'Lagos, Nigeria',
      serviceType: 'Land Survey',
      propertyAddress: 'Plot 23, Lekki Phase 1',
      items: [
        ServiceInvoiceItem(
          id: '1',
          description: 'Land Survey Service - Lekki Phase 1',
          quantity: 1,
          unitPrice: 500000,
        ),
      ],
      subtotal: 500000,
      taxRate: 7.5,
      taxAmount: 37500,
      discount: 0,
      totalAmount: 537500,
      issueDate: DateTime(2025, 1, 20),
      dueDate: DateTime(2025, 2, 19),
      status: ServiceInvoiceStatus.viewed,
      paymentStatus: ServicePaymentStatus.partiallyPaid,
      amountPaid: 250000,
      balance: 287500,
      payments: [
        ServicePayment(
          id: 'PAY-001',
          invoiceId: 'INV-002',
          amount: 250000,
          paymentDate: DateTime(2025, 1, 25),
          paymentMethod: 'Bank Transfer',
          status: 'Approved',
          transactionReference: 'TRF-2025-001',
        ),
      ],
      createdBy: 'Admin',
      createdDate: DateTime(2025, 1, 20),
    ),
    ServiceInvoice(
      id: 'INV-003',
      invoiceNumber: 'SRV-2025-01-87654323',
      leadId: 'SL-003',
      clientName: 'Michael Eze',
      clientEmail: 'michael.eze@example.com',
      clientPhone: '+234 802 789 1234',
      clientAddress: 'Ikeja, Lagos',
      serviceType: 'Property Management',
      propertyAddress: 'Ikeja - 3 Bedroom Apartment',
      items: [
        ServiceInvoiceItem(
          id: '1',
          description: 'Monthly Property Management Service',
          quantity: 3,
          unitPrice: 500000,
          unit: 'month',
        ),
      ],
      subtotal: 1500000,
      taxRate: 7.5,
      taxAmount: 112500,
      discount: 50000,
      totalAmount: 1562500,
      issueDate: DateTime(2025, 1, 10),
      dueDate: DateTime(2025, 2, 9),
      paidDate: DateTime(2025, 1, 28),
      status: ServiceInvoiceStatus.viewed,
      paymentStatus: ServicePaymentStatus.paid,
      amountPaid: 1562500,
      balance: 0,
      payments: [
        ServicePayment(
          id: 'PAY-002',
          invoiceId: 'INV-003',
          amount: 1562500,
          paymentDate: DateTime(2025, 1, 28),
          paymentMethod: 'Bank Transfer',
          status: 'Approved',
          transactionReference: 'TRF-2025-002',
        ),
      ],
      createdBy: 'Admin',
      createdDate: DateTime(2025, 1, 10),
    ),
  ];

  List<ServiceInvoice> get _filteredInvoices {
    return _invoices.where((invoice) {
      bool matchesSearch = invoice.clientName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          invoice.invoiceNumber
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      bool matchesStatus = _selectedStatus == "All" ||
          invoice.status.toDisplayString() == _selectedStatus;

      bool matchesPaymentStatus = _selectedPaymentStatus == "All" ||
          invoice.paymentStatus.toDisplayString() == _selectedPaymentStatus;

      return matchesSearch && matchesStatus && matchesPaymentStatus;
    }).toList();
  }

  String _formatCurrency(double amount) {
    return '₦${(amount / 1000000).toStringAsFixed(1)}M';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Service Invoices",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "View and manage invoices generated from service leads",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Search and Filters
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: "Search by client or invoice number...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButton<String>(
                  value: _selectedStatus,
                  isExpanded: true,
                  underline: const SizedBox(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  items: [
                    'All',
                    'Draft',
                    'Sent',
                    'Viewed',
                    'Overdue',
                    'Cancelled'
                  ].map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedStatus = value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButton<String>(
                  value: _selectedPaymentStatus,
                  isExpanded: true,
                  underline: const SizedBox(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  items: [
                    'All',
                    'Unpaid',
                    'Partially Paid',
                    'Paid',
                    'Refunded',
                    'Cancelled'
                  ].map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedPaymentStatus = value);
                    }
                  },
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Invoices List
        if (_filteredInvoices.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No invoices found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredInvoices.length,
            itemBuilder: (context, index) {
              final invoice = _filteredInvoices[index];
              final statusColor = invoice.status.getStatusColor();
              final paymentStatusColor =
                  invoice.paymentStatus.getStatusColor();

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  invoice.invoiceNumber,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  invoice.clientName,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  invoice.status.toDisplayString(),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: paymentStatusColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  invoice.paymentStatus.toDisplayString(),
                                  style: TextStyle(
                                    color: paymentStatusColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Service: ${invoice.serviceType}',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'Issue: ${_formatDate(invoice.issueDate)}',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Due: ${_formatDate(invoice.dueDate)}',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'Total: ${_formatCurrency(invoice.totalAmount)}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Progress Bar for Payment
                      if (invoice.totalAmount > 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Payment Progress',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '${((invoice.amountPaid / invoice.totalAmount) * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value:
                                    invoice.amountPaid / invoice.totalAmount,
                                minHeight: 6,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation(
                                  invoice.paymentStatus ==
                                          ServicePaymentStatus.paid
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Paid: ${_formatCurrency(invoice.amountPaid)} / Balance: ${_formatCurrency(invoice.balance)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          MyElevatedButton(
                            child: 'View Details',
                            bgColor: AppColors.blue,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    ViewInvoiceDialog(invoice: invoice),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
