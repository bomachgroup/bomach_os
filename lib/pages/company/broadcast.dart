import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/section/responsive_widget.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/model/broadcast_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'controllers/broadcast_controller.dart';
import 'controllers/company_controller.dart';
import 'company.dart';
import 'widget/broadcast_announcement_dialogs.dart';
import 'widget/broadcast_event_dialogs.dart';

class BroadcastPage extends StatelessWidget {
  const BroadcastPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BroadcastController controller = Get.put(BroadcastController());
    final CompanyController companyController = Get.put(CompanyController());

    Widget body = SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const MyText('Broadcast', style: AppText.black_600_32),
          const SizedBox(height: 8),
          const Text(
              'Manage Announcements, Events, Notifications',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
          const SizedBox(height: 24),

          // Stats Row
          _buildStatsSection(companyController),

          const SizedBox(height: 32),

          // Tabs
          Obx(() => _buildTabBar(controller)),

          const SizedBox(height: 24),

          // Tab Content
          Obx(() {
            switch (controller.currentTab.value) {
              case 'Announcements':
                return _AnnouncementsTab(controller: controller);
              case 'Events':
                return _EventsTab(controller: controller);
              case 'Notifications':
                return _NotificationsTab(controller: controller);
              default:
                return const SizedBox.shrink();
            }
          }),
        ],
      ),
    );

    return ResponsiveWidget(
      largeScreen: body,
      mediumScreen: body,
      smallScreen: body,
    );
  }

  Widget _buildStatsSection(CompanyController companyController) {
    return Obx(() {
      final stats = companyController.dashboardStats.value;
      return ResponsiveStatRow(cards: [
        DashboardStatCard(
          title: 'Total Employees',
          count: stats != null ? '${stats.totalEmployees}' : '–',
          borderColor: Colors.green,
          countColor: Colors.green,
        ),
        DashboardStatCard(
          title: 'Total Branches',
          count: stats != null ? '${stats.totalBranches}' : '–',
          borderColor: const Color(0xFF1976D2),
          countColor: const Color(0xFF1976D2),
        ),
        DashboardStatCard(
          title: 'Pending Approvals',
          count: stats != null ? '${stats.pendingApprovals}' : '–',
          borderColor: const Color(0xFFC27803),
          countColor: const Color(0xFFC27803),
        ),
        DashboardStatCard(
          title: 'Asset Inventory',
          count: stats != null ? '${stats.assetInventory}' : '–',
          borderColor: Colors.green,
          countColor: Colors.green,
        ),
      ]);
    });
  }

  Widget _buildTabBar(BroadcastController controller) {
    final tabs = ['Announcements', 'Events', 'Notifications'];
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Wrap(
        spacing: 8,
        children: tabs.map((tab) {
          final isSelected = controller.currentTab.value == tab;
          return InkWell(
            onTap: () => controller.currentTab.value = tab,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tab,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ANNOUNCEMENTS TAB
// ═══════════════════════════════════════════════════════════════════

class _AnnouncementsTab extends StatelessWidget {
  final BroadcastController controller;
  const _AnnouncementsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subheader
        ResponsiveSubheader(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText('Announcement', style: AppText.black_600_16),
              SizedBox(height: 2),
              Text('Bomach Group of Companies',
                  style:
                      TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            ],
          ),
          search: MyTextFormField(
            hintText: 'Search',
            leading:
                const Icon(Icons.search, color: Colors.grey, size: 20),
            onChanged: controller.onAnnouncementSearchChanged,
          ),
          action: MyElevatedButton(
            height: 40,
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            child: 'New Announcement',
            onTap: () => showDialog(
              context: context,
              builder: (_) => const CreateEditAnnouncementDialog(),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Table
        Obx(() {
          if (controller.isLoadingAnnouncements.value &&
              controller.announcementList.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.announcementList.isEmpty) {
            return _buildEmptyState(
              context,
              icon: Icons.campaign_outlined,
              title: 'No announcements yet',
              subtitle: 'Create a new announcement to get started.',
              buttonLabel: 'New Announcement',
              onAdd: () => showDialog(
                context: context,
                builder: (_) => const CreateEditAnnouncementDialog(),
              ),
            );
          }

          return Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 40),
                      Expanded(
                        flex: 2,
                        child: Text('Title',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B))),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Publish Date',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B))),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text('Type',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B))),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Status',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B))),
                      ),
                      SizedBox(
                        width: 48,
                        child: Text('Action',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B))),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ...controller.announcementList
                    .map((a) => _buildAnnouncementRow(context, a)),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Obx(() => PaginatorFooter(
                        totalItems:
                            controller.announcementTotalItems.value,
                        limit: controller.announcementLimit.value,
                        currentPage:
                            controller.announcementCurrentPage.value,
                        onPageChanged: controller.announcementGoToPage,
                        onLimitChanged: controller.announcementSetLimit,
                      )),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAnnouncementRow(
      BuildContext context, Announcement announcement) {
    // Format date from publishAt
    String displayDate = '';
    String displayTime = '';
    try {
      final parsed = DateTime.parse(announcement.publishAt);
      displayDate = DateFormat('MMM d, yyyy').format(parsed);
      displayTime = DateFormat('h:mm a').format(parsed);
    } catch (_) {
      displayDate = announcement.publishAt;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Checkbox(
              value: false,
              onChanged: (_) {},
              activeColor: AppColors.blue,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              announcement.title,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayDate, style: const TextStyle(fontSize: 13)),
                if (displayTime.isNotEmpty)
                  Text(displayTime,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              announcement.announcementTypeDisplay,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildStatusBadge(
                announcement.isActive ? 'Active' : 'Inactive'),
          ),
          SizedBox(
            width: 48,
            child: _buildActionMenu(context, announcement),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'expired':
        color = Colors.grey;
        break;
      case 'inactive':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 7, color: color),
            const SizedBox(width: 5),
            Text(status,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context, Announcement announcement) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) async {
        switch (value) {
          case 'view':
            showDialog(
              context: context,
              builder: (_) =>
                  ViewAnnouncementDialog(announcement: announcement),
            );
            break;
          case 'edit':
            showDialog(
              context: context,
              builder: (_) => CreateEditAnnouncementDialog(
                  announcement: announcement),
            );
            break;
          case 'delete':
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (c) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                title: const Text('Delete Announcement'),
                content: Text(
                    'Are you sure you want to delete "${announcement.title}"?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red))),
                ],
              ),
            );
            if (confirmed == true && context.mounted) {
              controller.deleteAnnouncement(context, announcement.id);
            }
            break;
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(children: [
            Icon(Icons.visibility_outlined, size: 18, color: Colors.grey),
            SizedBox(width: 8),
            Text('View Details'),
          ]),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
            SizedBox(width: 8),
            Text('Edit'),
          ]),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline, size: 18, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete', style: TextStyle(color: Colors.red)),
          ]),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onAdd,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: const Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(subtitle,
                style:
                    const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            MyElevatedButton(
              child: buttonLabel,
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              onTap: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  EVENTS TAB
// ═══════════════════════════════════════════════════════════════════

class _EventsTab extends StatelessWidget {
  final BroadcastController controller;
  const _EventsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subheader
        ResponsiveSubheader(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText('Events', style: AppText.black_600_16),
              SizedBox(height: 2),
              Text('Bomach Group of Companies',
                  style:
                      TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            ],
          ),
          search: MyTextFormField(
            hintText: 'Search',
            leading:
                const Icon(Icons.search, color: Colors.grey, size: 20),
            onChanged: controller.onEventSearchChanged,
          ),
          action: MyElevatedButton(
            height: 40,
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            child: 'New Event',
            onTap: () => showDialog(
              context: context,
              builder: (_) => const CreateEditEventDialog(),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Table
        Obx(() {
          if (controller.isLoadingEvents.value &&
              controller.eventList.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.eventList.isEmpty) {
            return _buildEmptyState(
              context,
              icon: Icons.event_outlined,
              title: 'No events yet',
              subtitle: 'Create a new event to get started.',
              buttonLabel: 'Create Event',
              onAdd: () => showDialog(
                context: context,
                builder: (_) => const CreateEditEventDialog(),
              ),
            );
          }

          return Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 40),
                      Expanded(
                        flex: 2,
                        child: Text('Title',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B))),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Date Sent',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B))),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text('Audience',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B))),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Type',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B))),
                      ),
                      SizedBox(
                        width: 48,
                        child: Text('Action',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B))),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ...controller.eventList
                    .map((e) => _buildEventRow(context, e)),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Obx(() => PaginatorFooter(
                        totalItems: controller.eventTotalItems.value,
                        limit: controller.eventLimit.value,
                        currentPage: controller.eventCurrentPage.value,
                        onPageChanged: controller.eventGoToPage,
                        onLimitChanged: controller.eventSetLimit,
                      )),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEventRow(BuildContext context, BroadcastEvent event) {
    String displayDate = '';
    String displayTime = '';
    try {
      final parsed = DateTime.parse(event.eventTimeFrom);
      displayDate = DateFormat('MMM d, yyyy').format(parsed);
      displayTime = DateFormat('h:mm a').format(parsed);
    } catch (_) {
      displayDate = event.eventTimeFrom;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Checkbox(
              value: false,
              onChanged: (_) {},
              activeColor: AppColors.blue,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              event.title,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayDate, style: const TextStyle(fontSize: 13)),
                if (displayTime.isNotEmpty)
                  Text(displayTime,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: event.targetAudienceLabels
                  .map((a) => _buildAudienceChip(a))
                  .toList(),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              event.eventTypeDisplay,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 48,
            child: _buildActionMenu(context, event),
          ),
        ],
      ),
    );
  }

  Widget _buildAudienceChip(String label) {
    Color chipColor;
    if (label.contains('Branch')) {
      chipColor = Colors.green;
    } else {
      chipColor = AppColors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildActionMenu(BuildContext context, BroadcastEvent event) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) async {
        switch (value) {
          case 'view':
            showDialog(
              context: context,
              builder: (_) => ViewEventDialog(event: event),
            );
            break;
          case 'edit':
            showDialog(
              context: context,
              builder: (_) => CreateEditEventDialog(event: event),
            );
            break;
          case 'delete':
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (c) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                title: const Text('Delete Event'),
                content: Text(
                    'Are you sure you want to delete "${event.title}"?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red))),
                ],
              ),
            );
            if (confirmed == true && context.mounted) {
              controller.deleteEvent(context, event.id);
            }
            break;
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(children: [
            Icon(Icons.visibility_outlined, size: 18, color: Colors.grey),
            SizedBox(width: 8),
            Text('View Details'),
          ]),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
            SizedBox(width: 8),
            Text('Edit'),
          ]),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline, size: 18, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete', style: TextStyle(color: Colors.red)),
          ]),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onAdd,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: const Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(subtitle,
                style:
                    const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            MyElevatedButton(
              child: buttonLabel,
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              onTap: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  NOTIFICATIONS TAB
// ═══════════════════════════════════════════════════════════════════

class _NotificationsTab extends StatelessWidget {
  final BroadcastController controller;
  const _NotificationsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Notification Stats
        Obx(() => Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildNotificationStat(
                  icon: Icons.people_outline,
                  count: controller.unreadCount.value,
                  label: 'Notifications',
                ),
                _buildNotificationStat(
                  icon: Icons.people_outline,
                  count: controller.announcementTotalItems.value,
                  label: 'Announcements',
                ),
                _buildNotificationStat(
                  icon: Icons.people_outline,
                  count: controller.eventTotalItems.value,
                  label: 'Upcoming Events',
                ),
              ],
            )),
        const SizedBox(height: 20),

        // Filter chips + Mark All Read
        Row(
          children: [
            Expanded(
              child: Obx(() => Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChip(
                          'Admin', controller.notificationFilter.value),
                      _buildFilterChip(
                          'Staff', controller.notificationFilter.value),
                      _buildFilterChip(
                          'Associate', controller.notificationFilter.value),
                      _buildFilterChip(
                          'Investor', controller.notificationFilter.value),
                    ],
                  )),
            ),
            ElevatedButton(
              onPressed: controller.markAllRead,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Mark All Read',
                  style: TextStyle(color: Colors.white, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Notification List
        Obx(() {
          if (controller.filteredNotifications.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Text('No notifications',
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
              ),
            );
          }

          return Column(
            children: controller.filteredNotifications
                .map((n) => _buildNotificationCard(n))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildNotificationStat({
    required IconData icon,
    required int count,
    required String label,
  }) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.blue, size: 20),
          ),
          const SizedBox(height: 12),
          Text('$count',
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              style:
                  const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String activeFilter) {
    final isActive = activeFilter == label;
    return InkWell(
      onTap: () => controller
          .filterNotifications(isActive ? '' : label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isActive
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  notification.subtitle,
                  style: const TextStyle(
                      color: Color(0xFF64748B), fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.description,
                  style: const TextStyle(
                      color: Color(0xFF94A3B8), fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            notification.time,
            style:
                const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
