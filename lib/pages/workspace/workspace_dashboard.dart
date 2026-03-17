import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/cards/stats_header.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/workspace/widget/add_project_workspace_dialog.dart';
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
        if (_selectedTab == 1) _communication(),
        if (_selectedTab == 2) _document(),
        if (_selectedTab == 3) _meeting(),
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
                              return const AddProjectWorkspaceDialog();
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
            if (maxWidth > 1200) {
              columns = 2;
            } else if (maxWidth > 900)
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

  Widget _communication() {
    return const ChatSection();
  }

  Widget _document() {
    return const SharedDocumentsSection();
  }

  Widget _meeting() {
    final List<Map<String, dynamic>> meetings = [
      {
        'date': '14 Aug 2025',
        'time': '20:49',
        'title': 'Client Progress Update',
        'subtitle': 'Commercial Complex Survey',
        'duration': '45 minutes',
        'attendees': '1 attendees',
        'status': 'Completed',
        'hasRecording': true,
      },
      {
        'date': '18 Aug 2025',
        'time': '20:49',
        'title': 'Weekly Project Review',
        'subtitle': 'Commercial Complex Survey',
        'duration': '60 minutes',
        'attendees': '3 attendees',
        'status': 'Scheduled',
        'hasRecording': false,
      },
      {
        'date': '20 Aug 2025',
        'time': '20:49',
        'title': 'Government Stakeholder Meeting',
        'subtitle': 'Infrastructure Assessment',
        'duration': '90 minutes',
        'attendees': '1 attendees',
        'status': 'Scheduled',
        'hasRecording': false,
      },
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Meetings & Calls",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "Schedule and manage team meetings",
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          ...meetings.map((m) => MeetingCard(meeting: m)),
        ],
      ),
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

class SharedDocumentsSection extends StatelessWidget {
  const SharedDocumentsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> documents = [
      {
        "name": "Site Survey Report.pdf",
        "project": "Commercial Complex Survey",
        "version": "v1.0",
        "size": "2.0 MB",
        "uploadedBy": "Mike Surveyor",
        "date": "16 Aug 2025",
        "shared": true
      },
      {
        "name": "Project Drawings.dwg",
        "project": "Commercial Complex Survey",
        "version": "v2.1",
        "size": "15.0 MB",
        "uploadedBy": "Sarah Engineer",
        "date": "15 Aug 2025",
        "shared": false
      },
      {
        "name": "Client Requirements.docx",
        "project": "Commercial Complex Survey",
        "version": "v1.2",
        "size": "0.5 MB",
        "uploadedBy": "John Manager",
        "date": "14 Aug 2025",
        "shared": true
      },
      {
        "name": "Assessment Protocol.pdf",
        "project": "Infrastructure Assessment",
        "version": "v1.0",
        "size": "1.0 MB",
        "uploadedBy": "Sarah Engineer",
        "date": "15 Aug 2025",
        "shared": true
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Shared Documents",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "Access project documents and shared files",
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(documents.length, (index) {
              final doc = documents[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey7),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(
                        Icons.file_open_outlined,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc['name']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${doc['project']} • ${doc['version']} • ${doc['size']}",
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black54),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Uploaded by ${doc['uploadedBy']} on ${doc['date']}",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black45),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (doc['shared'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.grey5,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Shared",
                          style:
                              TextStyle(fontSize: 12, color: AppColors.black),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: AppColors.grey7),
                      ),
                      child: const Icon(Icons.file_download_outlined),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: AppColors.grey7),
                      ),
                      child: const Icon(Icons.share),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class MeetingCard extends StatelessWidget {
  final Map<String, dynamic> meeting;

  const MeetingCard({super.key, required this.meeting});

  @override
  Widget build(BuildContext context) {
    final isCompleted = meeting['status'] == 'Completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                meeting['date'],
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                meeting['time'],
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meeting['title'],
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  meeting['subtitle'],
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      "${meeting['duration']} • ${meeting['attendees']}",
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCompleted ? AppColors.blue : AppColors.grey7,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        meeting['status'],
                        style: TextStyle(
                          color:
                              isCompleted ? AppColors.white : AppColors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right button
          if (isCompleted)
            OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.black,
                iconColor: AppColors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                side: const BorderSide(color: AppColors.grey7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.remove_red_eye, size: 18),
              label: const Text("Recording", style: TextStyle(fontSize: 13)),
            )
          else
            ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.videocam_outlined,
                  size: 18, color: Colors.white),
              label: const Text("Join",
                  style: TextStyle(color: Colors.white, fontSize: 13)),
            ),
        ],
      ),
    );
  }
}

class ChatSection extends StatelessWidget {
  const ChatSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400, // Adjust height as needed

      child: Row(
        spacing: 20,
        children: [
          // Left sidebar - Channels
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            width: 300,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grey7),
            ),
            child: Column(
              children: [
                // Channels header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Channels',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        width: 35,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: AppColors.grey7),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                // Channel list
                Expanded(
                  child: ListView(
                    children: [
                      _buildChannelItem(
                        '#',
                        'general',
                        isSelected: true,
                      ),
                      const SizedBox(height: 4),
                      _buildChannelItem(
                        '#',
                        'project-updates',
                        hasNotification: true,
                        notificationCount: 1,
                        icon: Icons.push_pin,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Right side - Chat area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey7),
              ),
              child: Column(
                children: [
                  // Chat header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        const Text(
                          '#general',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Public',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          '3 members',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Messages area
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          _buildMessage(
                            avatarText: 'JM',
                            name: 'John Manager',
                            time: '17 Aug, 18:49',
                            message:
                                'Good morning team! Ready for another productive day.',
                            reactionCount: 2,
                          ),
                          const SizedBox(height: 20),
                          _buildMessage(
                            avatarText: 'MS',
                            name: 'Mike Surveyor',
                            time: '17 Aug, 16:49',
                            message:
                                'The new survey equipment has arrived and is ready for deployment.',
                            hasAttachment: true,
                            attachmentName: 'equipment-photo.jpg',
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Message input
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: MyTextFormField(
                            hintText: 'Message #general...',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.grey7),
                          ),
                          child: const Icon(
                            Icons.file_upload_outlined,
                            size: 20,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.blue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Send',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelItem(
    String prefix,
    String name, {
    bool isSelected = false,
    bool hasNotification = false,
    int notificationCount = 0,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.blue2.withValues(alpha: 0.1)
            : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppColors.blue2 : Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        minLeadingWidth: 2,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        leading: Text(
          prefix,
          style: const TextStyle(
            color: AppColors.grey4,
            fontSize: 12,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 6),
                    Icon(
                      icon,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                  ],
                ],
              ),
            ),
            if (hasNotification) ...[
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    notificationCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessage({
    required String avatarText,
    required String name,
    required String time,
    required String message,
    int? reactionCount,
    bool hasAttachment = false,
    String? attachmentName,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.grey5,
            borderRadius: BorderRadius.circular(36),
          ),
          child: Center(
            child: Text(
              avatarText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Message content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name and time
              Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Message text
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              if (hasAttachment) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.grey5,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.insert_drive_file,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        attachmentName ?? 'attachment',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.download,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ],
              if (reactionCount != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.favorite,
                        size: 12,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reactionCount.toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
