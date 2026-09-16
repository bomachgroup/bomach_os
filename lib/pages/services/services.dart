import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/paginate/my_paginator.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/components/section/responsive_stat_row.dart';
import 'package:bomach_os/pages/services/controller/lead_controller.dart';
import 'package:bomach_os/pages/services/controller/service_controller.dart';
import 'package:bomach_os/pages/services/service_leads.dart';
import 'package:bomach_os/pages/services/widget/create_order_dialog.dart';
import 'package:bomach_os/pages/services/widget/create_quote_dialog.dart';
import 'package:bomach_os/pages/services/widget/service_form_dialog.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/shadows.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/utils/number_formatting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import './models/service_model.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  int _selectedTab = 0;
  final ServiceController _controller = Get.put(ServiceController());
  final LeadController _leadController = Get.put(LeadController());
  final TextEditingController _searchController = TextEditingController();

  void _onSearch(String? query) {
    if (query != null && query.isNotEmpty) {
      _controller.fetchServices(search: query);
    } else {
      _controller.fetchServices();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Services Dashboard',
        subtitle: 'Manage your service catalog, quotes, and orders',
        trailing: MyElevatedButton(
          height: 48,
          icon: const Icon(
            Iconsax.add_circle,
            color: AppColors.textOnPrimary,
            size: 18,
          ),
          child: 'Add Service',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const ServiceFormDialog(),
            );
          },
        ),
      ),
      children: [
        _buildTopStats(),
        _buildTabs((index) => setState(() => _selectedTab = index)),
        if (_selectedTab == 0) _catalog(),
        if (_selectedTab == 1) _quotes(),
        if (_selectedTab == 2) _orders(),
        if (_selectedTab == 3) const ServiceLeadsPage(),
      ],
    );
  }

  // ─── Stats ────────────────────────────────────────────────────────────────
  Widget _buildTopStats() {
    return Obx(() {
      final servicesCount = _controller.services.length.toString();
      final ordersCount = _controller.orders.length.toString();
      final quotesCount = _controller.quotes.length.toString();
      final leadsCount = _leadController.leads.length.toString();

      return ResponsiveStatRow(
        cards: [
          _StatCard(
            title: 'Services',
            count: servicesCount,
            icon: Iconsax.box,
            accent: AppColors.primary,
          ),
          _StatCard(
            title: 'Orders',
            count: ordersCount,
            icon: Iconsax.shopping_bag,
            accent: AppColors.success,
          ),
          _StatCard(
            title: 'Quotes',
            count: quotesCount,
            icon: Iconsax.document_text,
            accent: AppColors.warning,
          ),
          _StatCard(
            title: 'Leads',
            count: leadsCount,
            icon: Iconsax.user_tag,
            accent: const Color(0xFF8B5CF6),
          ),
        ],
      );
    });
  }

  // ─── Tabs ─────────────────────────────────────────────────────────────────
  Widget _buildTabs(void Function(int) onTap) {
    return Obx(() {
      final tabs = [
        'Service Catalog (${_controller.services.length})',
        'Quotes (${_controller.quotes.length})',
        'Orders (${_controller.orders.length})',
        'Service Leads (${_leadController.leads.length})',
      ];

      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: AppRadii.brLg,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(tabs.length, (index) {
              final isActive = _selectedTab == index;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: AppRadii.brMd,
                    onTap: () => onTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.surface : Colors.transparent,
                        borderRadius: AppRadii.brMd,
                        boxShadow: isActive ? AppShadows.sm : const <BoxShadow>[],
                      ),
                      child: Text(
                        tabs[index],
                        style: AppTextStyles.bodyMd.copyWith(
                          color: isActive
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      );
    });
  }

  // ─── Catalog tab ──────────────────────────────────────────────────────────
  Widget _catalog() {
    return Obx(() {
      if (_controller.errorMessage.isNotEmpty) {
        return AppCard(
          padding: const EdgeInsets.all(24),
          child: EmptyState(
            icon: Iconsax.warning_2,
            title: 'Unable to load services',
            subtitle: _controller.errorMessage.value,
            action: MyElevatedButton(
              child: 'Retry',
              icon: const Icon(
                Iconsax.refresh,
                size: 18,
                color: AppColors.textOnPrimary,
              ),
              onTap: () => _controller.fetchServices(),
            ),
          ),
        );
      }

      final loading =
          _controller.isLoading.value && _controller.services.isEmpty;
      final isEmpty =
          !_controller.isLoading.value && _controller.services.isEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader(
            title: 'Service Catalog',
            subtitle: 'Manage your service offerings and pricing',
            trailing: SizedBox(
              width: 320,
              child: MyTextFormField(
                controller: _searchController,
                hintText: 'Search services...',
                height: 44,
                leading: const Icon(
                  Iconsax.search_normal,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                onChanged: (v) => _onSearch(v.trim()),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (loading)
            LoadingSkeleton.listRows(count: 6)
          else if (isEmpty)
            AppCard(
              padding: const EdgeInsets.all(24),
              child: EmptyState(
                icon: Iconsax.box,
                title: 'No services yet',
                subtitle:
                    'Create your first service offering to start tracking quotes and orders.',
                action: MyElevatedButton(
                  child: 'Add Service',
                  icon: const Icon(
                    Iconsax.add_circle,
                    size: 18,
                    color: AppColors.textOnPrimary,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ServiceFormDialog(),
                    );
                  },
                ),
              ),
            )
          else
            LayoutBuilder(builder: (context, constraints) {
              double maxWidth = constraints.maxWidth;
              int columns;
              if (maxWidth > 1200) {
                columns = 3;
              } else if (maxWidth > 900) {
                columns = 3;
              } else if (maxWidth > 700) {
                columns = 2;
              } else {
                columns = 1;
              }

              const double spacing = 16;
              final double cardWidth =
                  (maxWidth - (columns - 1) * spacing) / columns;

              return Wrap(
                alignment: WrapAlignment.start,
                runSpacing: spacing,
                spacing: spacing,
                children: _controller.services
                    .map((service) => SizedBox(
                          width: cardWidth,
                          child: ServiceCard(
                            title: service.name,
                            category: service.category.name,
                            description: service.description,
                            price: service.basePrice.toNaira(),
                            duration: service.deliveryTime,
                            status: service.status,
                            service: service,
                          ),
                        ))
                    .toList(),
              );
            }),
          if (_controller.services.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildCatalogPaginator(),
          ],
        ],
      );
    });
  }

  Widget _buildCatalogPaginator() {
    return Obx(() {
      final currentPage = _controller.currentPage.value;
      final hasNextPage =
          _controller.services.length >= _controller.limit;
      final derivedTotal = hasNextPage
          ? currentPage * _controller.limit + 1
          : (currentPage - 1) * _controller.limit +
              _controller.services.length;

      return AppCard(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        elevation: AppCardElevation.sm,
        child: PaginatorFooter(
          totalItems: derivedTotal,
          limit: _controller.limit,
          currentPage: currentPage,
          onPageChanged: (page) => _controller.goToPage(
            page,
            search: _searchController.text.trim().isEmpty
                ? null
                : _searchController.text.trim(),
          ),
        ),
      );
    });
  }

  // ─── Quotes tab ───────────────────────────────────────────────────────────
  Widget _quotes() {
    return Obx(() {
      if (_controller.errorMessage.isNotEmpty) {
        return AppCard(
          padding: const EdgeInsets.all(24),
          child: EmptyState(
            icon: Iconsax.warning_2,
            title: 'Unable to load quotes',
            subtitle: _controller.errorMessage.value,
            action: MyElevatedButton(
              child: 'Retry',
              icon: const Icon(
                Iconsax.refresh,
                size: 18,
                color: AppColors.textOnPrimary,
              ),
              onTap: () => _controller.fetchQuotes(),
            ),
          ),
        );
      }

      final loading =
          _controller.isLoadingQuotes.value && _controller.quotes.isEmpty;
      final isEmpty =
          !_controller.isLoadingQuotes.value && _controller.quotes.isEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader(
            title: 'Quotes Management',
            subtitle: 'Manage and track your service quotes',
            trailing: MyElevatedButton(
              height: 44,
              icon: const Icon(
                Iconsax.add_circle,
                color: AppColors.textOnPrimary,
                size: 18,
              ),
              child: 'Create Quote',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const CreateQuoteDialog(),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (loading)
            LoadingSkeleton.listRows(count: 5)
          else if (isEmpty)
            AppCard(
              padding: const EdgeInsets.all(24),
              child: EmptyState(
                icon: Iconsax.document_text,
                title: 'No quotes yet',
                subtitle: 'Create a quote to share pricing with your clients.',
                action: MyElevatedButton(
                  child: 'Create Quote',
                  icon: const Icon(
                    Iconsax.add_circle,
                    size: 18,
                    color: AppColors.textOnPrimary,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const CreateQuoteDialog(),
                    );
                  },
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < _controller.quotes.length; i++) ...[
                  Builder(builder: (_) {
                    final quote = _controller.quotes[i];
                    return QuoteCard(
                      company: 'Client ID: ${quote.clientId}',
                      service: quote.service.name,
                      email: quote.quoteNumber,
                      validUntil: quote.validUntil,
                      description: quote.description,
                      price: quote.amount.toNaira(),
                      statuses: [
                        quote.status.capitalizeFirst ?? quote.status,
                      ],
                    );
                  }),
                  if (i != _controller.quotes.length - 1)
                    const SizedBox(height: 12),
                ],
              ],
            ),
          if (_controller.quotes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Obx(() {
              final currentPage = _controller.currentQuotePage.value;
              final hasNextPage =
                  _controller.quotes.length >= _controller.limit;
              final derivedTotal = hasNextPage
                  ? currentPage * _controller.limit + 1
                  : (currentPage - 1) * _controller.limit +
                      _controller.quotes.length;
              return AppCard(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                elevation: AppCardElevation.sm,
                child: PaginatorFooter(
                  totalItems: derivedTotal,
                  limit: _controller.limit,
                  currentPage: currentPage,
                  onPageChanged: _controller.goToQuotePage,
                ),
              );
            }),
          ],
        ],
      );
    });
  }

  // ─── Orders tab ───────────────────────────────────────────────────────────
  Widget _orders() {
    return Obx(() {
      if (_controller.errorMessage.isNotEmpty) {
        return AppCard(
          padding: const EdgeInsets.all(24),
          child: EmptyState(
            icon: Iconsax.warning_2,
            title: 'Unable to load orders',
            subtitle: _controller.errorMessage.value,
            action: MyElevatedButton(
              child: 'Retry',
              icon: const Icon(
                Iconsax.refresh,
                size: 18,
                color: AppColors.textOnPrimary,
              ),
              onTap: () => _controller.fetchOrders(),
            ),
          ),
        );
      }

      final loading =
          _controller.isLoadingOrders.value && _controller.orders.isEmpty;
      final isEmpty =
          !_controller.isLoadingOrders.value && _controller.orders.isEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader(
            title: 'Service Orders',
            subtitle: 'Track active and completed service orders',
            trailing: MyElevatedButton(
              height: 44,
              icon: const Icon(
                Iconsax.add_circle,
                color: AppColors.textOnPrimary,
                size: 18,
              ),
              child: 'Create Order',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const CreateOrderDialog(),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (loading)
            LoadingSkeleton.listRows(count: 5)
          else if (isEmpty)
            AppCard(
              padding: const EdgeInsets.all(24),
              child: EmptyState(
                icon: Iconsax.shopping_bag,
                title: 'No orders yet',
                subtitle:
                    'Approved quotes or direct orders will appear here for fulfilment.',
                action: MyElevatedButton(
                  child: 'Create Order',
                  icon: const Icon(
                    Iconsax.add_circle,
                    size: 18,
                    color: AppColors.textOnPrimary,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const CreateOrderDialog(),
                    );
                  },
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < _controller.orders.length; i++) ...[
                  Builder(builder: (_) {
                    final order = _controller.orders[i];
                    return QuoteCard(
                      company: 'Client ID: ${order.clientId}',
                      service: order.service.name,
                      email: order.orderNumber,
                      validUntil: order.validUntil,
                      description: order.description,
                      price: order.amount.toNaira(),
                      statuses: [
                        order.orderStatus.capitalizeFirst ?? order.orderStatus,
                        order.paymentStatus.capitalizeFirst ??
                            order.paymentStatus,
                      ],
                      paymentLink: order.paymentLink,
                    );
                  }),
                  if (i != _controller.orders.length - 1)
                    const SizedBox(height: 12),
                ],
              ],
            ),
          if (_controller.orders.isNotEmpty) ...[
            const SizedBox(height: 16),
            Obx(() {
              final currentPage = _controller.currentOrderPage.value;
              final hasNextPage =
                  _controller.orders.length >= _controller.limit;
              final derivedTotal = hasNextPage
                  ? currentPage * _controller.limit + 1
                  : (currentPage - 1) * _controller.limit +
                      _controller.orders.length;
              return AppCard(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                elevation: AppCardElevation.sm,
                child: PaginatorFooter(
                  totalItems: derivedTotal,
                  limit: _controller.limit,
                  currentPage: currentPage,
                  onPageChanged: _controller.goToOrderPage,
                ),
              );
            }),
          ],
        ],
      );
    });
  }

  // ─── Section header (title + trailing action) ────────────────────────────
  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 720;
      final titleBlock = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );

      if (compact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleBlock,
            if (trailing != null) ...[
              const SizedBox(height: 12),
              trailing,
            ],
          ],
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: titleBlock),
          if (trailing != null) trailing,
        ],
      );
    });
  }
}

// ─── Stat card ──────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color accent;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: AppRadii.brSm,
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: AppTextStyles.h1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Invoice card (kept for legacy reuse) ──────────────────────────────────
class InvoiceCard extends StatelessWidget {
  const InvoiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.sm,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('INV-SVC-2024-002', style: AppTextStyles.h4),
                    SizedBox(width: 12),
                    StatusChip(
                      label: 'Partially Paid',
                      tone: StatusTone.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Abuja Infrastructure Company',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Iconsax.calendar,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      'Issue: 25 Jul 2024',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Iconsax.timer_1,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      'Due: 25 Aug 2024',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total: ₦698,750.00',
                style: AppTextStyles.h4.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 4),
              Text(
                'Paid: ₦300,000.00',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  MyOutlinedButton(
                    height: 36,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    fontSize: 12,
                    icon: const Icon(Iconsax.eye,
                        size: 14, color: AppColors.primary),
                    child: 'View',
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  MyOutlinedButton(
                    height: 36,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    fontSize: 12,
                    icon: const Icon(Iconsax.edit,
                        size: 14, color: AppColors.primary),
                    child: 'Edit',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Quote / Order list card ───────────────────────────────────────────────
class QuoteCard extends StatelessWidget {
  final String company;
  final String service;
  final String email;
  final String validUntil;
  final String description;
  final String price;
  final List<String> statuses;
  final String? paymentLink;

  const QuoteCard({
    super.key,
    required this.company,
    required this.service,
    required this.email,
    required this.validUntil,
    required this.description,
    required this.price,
    required this.statuses,
    this.paymentLink,
  });

  StatusTone _mapStatusToTone(String status) {
    final s = status.toLowerCase();
    if (s.contains('completed') ||
        s.contains('accepted') ||
        s.contains('paid')) {
      return StatusTone.success;
    }
    if (s.contains('pending') || s.contains('partial')) {
      return StatusTone.warning;
    }
    if (s.contains('cancelled') || s.contains('rejected')) {
      return StatusTone.danger;
    }
    return StatusTone.neutral;
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.sm,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 640;
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(company, style: AppTextStyles.h4),
              const SizedBox(height: 6),
              Text(
                service,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Iconsax.calendar,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Valid until: $validUntil',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          );

          final pricing = Column(
            crossAxisAlignment:
                compact ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: AppTextStyles.h3.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: statuses
                    .map((status) => StatusChip(
                          label: status,
                          tone: _mapStatusToTone(status),
                        ))
                    .toList(),
              ),
              if (paymentLink != null && paymentLink!.isNotEmpty) ...[
                const SizedBox(height: 12),
                MyOutlinedButton(
                  height: 36,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  fontSize: 12,
                  icon: const Icon(Iconsax.copy,
                      size: 14, color: AppColors.primary),
                  child: 'Payment Link',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: paymentLink!));
                    AppToast.success(
                      context,
                      'Payment link copied to clipboard',
                    );
                  },
                ),
              ],
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                details,
                const SizedBox(height: 16),
                pricing,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: details),
              const SizedBox(width: 24),
              pricing,
            ],
          );
        },
      ),
    );
  }
}

// ─── Service tile card ────────────────────────────────────────────────────
class ServiceCard extends StatelessWidget {
  final String title;
  final String category;
  final String description;
  final String price;
  final String duration;
  final String status;
  final Service service;

  const ServiceCard({
    super.key,
    required this.title,
    required this.category,
    required this.description,
    required this.price,
    required this.duration,
    required this.status,
    required this.service,
  });

  StatusTone _statusTone(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return StatusTone.success;
      case 'paused':
        return StatusTone.warning;
      case 'closed':
        return StatusTone.neutral;
      case 'pending':
        return StatusTone.warning;
      default:
        return StatusTone.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryLabel =
        category.replaceFirst('_', ' ').capitalizeFirst ?? category;

    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: AppTextStyles.h4)),
              const SizedBox(width: 12),
              StatusChip(
                label: status.capitalizeFirst ?? status,
                tone: _statusTone(status),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StatusChip(
            label: categoryLabel,
            tone: StatusTone.info,
            dense: true,
          ),
          const SizedBox(height: 14),
          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(Iconsax.money_send,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                price,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Icon(Iconsax.timer_1,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                duration,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: MyOutlinedButton(
                  height: 42,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  icon: const Icon(Iconsax.eye,
                      size: 16, color: AppColors.primary),
                  child: 'View',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => ServiceFormDialog(service: service),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MyOutlinedButton(
                  height: 42,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  icon: const Icon(Iconsax.edit,
                      size: 16, color: AppColors.primary),
                  child: 'Edit',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => ServiceFormDialog(service: service),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
