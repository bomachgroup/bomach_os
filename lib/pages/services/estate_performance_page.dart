import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/pages/services/models/estate_models.dart';
import 'package:bms_front_end/pages/services/models/performance_invoice_model.dart';
import 'package:bms_front_end/pages/services/widget/add_performance_invoice_dialog.dart';
import 'package:bms_front_end/pages/services/widget/view_performance_invoice_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class EstatePerformancePage extends StatefulWidget {
  final Estate? estate;

  const EstatePerformancePage({
    super.key,
    this.estate,
  });

  @override
  State<EstatePerformancePage> createState() => _EstatePerformancePageState();
}

class _EstatePerformancePageState extends State<EstatePerformancePage> {
  String _selectedPeriod = 'This Month';
  String _selectedEstate = 'All Estates';
  String _selectedServiceType = 'All Services';
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;

  // Sample performance invoices data
  final List<PerformanceInvoice> _allInvoices = [];

  @override
  void initState() {
    super.initState();
    _initializeSampleData();
    _applyDateFilter();
  }

  void _initializeSampleData() {
    final now = DateTime.now();

    // Generate sample invoices for the last 6 months
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i * 5));
      final estates = [
        'Aso Villa Estate',
        'Fortress City Estate',
        'Victoria Gardens',
        'Diamond Heights'
      ];
      final estateName = estates[i % estates.length];
      final serviceTypes = [
        'Real Estate',
        'Land Survey',
        'Property Management',
        'Estate Management'
      ];
      final serviceType = serviceTypes[i % serviceTypes.length];
      final types = ['Sale', 'Reservation', 'Payment', 'Commission'];
      final type = types[i % types.length];
      final statuses = ['Paid', 'Pending', 'Partial'];
      final status = statuses[i % statuses.length];

      final amount = 5000000.0 + (i * 100000.0);
      final amountPaid = status == 'Paid'
          ? amount
          : (status == 'Partial' ? amount * 0.6 : 0.0);

      _allInvoices.add(
        PerformanceInvoice(
          id: 'INV-${(1000 + i).toString()}',
          estateId: (i % estates.length + 1).toString(),
          estateName: estateName,
          plotId: 'plot-$i',
          plotNumber: 'Plot ${(i + 1).toString().padLeft(3, '0')}',
          serviceType: serviceType,
          transactionType: type,
          amount: amount,
          transactionDate: date,
          clientName: 'Client ${i + 1}',
          clientPhone: '+234 80${i.toString().padLeft(8, '0')}',
          clientEmail: 'client$i@example.com',
          paymentMethod: ['Cash', 'Bank Transfer', 'Card'][i % 3],
          paymentStatus: status,
          amountPaid: amountPaid,
          balance: amount - amountPaid,
          invoiceNumber: 'INV-${now.year}-${(1000 + i).toString()}',
          description: 'Plot sale transaction for $estateName',
          agentName: 'Agent ${(i % 5) + 1}',
          commissionAmount: type == 'Commission' ? (amount * 0.05) : null,
          commissionPercentage: type == 'Commission' ? 5.0 : null,
          createdDate: date,
        ),
      );
    }
  }

  void _applyDateFilter() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Today':
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = now;
        break;
      case 'This Week':
        _startDate = now.subtract(Duration(days: now.weekday - 1));
        _endDate = now;
        break;
      case 'This Month':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
        break;
      case 'Last 3 Months':
        _startDate = DateTime(now.year, now.month - 3, now.day);
        _endDate = now;
        break;
      case 'Last 6 Months':
        _startDate = DateTime(now.year, now.month - 6, now.day);
        _endDate = now;
        break;
      case 'This Year':
        _startDate = DateTime(now.year, 1, 1);
        _endDate = now;
        break;
      case 'All Time':
        _startDate = null;
        _endDate = null;
        break;
    }
  }

  List<PerformanceInvoice> get _filteredInvoices {
    var filtered = _allInvoices;

    // Apply service type filter
    if (_selectedServiceType != 'All Services') {
      filtered = filtered
          .where((inv) => inv.serviceType == _selectedServiceType)
          .toList();
    }

    // Apply estate filter
    if (_selectedEstate != 'All Estates' && widget.estate == null) {
      filtered =
          filtered.where((inv) => inv.estateName == _selectedEstate).toList();
    }

    // Apply estate-specific filter from widget
    if (widget.estate != null) {
      filtered = filtered
          .where((inv) => inv.estateId == widget.estate!.id.toString())
          .toList();
    }

    // Apply date filter
    if (_startDate != null) {
      filtered = filtered.where((inv) {
        final isAfterStart = _startDate != null
            ? inv.transactionDate.isAfter(_startDate!)
            : true;
        final isBeforeEnd = _endDate != null
            ? inv.transactionDate
                .isBefore(_endDate!.add(const Duration(days: 1)))
            : true;
        return isAfterStart && isBeforeEnd;
      }).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((inv) {
        final matchesInvoice = inv.invoiceNumber
                ?.toLowerCase()
                .contains(_searchQuery.toLowerCase()) ??
            false;
        final matchesClient = inv.clientName
                ?.toLowerCase()
                .contains(_searchQuery.toLowerCase()) ??
            false;
        final matchesPlot = inv.plotNumber
                ?.toLowerCase()
                .contains(_searchQuery.toLowerCase()) ??
            false;
        return matchesInvoice || matchesClient || matchesPlot;
      }).toList();
    }

    return filtered;
  }

  PerformanceStats get _stats =>
      PerformanceStats.fromInvoices(_filteredInvoices);

  void _addInvoice(PerformanceInvoice invoice) {
    setState(() {
      _allInvoices.add(invoice);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: widget.estate != null
            ? '${widget.estate!.name} Performance'
            : 'Estate Performance & Invoices',
        subtitle:
            'Track revenue, transactions, and payments across your estates.',
        leading: widget.estate != null
            ? Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: AppRadii.brMd,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadii.brMd,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Icon(Iconsax.arrow_left_2,
                        size: 18, color: AppColors.textSecondary),
                  ),
                ),
              )
            : null,
        trailing: MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'Add Invoice',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return AddPerformanceInvoiceDialog(
                  estate: widget.estate,
                  onInvoiceAdded: _addInvoice,
                );
              },
            );
          },
        ),
      ),
      children: [
        _buildFilters(),
        _buildStatsCards(),
        _buildChartsSection(),
        _buildInvoicesTable(),
      ],
    );
  }

  Widget _buildFilters() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
            width: 200,
            child: MyDropdown(
              hintText: 'Period',
              items: const [
                'Today',
                'This Week',
                'This Month',
                'Last 3 Months',
                'Last 6 Months',
                'This Year',
                'All Time',
              ],
              initialSelection: _selectedPeriod,
              onChanged: (value) {
                setState(() {
                  _selectedPeriod = value ?? 'This Month';
                  _applyDateFilter();
                });
              },
            ),
          ),
          SizedBox(
            width: 220,
            child: MyDropdown(
              hintText: 'Service type',
              items: const [
                'All Services',
                'Real Estate',
                'Land Survey',
                'Property Management',
                'Estate Management',
              ],
              initialSelection: _selectedServiceType,
              onChanged: (value) {
                setState(() {
                  _selectedServiceType = value ?? 'All Services';
                });
              },
            ),
          ),
          if (widget.estate == null)
            SizedBox(
              width: 220,
              child: MyDropdown(
                hintText: 'Estate',
                items: const [
                  'All Estates',
                  'Aso Villa Estate',
                  'Fortress City Estate',
                  'Victoria Gardens',
                  'Diamond Heights',
                ],
                initialSelection: _selectedEstate,
                onChanged: (value) {
                  setState(() {
                    _selectedEstate = value ?? 'All Estates';
                  });
                },
              ),
            ),
          SizedBox(
            width: 260,
            child: MyTextFormField(
              hintText: 'Search invoices, clients, plots...',
              height: 50,
              leading: const Icon(Iconsax.search_normal,
                  size: 18, color: AppColors.textMuted),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      int perRow;
      if (width >= 1100) {
        perRow = 3;
      } else if (width >= 720) {
        perRow = 2;
      } else {
        perRow = 1;
      }
      const spacing = 16.0;
      final cardWidth =
          (width - ((perRow - 1) * spacing)) / perRow;

      final items = <Widget>[
        _buildStatCard(
          'Total Revenue',
          '₦${_formatAmount(_stats.totalRevenue)}',
          Iconsax.money_recive,
          StatusTone.primary,
          subtitle: '${_stats.totalTransactions} transactions',
        ),
        _buildStatCard(
          'Paid',
          '₦${_formatAmount(_stats.totalPaid)}',
          Iconsax.tick_circle,
          StatusTone.success,
          subtitle: 'Completed payments',
        ),
        _buildStatCard(
          'Pending',
          '₦${_formatAmount(_stats.totalPending)}',
          Iconsax.clock,
          StatusTone.warning,
          subtitle: 'Awaiting payment',
        ),
        _buildStatCard(
          'Sales',
          '${_stats.totalSales}',
          Iconsax.home,
          StatusTone.info,
          subtitle: 'Total plot sales',
        ),
        _buildStatCard(
          'Avg. Transaction',
          '₦${_formatAmount(_stats.averageTransactionValue)}',
          Iconsax.trend_up,
          StatusTone.primary,
          subtitle: 'Per transaction',
        ),
        _buildStatCard(
          'Commissions',
          '₦${_formatAmount(_stats.totalCommissions)}',
          Iconsax.card,
          StatusTone.info,
          subtitle: 'Total earned',
        ),
      ];

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: items
            .map((e) => SizedBox(width: cardWidth, child: e))
            .toList(),
      );
    });
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    StatusTone tone, {
    String? subtitle,
  }) {
    final palette = _tonePalette(tone);
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: palette.$1,
                  borderRadius: AppRadii.brMd,
                ),
                child: Icon(icon, color: palette.$2, size: 20),
              ),
              const Spacer(),
              const Icon(Iconsax.more, size: 18, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTextStyles.h2,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }

  (Color, Color) _tonePalette(StatusTone tone) {
    switch (tone) {
      case StatusTone.success:
        return (AppColors.successSubtle, AppColors.success);
      case StatusTone.warning:
        return (AppColors.warningSubtle, AppColors.warning);
      case StatusTone.danger:
        return (AppColors.dangerSubtle, AppColors.danger);
      case StatusTone.info:
        return (AppColors.infoSubtle, AppColors.info);
      case StatusTone.primary:
        return (AppColors.primarySubtle, AppColors.primary);
      case StatusTone.neutral:
        return (AppColors.surfaceMuted, AppColors.textSecondary);
    }
  }

  Widget _buildChartsSection() {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 900;
      const spacing = 16.0;
      final revenueWidth = widget.estate == null
          ? (isWide
              ? (constraints.maxWidth - spacing) * 0.55
              : double.infinity)
          : double.infinity;
      final typeWidth = widget.estate == null
          ? (isWide
              ? (constraints.maxWidth - spacing) * 0.45 - 4
              : double.infinity)
          : double.infinity;

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          if (widget.estate == null)
            SizedBox(
              width: revenueWidth,
              child: _buildRevenueByEstateCard(),
            ),
          SizedBox(
            width: widget.estate == null ? typeWidth : double.infinity,
            child: _buildTransactionsByTypeCard(),
          ),
        ],
      );
    });
  }

  Widget _buildRevenueByEstateCard() {
    final entries = _stats.revenueByEstate.entries.toList();

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text('Revenue by Estate', style: AppTextStyles.h3),
              ),
              StatusChip(
                label: 'Top performers',
                tone: StatusTone.primary,
                icon: Iconsax.trend_up,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: EmptyState(
                compact: true,
                icon: Iconsax.chart,
                title: 'No revenue yet',
                subtitle: 'Data will appear once invoices are recorded.',
              ),
            )
          else
            ...entries.map((entry) {
              final percentage = _stats.totalRevenue > 0
                  ? (entry.value / _stats.totalRevenue * 100)
                  : 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: AppTextStyles.bodyMd.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '₦${_formatAmount(entry.value)}',
                          style: AppTextStyles.bodyMd.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (percentage / 100).clamp(0, 1).toDouble(),
                        backgroundColor: AppColors.surfaceMuted,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTransactionsByTypeCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Transactions by Type', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          if (_stats.transactionsByType.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: EmptyState(
                compact: true,
                icon: Iconsax.chart_2,
                title: 'No transactions yet',
                subtitle: 'Transactions will appear here once recorded.',
              ),
            )
          else
            ..._stats.transactionsByType.entries.map((entry) {
              final tones = {
                'Sale': StatusTone.success,
                'Reservation': StatusTone.warning,
                'Payment': StatusTone.info,
                'Commission': StatusTone.primary,
              };
              final tone = tones[entry.key] ?? StatusTone.neutral;
              final palette = _tonePalette(tone);

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: palette.$2,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${entry.value}',
                      style: AppTextStyles.h4,
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildInvoicesTable() {
    if (_filteredInvoices.isEmpty) {
      return const AppCard(
        padding: EdgeInsets.all(12),
        child: EmptyState(
          icon: Iconsax.receipt_2,
          title: 'No invoices found',
          subtitle:
              'Try a different period or clear filters to see more results.',
        ),
      );
    }

    final pageLimit = _filteredInvoices.length > 10
        ? 10
        : _filteredInvoices.length;

    return AppCard(
      padding: EdgeInsets.zero,
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
                      const Text('Recent Invoices', style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        '${_filteredInvoices.length} total',
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                StatusChip(
                  label: '$pageLimit showing',
                  tone: StatusTone.neutral,
                  dense: true,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pageLimit,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: AppColors.borderSubtle),
            itemBuilder: (context, index) {
              final invoice = _filteredInvoices[index];
              return _buildInvoiceRow(invoice);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(PerformanceInvoice invoice) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => ViewPerformanceInvoiceDialog(invoice: invoice),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Invoice Info
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.invoiceNumber ?? 'N/A',
                    style: AppTextStyles.bodyMd
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    invoice.clientName ?? 'Unknown Client',
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Estate & Plot
            if (!isSmallScreen(context))
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.estateName,
                      style: AppTextStyles.bodySm.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      invoice.plotNumber ?? 'N/A',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),

            // Transaction Type
            if (isLargeScreen(context))
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: StatusChip(
                    label: invoice.transactionType,
                    tone: StatusTone.primary,
                    dense: true,
                  ),
                ),
              ),

            // Amount
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₦${_formatAmount(invoice.amount)}',
                    style: AppTextStyles.bodyMd
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (invoice.balance != null && invoice.balance! > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Bal: ₦${_formatAmount(invoice.balance!)}',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.warning),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Status
            StatusChip(
              label: invoice.paymentStatus,
              tone: _invoiceTone(invoice.paymentStatus),
              dense: true,
            ),

            const SizedBox(width: 8),

            // View Invoice Button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        ViewPerformanceInvoiceDialog(invoice: invoice),
                  );
                },
                borderRadius: AppRadii.brSm,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadii.brSm,
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: const Icon(Iconsax.receipt_2,
                      size: 16, color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  StatusTone _invoiceTone(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'approved':
        return StatusTone.success;
      case 'pending':
      case 'overdue':
        return status.toLowerCase() == 'overdue'
            ? StatusTone.danger
            : StatusTone.warning;
      case 'partial':
        return StatusTone.info;
      case 'draft':
        return StatusTone.neutral;
      case 'cancelled':
      case 'rejected':
      case 'failed':
        return StatusTone.danger;
      default:
        return StatusTone.neutral;
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}
