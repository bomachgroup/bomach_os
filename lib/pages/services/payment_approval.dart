import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/app_text.dart';
import 'package:bms_front_end/pages/services/controller/payment_approval_controller.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
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
              AppText.displayLg('Payment Approval'),
              SizedBox(height: 4),
              AppText.bodyLg(
                'Review and approve pending payment submissions',
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => controller.fetchPendingApprovals(),
          icon: const Icon(Iconsax.refresh),
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
          Iconsax.timer_1,
          AppColors.primary,
        ),
        _buildStatCard(
          'Total Amount',
          '\u20A6${NumberFormat('#,###').format(pendingAmount)}',
          Iconsax.money_recive,
          AppColors.success,
        ),
        _buildStatCard(
          'Today\'s Submissions',
          todayCount.toString(),
          Iconsax.calendar_1,
          AppColors.warning,
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
        border: Border.all(color: AppColors.neutral300),
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
          AppText.h2(value),
          const SizedBox(height: 4),
          AppText.bodySm(
            label,
            color: AppColors.textSecondary,
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
                    Iconsax.search_normal,
                    color: AppColors.neutral500.withValues(alpha: 0.5),
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
            Icon(Iconsax.danger, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            AppText.bodyMd(
              controller.errorMessage.value,
              color: AppColors.error,
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
              Iconsax.tick_circle,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            AppText.h3(
              'No pending payments',
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            AppText.bodyMd(
              'All payments have been processed',
              color: AppColors.textTertiary,
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
                        AppText.h4(invoiceNumber),
                        const SizedBox(width: 12),
                        _buildStatusBadge(status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppText.bodyMd(
                      clientName,
                      fontWeight: FontWeight.w500,
                    ),
                    if (invoiceType.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      AppText.bodySm(
                        invoiceType,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppText.bodyMd(
                    'Total: \u20A6${NumberFormat('#,###').format(totalAmount)}',
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 4),
                  AppText.bodySm(
                    'Balance: \u20A6${NumberFormat('#,###').format(balance)}',
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
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
            AppText.h4('Invoice Items'),
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
                      child: AppText.bodySm(
                        description,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    AppText.bodySm(
                      '$quantity x \u20A6${NumberFormat('#,###').format(unitPrice)}',
                      color: AppColors.textTertiary,
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
            AppText.h4('Approval Steps'),
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
                    ? Iconsax.timer_1
                    : decision == 'approved'
                        ? Iconsax.tick_circle
                        : Iconsax.close_circle,
                size: 18,
                color: isPending
                    ? Colors.orange
                    : decision == 'approved'
                        ? Colors.green
                        : Colors.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppText.bodyMd(
                  stepName,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!isPending) _buildDecisionBadge(decision),
            ],
          ),
          if (decidedBy.isNotEmpty) ...[
            const SizedBox(height: 4),
            AppText.bodySm(
              'Decided by: $decidedBy',
              color: AppColors.textSecondary,
            ),
          ],
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 4),
            AppText.bodySm(
              'Comment: $comment',
              color: AppColors.textSecondary,
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
                  icon: const Icon(Iconsax.tick_circle, color: Colors.white, size: 18),
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
      child: AppText.label(
        isApproved ? 'Approved' : 'Rejected',
        color: isApproved ? AppColors.success : AppColors.error,
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'paid':
        backgroundColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        label = 'Paid';
        break;
      case 'partially_paid':
        backgroundColor = AppColors.warning.withValues(alpha: 0.1);
        textColor = AppColors.warning;
        label = 'Partially Paid';
        break;
      case 'overdue':
        backgroundColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        label = 'Overdue';
        break;
      case 'sent':
        backgroundColor = AppColors.info.withValues(alpha: 0.1);
        textColor = AppColors.info;
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
      child: AppText.label(
        label,
        color: textColor,
      ),
    );
  }

  void _handleApprovePayment(
      dynamic invoiceId, dynamic step, Map<String, dynamic> invoice) {
    final invoiceNumber = invoice['invoice_number'] ?? '';
    final clientName = invoice['client_name'] ?? '';
    final balance = ((invoice['balance'] ?? 0) as num).toDouble();

    DialogScaffold.show(
      context,
      title: 'Approve Payment',
      size: DialogSize.sm,
      body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.bodyMd('Are you sure you want to approve this payment?'),
            const SizedBox(height: 16),
            AppText.bodyMd(
              'Amount: \u20A6${NumberFormat('#,###').format(balance)}',
              fontWeight: FontWeight.w600,
            ),
            AppText.bodySm('Invoice: $invoiceNumber'),
            AppText.bodySm('Client: $clientName'),
          ],
        ),
      actions: [MyOutlinedButton(
            textColor: AppColors.neutral500,
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
          ),],
    );
  }

  void _handleRejectPayment(
      dynamic invoiceId, dynamic step, Map<String, dynamic> invoice) {
    final reasonController = TextEditingController();
    final invoiceNumber = invoice['invoice_number'] ?? '';
    final balance = ((invoice['balance'] ?? 0) as num).toDouble();

    DialogScaffold.show(
      context,
      title: 'Reject Payment',
      size: DialogSize.sm,
      body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.bodyMd('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            MyTextFormField(
              controller: reasonController,
              hintText: 'Enter rejection reason',
              title: 'Reason',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            AppText.bodyMd(
              'Amount: \u20A6${NumberFormat('#,###').format(balance)}',
              fontWeight: FontWeight.w600,
            ),
            AppText.bodySm('Invoice: $invoiceNumber'),
          ],
        ),
      actions: [MyOutlinedButton(
            textColor: AppColors.neutral500,
            borderColor: null,
            child: 'Cancel',
            onTap: () => Navigator.pop(context),
          ),
          MyElevatedButton(
            bgColor: Colors.red,
            child: 'Reject',
            onTap: () {
              if (reasonController.text.isEmpty) {
                AppToast.error(context, 'Please provide a reason for rejection');
                return;
              }
              Navigator.pop(context);
              controller.rejectInvoice(
                invoiceId is int ? invoiceId : int.parse(invoiceId.toString()),
                step is int ? step : int.parse(step.toString()),
                reason: reasonController.text,
              );
            },
          ),],
    );
  }
}
