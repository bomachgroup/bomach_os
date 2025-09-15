import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

class ServicesPage extends StatelessWidget {
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

  ServicesPage({super.key});

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
                      // showDialog(
                      //   context: context,
                      //   builder: (context) {
                      //     return const AddExpenseDialog();
                      //   },
                      // );
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
        _buildTabs(context),
        const SizedBox(height: 18),
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

        const SizedBox(height: 40),
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

  Widget _buildTabs(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _PrimaryTab('Service Catalog (8)'),
                SizedBox(width: 12),
                _OutlineTab('Quotes (5)'),
                SizedBox(width: 12),
                _OutlineTab('Orders(5)'),
                SizedBox(width: 12),
                _OutlineTab('Billing(6)'),
              ],
            ),
          ),
        ),
      ],
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

class _PrimaryTab extends StatelessWidget {
  final String text;
  const _PrimaryTab(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.blue,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }
}

class _OutlineTab extends StatelessWidget {
  final String text;
  const _OutlineTab(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.black45, fontWeight: FontWeight.w600)),
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
