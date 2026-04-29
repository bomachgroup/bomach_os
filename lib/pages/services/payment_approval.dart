import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/pages/services/controller/payment_approval_controller.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
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

  StatusTone _toneForPaymentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return StatusTone.success;
      case 'partially_paid':
        return StatusTone.warning;
      case 'overdue':
        return StatusTone.danger;
      case 'sent':
        return StatusTone.info;
      case 'draft':
      case 'cancelled':
        return StatusTone.neutral;
      case 'pending_approval':
        return StatusTone.warning;
      case 'approved':
        return StatusTone.success;
      case 'rejected':
      case 'flagged':
        return StatusTone.danger;
      case 'under_review':
        return StatusTone.info;
      default:
        return StatusTone.neutral;
    }
  }

  String _formatStatusLabel(String status) {
    if (status.isEmpty) return 'Unknown';
    return status[0].toUpperCase() +
        status.substring(1).replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Payment Approval',
        subtitle: 'Review and approve pending payment submissions.',
        trailing: MyOutlinedButton(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          icon: const Icon(Iconsax.refresh,
              size: 18, color: AppColors.primary),
          child: 'Refresh',
          onTap: () => controller.fetchPendingApprovals(),
        ),
      ),
      children: [
        Obx(() => _buildStatsCards()),
        _buildFilters(),
        Obx(() => _buildPaymentsCard()),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        final stats = [
          _StatData(
            label: 'Pending Approvals',
            value: pendingCount.toString(),
            icon: Iconsax.timer_1,
            tone: AppColors.primary,
          ),
          _StatData(
            label: 'Total Amount',
            value:
                '\u20A6${NumberFormat('#,###').format(pendingAmount)}',
            icon: Iconsax.money_recive,
            tone: AppColors.success,
          ),
          _StatData(
            label: "Today's Submissions",
            value: todayCount.toString(),
            icon: Iconsax.calendar_1,
            tone: AppColors.warning,
          ),
        ];

        if (isWide) {
          return Row(
            children: stats
                .map((s) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: s == stats.last ? 0 : 16),
                        child: _buildStatCard(s),
                      ),
                    ))
                .toList(),
          );
        }
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: stats
              .map((s) => SizedBox(
                    width: (constraints.maxWidth - 16) / 2,
                    child: _buildStatCard(s),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildStatCard(_StatData data) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: data.tone.withValues(alpha: 0.12),
              borderRadius: AppRadii.brSm,
            ),
            child: Icon(data.icon, color: data.tone, size: 20),
          ),
          const SizedBox(height: 14),
          Text(data.value, style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(
            data.label,
            style: AppTextStyles.bodySm,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 640;
          final searchField = MyTextFormField(
            hintText: 'Search by invoice or client',
            height: 48,
            leading: const Icon(Iconsax.search_normal,
                size: 18, color: AppColors.textMuted),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          );
          final statusFilter = MyDropdown(
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
            initialSelection: _selectedFilter,
            onChanged: (value) {
              setState(() {
                _selectedFilter = value ?? 'All';
              });
            },
          );
          if (isWide) {
            return Row(
              children: [
                Expanded(flex: 3, child: searchField),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: statusFilter),
              ],
            );
          }
          return Column(
            children: [
              searchField,
              const SizedBox(height: 12),
              statusFilter,
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaymentsCard() {
    final loading = controller.isLoading.value;
    final hasError = controller.errorMessage.value.isNotEmpty;
    final filteredInvoices = _filteredInvoices;

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
                      const Text('Approval queue', style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        loading
                            ? 'Loading pending approvals...'
                            : '${filteredInvoices.length} invoice${filteredInvoices.length == 1 ? '' : 's'} awaiting decision',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const StatusChip(
                  label: 'Approvals',
                  tone: StatusTone.warning,
                  icon: Iconsax.shield_tick,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          if (loading)
            Padding(
              padding: const EdgeInsets.all(20),
              child: LoadingSkeleton.listRows(count: 4),
            )
          else if (hasError)
            Padding(
              padding: const EdgeInsets.all(24),
              child: EmptyState(
                icon: Iconsax.danger,
                title: 'Could not load approvals',
                subtitle: controller.errorMessage.value,
                action: MyElevatedButton(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                  icon: const Icon(Iconsax.refresh,
                      size: 18, color: AppColors.textOnPrimary),
                  child: 'Retry',
                  onTap: () => controller.fetchPendingApprovals(),
                ),
              ),
            )
          else if (filteredInvoices.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: EmptyState(
                icon: Iconsax.tick_circle,
                title: 'No pending payments',
                subtitle: 'All payments have been processed.',
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredInvoices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, index) =>
                    _buildPaymentCard(filteredInvoices[index]),
              ),
            ),
        ],
      ),
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            invoiceNumber.toString(),
                            style: AppTextStyles.h4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        StatusChip(
                          label: _formatStatusLabel(status),
                          tone: _toneForPaymentStatus(status),
                          dense: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      clientName.toString(),
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (invoiceType.toString().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        invoiceType.toString(),
                        style: AppTextStyles.bodySm,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Total',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\u20A6${NumberFormat('#,###').format(totalAmount)}',
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Balance \u20A6${NumberFormat('#,###').format(balance)}',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.borderSubtle),
            const SizedBox(height: 12),
            const Text('Invoice Items', style: AppTextStyles.h4),
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
                        style: AppTextStyles.bodySm,
                      ),
                    ),
                    Text(
                      '$quantity × \u20A6${NumberFormat('#,###').format(unitPrice)}',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          if (approvals.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.borderSubtle),
            const SizedBox(height: 12),
            const Text('Approval Steps', style: AppTextStyles.h4),
            const SizedBox(height: 10),
            ...approvals.map(
              (approval) => _buildApprovalStep(approval, invoice),
            ),
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
    final isApproved = decision == 'approved';

    final tone = isPending
        ? StatusTone.warning
        : isApproved
            ? StatusTone.success
            : StatusTone.danger;
    final icon = isPending
        ? Iconsax.timer_1
        : isApproved
            ? Iconsax.tick_circle
            : Iconsax.close_circle;

    final backgroundColor = isPending
        ? AppColors.warningSubtle
        : AppColors.surfaceMuted;
    final borderColor = isPending
        ? AppColors.warningSubtle
        : AppColors.borderSubtle;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadii.brSm,
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isPending
                    ? AppColors.warning
                    : isApproved
                        ? AppColors.success
                        : AppColors.danger,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stepName,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (!isPending)
                StatusChip(
                  label: isApproved ? 'Approved' : 'Rejected',
                  tone: tone,
                  dense: true,
                ),
            ],
          ),
          if (decidedBy.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Decided by: $decidedBy',
              style: AppTextStyles.bodySm,
            ),
          ],
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Comment: $comment',
              style: AppTextStyles.bodySm,
            ),
          ],
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyOutlinedButton(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  borderColor: AppColors.danger,
                  textColor: AppColors.danger,
                  icon: const Icon(Iconsax.close_circle,
                      size: 16, color: AppColors.danger),
                  child: 'Reject',
                  onTap: () =>
                      _handleRejectPayment(invoiceId, step, invoice),
                ),
                const SizedBox(width: 10),
                MyElevatedButton(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  icon: const Icon(Iconsax.tick_circle,
                      size: 16, color: AppColors.textOnPrimary),
                  child: 'Approve',
                  onTap: () =>
                      _handleApprovePayment(invoiceId, step, invoice),
                ),
              ],
            ),
          ],
        ],
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
          const Text(
            'Are you sure you want to approve this payment?',
            style: AppTextStyles.bodyMd,
          ),
          const SizedBox(height: 16),
          Text(
            'Amount: \u20A6${NumberFormat('#,###').format(balance)}',
            style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text('Invoice: $invoiceNumber', style: AppTextStyles.bodySm),
          Text('Client: $clientName', style: AppTextStyles.bodySm),
        ],
      ),
      actions: [
        MyOutlinedButton(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: 'Cancel',
          onTap: () => Navigator.pop(context),
        ),
        MyElevatedButton(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          const Text(
            'Please provide a reason for rejection:',
            style: AppTextStyles.bodyMd,
          ),
          const SizedBox(height: 14),
          MyTextFormField(
            controller: reasonController,
            hintText: 'Enter rejection reason',
            title: 'Reason',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Amount: \u20A6${NumberFormat('#,###').format(balance)}',
            style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text('Invoice: $invoiceNumber', style: AppTextStyles.bodySm),
        ],
      ),
      actions: [
        MyOutlinedButton(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: 'Cancel',
          onTap: () => Navigator.pop(context),
        ),
        MyElevatedButton(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          bgColor: AppColors.danger,
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
        ),
      ],
    );
  }
}

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color tone;
  const _StatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.tone,
  });
}
