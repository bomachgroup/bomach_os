import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

class OperationsPage extends StatefulWidget {
  const OperationsPage({super.key});

  @override
  State<OperationsPage> createState() => _OperationsPageState();
}

class _OperationsPageState extends State<OperationsPage> {
  int _selectedTab = 0;

  final List<Map<String, dynamic>> projects = [
    {
      'title': 'Lekki Residential Development Phase 2',
      'client': 'Lagos Property Development Ltd',
      'service': 'Land Surveying',
      'budget': '₦2,500,000.00',
      'progress': 33,
      'startDate': '15 Jan 2024',
      'endDate': '15 Mar 2024',
      'location': 'Lekki Phase 2, Lagos State',
      'status': 'In Progress',
      'priority': 'High',
    },
    {
      'title': 'Abuja Highway Expansion Project',
      'client': 'Federal Ministry of Works',
      'service': 'Topographic Survey',
      'budget': '₦2,500,000.00',
      'progress': 33,
      'startDate': '15 Jan 2024',
      'endDate': '15 Mar 2024',
      'location': 'Lekki Phase 2, Lagos State',
      'status': 'In Progress',
      'priority': 'High',
    },
    {
      'title': 'Port Harcourt Industrial Estate Survey',
      'client': 'Rivers State Development Authority',
      'service': 'Environmental Impact Assessment',
      'budget': '₦2,500,000.00',
      'progress': 33,
      'startDate': '15 Jan 2024',
      'endDate': '15 Mar 2024',
      'location': 'Lekki Phase 2, Lagos State',
      'status': 'In Progress',
      'priority': 'High',
    },
    // Duplicate for second row
    {
      'title': 'Lekki Residential Development Phase 2',
      'client': 'Lagos Property Development Ltd',
      'service': 'Land Surveying',
      'budget': '₦2,500,000.00',
      'progress': 33,
      'startDate': '15 Jan 2024',
      'endDate': '15 Mar 2024',
      'location': 'Lekki Phase 2, Lagos State',
      'status': 'In Progress',
      'priority': 'High',
    },
    {
      'title': 'Abuja Highway Expansion Project',
      'client': 'Federal Ministry of Works',
      'service': 'Topographic Survey',
      'budget': '₦2,500,000.00',
      'progress': 33,
      'startDate': '15 Jan 2024',
      'endDate': '15 Mar 2024',
      'location': 'Lekki Phase 2, Lagos State',
      'status': 'In Progress',
      'priority': 'High',
    },
    {
      'title': 'Port Harcourt Industrial Estate Survey',
      'client': 'Rivers State Development Authority',
      'service': 'Environmental Impact Assessment',
      'budget': '₦2,500,000.00',
      'progress': 33,
      'startDate': '15 Jan 2024',
      'endDate': '15 Mar 2024',
      'location': 'Lekki Phase 2, Lagos State',
      'status': 'In Progress',
      'priority': 'High',
    },
  ];

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
                        'Operations',
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
                    child: "Add Project",
                    onTap: () {},
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
        if (_selectedTab == 0) _projects(),
        if (_selectedTab == 1) _tasks(),
        if (_selectedTab == 2) _worksites(),
        if (_selectedTab == 3) _contracts(),
        if (_selectedTab == 4) _timelines(),
      ],
    );
  }

  Widget _projects() {
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
                      Text('Projects',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w600)),
                      SizedBox(height: 8),
                      Text('Manage your service offerings and pricing',
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

        // Project Grid
        LayoutBuilder(builder: (context, constraints) {
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
            children: projects
                .map((project) => SizedBox(
                      width: cardWidth,
                      child: ProjectCard(
                        title: project['title']!,
                        client: project['client']!,
                        service: project['service']!,
                        budget: project['budget']!,
                        progress: project['progress']!,
                        startDate: project['startDate']!,
                        endDate: project['endDate']!,
                        location: project['location']!,
                        status: project['status']!,
                        priority: project['priority']!,
                      ),
                    ))
                .toList(),
          );
        }),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _tasks() {
    final List<Map<String, dynamic>> tasks = [
      {
        'title': 'Initial Site Reconnaissance',
        'description':
            'Conduct preliminary site visit to assess terrain and access points',
        'dueDate': '20 Jan 2024',
        'assignedTo': 'John Doe',
        'estimatedHours': '16h',
        'status': 'Completed',
        'priority': 'High',
      },
      {
        'title': 'Topographic Data Collection',
        'description':
            'Collect detailed topographic data using total station and GPS',
        'dueDate': '28 Feb 2024',
        'assignedTo': 'Ahmed Bello',
        'estimatedHours': '32h',
        'status': 'Pending',
        'priority': 'Medium',
      },
      {
        'title': 'Boundary Survey and Marking',
        'description':
            'Survey and mark all property boundaries with permanent markers',
        'dueDate': '15 Feb 2024',
        'assignedTo': 'Jane Smith',
        'estimatedHours': '40h',
        'status': 'In Progress',
        'priority': 'High',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tasks Header
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
                      Text('Tasks',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w600)),
                      SizedBox(height: 8),
                      Text('Manage project tasks and assignments',
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
                        child: 'Add Task',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Tasks List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskCard(
              title: task['title']!,
              description: task['description']!,
              dueDate: task['dueDate']!,
              assignedTo: task['assignedTo']!,
              estimatedHours: task['estimatedHours']!,
              status: task['status']!,
              priority: task['priority']!,
            );
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _worksites() {
    final List<Map<String, dynamic>> worksites = [
      {
        'title': 'Lekki Phase 2 Survey Base',
        'location': 'Block A, Lekki Phase 2, Lagos',
        'description': 'Site accessible 6 AM to 7 PM. Security guard on duty.',
        'status': 'Active',
      },
      {
        'title': 'Abuja Highway Station 1',
        'location': 'KM 25, Abuja-Kaduna Highway',
        'description':
            'Heavy traffic area - safety protocols strictly enforced',
        'status': 'Setup',
      },
      {
        'title': 'Port Harcourt Industrial Site Office',
        'location': 'Trans-Amadi Industrial Lay...',
        'description': 'Project completed successfully. Equipment relocated.',
        'status': 'Completed',
      },
      // Duplicate for second row
      {
        'title': 'Lekki Phase 2 Survey Base',
        'location': 'Block A, Lekki Phase 2, Lagos',
        'description': 'Site accessible 6 AM to 7 PM. Security guard on duty.',
        'status': 'Active',
      },
      {
        'title': 'Abuja Highway Station 1',
        'location': 'KM 25, Abuja-Kaduna Highway',
        'description':
            'Heavy traffic area - safety protocols strictly enforced',
        'status': 'Setup',
      },
      {
        'title': 'Port Harcourt Industrial Site Office',
        'location': 'Trans-Amadi Industrial Lay...',
        'description': 'Project completed successfully. Equipment relocated.',
        'status': 'Completed',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Worksites Header
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
                      Text('Tasks',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w600)),
                      SizedBox(height: 8),
                      Text('Manage project tasks and assignments',
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
                        child: 'Add Worksite',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Worksites Grid
        LayoutBuilder(builder: (context, constraints) {
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
            children: worksites
                .map((worksite) => SizedBox(
                      width: cardWidth,
                      child: WorksiteCard(
                        title: worksite['title']!,
                        location: worksite['location']!,
                        description: worksite['description']!,
                        status: worksite['status']!,
                      ),
                    ))
                .toList(),
          );
        }),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _contracts() {
    final List<Map<String, dynamic>> tasks = [
      {
        'title': 'Federal Highways Consulting',
        'description': 'CON-2024-001',
        'startDate': '11 Jan 2024',
        'endDate': '20 Jan 2024',
        'value': '₦800,000.00',
        'status': 'Completed',
        'position': 'Specialist',
      },
      {
        'title': 'Elite Survey Solutions Ltd',
        'description': 'CON-2024-009',
        'startDate': '11 Jan 2024',
        'endDate': '28 Feb 2024',
        'value': '₦800,000.00',
        'status': 'Pending',
        'position': 'Project Management',
      },
      {
        'title': 'Northern Construction Management',
        'description': 'CON-2024-005',
        'startDate': '11 Jan 2024',
        'endDate': '15 Feb 2024',
        'value': '₦800,000.00',
        'status': 'In Progress',
        'position': 'Specialist',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tasks Header
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
                      Text('Contracts',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w600)),
                      SizedBox(height: 8),
                      Text('Manage project contracts and agreements',
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
                        child: 'Add Contract',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Tasks List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return ContractCard(
              title: task['title']!,
              description: task['description']!,
              startDate: task['startDate']!,
              endDate: task['endDate']!,
              value: task['value']!,
              status: task['status']!,
              position: task['position']!,
            );
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _timelines() {
    final List<Map<String, dynamic>> tasks = [
      {
        'title': 'Site Preparation',
        'description': 'Detailed topographic survey and mapping',
        'startDate': '15 Jan 2024',
        'endDate': '20 Jan 2024',
        'status': 'Completed',
      },
      {
        'title': 'Boundary Survey',
        'description': 'Survey and marking of all property boundaries',
        'startDate': '28 Feb 2024',
        'endDate': '20 Jan 2024',
        'status': 'Pending',
      },
      {
        'title': 'Boundary Survey and Marking',
        'description': 'Detailed topographic survey and mapping',
        'startDate': '15 Feb 2024',
        'endDate': '20 Jan 2024',
        'status': 'In Progress',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tasks Header
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
                      Text('Project Timelines',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w600)),
                      SizedBox(height: 8),
                      Text('Manage project contracts and agreements',
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
                        child: 'Add Timelines',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Tasks List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TimelineCard(
              title: task['title']!,
              description: task['description']!,
              endDate: task['endDate']!,
              startDate: task['startDate']!,
              status: task['status']!,
            );
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildTopStats(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {'label': 'Active Projects', 'count': '452', 'icon': Icons.folder_open},
      {
        'label': 'Total Budget',
        'count': '₦34,000,000.00',
        'icon': Icons.account_balance_wallet
      },
      {'label': 'Total Tasks', 'count': '2', 'icon': Icons.task_alt},
      {'label': 'Worksites', 'count': '4', 'icon': Icons.location_on},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        if (width > 900) {
          return Row(
            spacing: 18,
            children: items
                .map((it) => Expanded(
                      child: OperationsStatsCard(
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
                    child: OperationsStatsCard(
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
      'Projects (5)',
      'Tasks (6)',
      'Worksites (4)',
      'Contracts (6)',
      'Timelines (6)',
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

class TaskCard extends StatelessWidget {
  final String title;
  final String description;
  final String dueDate;
  final String assignedTo;
  final String estimatedHours;
  final String status;
  final String priority;

  const TaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.assignedTo,
    required this.estimatedHours,
    required this.status,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey;
    Color statusBgColor = Colors.grey.shade100;

    switch (status) {
      case 'Completed':
        statusColor = Colors.white;
        statusBgColor = Colors.black;
        break;
      case 'In Progress':
        statusColor = Colors.white;
        statusBgColor = Colors.black;
        break;
      case 'Pending':
        statusColor = Colors.black87;
        statusBgColor = Colors.grey.shade200;
        break;
    }

    Color priorityColor = Colors.grey;
    switch (priority) {
      case 'High':
        priorityColor = Colors.red;
        break;
      case 'Medium':
        priorityColor = Colors.orange;
        break;
      case 'Low':
        priorityColor = Colors.green;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Status
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    kSizedBoxWidthSM,
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: priorityColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        priority,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                // Due date, assigned to, estimated hours
                Row(
                  children: [
                    Text(
                      'Due: $dueDate',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      'Assigned: $assignedTo',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      'Est: $estimatedHours',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right Action Icons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border:
                      Border.all(color: AppColors.black.withValues(alpha: 0.1)),
                ),
                padding: const EdgeInsets.all(5),
                constraints: const BoxConstraints(),
                child: const Icon(Icons.remove_red_eye_outlined),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border:
                      Border.all(color: AppColors.black.withValues(alpha: 0.1)),
                ),
                padding: const EdgeInsets.all(5),
                constraints: const BoxConstraints(),
                child: const Icon(Icons.play_arrow_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WorksiteCard extends StatelessWidget {
  final String title;
  final String location;
  final String description;
  final String status;

  const WorksiteCard({
    super.key,
    required this.title,
    required this.location,
    required this.description,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.white;
    Color statusBgColor = Colors.grey.shade300;

    switch (status) {
      case 'Active':
        statusColor = Colors.white;
        statusBgColor = Colors.black;
        break;
      case 'Completed':
        statusColor = Colors.white;
        statusBgColor = Colors.black;
        break;
      case 'Setup':
        statusColor = Colors.black87;
        statusBgColor = Colors.grey.shade300;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Location with icon
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 16,
                color: Colors.black54,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.remove_red_eye, size: 16),
                  label: const Text('View'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                    foregroundColor: Colors.black87,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                    foregroundColor: Colors.black87,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OperationsStatsCard extends StatelessWidget {
  final String label;
  final String count;
  final IconData icon;

  const OperationsStatsCard({
    super.key,
    required this.label,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 200, minHeight: 120),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.blue.withValues(alpha: 0.12),
            radius: 16,
            child: Icon(icon, color: AppColors.blue, size: 18),
          ),
          const SizedBox(height: 16),
          Text(
            count,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final String title;
  final String client;
  final String service;
  final String budget;
  final int progress;
  final String startDate;
  final String endDate;
  final String location;
  final String status;
  final String priority;

  const ProjectCard({
    super.key,
    required this.title,
    required this.client,
    required this.service,
    required this.budget,
    required this.progress,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.status,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      priority,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Client
          Text(
            client,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Service badge
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              service,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Budget and Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Budget:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              Text(
                budget,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              Text(
                '$progress%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.blue),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 16),

          // Dates
          Row(
            children: [
              Text(
                'Start: $startDate',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'End: $endDate',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Location
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 14,
                color: Colors.black54,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.remove_red_eye, size: 16),
                  label: const Text('View'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                    foregroundColor: Colors.black87,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                    foregroundColor: Colors.black87,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ContractCard extends StatelessWidget {
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final String status;
  final String position;
  final String value;

  const ContractCard({
    super.key,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.position,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.black87;
    Color statusBgColor = Colors.grey.shade100;

    switch (status) {
      case 'Completed':
        statusColor = Colors.white;
        statusBgColor = Colors.black;
        break;
      case 'Active':
        statusColor = Colors.white;
        statusBgColor = Colors.black;
        break;
      case 'Pending':
        statusColor = Colors.black87;
        statusBgColor = Colors.grey.shade200;
        break;
      case 'On Hold':
        statusColor = Colors.black87;
        statusBgColor = Colors.grey.shade200;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Status
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    kSizedBoxWidthSM,
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.black.withValues(alpha: 0.1)),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        position,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Text(
                      'Value: $value',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      'Start: $startDate',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      'End: $endDate',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right Action Icons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border:
                      Border.all(color: AppColors.black.withValues(alpha: 0.1)),
                ),
                padding: const EdgeInsets.all(5),
                constraints: const BoxConstraints(),
                child: const Icon(Icons.remove_red_eye_outlined),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border:
                      Border.all(color: AppColors.black.withValues(alpha: 0.1)),
                ),
                padding: const EdgeInsets.all(5),
                constraints: const BoxConstraints(),
                child: const Icon(Icons.edit_note_sharp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TimelineCard extends StatelessWidget {
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final String status;

  const TimelineCard({
    super.key,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.black87;
    Color statusBgColor = Colors.grey.shade100;

    switch (status) {
      case 'Completed':
        statusColor = Colors.white;
        statusBgColor = Colors.black;
        break;
      case 'Active':
        statusColor = Colors.white;
        statusBgColor = Colors.black;
        break;
      case 'Pending':
        statusColor = Colors.black87;
        statusBgColor = Colors.grey.shade200;
        break;
      case 'On Hold':
        statusColor = Colors.black87;
        statusBgColor = Colors.grey.shade200;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Status
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    kSizedBoxWidthSM,
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Text(
                      'Start: $startDate',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      'End: $endDate',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right Action Icons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border:
                      Border.all(color: AppColors.black.withValues(alpha: 0.1)),
                ),
                padding: const EdgeInsets.all(5),
                constraints: const BoxConstraints(),
                child: const Icon(Icons.remove_red_eye_outlined),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border:
                      Border.all(color: AppColors.black.withValues(alpha: 0.1)),
                ),
                padding: const EdgeInsets.all(5),
                constraints: const BoxConstraints(),
                child: const Icon(Icons.edit_note_sharp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
