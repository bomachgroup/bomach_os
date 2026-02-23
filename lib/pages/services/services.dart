import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/services/controller/lead_controller.dart';
import 'package:bms_front_end/pages/services/controller/service_controller.dart';
import 'package:bms_front_end/pages/services/service_leads.dart';
import 'package:bms_front_end/pages/services/widget/add_invoice_dialog.dart';
import 'package:bms_front_end/pages/services/widget/create_order_dialog.dart';
import 'package:bms_front_end/pages/services/widget/create_quote_dialog.dart';
import 'package:bms_front_end/pages/services/widget/service_form_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 10,
                runSpacing: 10,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        'Services',
                        style: AppText.black_500_32,
                      ),
                      MyText(
                        'Manage your service catalog, quotes, and orders',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  MyElevatedButton(
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.white,
                    ),
                    child: "Add Service",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const ServiceFormDialog();
                        },
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
        kSizedBox,
        _buildTopStats(context),
        const SizedBox(height: 18),
        _buildTabs(context, (index) => setState(() => _selectedTab = index)),
        const SizedBox(height: 18),
        if (_selectedTab == 0) _catalog(),
        if (_selectedTab == 1) _quotes(),
        if (_selectedTab == 2) _orders(),
        // if (_selectedTab == 3) _billing(),
        // if (_selectedTab == 4) const GenerateInvoicePage(),
        if (_selectedTab == 3) const ServiceLeadsPage(),
        // if (_selectedTab == 6) const ServiceInvoicesPage(),

        // _catalog(),
        // _quotes(),
        // _orders(),
        // _billing(),
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
                Text(
                  _controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
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
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + subtitle
                        Text('Service Catalog',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w600)),
                        SizedBox(height: 8),
                        Text('Manage your service offerings and pricing',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54)),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 250,
                          child: MyTextFormField(
                            controller: _searchController,
                            hintText: 'Search for services...',
                            leading: Icon(
                              Icons.search,
                              color: AppColors.grey1.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        MyElevatedButton(
                          child: 'Filter',
                          onTap: () => _onSearch(
                            _searchController.text.trim(),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
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
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(
                child: Text(
                  'No services available',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
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
                if (maxWidth > 1200)
                  columns = 3;
                else if (maxWidth > 900)
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
                    icon: const Icon(Icons.chevron_left),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          currentPage > 1 ? AppColors.blue : Colors.grey[300],
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
                              color:
                                  isCurrentPage ? AppColors.blue : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isCurrentPage
                                    ? AppColors.blue
                                    : Colors.grey[300]!,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$pageNumber',
                              style: TextStyle(
                                color: isCurrentPage
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: isCurrentPage
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
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
                    icon: const Icon(Icons.chevron_right),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          hasNextPage ? AppColors.blue : Colors.grey[300],
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
                Text(
                  _controller.errorMessage.value,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
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
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quotes Management',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w600)),
                        SizedBox(height: 8),
                        Text('Track and manage service quotes',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54)),
                      ],
                    ),
                    MyElevatedButton(
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppColors.white,
                      ),
                      child: "Create Quote",
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return const CreateQuoteDialog();
                          },
                        );
                      },
                    ),
                  ],
                ),
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
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(
                child: Text(
                  'No quotes available',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
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
                        icon: const Icon(Icons.chevron_left),
                        style: IconButton.styleFrom(
                          backgroundColor: currentPage > 1
                              ? AppColors.blue
                              : Colors.grey[300],
                          foregroundColor:
                              currentPage > 1 ? Colors.white : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
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
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isCurrentPage
                                      ? AppColors.blue
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isCurrentPage
                                        ? AppColors.blue
                                        : Colors.grey[300]!,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$pageNumber',
                                  style: TextStyle(
                                    color: isCurrentPage
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: isCurrentPage
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: hasNextPage
                            ? () => _controller.nextQuotePage()
                            : null,
                        icon: const Icon(Icons.chevron_right),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              hasNextPage ? AppColors.blue : Colors.grey[300],
                          foregroundColor:
                              hasNextPage ? Colors.white : Colors.grey[600],
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
                Text(
                  _controller.errorMessage.value,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
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
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Service Orders',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w600)),
                        SizedBox(height: 8),
                        Text('Track active and completed service orders',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54)),
                      ],
                    ),
                    MyElevatedButton(
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppColors.white,
                      ),
                      child: "Create Order",
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return const CreateOrderDialog();
                          },
                        );
                      },
                    ),
                  ],
                ),
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
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(
                child: Text(
                  'No orders available',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
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
                        icon: const Icon(Icons.chevron_left),
                        style: IconButton.styleFrom(
                          backgroundColor: currentPage > 1
                              ? AppColors.blue
                              : Colors.grey[300],
                          foregroundColor:
                              currentPage > 1 ? Colors.white : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
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
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isCurrentPage
                                      ? AppColors.blue
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isCurrentPage
                                        ? AppColors.blue
                                        : Colors.grey[300]!,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$pageNumber',
                                  style: TextStyle(
                                    color: isCurrentPage
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: isCurrentPage
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: hasNextPage
                            ? () => _controller.nextOrderPage()
                            : null,
                        icon: const Icon(Icons.chevron_right),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              hasNextPage ? AppColors.blue : Colors.grey[300],
                          foregroundColor:
                              hasNextPage ? Colors.white : Colors.grey[600],
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

  Widget _billing() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 10,
                runSpacing: 10,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + subtitle
                      Text('Service Billing',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w600)),
                      SizedBox(height: 8),
                      Text('Manage billing and invoicing for service',
                          style:
                              TextStyle(fontSize: 14, color: Colors.black54)),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MyOutlinedButton(
                        textColor: AppColors.grey1,
                        borderColor: AppColors.grey2,
                        child: 'Filter',
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                      MyElevatedButton(
                        child: 'Create Invoice',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return const AddInvoiceDialog();
                            },
                          );
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ListView.separated(
          shrinkWrap: true,
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return const InvoiceCard();
          },
        ),
      ],
    );
  }

  Widget _buildTopStats(BuildContext context) {
    return Obx(() {
      final items = [
        {'label': 'Services', 'count': _controller.services.length.toString()},
        {'label': 'Orders', 'count': _controller.orders.length.toString()},
        {'label': 'Quotes', 'count': _controller.quotes.length.toString()},
        {'label': 'Leads', 'count': _leadController.leads.length.toString()},
      ];

      return LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          // show 4 cards in a row on wide screens, otherwise stack
          if (width > 900) {
            return Row(
              spacing: 18,
              children: items
                  .map((it) => Expanded(
                        child:
                            StatsCard(label: it['label']!, count: it['count']!),
                      ))
                  .toList(),
            );
          } else {
            return Wrap(
              spacing: 18,
              runSpacing: 18,
              children: items
                  .map((it) => Expanded(
                      child:
                          StatsCard(label: it['label']!, count: it['count']!)))
                  .toList(),
            );
          }
        },
      );
    });
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
              child: GestureDetector(
                onTap: () => onTap(index),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.blue
                        : AppColors.white.withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: isActive ? AppColors.blue : AppColors.grey4),
                  ),
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.black87,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Invoice No + Status
                Row(
                  children: [
                    const Text(
                      "INV-SVC-2024-002",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey.shade100,
                      ),
                      child: const Text(
                        "Partially Paid",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  "Abuja Infrastructure Company",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Text(
                      "Issue Date: 25 Jul 2024",
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    SizedBox(width: 16),
                    Text(
                      "Due Date: 25 Aug 2024",
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "Amount: ₦650,000.00",
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const Text(
                "Tax: ₦48,750.00",
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const Text(
                "Total: ₦698,750.00",
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const Text(
                "Paid: ₦300,000.00",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(50, 32),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                    ),
                    onPressed: () {},
                    child: const Text("View"),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(50, 32),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                    ),
                    onPressed: () {},
                    child: const Text("Edit"),
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
    // final isAccepted = status == 'Accepted';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Text Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  service,
                  style: const TextStyle(color: Colors.black87),
                ),
                Text(
                  email,
                  style: const TextStyle(color: Colors.black54),
                ),
                Text(
                  'Valid until: $validUntil',
                  style: const TextStyle(color: Colors.black54),
                ),
                Text(
                  description,
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Price & Status Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                spacing: 10,
                mainAxisSize: MainAxisSize.min,
                children: statuses
                    .map(
                      (status) => Builder(builder: (context) {
                        final isAccepted =
                            ['Completed', 'Accepted'].contains(status)
                                ? true
                                : false;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color:
                                isAccepted ? Colors.black : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: isAccepted
                                ? null
                                : Border.all(color: Colors.black26, width: 1),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: isAccepted ? Colors.white : Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }),
                    )
                    .toList(),
              ),
              if (paymentLink != null && paymentLink!.isNotEmpty) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: paymentLink!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payment link copied to clipboard'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy Payment Link'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.blue,
                    side: const BorderSide(color: AppColors.blue),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class StatsCard extends StatelessWidget {
  final String label;
  final String count;
  const StatsCard({super.key, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 160,
      constraints: const BoxConstraints(minWidth: 200, maxHeight: 160),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 8))
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.blue.withValues(alpha: 0.12),
            radius: 16,
            child: const Icon(Icons.person, color: AppColors.blue, size: 18),
          ),
          const Spacer(),
          Text(count,
              style:
                  const TextStyle(fontSize: 36, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
        ],
      ),
    );
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 8))
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status.capitalizeFirst ?? "",
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              )
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.white,
            ),
            child: Text(category.replaceFirst("_", " ").capitalizeFirst ?? "",
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
          const SizedBox(height: 12),
          Text(description,
              style: const TextStyle(
                  fontSize: 13, color: Colors.black54, height: 1.35)),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Base Price: $price',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500)),
              const Spacer(),
              Text(duration,
                  style: const TextStyle(fontSize: 13, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ServiceFormDialog(service: service);
                      },
                    );
                  },
                  icon: const Icon(Icons.remove_red_eye),
                  label: const Text('View'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    side: BorderSide(color: Colors.grey.shade300),
                    foregroundColor: Colors.black87,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ServiceFormDialog(service: service);
                      },
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    side: BorderSide(color: Colors.grey.shade300),
                    foregroundColor: Colors.black87,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
