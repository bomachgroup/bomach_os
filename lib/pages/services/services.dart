import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/cards/module_shortcut_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/section/module_dashboard.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/components/text/app_text.dart';
import 'package:bms_front_end/pages/services/controller/lead_controller.dart';
import 'package:bms_front_end/pages/services/controller/service_controller.dart';
import 'package:bms_front_end/pages/services/service_leads.dart';
import 'package:bms_front_end/pages/services/widget/create_order_dialog.dart';
import 'package:bms_front_end/pages/services/widget/create_quote_dialog.dart';
import 'package:bms_front_end/pages/services/widget/service_form_dialog.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/permissions.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/services/permission_service.dart';
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
      header: PageHeader(
        title: 'Services Dashboard',
        subtitle: 'Manage your service catalog, quotes, and orders',
        trailing: MyElevatedButton(
          icon: const Icon(Iconsax.add_circle, color: AppColors.white),
          child: "Add Service",
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const ServiceFormDialog(),
            );
          },
        ),
      ),
      children: [
        _buildTopStats(context),
        const SizedBox(height: 32),
        _buildTabs(context, (index) => setState(() => _selectedTab = index)),
        const SizedBox(height: 24),
        if (_selectedTab == 0) _catalog(),
        if (_selectedTab == 1) _quotes(),
        if (_selectedTab == 2) _orders(),
        if (_selectedTab == 3) const ServiceLeadsPage(),
      ],
    );
  }

  Widget _catalog() {
    return Obx(() {
      if (_controller.errorMessage.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText.bodyMd(
                  _controller.errorMessage.value,
                  color: AppColors.danger,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                MyElevatedButton(
                  child: 'Retry',
                  onTap: () => _controller.fetchServices(),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.h3('Service Catalog'),
                    const SizedBox(height: 4),
                    AppText.bodySm(
                      'Manage your service offerings and pricing',
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 300,
                    child: MyTextFormField(
                      controller: _searchController,
                      hintText: 'Search services...',
                      leading: Icon(
                        Iconsax.search_normal,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                        size: 18,
                      ),
                      onChanged: (v) => _onSearch(v.trim()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  MyElevatedButton(
                    child: 'Filter',
                    onTap: () => _onSearch(_searchController.text.trim()),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 18),
          if (_controller.isLoading.value)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_controller.services.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Center(
                child: AppText.bodyMd(
                  'No services available',
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: LayoutBuilder(builder: (context, constraints) {
                // determine columns from available width
                double maxWidth = constraints.maxWidth;
                int columns = 1;
                if (maxWidth > 1200) {
                  columns = 3;
                } else if (maxWidth > 900)
                  columns = 3;
                else if (maxWidth > 700)
                  columns = 2;
                else
                  columns = 1;

                double spacing = 18;
                double cardWidth =
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
                              price: '₦${service.basePrice}',
                              duration: service.deliveryTime,
                              status: service.status,
                              service: service,
                            ),
                          ))
                      .toList(),
                );
              }),
            ),
          const SizedBox(height: 24),
          // Pagination Controls
          if (_controller.services.isNotEmpty)
            Obx(() {
              final currentPage = _controller.currentPage.value;
              final hasNextPage =
                  _controller.services.length >= _controller.limit;

              // Calculate page range to show
              final totalPages = hasNextPage ? currentPage + 1 : currentPage;
              int endPage = totalPages.clamp(1, totalPages);
              int startPage = (endPage - 4).clamp(1, endPage);

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Previous Button
                  IconButton(
                    onPressed: currentPage > 1
                        ? () => _controller.previousPage(
                              search: _searchController.text.trim().isEmpty
                                  ? null
                                  : _searchController.text.trim(),
                            )
                        : null,
                    icon: const Icon(Iconsax.arrow_left_2),
                    style: IconButton.styleFrom(
                      backgroundColor: currentPage > 1
                          ? AppColors.primary
                          : Colors.grey[300],
                      foregroundColor:
                          currentPage > 1 ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Page Numbers
                  ...List.generate(
                    endPage - startPage + 1,
                    (index) {
                      final pageNumber = startPage + index;
                      final isCurrentPage = pageNumber == currentPage;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: InkWell(
                          onTap: () => _controller.goToPage(
                            pageNumber,
                            search: _searchController.text.trim().isEmpty
                                ? null
                                : _searchController.text.trim(),
                          ),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isCurrentPage
                                  ? AppColors.primary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isCurrentPage
                                    ? AppColors.primary
                                    : Colors.grey[300]!,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: AppText.bodyMd(
                              '$pageNumber',
                              color: isCurrentPage
                                  ? AppColors.white
                                  : AppColors.textPrimary,
                              fontWeight: isCurrentPage
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  // Next Button
                  IconButton(
                    onPressed: hasNextPage
                        ? () => _controller.nextPage(
                              search: _searchController.text.trim().isEmpty
                                  ? null
                                  : _searchController.text.trim(),
                            )
                        : null,
                    icon: const Icon(Iconsax.arrow_right_3),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          hasNextPage ? AppColors.primary : Colors.grey[300],
                      foregroundColor:
                          hasNextPage ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ],
              );
            }),
          const SizedBox(height: 40)
        ],
      );
    });
  }

  Widget _quotes() {
    return Obx(() {
      if (_controller.errorMessage.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText.bodyMd(
                  _controller.errorMessage.value,
                  color: AppColors.danger,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _controller.fetchQuotes(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.h3('Quotes Management'),
                    const SizedBox(height: 4),
                    AppText.bodySm(
                      'Manage and track your service quotes',
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              MyElevatedButton(
                icon: const Icon(Iconsax.add_circle, color: AppColors.white),
                child: "Create Quote",
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const CreateQuoteDialog(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_controller.isLoadingQuotes.value)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_controller.quotes.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Center(
                child: AppText.bodyMd(
                  'No quotes available',
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _controller.quotes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final quote = _controller.quotes[index];
                    return QuoteCard(
                      company: 'Client ID: ${quote.clientId}',
                      service: quote.service.name,
                      email: quote.quoteNumber,
                      validUntil: quote.validUntil,
                      description: quote.description,
                      price: '₦${quote.amount}',
                      statuses: [quote.status.capitalizeFirst ?? quote.status],
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Pagination Controls
                Obx(() {
                  final currentPage = _controller.currentQuotePage.value;
                  final hasNextPage =
                      _controller.quotes.length >= _controller.limit;

                  final totalPages =
                      hasNextPage ? currentPage + 1 : currentPage;
                  int endPage = totalPages.clamp(1, totalPages);
                  int startPage = (endPage - 4).clamp(1, endPage);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: currentPage > 1
                            ? () => _controller.previousQuotePage()
                            : null,
                        icon: const Icon(Iconsax.arrow_left_2, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: currentPage > 1
                              ? AppColors.primary
                              : AppColors.neutral200,
                          foregroundColor: currentPage > 1
                              ? Colors.white
                              : AppColors.textSecondary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ...List.generate(
                        endPage - startPage + 1,
                        (index) {
                          final pageNumber = startPage + index;
                          final isCurrentPage = pageNumber == currentPage;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: () =>
                                  _controller.goToQuotePage(pageNumber),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isCurrentPage
                                      ? AppColors.primary
                                      : AppColors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isCurrentPage
                                        ? AppColors.primary
                                        : AppColors.neutral200,
                                  ),
                                  boxShadow: isCurrentPage
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: AppText.bodyMd(
                                  '$pageNumber',
                                  color: isCurrentPage
                                      ? AppColors.white
                                      : AppColors.textPrimary,
                                  fontWeight: isCurrentPage
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: hasNextPage
                            ? () => _controller.nextQuotePage()
                            : null,
                        icon: const Icon(Iconsax.arrow_right_3, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: hasNextPage
                              ? AppColors.primary
                              : AppColors.neutral200,
                          foregroundColor: hasNextPage
                              ? Colors.white
                              : AppColors.textSecondary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
        ],
      );
    });
  }

  Widget _orders() {
    return Obx(() {
      if (_controller.errorMessage.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText.bodyMd(
                  _controller.errorMessage.value,
                  color: AppColors.danger,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _controller.fetchOrders(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.h3('Service Orders'),
                    const SizedBox(height: 4),
                    AppText.bodySm(
                      'Track active and completed service orders',
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              MyElevatedButton(
                icon: const Icon(Iconsax.add_circle, color: AppColors.white),
                child: "Create Order",
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const CreateOrderDialog(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_controller.isLoadingOrders.value)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_controller.orders.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Center(
                child: AppText.bodyMd(
                  'No orders available',
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _controller.orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final order = _controller.orders[index];
                    return QuoteCard(
                      company: 'Client ID: ${order.clientId}',
                      service: order.service.name,
                      email: order.orderNumber,
                      validUntil: order.validUntil,
                      description: order.description,
                      price: '₦${order.amount}',
                      statuses: [
                        order.orderStatus.capitalizeFirst ?? order.orderStatus,
                        order.paymentStatus.capitalizeFirst ??
                            order.paymentStatus,
                      ],
                      paymentLink: order.paymentLink,
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Pagination Controls
                Obx(() {
                  final currentPage = _controller.currentOrderPage.value;
                  final hasNextPage =
                      _controller.orders.length >= _controller.limit;

                  final totalPages =
                      hasNextPage ? currentPage + 1 : currentPage;
                  int endPage = totalPages.clamp(1, totalPages);
                  int startPage = (endPage - 4).clamp(1, endPage);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: currentPage > 1
                            ? () => _controller.previousOrderPage()
                            : null,
                        icon: const Icon(Iconsax.arrow_left_2, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: currentPage > 1
                              ? AppColors.primary
                              : AppColors.neutral200,
                          foregroundColor: currentPage > 1
                              ? Colors.white
                              : AppColors.textSecondary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ...List.generate(
                        endPage - startPage + 1,
                        (index) {
                          final pageNumber = startPage + index;
                          final isCurrentPage = pageNumber == currentPage;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: () =>
                                  _controller.goToOrderPage(pageNumber),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isCurrentPage
                                      ? AppColors.primary
                                      : AppColors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isCurrentPage
                                        ? AppColors.primary
                                        : AppColors.neutral200,
                                  ),
                                  boxShadow: isCurrentPage
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.2),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: AppText.bodyMd(
                                  '$pageNumber',
                                  color: isCurrentPage
                                      ? AppColors.white
                                      : AppColors.textPrimary,
                                  fontWeight: isCurrentPage
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: hasNextPage
                            ? () => _controller.nextOrderPage()
                            : null,
                        icon: const Icon(Iconsax.arrow_right_3, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: hasNextPage
                              ? AppColors.primary
                              : AppColors.neutral200,
                          foregroundColor: hasNextPage
                              ? Colors.white
                              : AppColors.textSecondary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
        ],
      );
    });
  }

  Widget _buildTopStats(BuildContext context) {
    return Obx(() {
      final servicesCount = _controller.services.length.toString();
      final ordersCount = _controller.orders.length.toString();
      final quotesCount = _controller.quotes.length.toString();
      final leadsCount = _leadController.leads.length.toString();

      return LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 650;
          final int crossAxisCount =
              isMobile ? 1 : (constraints.maxWidth > 1100 ? 4 : 2);

          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: isMobile ? 2.8 : 2.2,
            children: [
              _buildStatCard(
                  "Services", servicesCount, AppColors.primary, Iconsax.box),
              _buildStatCard("Orders", ordersCount, AppColors.success,
                  Iconsax.shopping_bag),
              _buildStatCard("Quotes", quotesCount, AppColors.warning,
                  Iconsax.document_text),
              _buildStatCard("Leads", leadsCount, const Color(0xFF8B5CF6),
                  Iconsax.user_tag),
            ],
          );
        },
      );
    });
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText.bodySm(
                  title,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 4),
                AppText.h2(
                  value,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context, void Function(int) onTap) {
    return Obx(() {
      final tabs = [
        'Service Catalog (${_controller.services.length})',
        'Quotes (${_controller.quotes.length})',
        'Orders (${_controller.orders.length})',
        // 'Billing (5)',
        // 'Generate Invoice',
        'Service Leads (${_leadController.leads.length})',
        // 'Service Invoices (3)',
      ];

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isActive = _selectedTab == index;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                onTap: () => onTap(index),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isActive ? AppColors.primary : AppColors.neutral200,
                      width: 1,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: AppText.bodySm(
                    tabs[index],
                    color: isActive ? AppColors.white : AppColors.textPrimary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }),
        ),
      );
    });
  }
}

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppText.h4("INV-SVC-2024-002"),
                    const SizedBox(width: 12),
                    const StatusChip(
                        label: "Partially Paid", tone: StatusTone.warning),
                  ],
                ),
                const SizedBox(height: 8),
                AppText.bodyMd(
                  "Abuja Infrastructure Company",
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Iconsax.calendar,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    AppText.caption("Issue: 25 Jul 2024"),
                    const SizedBox(width: 16),
                    const Icon(Iconsax.timer_1,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    AppText.caption("Due: 25 Aug 2024"),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText.h4(
                "Total: ₦698,750.00",
                color: AppColors.primary,
              ),
              const SizedBox(height: 4),
              AppText.bodySm(
                "Paid: ₦300,000.00",
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _cardButton("View", Iconsax.eye, () {}),
                  const SizedBox(width: 8),
                  _cardButton("Edit", Iconsax.edit, () {}),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardButton(String label, IconData icon, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        textStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.h4(company),
                const SizedBox(height: 6),
                AppText.bodyMd(
                  service,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(height: 4),
                AppText.caption(email),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Iconsax.calendar,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    AppText.caption('Valid until: $validUntil'),
                  ],
                ),
                const SizedBox(height: 8),
                AppText.bodySm(
                  description,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText.h4(
                price,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: statuses
                    .map((status) => StatusChip(
                          label: status,
                          tone: _mapStatusToTone(status),
                        ))
                    .toList(),
              ),
              if (paymentLink != null && paymentLink!.isNotEmpty) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: paymentLink!));
                    AppToast.success(
                        context, 'Payment link copied to clipboard');
                  },
                  icon: const Icon(Iconsax.copy, size: 14),
                  label: const Text('Payment Link'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle:
                        AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  StatusTone _mapStatusToTone(String status) {
    final s = status.toLowerCase();
    if (s.contains('completed') || s.contains('accepted') || s.contains('paid')) {
      return StatusTone.success;
    }
    if (s.contains('pending') || s.contains('partial')) return StatusTone.warning;
    if (s.contains('cancelled') || s.contains('rejected')) return StatusTone.danger;
    return StatusTone.neutral;
  }
}

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

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: AppText.h4(title)),
              StatusChip(
                label: status.capitalizeFirst ?? "",
                tone:
                    status.toLowerCase() == 'active' ? StatusTone.success : StatusTone.neutral,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: AppText.caption(
              category.replaceFirst("_", " ").capitalizeFirst ?? "",
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          AppText.bodySm(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Iconsax.money_send,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              AppText.bodySm(
                price,
                fontWeight: FontWeight.w700,
              ),
              const Spacer(),
              const Icon(Iconsax.timer_1,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              AppText.caption(duration),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _actionButton("View", Iconsax.eye, context)),
              const SizedBox(width: 12),
              Expanded(child: _actionButton("Edit", Iconsax.edit, context)),
            ],
          )
        ],
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => ServiceFormDialog(service: service),
        );
      },
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: const BorderSide(color: AppColors.neutral200),
        foregroundColor: AppColors.textPrimary,
      ),
    );
  }
}
