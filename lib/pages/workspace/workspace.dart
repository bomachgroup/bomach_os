import 'package:bms_front_end/components/cards/stats_header.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/workspace_controller.dart';

class WorkspacePage extends StatefulWidget {
  const WorkspacePage({super.key});

  @override
  State<WorkspacePage> createState() => _WorkspacePageState();
}

class _WorkspacePageState extends State<WorkspacePage> {
  final WorkspaceController _controller = Get.put(WorkspaceController());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        const Row(
          children: [
            Expanded(
              child: Column(
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
            ),
          ],
        ),
        kSizedBox,

        // Stats Cards
        _buildTopStats(context),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey7),
            borderRadius: BorderRadius.circular(15),
            color: AppColors.white,
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                "Active Projects",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              kSizedBox,
              MyText(
                "Current project workspaces",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                ),
              ),
              kSizedBox,
              _ProjectCard(),
              kSizedBox,
              _ProjectCard(),
            ],
          ),
        ),

        kSizedBox,

        const RecentCommunicationWidget(),
      ],
    );
  }

  Widget _buildTopStats(BuildContext context) {
    return Obx(() {
      final List<Map<String, dynamic>> items = [
        {'label': 'Projects', 'count': '—', 'icon': Icons.folder_outlined},
        {
          'label': 'Meetings',
          'count': _controller.totalMeetings.value.toString(),
          'icon': Icons.groups_outlined
        },
        {
          'label': 'Documents',
          'count': '—',
          'icon': Icons.description_outlined
        },
        {'label': 'Team Members', 'count': '—', 'icon': Icons.people_outline},
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
    });
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey7),
        borderRadius: BorderRadius.circular(15),
        color: AppColors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    const MyText(
                      "Commercial Complex Survey",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const MyText(
                        "Active",
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const MyText(
                        "High",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  ],
                ),
                kSizedBoxTiny,
                const Row(
                  spacing: 10,
                  children: [
                    MyText(
                      "3 members",
                      style: TextStyle(
                        color: AppColors.grey2,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    MyText(
                      "2 files",
                      style: TextStyle(
                        color: AppColors.grey2,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    MyText(
                      "1 pending tasks",
                      style: TextStyle(
                        color: AppColors.grey2,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                kSizedBoxSM,
                LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  return Container(
                    width: constraints.maxWidth,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.grey7,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.60,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              spacing: 10,
              children: [
                Icon(Icons.remove_red_eye_outlined),
                MyText(
                  "Open",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecentCommunicationWidget extends StatelessWidget {
  const RecentCommunicationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey7),
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Recent Communication',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Latest messages and updates',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Communication Items
          ListView(
            shrinkWrap: true,
            children: const [
              CommunicationItem(
                initials: 'JM',
                name: 'John Manager',
                tag: '#general',
                time: '17 Aug, 18:49',
                message: 'Good morning team! Ready for another productive day.',
                hasAttachment: false,
              ),
              SizedBox(height: 24),
              CommunicationItem(
                initials: 'MS',
                name: 'Mike Surveyor',
                tag: '#general',
                time: '17 Aug, 16:49',
                message:
                    'The new survey equipment has arrived and is ready for deployment.',
                hasAttachment: true,
              ),
              SizedBox(height: 24),
              CommunicationItem(
                initials: 'JM',
                name: 'John Manager',
                tag: '#project-updates',
                time: '17 Aug, 14:49',
                message:
                    'Commercial Complex Survey project is 65% complete. Field work wrapping up this week.',
                hasAttachment: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CommunicationItem extends StatelessWidget {
  final String initials;
  final String name;
  final String tag;
  final String time;
  final String message;
  final bool hasAttachment;

  const CommunicationItem({
    super.key,
    required this.initials,
    required this.name,
    required this.tag,
    required this.time,
    required this.message,
    required this.hasAttachment,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.black2,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with name, tag, and time
              Row(
                spacing: 10,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[900],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Message
              Text(
                message,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[800],
                  height: 1.4,
                ),
              ),

              // Attachment indicator
              if (hasAttachment) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.attach_file,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '1 attachment',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
