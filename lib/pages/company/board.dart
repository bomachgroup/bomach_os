import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/section/responsive_widget.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/model/board_model.dart';
import 'package:bms_front_end/src/model/company_model.dart';
import 'package:bms_front_end/src/model/employees_model.dart';
import 'package:bms_front_end/src/model/partner_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'controllers/board_controller.dart';
import 'controllers/company_controller.dart';
import 'company.dart';
import 'widget/add_partner_dialog.dart';
import 'widget/add_shareholder_dialog.dart';
import 'widget/board_meeting_dialogs.dart';
import 'widget/board_resolution_dialogs.dart';

class BoardPage extends StatelessWidget {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BoardController controller = Get.put(BoardController());
    // Ensure CompanyController is available for stats
    final CompanyController companyController = Get.put(CompanyController());

    Widget body = SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const MyText('Board', style: AppText.black_600_32),
          const SizedBox(height: 8),
          const Text(
              'Manage Board meetings, Resolutions, Reports, Investors, Associates, and partners',
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
              case 'Meetings':
                return _MeetingsTab(controller: controller);
              case 'Resolutions':
                return _ResolutionsTab(controller: controller);
              case 'Investors':
                return _InvestorsTab(controller: controller);
              case 'Associates':
                return _AssociatesTab(controller: controller);
              case 'Partners':
                return _PartnersTab(controller: controller);
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
      return ResponsiveStatRow(
        cards: [
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
        ],
      );
    });
  }

  Widget _buildTabBar(BoardController controller) {
    final tabs = [
      'Meetings',
      'Resolutions',
      'Investors',
      'Associates',
      'Partners',
    ];
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
//  MEETINGS TAB
// ═══════════════════════════════════════════════════════════════════

class _MeetingsTab extends StatelessWidget {
  final BoardController controller;
  const _MeetingsTab({required this.controller});

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
              MyText('Meetings', style: AppText.black_600_16),
              SizedBox(height: 2),
              Text('Bomach Group of Companies',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            ],
          ),
          search: MyTextFormField(
            hintText: 'Search',
            leading: const Icon(Icons.search, color: Colors.grey, size: 20),
            onChanged: controller.onMeetingSearchChanged,
          ),
          action: MyElevatedButton(
            height: 40,
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            child: 'New Meeting',
            onTap: () => showDialog(
              context: context,
              builder: (_) => const ScheduleMeetingDialog(),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Table
        Obx(() {
          if (controller.isLoadingMeetings.value &&
              controller.meetingList.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.meetingList.isEmpty) {
            return _buildEmptyState(
              context,
              icon: Icons.event_outlined,
              title: 'No meetings scheduled',
              subtitle: 'Schedule a new meeting to get started.',
              buttonLabel: 'New Meeting',
              onAdd: () => showDialog(
                context: context,
                builder: (_) => const ScheduleMeetingDialog(),
              ),
            );
          }

          return ResponsiveTableWrapper(
            child: Card(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        flex: 3,
                        child: Text('Title',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B))),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Date & Time',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B))),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text('Agenda',
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
                // Rows
                ...controller.meetingList
                    .map((m) => _buildMeetingRow(context, m)),

                // Paginator
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Obx(() => PaginatorFooter(
                        totalItems: controller.meetingTotalItems.value,
                        limit: controller.meetingLimit.value,
                        currentPage: controller.meetingCurrentPage.value,
                        onPageChanged: controller.meetingGoToPage,
                        onLimitChanged: controller.meetingSetLimit,
                      )),
                ),
              ],
            ),
          ),
          );
        }),
      ],
    );
  }

  Widget _buildMeetingRow(BuildContext context, BoardMeeting meeting) {
    // Format date
    String displayDate = meeting.meetingDate;
    try {
      final parsed = DateTime.parse(meeting.meetingDate);
      displayDate = DateFormat('MMM d, yyyy').format(parsed);
    } catch (_) {}

    // Format time
    String displayTime = meeting.meetingTime;
    try {
      final parts = meeting.meetingTime.split(':');
      int h = int.parse(parts[0]);
      int min = int.parse(parts[1]);
      final period = h >= 12 ? 'PM' : 'AM';
      if (h > 12) h -= 12;
      if (h == 0) h = 12;
      displayTime = '$h:${min.toString().padLeft(2, '0')} $period';
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
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
            flex: 3,
            child: Text(
              meeting.title,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayDate,
                    style: const TextStyle(fontSize: 13)),
                if (meeting.meetingTime.isNotEmpty)
                  Text(displayTime,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              meeting.agenda,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildStatusBadge(meeting.statusDisplay),
          ),
          SizedBox(
            width: 48,
            child: _buildActionMenu(context, meeting),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'upcoming':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      case 'postponed':
        color = Colors.orange;
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
            Text(
              status,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context, BoardMeeting meeting) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) async {
        switch (value) {
          case 'view':
            showDialog(
              context: context,
              builder: (_) => ViewMeetingDialog(meeting: meeting),
            );
            break;
          case 'edit':
            showDialog(
              context: context,
              builder: (_) => ScheduleMeetingDialog(meeting: meeting),
            );
            break;
          case 'delete':
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (c) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                title: const Text('Cancel Meeting'),
                content: Text(
                    'Are you sure you want to cancel "${meeting.title}"?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('No')),
                  TextButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Yes, Cancel',
                          style: TextStyle(color: Colors.red))),
                ],
              ),
            );
            if (confirmed == true && context.mounted) {
              controller.cancelMeeting(context, meeting.id);
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
            Icon(Icons.close_outlined, size: 18, color: Colors.red),
            SizedBox(width: 8),
            Text('Cancel', style: TextStyle(color: Colors.red)),
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
//  RESOLUTIONS TAB
// ═══════════════════════════════════════════════════════════════════

class _ResolutionsTab extends StatelessWidget {
  final BoardController controller;
  const _ResolutionsTab({required this.controller});

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
              MyText('Resolutions', style: AppText.black_600_16),
              SizedBox(height: 2),
              Text('Bomach Group of Companies',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            ],
          ),
          search: MyTextFormField(
            hintText: 'Search',
            leading: const Icon(Icons.search, color: Colors.grey, size: 20),
            onChanged: controller.onResolutionSearchChanged,
          ),
          action: MyElevatedButton(
            height: 40,
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            child: 'New Resolution',
            onTap: () => showDialog(
              context: context,
              builder: (_) => const NewResolutionDialog(),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Table
        Obx(() {
          if (controller.isLoadingResolutions.value &&
              controller.resolutionList.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.resolutionList.isEmpty) {
            return _buildEmptyState(
              context,
              icon: Icons.gavel_outlined,
              title: 'No resolutions yet',
              subtitle: 'Create a new resolution to get started.',
              buttonLabel: 'New Resolution',
              onAdd: () => showDialog(
                context: context,
                builder: (_) => const NewResolutionDialog(),
              ),
            );
          }

          return ResponsiveTableWrapper(
            child: Card(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        flex: 3,
                        child: Text('Title',
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
                      Expanded(
                        flex: 2,
                        child: Text('Date',
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
                // Rows
                ...controller.resolutionList
                    .map((r) => _buildResolutionRow(context, r)),

                // Paginator
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Obx(() => PaginatorFooter(
                        totalItems: controller.resolutionTotalItems.value,
                        limit: controller.resolutionLimit.value,
                        currentPage: controller.resolutionCurrentPage.value,
                        onPageChanged: controller.resolutionGoToPage,
                        onLimitChanged: controller.resolutionSetLimit,
                      )),
                ),
              ],
            ),
          ),
          );
        }),
      ],
    );
  }

  Widget _buildResolutionRow(
      BuildContext context, BoardResolution resolution) {
    // Format date
    String displayDate = resolution.resolutionDate;
    try {
      final parsed = DateTime.parse(resolution.resolutionDate);
      displayDate = DateFormat('MMM d, yyyy').format(parsed);
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
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
            flex: 3,
            child: Text(
              resolution.title,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              resolution.resolutionTypeDisplay,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              displayDate,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildStatusBadge(resolution.statusDisplay),
          ),
          SizedBox(
            width: 48,
            child: _buildActionMenu(context, resolution),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      case 'archived':
        color = Colors.blueGrey;
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
            Text(
              status,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionMenu(
      BuildContext context, BoardResolution resolution) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) async {
        switch (value) {
          case 'view':
            showDialog(
              context: context,
              builder: (_) =>
                  ViewResolutionDialog(resolution: resolution),
            );
            break;
          case 'edit':
            showDialog(
              context: context,
              builder: (_) =>
                  NewResolutionDialog(resolution: resolution),
            );
            break;
          case 'delete':
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (c) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                title: const Text('Archive Resolution'),
                content: Text(
                    'Are you sure you want to archive "${resolution.title}"?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Archive',
                          style: TextStyle(color: Colors.red))),
                ],
              ),
            );
            if (confirmed == true && context.mounted) {
              controller.archiveResolution(context, resolution.id);
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
            Icon(Icons.archive_outlined, size: 18, color: Colors.red),
            SizedBox(width: 8),
            Text('Archive', style: TextStyle(color: Colors.red)),
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
//  INVESTORS TAB
// ═══════════════════════════════════════════════════════════════════

class _InvestorsTab extends StatelessWidget {
  final BoardController controller;
  const _InvestorsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    final companyCtrl = Get.find<CompanyController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Create button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText('Shareholders', style: AppText.black_600_16),
                SizedBox(height: 2),
                Text('Manage company shareholders and investors',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              ],
            ),
            MyElevatedButton(
              child: '+ Create Shareholder',
              onTap: () => showDialog(
                context: context,
                builder: (_) => const AddShareholderDialog(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Table
        Obx(() {
          if (companyCtrl.isShareholdersLoading.value &&
              companyCtrl.shareholders.isEmpty) {
            return const Center(
                child: Padding(
                    padding: EdgeInsets.all(60),
                    child: CircularProgressIndicator()));
          }

          if (companyCtrl.shareholders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                    child: const Icon(Icons.account_balance_outlined,
                        size: 48, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 20),
                  const Text('No shareholders found',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text('Add shareholders using the button above.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                ]),
              ),
            );
          }

          return ResponsiveTableWrapper(
            child: Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Column(children: [
                // Table Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12)),
                  ),
                  child: const Row(children: [
                    Expanded(
                        flex: 3,
                        child: Text('Name',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B)))),
                    Expanded(
                        flex: 3,
                        child: Text('Email',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B)))),
                    Expanded(
                        flex: 2,
                        child: Text('Title',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B)))),
                    Expanded(
                        flex: 1,
                        child: Text('Share %',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B)))),
                    Expanded(
                        flex: 1,
                        child: Text('Board',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B)))),
                    SizedBox(
                        width: 80,
                        child: Text('Action',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B)))),
                  ]),
                ),
                const Divider(height: 1),
                // Rows
                ...companyCtrl.shareholders
                    .map((s) => _buildShareholderRow(context, s, companyCtrl)),
              ]),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildShareholderRow(
      BuildContext context, Shareholder s, CompanyController ctrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(children: [
        Expanded(
          flex: 3,
          child: Row(children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE8EAF6),
              child: Text(s.firstName.isNotEmpty ? s.firstName[0] : '?',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 10),
            Flexible(
                child: Text(s.fullName,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis)),
          ]),
        ),
        Expanded(
            flex: 3,
            child: Text(s.email,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                overflow: TextOverflow.ellipsis)),
        Expanded(
            flex: 2,
            child: Text(s.titleDisplay,
                style:
                    const TextStyle(fontSize: 13, color: Color(0xFF64748B)))),
        Expanded(
            flex: 1,
            child: Text('${s.sharePercentage}%',
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        Expanded(
          flex: 1,
          child: Icon(
              s.isBoardMember ? Icons.check_circle : Icons.cancel_outlined,
              size: 18,
              color: s.isBoardMember ? Colors.green : Colors.grey.shade400),
        ),
        SizedBox(
          width: 80,
          child: Row(children: [
            InkWell(
              onTap: () => showDialog(
                context: context,
                builder: (_) => AddShareholderDialog(shareholder: s),
              ),
              child: const Icon(Icons.edit_outlined,
                  size: 18, color: Color(0xFF64748B)),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () => _confirmDelete(context, ctrl, s),
              child:
                  const Icon(Icons.delete_outline, size: 18, color: Colors.red),
            ),
          ]),
        ),
      ]),
    );
  }

  void _confirmDelete(
      BuildContext context, CompanyController ctrl, Shareholder s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Shareholder'),
        content: Text('Are you sure you want to remove ${s.fullName}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctrl.deleteShareholder(context, s.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ASSOCIATES TAB
// ═══════════════════════════════════════════════════════════════════

class _AssociatesTab extends StatelessWidget {
  final BoardController controller;
  const _AssociatesTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _EmployeeListTab(
      controller: controller,
      tabLabel: 'Associates',
      subtitle: 'Manage company associates',
      emptyIcon: Icons.people_outline,
      emptyTitle: 'No associates found',
      emptySubtitle: 'Associates will appear here once added.',
      isLoading: controller.isLoadingAssociates,
      employeeList: controller.associateList,
      totalItems: controller.associateTotalItems,
      limit: controller.associateLimit,
      currentPage: controller.associateCurrentPage,
      onSearchChanged: controller.onAssociateSearchChanged,
      onPageChanged: controller.associateGoToPage,
      onLimitChanged: controller.associateSetLimit,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  PARTNERS TAB — uses dedicated /api/v1/partners/ endpoints
// ═══════════════════════════════════════════════════════════════════

class _PartnersTab extends StatelessWidget {
  final BoardController controller;
  const _PartnersTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText('Partners', style: AppText.black_600_16),
                SizedBox(height: 2),
                Text('Manage company partners and agreements',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              ],
            ),
            Row(children: [
              SizedBox(
                width: 220,
                child: MyTextFormField(
                  hintText: 'Search partners...',
                  leading:
                      const Icon(Icons.search, color: Colors.grey, size: 20),
                  onChanged: controller.onPartnerSearchChanged,
                ),
              ),
              const SizedBox(width: 12),
              MyElevatedButton(
                child: '+ Add Partner',
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => const AddPartnerDialog(),
                ),
              ),
            ]),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoadingPartners.value &&
              controller.partnerList.isEmpty) {
            return const Center(
                child: Padding(
                    padding: EdgeInsets.all(60),
                    child: CircularProgressIndicator()));
          }

          if (controller.partnerList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                    child: const Icon(Icons.handshake_outlined,
                        size: 48, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 20),
                  const Text('No partners found',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text('Add partners using the button above.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                ]),
              ),
            );
          }

          return ResponsiveTableWrapper(
            child: Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Column(children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12)),
                  ),
                  child: const Row(children: [
                    Expanded(
                        flex: 3,
                        child: Text('Name',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B)))),
                    Expanded(
                        flex: 3,
                        child: Text('Email',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B)))),
                    Expanded(
                        flex: 2,
                        child: Text('Category',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B)))),
                    Expanded(
                        flex: 2,
                        child: Text('Status',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B)))),
                    Expanded(
                        flex: 1,
                        child: Text('Agreements',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B)))),
                    SizedBox(
                        width: 80,
                        child: Text('Action',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B)))),
                  ]),
                ),
                const Divider(height: 1),
                ...controller.partnerList
                    .map((p) => _buildPartnerRow(context, p)),
              ]),
            ),
          );
        }),
        const SizedBox(height: 16),
        Obx(() => PaginatorFooter(
              currentPage: controller.partnerCurrentPage.value,
              totalItems: controller.partnerTotalItems.value,
              limit: controller.partnerLimit.value,
              onPageChanged: controller.partnerGoToPage,
              onLimitChanged: controller.partnerSetLimit,
            )),
      ],
    );
  }

  Widget _buildPartnerRow(BuildContext context, Partner p) {
    final isActive = p.status == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(children: [
        Expanded(
          flex: 3,
          child: Row(children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE8EAF6),
              child: Text(p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 10),
            Flexible(
                child: Text(p.name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis)),
          ]),
        ),
        Expanded(
            flex: 3,
            child: Text(p.email,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                overflow: TextOverflow.ellipsis)),
        Expanded(
            flex: 2,
            child: Text(p.categoryDisplay,
                style:
                    const TextStyle(fontSize: 13, color: Color(0xFF64748B)))),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? Colors.green : Colors.grey)),
              const SizedBox(width: 6),
              Text(p.statusDisplay,
                  style: TextStyle(
                      fontSize: 12,
                      color: isActive ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.w500)),
            ]),
          ),
        ),
        Expanded(
            flex: 1,
            child: Text('${p.agreementCount}',
                style: const TextStyle(fontSize: 13))),
        SizedBox(
          width: 80,
          child: Row(children: [
            InkWell(
              onTap: () => showDialog(
                context: context,
                builder: (_) => AddPartnerDialog(partner: p),
              ),
              child: const Icon(Icons.edit_outlined,
                  size: 18, color: Color(0xFF64748B)),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () => _confirmDelete(context, p),
              child:
                  const Icon(Icons.delete_outline, size: 18, color: Colors.red),
            ),
          ]),
        ),
      ]),
    );
  }

  void _confirmDelete(BuildContext context, Partner p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Partner'),
        content: Text(
            'Are you sure you want to delete "${p.name}"? This will also delete all associated agreements.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.deletePartner(context, p.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SHARED EMPLOYEE LIST TAB (reused by Investors, Associates, Partners)
// ═══════════════════════════════════════════════════════════════════

class _EmployeeListTab extends StatelessWidget {
  final BoardController controller;
  final String tabLabel;
  final String subtitle;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final RxBool isLoading;
  final RxList<Employee> employeeList;
  final RxInt totalItems;
  final RxInt limit;
  final RxInt currentPage;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onLimitChanged;

  const _EmployeeListTab({
    required this.controller,
    required this.tabLabel,
    required this.subtitle,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.isLoading,
    required this.employeeList,
    required this.totalItems,
    required this.limit,
    required this.currentPage,
    required this.onSearchChanged,
    required this.onPageChanged,
    required this.onLimitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subheader
        ResponsiveSubheader(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(tabLabel, style: AppText.black_600_16),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      color: Color(0xFF64748B), fontSize: 13)),
            ],
          ),
          search: MyTextFormField(
            hintText: 'Search',
            leading:
                const Icon(Icons.search, color: Colors.grey, size: 20),
            onChanged: onSearchChanged,
          ),
        ),
        const SizedBox(height: 16),

        // Table
        Obx(() {
          if (isLoading.value && employeeList.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (employeeList.isEmpty) {
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
                      child: Icon(emptyIcon,
                          size: 48, color: const Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 20),
                    Text(emptyTitle,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(emptySubtitle,
                        style: const TextStyle(
                            color: Color(0xFF64748B), fontSize: 14),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }

          return ResponsiveTableWrapper(
            child: Card(
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
                      SizedBox(width: 48),
                      Expanded(
                        flex: 3,
                        child: Text('Name',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B))),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text('Email',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B))),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Phone',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF64748B))),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Department',
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
                // Rows
                ...employeeList
                    .map((e) => _buildEmployeeRow(context, e)),

                // Paginator
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Obx(() => PaginatorFooter(
                        totalItems: totalItems.value,
                        limit: limit.value,
                        currentPage: currentPage.value,
                        onPageChanged: onPageChanged,
                        onLimitChanged: onLimitChanged,
                      )),
                ),
              ],
            ),
          ),
          );
        }),
      ],
    );
  }

  Widget _buildEmployeeRow(BuildContext context, Employee employee) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.blue.withValues(alpha: 0.1),
              backgroundImage: employee.profilePicture != null &&
                      employee.profilePicture!.isNotEmpty &&
                      employee.profilePicture != 'string'
                  ? NetworkImage(employee.profilePicture!)
                  : null,
              child: employee.profilePicture == null ||
                      employee.profilePicture!.isEmpty ||
                      employee.profilePicture == 'string'
                  ? Text(
                      employee.firstName.isNotEmpty
                          ? employee.firstName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.fullName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                if (employee.role.isNotEmpty)
                  Text(
                    employee.role,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF64748B)),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              employee.email,
              style:
                  const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              employee.phoneNumber ?? '–',
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              employee.departmentName ?? '–',
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildStatusBadge(employee.isActive),
          ),
          SizedBox(
            width: 48,
            child: _buildActionMenu(context, employee),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    final color = isActive ? Colors.green : Colors.red;
    final label = isActive ? 'Active' : 'Inactive';

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
            Text(
              label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context, Employee employee) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        switch (value) {
          case 'view':
            _showViewDialog(context, employee);
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
      ],
    );
  }

  void _showViewDialog(BuildContext context, Employee employee) {
    // Format dates
    String joinDate = '–';
    if (employee.startDate != null) {
      joinDate = DateFormat('MMMM d, yyyy').format(employee.startDate!);
    }

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$tabLabel Details',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Profile avatar + name
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor:
                          AppColors.blue.withValues(alpha: 0.1),
                      backgroundImage: employee.profilePicture !=
                                  null &&
                              employee.profilePicture!.isNotEmpty &&
                              employee.profilePicture != 'string'
                          ? NetworkImage(employee.profilePicture!)
                          : null,
                      child: employee.profilePicture == null ||
                              employee.profilePicture!.isEmpty ||
                              employee.profilePicture == 'string'
                          ? Text(
                              employee.firstName.isNotEmpty
                                  ? employee.firstName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  color: AppColors.blue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 22),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(employee.fullName,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(employee.role,
                              style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                _detailRow('Email', employee.email),
                _detailRow('Phone', employee.phoneNumber ?? '–'),
                _detailRow(
                    'Department', employee.departmentName ?? '–'),
                _detailRow('Branch', employee.branchName ?? '–'),
                _detailRow('Join Date', joinDate),
                _detailRow('Status',
                    employee.isActive ? 'Active' : 'Inactive'),
                if (employee.employmentType != null)
                  _detailRow(
                      'Employment Type', employee.employmentType!),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(
                    color: Color(0xFF64748B), fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
