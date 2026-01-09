import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/services/widget/add_invoice_dialog.dart';
import 'package:bms_front_end/pages/services/widget/add_service_dialog.dart';
import 'package:bms_front_end/pages/services/service_leads.dart';
import 'package:bms_front_end/pages/services/service_invoices.dart';
import 'package:bms_front_end/pages/services/generate_invoice_page.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  int _selectedTab = 0;

  final List<Map<String, String>> services = List.generate(
    6,
    (i) => {
      'title': 'Geotechnical Investigation',
      'category': 'Engineering',
      'desc':
          'Soil analysis and foundation engineering services for construction and infrastructure projects.',
      'price': 'N300,000.00',
      'duration': '3-5 weeks',
    },
  );
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
                          return const AddServiceDialog();
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
        if (_selectedTab == 3) _billing(),
        if (_selectedTab == 4) const GenerateInvoicePage(),
        if (_selectedTab == 5) const ServiceLeadsPage(),
        if (_selectedTab == 6) const ServiceInvoicesPage(),

        // _catalog(),
        // _quotes(),
        // _orders(),
        // _billing(),
      ],
    );
  }

  Widget _catalog() {
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
                        onTap: () {},
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Grid of cards
        LayoutBuilder(builder: (context, constraints) {
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
          double cardWidth = (maxWidth - (columns - 1) * spacing) / columns;

          return Wrap(
            runSpacing: spacing,
            spacing: spacing,
            children: services
                .map((s) => SizedBox(
                      width: cardWidth,
                      child: ServiceCard(
                        title: s['title']!,
                        category: s['category']!,
                        description: s['desc']!,
                        price: s['price']!,
                        duration: s['duration']!,
                      ),
                    ))
                .toList(),
          );
        }),

        const SizedBox(height: 40)
      ],
    );
  }

  Widget _quotes() {
    final List<Map<String, dynamic>> quotes = [
      {
        'company': 'Abuja infrastructure Company',
        'service': 'Environmental Impact Assessment',
        'email': 'projects@abujainfra.ng',
        'valid': '31 Aug 2024',
        'description':
            'EIA for shopping mall development in Central Business District',
        'price': '₦650,000.00',
        'statuses': ['Accepted'],
      },
      {
        'company': 'Abuja infrastructure Company',
        'service': 'Environmental Impact Assessment',
        'email': 'projects@abujainfra.ng',
        'valid': '31 Aug 2024',
        'description':
            'EIA for shopping mall development in Central Business District',
        'price': '₦650,000.00',
        'statuses': ['Sent'],
      },
      {
        'company': 'Abuja infrastructure Company',
        'service': 'Environmental Impact Assessment',
        'email': 'projects@abujainfra.ng',
        'valid': '31 Aug 2024',
        'description':
            'EIA for shopping mall development in Central Business District',
        'price': '₦650,000.00',
        'statuses': ['Accepted'],
      },
      {
        'company': 'Abuja infrastructure Company',
        'service': 'Environmental Impact Assessment',
        'email': 'projects@abujainfra.ng',
        'valid': '31 Aug 2024',
        'description':
            'EIA for shopping mall development in Central Business District',
        'price': '₦650,000.00',
        'statuses': ['Sent'],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quotes Management',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text('Track and manage service quotes',
            style: TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 24),
        ListView.separated(
          shrinkWrap: true,
          itemCount: quotes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final quote = quotes[index];
            return QuoteCard(
              company: quote['company']!,
              service: quote['service']!,
              email: quote['email']!,
              validUntil: quote['valid']!,
              description: quote['description']!,
              price: quote['price']!,
              statuses: quote['statuses']!,
            );
          },
        ),
      ],
    );
  }

  Widget _orders() {
    final List<Map<String, dynamic>> quotes = [
      {
        'company': 'Abuja infrastructure Company',
        'service': 'Environmental Impact Assessment',
        'email': 'projects@abujainfra.ng',
        'valid': '31 Aug 2024',
        'description':
            'EIA for shopping mall development in Central Business District',
        'price': '₦650,000.00',
        'statuses': ['In Progress', 'Partial'],
      },
      {
        'company': 'Abuja infrastructure Company',
        'service': 'Environmental Impact Assessment',
        'email': 'projects@abujainfra.ng',
        'valid': '31 Aug 2024',
        'description':
            'EIA for shopping mall development in Central Business District',
        'price': '₦650,000.00',
        'statuses': ['Completed', 'Paid'],
      },
      {
        'company': 'Abuja infrastructure Company',
        'service': 'Environmental Impact Assessment',
        'email': 'projects@abujainfra.ng',
        'valid': '31 Aug 2024',
        'description':
            'EIA for shopping mall development in Central Business District',
        'price': '₦650,000.00',
        'statuses': ['Accepted'],
      },
      {
        'company': 'Abuja infrastructure Company',
        'service': 'Environmental Impact Assessment',
        'email': 'projects@abujainfra.ng',
        'valid': '31 Aug 2024',
        'description':
            'EIA for shopping mall development in Central Business District',
        'price': '₦650,000.00',
        'statuses': ['Sent'],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Service Orders',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text('Track active adn completed service orders',
            style: TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 24),
        ListView.separated(
          shrinkWrap: true,
          itemCount: quotes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final quote = quotes[index];
            return QuoteCard(
              company: quote['company']!,
              service: quote['service']!,
              email: quote['email']!,
              validUntil: quote['valid']!,
              description: quote['description']!,
              price: quote['price']!,
              statuses: quote['statuses']!,
            );
          },
        ),
      ],
    );
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
    final items = [
      {'label': 'Services', 'count': '452'},
      {'label': 'Orders', 'count': '452'},
      {'label': 'Quotes', 'count': '452'},
      {'label': 'Invoices', 'count': '452'},
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
                    child: StatsCard(label: it['label']!, count: it['count']!)))
                .toList(),
          );
        }
      },
    );
  }

  Widget _buildTabs(BuildContext context, void Function(int) onTap) {
    final tabs = [
      'Service Catalog (8)',
      'Quotes (12)',
      'Orders (6)',
      'Billing (5)',
      'Generate Invoice',
      'Service Leads (4)',
      'Service Invoices (3)',
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
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
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
            color: Colors.black.withValues(alpha:0.02),
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

  const QuoteCard({
    super.key,
    required this.company,
    required this.service,
    required this.email,
    required this.validUntil,
    required this.description,
    required this.price,
    required this.statuses,
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

  const ServiceCard({
    super.key,
    required this.title,
    required this.category,
    required this.description,
    required this.price,
    required this.duration,
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
                child: const Text('Active',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
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
            child: Text(category,
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
                  onPressed: () {},
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
                  onPressed: () {},
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
