import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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

  int _pageSize = 10;
  int _currentPage = 1;

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

  StatusTone _toneForInvoiceStatus(ServiceInvoiceStatus status) {
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
        return StatusTone.danger;
    }
  }

  StatusTone _toneForPaymentStatus(ServicePaymentStatus status) {
    switch (status) {
      case ServicePaymentStatus.unpaid:
        return StatusTone.warning;
      case ServicePaymentStatus.partiallyPaid:
        return StatusTone.info;
      case ServicePaymentStatus.paid:
        return StatusTone.success;
      case ServicePaymentStatus.refunded:
        return StatusTone.info;
      case ServicePaymentStatus.cancelled:
        return StatusTone.danger;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredInvoices;

    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex = (startIndex + _pageSize).clamp(0, filtered.length);
    final pageItems = filtered.isEmpty
        ? const <ServiceInvoice>[]
        : filtered.sublist(startIndex, endIndex);

    return PageScaffold(
      maxContentWidth: 1440,
      header: const PageHeader(
        title: 'Service Invoices',
        subtitle: 'View and manage invoices generated from service leads.',
      ),
      children: [
        _buildToolbar(),
        _buildTableCard(
          filtered: filtered,
          pageItems: pageItems,
          startIndex: startIndex,
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 720;
          final searchField = MyTextFormField(
            controller: _searchController,
            hintText: 'Search by client or invoice number',
            height: 48,
            leading: const Icon(Iconsax.search_normal,
                size: 18, color: AppColors.textMuted),
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
                _currentPage = 1;
              });
            },
          );

          final statusFilter = MyDropdown(
            hintText: _selectedStatus,
            initialSelection: _selectedStatus,
            items: const [
              'All',
              'Draft',
              'Sent',
              'Viewed',
              'Overdue',
              'Cancelled',
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedStatus = value;
                  _currentPage = 1;
                });
              }
            },
          );

          final paymentFilter = MyDropdown(
            hintText: _selectedPaymentStatus,
            initialSelection: _selectedPaymentStatus,
            items: const [
              'All',
              'Unpaid',
              'Partially Paid',
              'Paid',
              'Refunded',
              'Cancelled',
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedPaymentStatus = value;
                  _currentPage = 1;
                });
              }
            },
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: searchField),
                const SizedBox(width: 12),
                Expanded(child: statusFilter),
                const SizedBox(width: 12),
                Expanded(child: paymentFilter),
              ],
            );
          }
          return Column(
            children: [
              searchField,
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: statusFilter),
                  const SizedBox(width: 12),
                  Expanded(child: paymentFilter),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTableCard({
    required List<ServiceInvoice> filtered,
    required List<ServiceInvoice> pageItems,
    required int startIndex,
  }) {
    final isEmpty = filtered.isEmpty;

    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Invoice directory',
                          style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        '${filtered.length} invoice${filtered.length == 1 ? '' : 's'} matching your filters',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const StatusChip(
                  label: 'Billing',
                  tone: StatusTone.primary,
                  icon: Iconsax.receipt_2,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          if (isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: EmptyState.noResults(
                title: 'No invoices found',
                subtitle:
                    'Try adjusting your search terms or status filters to widen the results.',
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: pageItems
                    .asMap()
                    .entries
                    .map((e) => Padding(
                          padding: EdgeInsets.only(
                            bottom: e.key == pageItems.length - 1 ? 0 : 12,
                          ),
                          child: _buildInvoiceCard(e.value),
                        ))
                    .toList(),
              ),
            ),
          if (!isEmpty) ...[
            const Divider(height: 1, color: AppColors.borderSubtle),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: PaginatorFooter(
                totalItems: filtered.length,
                limit: _pageSize,
                currentPage: _currentPage,
                onPageChanged: (page) =>
                    setState(() => _currentPage = page),
                onLimitChanged: (newLimit) => setState(() {
                  _pageSize = newLimit;
                  _currentPage = 1;
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(ServiceInvoice invoice) {
    final progress = invoice.totalAmount > 0
        ? (invoice.amountPaid / invoice.totalAmount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brMd,
        border: Border.all(color: AppColors.borderSubtle),
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
                    Text(
                      invoice.invoiceNumber,
                      style: AppTextStyles.h4,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      invoice.clientName,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusChip(
                    label: invoice.status.toDisplayString(),
                    tone: _toneForInvoiceStatus(invoice.status),
                    dense: true,
                  ),
                  const SizedBox(height: 6),
                  StatusChip(
                    label: invoice.paymentStatus.toDisplayString(),
                    tone: _toneForPaymentStatus(invoice.paymentStatus),
                    dense: true,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: AppRadii.brSm,
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  left: 'Service: ${invoice.serviceType}',
                  right: 'Issued: ${_formatDate(invoice.issueDate)}',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  left: 'Due: ${_formatDate(invoice.dueDate)}',
                  right: 'Total: ${_formatCurrency(invoice.totalAmount)}',
                  rightColor: AppColors.success,
                  rightWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
          if (invoice.totalAmount > 0) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Payment progress',
                  style: AppTextStyles.bodySm,
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.neutral200,
                valueColor: AlwaysStoppedAnimation(
                  invoice.paymentStatus == ServicePaymentStatus.paid
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Paid ${_formatCurrency(invoice.amountPaid)} · Balance ${_formatCurrency(invoice.balance)}',
              style: AppTextStyles.bodySm,
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: MyOutlinedButton(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              icon: const Icon(Iconsax.eye,
                  size: 16, color: AppColors.primary),
              child: 'View Details',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => ViewInvoiceDialog(invoice: invoice),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String left,
    required String right,
    Color? rightColor,
    FontWeight? rightWeight,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            left,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            right,
            style: AppTextStyles.bodySm.copyWith(
              color: rightColor ?? AppColors.textSecondary,
              fontWeight: rightWeight,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
