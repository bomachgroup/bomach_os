import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/cards/stats_header.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/marketing/widget/add_lead_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

class WorkspaceDashboardPage extends StatefulWidget {
  const WorkspaceDashboardPage({super.key});

  @override
  State<WorkspaceDashboardPage> createState() => _WorkspaceDashboardPageState();
}

class _WorkspaceDashboardPageState extends State<WorkspaceDashboardPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        const Row(
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 10,
                runSpacing: 10,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        'Virtual Workspace',
                        style: AppText.black_500_32,
                      ),
                      MyText(
                        'Collaborate with your team on projects and communicate effectively',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
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
        if (_selectedTab == 0) _project(),
        // if (_selectedTab == 1) _leads(),
        // if (_selectedTab == 2) _content(),
        // if (_selectedTab == 3) _event(),
      ],
    );
  }

  Widget _project() {
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
                      Text('Project Workspaces',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w600)),
                      SizedBox(height: 8),
                      Text('Manage collaborative project environments',
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
                        child: 'Add Project',
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

        LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth;
            int columns = 1;
            if (maxWidth > 1200)
              columns = 2;
            else if (maxWidth > 900)
              columns = 2;
            else if (maxWidth > 700)
              columns = 2;
            else
              columns = 1;

            double spacing = 18;
            double cardWidth = (maxWidth - (columns - 1) * spacing) / columns;

            return Wrap(
              runSpacing: spacing,
              spacing: spacing,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: const ProjectCard(
                    title: 'Infrastructure Assessment',
                    description:
                        'Road infrastructure condition assessment for Lagos State Government',
                    members: 2,
                    documents: 1,
                    tasks: '1 pending',
                    meetings: '1 upcoming',
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: const ProjectCard(
                    title: 'Infrastructure Assessment',
                    description:
                        'Road infrastructure condition assessment for Lagos State Government',
                    members: 2,
                    documents: 1,
                    tasks: '1 pending',
                    meetings: '1 upcoming',
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildTopStats(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {'label': 'Projects', 'count': '20', 'icon': Icons.person},
      {'label': 'Channels', 'count': '3', 'icon': Icons.person},
      {'label': 'Documents', 'count': '5', 'icon': Icons.person},
      {'label': 'Team Members', 'count': '4', 'icon': Icons.person},
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
      'Project',
      'Commuication',
      'Documents',
      'Meeting',
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

class ProjectCard extends StatelessWidget {
  final String title;
  final String description;
  final int members;
  final int documents;
  final String tasks;
  final String meetings;

  const ProjectCard({
    super.key,
    required this.title,
    required this.description,
    required this.members,
    required this.documents,
    required this.tasks,
    required this.meetings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and active badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),

            const SizedBox(height: 32),

            // Stats
            Column(
              children: [
                _buildStatRow('Members:', members.toString()),
                const SizedBox(height: 16),
                _buildStatRow('Documents:', documents.toString()),
                const SizedBox(height: 16),
                _buildStatRow('Tasks:', tasks),
                const SizedBox(height: 16),
                _buildStatRow('Meetings:', meetings),
              ],
            ),

            const SizedBox(height: 32),

            // Open Workspace Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(
                  Icons.laptop_mac,
                  size: 18,
                  color: Colors.grey[700],
                ),
                label: Text(
                  'Open Workspace',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

// For mobile responsive layout
class MobileProjectWorkspace extends StatelessWidget {
  const MobileProjectWorkspace({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F5F7),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              ProjectCard(
                title: 'Commercial Complex Survey',
                description:
                    'Comprehensive survey and mapping for new commercial development in Victoria Island',
                members: 3,
                documents: 3,
                tasks: '2 pending',
                meetings: '1 upcoming',
              ),
              SizedBox(height: 16),
              ProjectCard(
                title: 'Infrastructure Assessment',
                description:
                    'Road infrastructure condition assessment for Lagos State Government',
                members: 2,
                documents: 1,
                tasks: '1 pending',
                meetings: '1 upcoming',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
