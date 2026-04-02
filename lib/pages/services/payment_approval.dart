import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/services/controller/payment_approval_controller.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PaymentApprovalPage extends StatefulWidget {
  const PaymentApprovalPage({super.key});

  @override
  State<PaymentApprovalPage> createState() => _PaymentApprovalPageState();
}

class _PaymentApprovalPageState extends State<PaymentApprovalPage> {
  final controller = Get.put(PaymentApprovalController());
  String _selectedFilter = 'All';
  String _searchQuery = '';

  List<Map<String, dynamic>> get _filteredInvoices {
    var invoices = controller.pendingInvoices.toList();

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      invoices = invoices.where((invoice) {
        final invoiceNumber =
            (invoice['invoice_number'] ?? '').toString().toLowerCase();
        final clientName =
            (invoice['client_name'] ?? '').toString().toLowerCase();
        return invoiceNumber.contains(query) || clientName.contains(query);
      }).toList();
    }

    if (_selectedFilter != 'All') {
      final filterValue = _selectedFilter.toLowerCase().replaceAll(' ', '_');
      invoices = invoices.where((invoice) {
        final status = (invoice['status'] ?? '').toString().toLowerCase();
        return status == filterValue;
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
        Obx(() => _buildStatsCards()),
        const SizedBox(height: 24),
        _buildFilters(),
        const SizedBox(height: 24),
        Obx(() => _buildPaymentsList()),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
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
          ),
        ),
        IconButton(
          onPressed: () => controller.fetchPendingApprovals(),
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    final invoices = controller.pendingInvoices;
    final pendingCount = invoices.length;

    final pendingAmount = invoices.fold<double>(
      0,
      (sum, invoice) => sum + ((invoice['balance'] ?? 0) as num).toDouble(),
    );

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayCount = invoices.where((invoice) {
      final issueDate = (invoice['issue_date'] ?? '').toString();
      return issueDate.startsWith(today);
    }).length;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard(
          'Pending Approvals',
          pendingCount.toString(),
          Icons.pending_actions,
          AppColors.blue,
        ),
        _buildStatCard(
          'Total Amount',
          '\u20A6${NumberFormat('#,###').format(pendingAmount)}',
          Icons.attach_money,
          Colors.green,
        ),
        _buildStatCard(
          'Today\'s Submissions',
          todayCount.toString(),
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
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              SizedBox(
                width: 200,
                child: MyDropdown(
                  items: const [
                    'All',
                    'Draft',
                    'Sent',
                    'Partially Paid',
                    'Paid',
                    'Overdue',
                    'Cancelled',
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
    if (controller.isLoading.value) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (controller.errorMessage.value.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage.value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.red.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            MyElevatedButton(
              child: 'Retry',
              onTap: () => controller.fetchPendingApprovals(),
            ),
          ],
        ),
      );
    }

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

  Widget _buildPaymentCard(Map<String, dynamic> invoice) {
    final invoiceNumber = invoice['invoice_number'] ?? '';
    final clientName = invoice['client_name'] ?? '';
    final invoiceType = invoice['invoice_type'] ?? '';
    final totalAmount = ((invoice['total_amount'] ?? 0) as num).toDouble();
    final balance = ((invoice['balance'] ?? 0) as num).toDouble();
    final status = (invoice['status'] ?? '').toString();
    final items = (invoice['items'] as List?) ?? [];
    final approvals = (invoice['approvals'] as List?) ?? [];

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
                          invoiceNumber,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildStatusBadge(status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      clientName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (invoiceType.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        invoiceType,
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
                    'Total: \u20A6${NumberFormat('#,###').format(totalAmount)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Balance: \u20A6${NumberFormat('#,###').format(balance)}',
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

          // Items section
          if (items.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Invoice Items',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...items.map((item) {
              final description =
                  (item['description'] ?? item['name'] ?? '').toString();
              final quantity = item['quantity'] ?? 1;
              final unitPrice = ((item['unit_price'] ?? 0) as num).toDouble();
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Text(
                      '$quantity x \u20A6${NumberFormat('#,###').format(unitPrice)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          // Approvals section
          if (approvals.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Approval Steps',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...approvals.map((approval) => _buildApprovalStep(
                  approval,
                  invoice,
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildApprovalStep(dynamic approval, Map<String, dynamic> invoice) {
    final step = approval['step'] ?? 0;
    final stepName = (approval['step_name'] ?? 'Step $step').toString();
    final decision = (approval['decision'] ?? '').toString();
    final decidedBy = (approval['decided_by_name'] ?? '').toString();
    final comment = (approval['comment'] ?? '').toString();
    final invoiceId = invoice['id'];
    final isPending = decision.isEmpty || decision == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPending ? Colors.orange.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPending ? Colors.orange.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPending
                    ? Icons.pending_actions
                    : decision == 'approved'
                        ? Icons.check_circle
                        : Icons.cancel,
                size: 18,
                color: isPending
                    ? Colors.orange
                    : decision == 'approved'
                        ? Colors.green
                        : Colors.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stepName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (!isPending) _buildDecisionBadge(decision),
            ],
          ),
          if (decidedBy.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Decided by: $decidedBy',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Comment: $comment',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyOutlinedButton(
                  textColor: Colors.red,
                  borderColor: Colors.red,
                  child: 'Reject',
                  onTap: () => _handleRejectPayment(invoiceId, step, invoice),
                ),
                const SizedBox(width: 12),
                MyElevatedButton(
                  icon: const Icon(Icons.check, color: Colors.white, size: 18),
                  child: 'Approve',
                  onTap: () => _handleApprovePayment(invoiceId, step, invoice),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDecisionBadge(String decision) {
    final isApproved = decision == 'approved';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isApproved ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isApproved ? 'Approved' : 'Rejected',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isApproved ? Colors.green.shade800 : Colors.red.shade800,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'paid':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        label = 'Paid';
        break;
      case 'partially_paid':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        label = 'Partially Paid';
        break;
      case 'overdue':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        label = 'Overdue';
        break;
      case 'sent':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        label = 'Sent';
        break;
      case 'draft':
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        label = 'Draft';
        break;
      case 'cancelled':
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        label = 'Cancelled';
        break;
      default:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        label = status.isNotEmpty
            ? status[0].toUpperCase() + status.substring(1).replaceAll('_', ' ')
            : 'Unknown';
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

  void _handleApprovePayment(
      dynamic invoiceId, dynamic step, Map<String, dynamic> invoice) {
    final invoiceNumber = invoice['invoice_number'] ?? '';
    final clientName = invoice['client_name'] ?? '';
    final balance = ((invoice['balance'] ?? 0) as num).toDouble();

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
              'Amount: \u20A6${NumberFormat('#,###').format(balance)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text('Invoice: $invoiceNumber'),
            Text('Client: $clientName'),
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
              Navigator.pop(context);
              controller.approveInvoice(
                invoiceId is int ? invoiceId : int.parse(invoiceId.toString()),
                step is int ? step : int.parse(step.toString()),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleRejectPayment(
      dynamic invoiceId, dynamic step, Map<String, dynamic> invoice) {
    final reasonController = TextEditingController();
    final invoiceNumber = invoice['invoice_number'] ?? '';
    final balance = ((invoice['balance'] ?? 0) as num).toDouble();

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
              'Amount: \u20A6${NumberFormat('#,###').format(balance)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text('Invoice: $invoiceNumber'),
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
              Navigator.pop(context);
              controller.rejectInvoice(
                invoiceId is int ? invoiceId : int.parse(invoiceId.toString()),
                step is int ? step : int.parse(step.toString()),
                reason: reasonController.text,
              );
            },
          ),
        ],
      ),
    );
  }
}
