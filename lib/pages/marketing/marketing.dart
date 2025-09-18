import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/cards/stats_header.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/marketing/widget/add_campaign_dialog.dart';
import 'package:bms_front_end/pages/marketing/widget/add_content_dialog.dart';
import 'package:bms_front_end/pages/marketing/widget/add_lead_dialog.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MarketingPage extends StatefulWidget {
  const MarketingPage({super.key});

  @override
  State<MarketingPage> createState() => _MarketingPageState();
}

class _MarketingPageState extends State<MarketingPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
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
                        'Marketing',
                        style: AppText.black_500_32,
                      ),
                      MyText(
                        'Manage projects, tasks, worksites, and operational workflows',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  MyElevatedButton(
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.white,
                    ),
                    child: "Add Campaign",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const AddCampaignDialog();
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

        // Stats Cards
        _buildTopStats(context),
        const SizedBox(height: 18),

        // Tabs
        _buildTabs(context, (index) => setState(() => _selectedTab = index)),
        const SizedBox(height: 18),

        // Tab Content
        if (_selectedTab == 0) _campaigns(),
        if (_selectedTab == 1) _leads(),
        if (_selectedTab == 2) _content(),
        if (_selectedTab == 3) _event(),
        if (_selectedTab == 4) _analytics(),
      ],
    );
  }

  Widget _campaigns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Projects Header
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
                      Text('Marketing Campaigns (2)',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w600)),
                      SizedBox(height: 8),
                      Text('Manage and track marketing campaign performance',
                          style:
                              TextStyle(fontSize: 14, color: Colors.black54)),
                    ],
                  ),
                  SizedBox(
                    width: 300,
                    child: MyTextFormField(
                      hintText: 'Search ...',
                      leading: Icon(
                        Icons.search,
                        color: AppColors.grey1.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                context.go(RouteConstants.marketingCampaignDetail);
              },
              child: const CampaignCard(
                title: "Q1 Land Survey Awareness",
                subtitle: "Property developers in Lagos",
                status: "Active",
                channel: "Social Media",
                budgetUsed: 62.5,
                impressions: 130000,
                ctr: 2.6,
                roi: 120,
                spent: 145000,
                total: 1200000,
              ),
            );
          },
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _leads() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Projects Header
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
                      Text('Marketing Leads (2)',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w600)),
                      SizedBox(height: 8),
                      Text('Track and nurture potential customers',
                          style:
                              TextStyle(fontSize: 14, color: Colors.black54)),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 300,
                        child: MyTextFormField(
                          hintText: 'Search ...',
                          leading: Icon(
                            Icons.search,
                            color: AppColors.grey1.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      MyElevatedButton(
                        child: 'Add Lead',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return const AddLeadDialog();
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                context.go(RouteConstants.marketingLeadDetail);
              },
              child: const LeadCard(),
            );
          },
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _content() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Projects Header
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
                      Text('Content Management (2)',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w600)),
                      SizedBox(height: 8),
                      Text('Create, schedule, and manage marketing content',
                          style:
                              TextStyle(fontSize: 14, color: Colors.black54)),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 300,
                        child: MyTextFormField(
                          hintText: 'Search ...',
                          leading: Icon(
                            Icons.search,
                            color: AppColors.grey1.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      MyElevatedButton(
                        child: 'Add Content',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return const AddContentDialog();
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                context.go(RouteConstants.marketingSiteDetail);
              },
              child: const ContentCard(),
            );
          },
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _event() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Projects Header
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
                      Text('Marketing Analytics',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w600)),
                      SizedBox(height: 8),
                      Text('Analyze marketing performance and insights',
                          style:
                              TextStyle(fontSize: 14, color: Colors.black54)),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 300,
                        child: MyTextFormField(
                          hintText: 'Search ...',
                          leading: Icon(
                            Icons.search,
                            color: AppColors.grey1.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      MyElevatedButton(
                        child: 'Add Event',
                        onTap: () {
                          // showDialog(
                          //   context: context,
                          //   builder: (context) {
                          //     return const AddTaskDialog();
                          //   },
                          // );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        const EventsCalendarWidget(),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _analytics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Projects Header
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
                      Text('Marketing Analytics',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w600)),
                      SizedBox(height: 8),
                      Text('Analyze marketing performance and insights',
                          style:
                              TextStyle(fontSize: 14, color: Colors.black54)),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 300,
                        child: MyTextFormField(
                          hintText: 'Search ...',
                          leading: Icon(
                            Icons.search,
                            color: AppColors.grey1.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      MyElevatedButton(
                        child: 'Generate Report',
                        onTap: () {
                          // showDialog(
                          //   context: context,
                          //   builder: (context) {
                          //     return const AddTaskDialog();
                          //   },
                          // );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        const AnalyticsDashboard(),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildTopStats(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {'label': 'Total Budget', 'count': '₦700,000.00', 'icon': Icons.person},
      {'label': 'Amount Spent', 'count': '₦505,000.00', 'icon': Icons.person},
      {'label': 'Total Lead', 'count': '5', 'icon': Icons.person},
      {'label': 'Qualified Leads', 'count': '4', 'icon': Icons.person},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        if (width > 900) {
          return Row(
            spacing: 18,
            children: items
                .map((it) => Expanded(
                      child: StatsHeaderCard(
                        label: it['label']!,
                        count: it['count']!,
                        icon: it['icon']! as IconData,
                      ),
                    ))
                .toList(),
          );
        } else {
          return Wrap(
            spacing: 18,
            runSpacing: 18,
            children: items
                .map((it) => SizedBox(
                    width: (width - 18) / 2,
                    child: StatsHeaderCard(
                      label: it['label']!,
                      count: it['count']!,
                      icon: it['icon']! as IconData,
                    )))
                .toList(),
          );
        }
      },
    );
  }

  Widget _buildTabs(BuildContext context, void Function(int) onTap) {
    final tabs = [
      'Campaigns (12)',
      'Leads (22)',
      'Content',
      'Events',
      'Analytics',
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
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isActive ? AppColors.blue : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.black54,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                    fontSize: 14,
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

class CampaignCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status; // Active / Completed
  final String channel; // Social Media / Email Marketing
  final double budgetUsed; // 0.65 = 65%
  final int impressions;
  final double ctr; // e.g. 2.6
  final double roi; // e.g. 1976.9
  final double spent;
  final double total;

  const CampaignCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.channel,
    required this.budgetUsed,
    required this.impressions,
    required this.ctr,
    required this.roi,
    required this.spent,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey7),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.campaign, color: Colors.purple),
          ),
          const SizedBox(width: 12),

          // Middle content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and badges
                Row(
                  spacing: 10,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey4),
                        // color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        channel,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 100,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: budgetUsed,
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade300,
                              valueColor:
                                  const AlwaysStoppedAnimation(Colors.black87),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${(budgetUsed * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    _buildStat('Impressions', impressions.toString()),
                    _buildStat('CTR', '${ctr.toStringAsFixed(1)}%'),
                    _buildStat(
                      'ROI',
                      '${roi.toStringAsFixed(1)}%',
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Right side amount + icons
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₦${spent.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'of ₦${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.bar_chart_outlined, size: 20),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_red_eye_outlined, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}

class LeadCard extends StatelessWidget {
  const LeadCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey7),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        spacing: 10,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue.shade100,
                child: const Text(
                  'AJ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Middle Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Chips
                    Row(
                      spacing: 10,
                      children: [
                        const Text(
                          'Adebayo Johnson',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.purple.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Text(
                            "Qualified",
                            style: TextStyle(
                              color: Colors.purple,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Chip(
                          label: Text('Score: 85'),
                          labelStyle: TextStyle(fontSize: 12),
                          backgroundColor: AppColors.white,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),

                    // Company
                    const Text(
                      'Johnson Properties Ltd',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Contact Info
                    const Row(
                      children: [
                        Icon(Icons.email_outlined,
                            size: 16, color: Colors.black54),
                        SizedBox(width: 4),
                        Text(
                          'adebayo.johnson@example.com',
                          style: TextStyle(color: Colors.black87, fontSize: 13),
                        ),
                        SizedBox(width: 12),
                        Icon(Icons.phone_outlined,
                            size: 16, color: Colors.black54),
                        SizedBox(width: 4),
                        Text(
                          '+234 803 123 4567',
                          style: TextStyle(color: Colors.black87, fontSize: 13),
                        ),
                        SizedBox(width: 12),
                        Icon(Icons.link_outlined,
                            size: 16, color: Colors.black54),
                        SizedBox(width: 4),
                        Text(
                          'LinkedIn',
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Tags
                  ],
                ),
              ),

              // Right Side
              Row(
                spacing: 10,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Column(
                    children: [
                      Text(
                        'LEAD-001',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '1/28/2025',
                        style: TextStyle(color: Colors.black45, fontSize: 12),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                          color: AppColors.black.withValues(alpha: 0.1)),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: const Icon(Icons.remove_red_eye_outlined),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.grey.shade200,
                ),
                child: const Text(
                  'Hot Lead',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.grey.shade200,
                ),
                child: const Text(
                  'Property Developer',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ContentCard extends StatelessWidget {
  const ContentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey7),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left icon
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE6FDF5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.photo_camera_outlined,
                color: Color(0xFF10B981)),
          ),
          const SizedBox(width: 12),

          // Center content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(
                  spacing: 10,
                  children: [
                    const Text(
                      "The Importance of Professional Land Surveying",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    _tagChip("Published"),
                    _tagChip("LinkedIn", color: AppColors.white),
                  ],
                ),
                const SizedBox(height: 4),

                const Text(
                  "Blog Post",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),

                Row(
                  children: [
                    _iconStat(Icons.visibility_outlined, "2340"),
                    const SizedBox(width: 12),
                    _iconStat(Icons.favorite_border, "124"),
                    const SizedBox(width: 12),
                    _iconStat(Icons.share_outlined, "18"),
                    const SizedBox(width: 12),
                    _iconStat(Icons.comment_outlined, "32"),
                  ],
                ),
              ],
            ),
          ),

          // Right side: Published date
          // Right Side
          Row(
            spacing: 10,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Column(
                children: [
                  Text(
                    'Published',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '1/28/2025',
                    style: TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border:
                      Border.all(color: AppColors.black.withValues(alpha: 0.1)),
                ),
                padding: const EdgeInsets.all(5),
                child: const Icon(Icons.remove_red_eye_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _iconStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  static Widget _tagChip(String text, {Color color = const Color(0xFFF3F4F6)}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey4),
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF4B5563),
        ),
      ),
    );
  }
}

class EventsCalendarWidget extends StatelessWidget {
  const EventsCalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistics Cards Row - Make scrollable on small screens
          LayoutBuilder(
            builder: (context, constraints) {
              // If screen is too narrow, make it scrollable
              if (constraints.maxWidth < 800) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 180,
                        child: _buildStatCard(
                          title: 'Total Events',
                          value: '3',
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 180,
                        child: _buildStatCard(
                          title: 'Confirmed',
                          value: '1',
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 180,
                        child: _buildStatCard(
                          title: 'Upcoming',
                          value: '0',
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 180,
                        child: _buildStatCard(
                          title: 'Total Registrations',
                          value: '443',
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // Normal responsive layout for larger screens
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total Events',
                          value: '3',
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Confirmed',
                          value: '1',
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Upcoming',
                          value: '0',
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total Registrations',
                          value: '443',
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 32),

          // Calendar Section - Make scrollable
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grey7),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Events Calendar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Manage your marketing events and activities',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 24),

                // Table Container - Horizontal scroll for small screens
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Minimum width needed for the table to look good
                    const double minTableWidth = 900;

                    if (constraints.maxWidth < minTableWidth) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: minTableWidth,
                          child: _buildTableContent(),
                        ),
                      );
                    } else {
                      return _buildTableContent();
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTableContent() {
    return Column(
      children: [
        // Table Header
        const Row(
          children: [
            Expanded(flex: 3, child: _TableHeader(text: 'Event')),
            Expanded(flex: 2, child: _TableHeader(text: 'Type')),
            Expanded(flex: 2, child: _TableHeader(text: 'Date')),
            Expanded(flex: 2, child: _TableHeader(text: 'Status')),
            Expanded(flex: 2, child: _TableHeader(text: 'Registrations')),
            Expanded(flex: 2, child: _TableHeader(text: 'Actions')),
          ],
        ),
        kSizedBox,
        _buildDivider(),

        // Table Rows
        _buildTableRow(
          event: 'Nigeria Construction & Real Estate Expo 2024',
          location: 'Landmark Centre, Lagos',
          type: 'Trade Show',
          date: '15/04/2024',
          status: 'Confirmed',
          registrations: '156/200',
          percentage: '78.0% full',
          statusColor: AppColors.white,
          statusBgColor: AppColors.black,
        ),
        _buildDivider(),
        _buildTableRow(
          event: 'Webinar: Future of Surveying Technology',
          location: 'Online (Zoom)',
          type: 'Webinar',
          date: '20/02/2024',
          status: 'Completed',
          registrations: '287/500',
          percentage: '57.4% full',
          statusColor: AppColors.black,
          statusBgColor: AppColors.grey5,
        ),
        _buildDivider(),
        _buildTableRow(
          event: 'University Engineering Career Fair',
          location: 'University of Lagos',
          type: 'Career Fair',
          date: '10/05/2024',
          status: 'Planning',
          registrations: '0/100',
          percentage: '0.0% full',
          statusColor: AppColors.black,
          statusBgColor: AppColors.white,
          statusBorderColor: AppColors.grey4,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow({
    required String event,
    required String location,
    required String type,
    required String date,
    required String status,
    required String registrations,
    required String percentage,
    required Color statusColor,
    required Color statusBgColor,
    Color? statusBorderColor,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        borderRadius: isLast
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Event Column
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Type Column
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey4),
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.white,
                    ),
                    child: Text(
                      type,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF374151),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Date Column
          Expanded(
            flex: 2,
            child: Text(
              date,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
              ),
            ),
          ),

          // Status Column
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      border:
                          Border.all(color: statusBorderColor ?? statusBgColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Registrations Column
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  registrations,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  percentage,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // Actions Column
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildActionButton(Icons.visibility_outlined),
                const SizedBox(width: 8),
                _buildActionButton(Icons.edit_outlined),
                const SizedBox(width: 8),
                _buildActionButton(Icons.calendar_month_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Icon(
        icon,
        size: 16,
        color: const Color(0xFF6B7280),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.grey7,
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;

  const _TableHeader({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
        letterSpacing: 0.5,
      ),
    );
  }
}

class AnalyticsDashboard extends StatelessWidget {
  const AnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top metrics row
        Row(
          children: [
            Expanded(
                child: _buildMetricCard('3', 'Active Reports', Colors.blue)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildMetricCard('266.7%', 'Avg ROI', Colors.green)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildMetricCard(
                    '₦2,150,000.00', 'Total Revenue', Colors.orange)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildMetricCard(
                    '₦465,000.00', 'Total Spent', Colors.purple)),
          ],
        ),
        const SizedBox(height: 32),
        // Bottom section
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campaign Performance section
            Expanded(
              child: _buildCampaignPerformance(),
            ),
            const SizedBox(width: 32),
            // Lead Generation Trends section
            Expanded(
              child: _buildLeadGenerationTrends(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey7),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignPerformance() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Campaign Performance',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 24),
          _buildCampaignItem(
            'Q1 2024 Lead Generation',
            'Email Marketing',
            '567.0% ROI',
            '85 leads',
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildCampaignItem(
            'Brand Awareness - Social Media',
            'Social Media',
            '233.0% ROI',
            '100 leads',
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildCampaignItem(
            'Government Sector Outreach',
            'Direct Mail',
            '0.0% ROI',
            '0 leads',
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignItem(
      String title, String channel, String roi, String leads, Color roiColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey7, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Text(
                roi,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: roiColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                channel,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              Text(
                leads,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeadGenerationTrends() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lead Generation Trends',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 24),
          _buildTrendItem('Email Marketing', 85, AppColors.blue, 0.85),
          const SizedBox(height: 16),
          _buildTrendItem('Social Media', 100, AppColors.green, 1.0),
          const SizedBox(height: 16),
          _buildTrendItem('Direct Mail', 0, AppColors.grey7, 0.0),
        ],
      ),
    );
  }

  Widget _buildTrendItem(
      String channel, int leads, Color color, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              channel,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
              ),
            ),
            Row(
              spacing: 10,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$leads leads',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                Container(
                  height: 8,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppColors.grey7,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }
}
