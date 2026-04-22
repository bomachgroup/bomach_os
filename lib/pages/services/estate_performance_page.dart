import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/services/models/estate_models.dart';
import 'package:bms_front_end/pages/services/models/performance_invoice_model.dart';
import 'package:bms_front_end/pages/services/widget/add_performance_invoice_dialog.dart';
import 'package:bms_front_end/pages/services/widget/view_performance_invoice_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            if (widget.estate != null)
              IconButton(
                icon: const Icon(Iconsax.arrow_left_2),
                onPressed: () => Navigator.pop(context),
              ),
            Expanded(
              child: MyText(
                widget.estate != null
                    ? '${widget.estate!.name} - Performance'
                    : 'Estate Performance & Invoices',
                style: AppText.displayLg,
              ),
            ),
          ],
        ),
        kSizedBox,

        // Filters and Actions
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 15,
                runSpacing: 15,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    children: [
                      // Period Filter
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.neutral300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedPeriod,
                          underline: const SizedBox(),
                          items: [
                            'Today',
                            'This Week',
                            'This Month',
                            'Last 3 Months',
                            'Last 6 Months',
                            'This Year',
                            'All Time'
                          ].map((period) {
                            return DropdownMenuItem(
                              value: period,
                              child: MyText(period),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPeriod = value ?? 'This Month';
                              _applyDateFilter();
                            });
                          },
                        ),
                      ),

                      // Service Type Filter
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.neutral300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedServiceType,
                          underline: const SizedBox(),
                          items: [
                            'All Services',
                            'Real Estate',
                            'Land Survey',
                            'Property Management',
                            'Estate Management'
                          ].map((service) {
                            return DropdownMenuItem(
                              value: service,
                              child: MyText(service),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedServiceType = value ?? 'All Services';
                            });
                          },
                        ),
                      ),

                      // Estate Filter (if not viewing specific estate)
                      if (widget.estate == null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.neutral300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedEstate,
                            underline: const SizedBox(),
                            items: [
                              'All Estates',
                              'Aso Villa Estate',
                              'Fortress City Estate',
                              'Victoria Gardens',
                              'Diamond Heights'
                            ].map((estate) {
                              return DropdownMenuItem(
                                value: estate,
                                child: MyText(estate),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedEstate = value ?? 'All Estates';
                              });
                            },
                          ),
                        ),

                      // Search
                      SizedBox(
                        width: 200,
                        child: MyTextFormField(
                          hintText: 'Search invoices...',
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
                    ],
                  ),

                  // Add Invoice Button
                  MyElevatedButton(
                    icon: const Icon(
                      Iconsax.add_circle,
                      color: AppColors.white,
                    ),
                    child: "Add Invoice",
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
                ],
              ),
            ),
          ],
        ),
        kSizedBox,

        // Statistics Cards
        _buildStatsCards(),
        kSizedBox,

        // Charts Section
        _buildChartsSection(),
        kSizedBox,

        // Recent Invoices Table
        _buildInvoicesTable(),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard(
          'Total Revenue',
          '₦${_formatAmount(_stats.totalRevenue)}',
          Iconsax.money_recive,
          AppColors.primary,
          subtitle: '${_stats.totalTransactions} transactions',
        ),
        _buildStatCard(
          'Paid',
          '₦${_formatAmount(_stats.totalPaid)}',
          Iconsax.tick_circle,
          Colors.green,
          subtitle: 'Completed payments',
        ),
        _buildStatCard(
          'Pending',
          '₦${_formatAmount(_stats.totalPending)}',
          Iconsax.clock,
          Colors.orange,
          subtitle: 'Awaiting payment',
        ),
        _buildStatCard(
          'Sales',
          '${_stats.totalSales}',
          Iconsax.home,
          Colors.purple,
          subtitle: 'Total plot sales',
        ),
        _buildStatCard(
          'Avg. Transaction',
          '₦${_formatAmount(_stats.averageTransactionValue)}',
          Iconsax.trend_up,
          Colors.teal,
          subtitle: 'Per transaction',
        ),
        _buildStatCard(
          'Commissions',
          '₦${_formatAmount(_stats.totalCommissions)}',
          Iconsax.card,
          Colors.indigo,
          subtitle: 'Total earned',
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 200),
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
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.1),
                radius: 20,
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              const Icon(Iconsax.more, size: 20, color: AppColors.neutral500),
            ],
          ),
          kSizedBox,
          MyText(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          MyText(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.neutral500,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            MyText(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.neutral500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        // Revenue by Estate
        if (widget.estate == null)
          Container(
            width: isLargeScreen(context) ? 500 : double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.neutral300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MyText(
                  'Revenue by Estate',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                kSizedBox,
                ..._stats.revenueByEstate.entries.map((entry) {
                  final percentage = _stats.totalRevenue > 0
                      ? (entry.value / _stats.totalRevenue * 100)
                      : 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: MyText(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            MyText(
                              '₦${_formatAmount(entry.value)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: AppColors.neutral300,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 4),
                        MyText(
                          '${percentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

        // Transactions by Type
        Container(
          width: isLargeScreen(context) ? 400 : double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.neutral300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MyText(
                'Transactions by Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              kSizedBox,
              ..._stats.transactionsByType.entries.map((entry) {
                final colors = {
                  'Sale': Colors.green,
                  'Reservation': Colors.orange,
                  'Payment': Colors.blue,
                  'Commission': Colors.purple,
                };
                final color = colors[entry.key] ?? AppColors.neutral500;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MyText(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      MyText(
                        '${entry.value}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInvoicesTable() {
    if (_filteredInvoices.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutral300),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Iconsax.receipt_2,
                size: 64,
                color: AppColors.neutral500.withValues(alpha: 0.5),
              ),
              kSizedBox,
              const MyText(
                'No invoices found',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const MyText(
                  'Recent Invoices',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                MyText(
                  '${_filteredInvoices.length} total',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount:
                _filteredInvoices.length > 10 ? 10 : _filteredInvoices.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
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
    final statusColor = _getPaymentStatusColor(invoice.paymentStatus);

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => ViewPerformanceInvoiceDialog(invoice: invoice),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Invoice Info
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    invoice.invoiceNumber ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  MyText(
                    invoice.clientName ?? 'Unknown Client',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.neutral500,
                    ),
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
                    MyText(
                      invoice.estateName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    MyText(
                      invoice.plotNumber ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),

            // Transaction Type
            if (isLargeScreen(context))
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: MyText(
                    invoice.transactionType,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            // Amount
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MyText(
                    '₦${_formatAmount(invoice.amount)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (invoice.balance != null && invoice.balance! > 0) ...[
                    const SizedBox(height: 4),
                    MyText(
                      'Bal: ₦${_formatAmount(invoice.balance!)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: MyText(
                invoice.paymentStatus,
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // View Invoice Button
            IconButton(
              icon: const Icon(Iconsax.receipt_2, size: 20),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      ViewPerformanceInvoiceDialog(invoice: invoice),
                );
              },
              tooltip: 'View Invoice',
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Partial':
        return Colors.blue;
      case 'Failed':
        return Colors.red;
      default:
        return AppColors.neutral500;
    }
  }
}
