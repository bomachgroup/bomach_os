import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/loading_skeleton.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/model/broadcast_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'controllers/broadcast_controller.dart';
import 'widget/broadcast_announcement_dialogs.dart';
import 'widget/broadcast_event_dialogs.dart';

const List<String> _broadcastTabs = [
  'Announcements',
  'Events',
  'Notifications',
];

class BroadcastPage extends StatelessWidget {
  const BroadcastPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BroadcastController controller = Get.put(BroadcastController());

    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Broadcast',
        subtitle: 'Manage announcements, events, and notifications.',
        trailing: Obx(() => _buildHeaderAction(context, controller)),
      ),
      children: [
        Obx(() => _buildTabBar(controller)),
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
    );
  }

  Widget _buildHeaderAction(
      BuildContext context, BroadcastController controller) {
    switch (controller.currentTab.value) {
      case 'Announcements':
        return MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'New Announcement',
          onTap: () => showDialog(
            context: context,
            builder: (_) => const CreateEditAnnouncementDialog(),
          ),
        );
      case 'Events':
        return MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'New Event',
          onTap: () => showDialog(
            context: context,
            builder: (_) => const CreateEditEventDialog(),
          ),
        );
      case 'Notifications':
        return MyOutlinedButton(
          height: 48,
          icon: const Icon(Iconsax.tick_circle,
              color: AppColors.primary, size: 18),
          child: 'Mark all read',
          onTap: controller.markAllRead,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTabBar(BroadcastController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: AppCard(
        padding: const EdgeInsets.all(6),
        elevation: AppCardElevation.sm,
        child: Row(
          children: _broadcastTabs.map((tab) {
            final isSelected = controller.currentTab.value == tab;
            return Expanded(
              child: InkWell(
                onTap: () => controller.currentTab.value = tab,
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tab,
                    style: AppText.bodyMd.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.textOnPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SHARED HELPERS
// ═══════════════════════════════════════════════════════════════════

Widget _buildToolbar({
  required String searchHint,
  required ValueChanged<String> onSearchChanged,
}) {
  return AppCard(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    elevation: AppCardElevation.sm,
    child: Row(
      children: [
        Expanded(
          child: MyTextFormField(
            hintText: searchHint,
            height: 44,
            onChanged: onSearchChanged,
            leading: const Icon(Iconsax.search_normal,
                size: 18, color: AppColors.textMuted),
          ),
        ),
      ],
    ),
  );
}

Widget _buildTableCard({
  required String title,
  required String subtitle,
  Widget? headerTrailing,
  required Widget body,
  Widget? footer,
}) {
  return AppCard(
    padding: EdgeInsets.zero,
    elevation: AppCardElevation.sm,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppText.h3),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppText.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (headerTrailing != null) headerTrailing,
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderSubtle),
        body,
        if (footer != null) ...[
          const Divider(height: 1, color: AppColors.borderSubtle),
          footer,
        ],
      ],
    ),
  );
}

Widget _buildHeaderCell(String label, {double? width, int? flex}) {
  final content = Text(
    label,
    style: AppText.bodySm.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w600,
    ),
  );
  if (width != null) return SizedBox(width: width, child: content);
  return Expanded(flex: flex ?? 1, child: content);
}

Widget _tablePaginator(Widget child) {
  return Container(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
    child: child,
  );
}

Widget _buildRowActions({
  required VoidCallback onView,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      MyOutlinedButton(
        onTap: onView,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        icon: const Icon(Iconsax.eye, size: 16, color: AppColors.primary),
        child: 'View',
      ),
      const SizedBox(width: 8),
      MyElevatedButton(
        height: 36,
        width: 80,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        icon: const Icon(Iconsax.edit,
            size: 16, color: AppColors.textOnPrimary),
        child: 'Edit',
        onTap: onEdit,
      ),
      const SizedBox(width: 4),
      IconButton(
        onPressed: onDelete,
        icon: const Icon(Iconsax.trash, size: 18, color: AppColors.danger),
        tooltip: 'Delete',
        splashRadius: 20,
      ),
    ],
  );
}

StatusTone _statusToneFromStatus(String status) {
  switch (status.trim().toLowerCase()) {
    case 'pending':
    case 'upcoming':
    case 'postponed':
    case 'scheduled':
    case 'waiting':
      return StatusTone.warning;
    case 'approved':
    case 'completed':
    case 'active':
    case 'signed':
    case 'published':
    case 'paid':
      return StatusTone.success;
    case 'cancelled':
    case 'canceled':
    case 'rejected':
    case 'overdue':
    case 'expired':
    case 'failed':
      return StatusTone.danger;
    case 'archived':
    case 'draft':
    case 'inactive':
      return StatusTone.neutral;
    case 'in progress':
    case 'ongoing':
      return StatusTone.info;
    default:
      return StatusTone.neutral;
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildToolbar(
          searchHint: 'Search announcements by title or type',
          onSearchChanged: controller.onAnnouncementSearchChanged,
        ),
        const SizedBox(height: 16),
        Obx(() {
          final loading = controller.isLoadingAnnouncements.value &&
              controller.announcementList.isEmpty;
          final isEmpty = !controller.isLoadingAnnouncements.value &&
              controller.announcementList.isEmpty;

          return _buildTableCard(
            title: 'Announcements register',
            subtitle: loading
                ? 'Loading announcements...'
                : '${controller.announcementTotalItems.value} announcements on record',
            headerTrailing: const StatusChip(
              label: 'Company broadcasts',
              tone: StatusTone.primary,
              icon: Iconsax.notification_bing,
            ),
            body: loading
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: LoadingSkeleton.listRows(count: 5),
                  )
                : isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: EmptyState(
                          icon: Iconsax.notification_bing,
                          title: 'No announcements yet',
                          subtitle:
                              'Create a new announcement to get started.',
                          action: MyOutlinedButton(
                            child: 'New Announcement',
                            icon: const Icon(Iconsax.add_circle,
                                size: 18, color: AppColors.primary),
                            onTap: () => showDialog(
                              context: context,
                              builder: (_) =>
                                  const CreateEditAnnouncementDialog(),
                            ),
                          ),
                        ),
                      )
                    : _buildAnnouncementTable(context),
            footer: _tablePaginator(
              Obx(() => PaginatorFooter(
                    totalItems: controller.announcementTotalItems.value,
                    limit: controller.announcementLimit.value,
                    currentPage: controller.announcementCurrentPage.value,
                    onPageChanged: controller.announcementGoToPage,
                    onLimitChanged: controller.announcementSetLimit,
                  )),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAnnouncementTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1120,
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              color: AppColors.surfaceMuted,
              child: Row(
                children: [
                  _buildHeaderCell('Title', flex: 3),
                  _buildHeaderCell('Publish Date', flex: 2),
                  _buildHeaderCell('Type', flex: 2),
                  _buildHeaderCell('Status', flex: 2),
                  _buildHeaderCell('Actions', width: 240),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderSubtle),
            ...controller.announcementList
                .map((a) => _buildAnnouncementRow(context, a)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementRow(
      BuildContext context, Announcement announcement) {
    String displayDate = '';
    String displayTime = '';
    try {
      final parsed = DateTime.parse(announcement.publishAt);
      displayDate = DateFormat('MMM d, yyyy').format(parsed);
      displayTime = DateFormat('h:mm a').format(parsed);
    } catch (_) {
      displayDate = announcement.publishAt;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showDialog(
          context: context,
          builder: (_) => ViewAnnouncementDialog(announcement: announcement),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  announcement.title,
                  style: AppText.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayDate,
                      style:
                          AppText.bodyMd.copyWith(color: AppColors.textPrimary),
                    ),
                    if (displayTime.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        displayTime,
                        style: AppText.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  announcement.announcementTypeDisplay,
                  style: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
                ),
              ),
              Expanded(
                flex: 2,
                child: StatusChip(
                  label: announcement.isActive ? 'Active' : 'Inactive',
                  tone: announcement.isActive
                      ? StatusTone.success
                      : StatusTone.neutral,
                ),
              ),
              SizedBox(
                width: 240,
                child: _buildRowActions(
                  onView: () => showDialog(
                    context: context,
                    builder: (_) => ViewAnnouncementDialog(announcement: announcement),
                  ),
                  onEdit: () => showDialog(
                    context: context,
                    builder: (_) => CreateEditAnnouncementDialog(announcement: announcement),
                  ),
                  onDelete: () => _confirmDeleteAnnouncement(context, announcement),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAnnouncement(
      BuildContext context, Announcement announcement) async {
    final confirmed = await DialogScaffold.show<bool>(
      context,
      title: 'Delete Announcement',
      size: DialogSize.sm,
      body: Text(
        'Are you sure you want to delete "${announcement.title}"?',
        style: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          onTap: () => Navigator.pop(context, false),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        MyElevatedButton(
          width: 120,
          height: 44,
          child: 'Delete',
          icon: const Icon(Iconsax.trash,
              size: 18, color: AppColors.textOnPrimary),
          onTap: () => Navigator.pop(context, true),
        ),
      ],
    );
    if (confirmed == true && context.mounted) {
      controller.deleteAnnouncement(context, announcement.id);
    }
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildToolbar(
          searchHint: 'Search events by title or audience',
          onSearchChanged: controller.onEventSearchChanged,
        ),
        const SizedBox(height: 16),
        Obx(() {
          final loading = controller.isLoadingEvents.value &&
              controller.eventList.isEmpty;
          final isEmpty = !controller.isLoadingEvents.value &&
              controller.eventList.isEmpty;

          return _buildTableCard(
            title: 'Events register',
            subtitle: loading
                ? 'Loading events...'
                : '${controller.eventTotalItems.value} events scheduled',
            headerTrailing: const StatusChip(
              label: 'Company events',
              tone: StatusTone.primary,
              icon: Iconsax.calendar_1,
            ),
            body: loading
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: LoadingSkeleton.listRows(count: 5),
                  )
                : isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: EmptyState(
                          icon: Iconsax.calendar_1,
                          title: 'No events yet',
                          subtitle: 'Create a new event to get started.',
                          action: MyOutlinedButton(
                            child: 'New Event',
                            icon: const Icon(Iconsax.add_circle,
                                size: 18, color: AppColors.primary),
                            onTap: () => showDialog(
                              context: context,
                              builder: (_) => const CreateEditEventDialog(),
                            ),
                          ),
                        ),
                      )
                    : _buildEventTable(context),
            footer: _tablePaginator(
              Obx(() => PaginatorFooter(
                    totalItems: controller.eventTotalItems.value,
                    limit: controller.eventLimit.value,
                    currentPage: controller.eventCurrentPage.value,
                    onPageChanged: controller.eventGoToPage,
                    onLimitChanged: controller.eventSetLimit,
                  )),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEventTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1160,
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              color: AppColors.surfaceMuted,
              child: Row(
                children: [
                  _buildHeaderCell('Title', flex: 3),
                  _buildHeaderCell('Date & Time', flex: 2),
                  _buildHeaderCell('Audience', flex: 3),
                  _buildHeaderCell('Type', flex: 2),
                  _buildHeaderCell('Actions', width: 240),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderSubtle),
            ...controller.eventList.map((e) => _buildEventRow(context, e)),
          ],
        ),
      ),
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showDialog(
          context: context,
          builder: (_) => ViewEventDialog(event: event),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  event.title,
                  style: AppText.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayDate,
                      style:
                          AppText.bodyMd.copyWith(color: AppColors.textPrimary),
                    ),
                    if (displayTime.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        displayTime,
                        style: AppText.bodySm
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: event.targetAudienceLabels.isEmpty
                    ? Text(
                        '-',
                        style: AppText.bodyMd
                            .copyWith(color: AppColors.textSecondary),
                      )
                    : Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: event.targetAudienceLabels
                            .map((label) => StatusChip(
                                  label: label,
                                  tone: label.toLowerCase().contains('branch')
                                      ? StatusTone.info
                                      : StatusTone.primary,
                                  dense: true,
                                ))
                            .toList(),
                      ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  event.eventTypeDisplay,
                  style: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 240,
                child: _buildRowActions(
                  onView: () => showDialog(
                    context: context,
                    builder: (_) => ViewEventDialog(event: event),
                  ),
                  onEdit: () => showDialog(
                    context: context,
                    builder: (_) => CreateEditEventDialog(event: event),
                  ),
                  onDelete: () => _confirmDeleteEvent(context, event),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteEvent(
      BuildContext context, BroadcastEvent event) async {
    final confirmed = await DialogScaffold.show<bool>(
      context,
      title: 'Delete Event',
      size: DialogSize.sm,
      body: Text(
        'Are you sure you want to delete "${event.title}"?',
        style: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          onTap: () => Navigator.pop(context, false),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        MyElevatedButton(
          width: 120,
          height: 44,
          child: 'Delete',
          icon: const Icon(Iconsax.trash,
              size: 18, color: AppColors.textOnPrimary),
          onTap: () => Navigator.pop(context, true),
        ),
      ],
    );
    if (confirmed == true && context.mounted) {
      controller.deleteEvent(context, event.id);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
//  NOTIFICATIONS TAB
// ═══════════════════════════════════════════════════════════════════

class _NotificationsTab extends StatelessWidget {
  final BroadcastController controller;
  const _NotificationsTab({required this.controller});

  static const List<String> _filters = [
    'Admin',
    'Staff',
    'Associate',
    'Investor',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          elevation: AppCardElevation.sm,
          child: Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: _filters
                    .map((label) => _buildFilterChip(
                        label, controller.notificationFilter.value))
                    .toList(),
              )),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final items = controller.filteredNotifications;
          if (items.isEmpty) {
            return const AppCard(
              padding: EdgeInsets.zero,
              elevation: AppCardElevation.md,
              child: Padding(
                padding: EdgeInsets.all(24),
                child: EmptyState(
                  icon: Iconsax.notification,
                  title: 'No notifications',
                  subtitle:
                      'Notifications matching the selected filter will appear here.',
                ),
              ),
            );
          }

          return _buildTableCard(
            title: 'Notifications inbox',
            subtitle: '${items.length} notifications available',
            headerTrailing: Obx(() => StatusChip(
                  label: '${controller.unreadCount.value} unread',
                  tone: controller.unreadCount.value > 0
                      ? StatusTone.warning
                      : StatusTone.neutral,
                  icon: Iconsax.notification_bing,
                )),
            body: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  _buildNotificationRow(items[i]),
                  if (i != items.length - 1)
                    const Divider(
                        height: 1, color: AppColors.borderSubtle),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFilterChip(String label, String activeFilter) {
    final isActive = activeFilter == label;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadii.brPill,
        onTap: () => controller.filterNotifications(isActive ? '' : label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.surface,
            borderRadius: AppRadii.brPill,
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.borderSubtle,
            ),
          ),
          child: Text(
            label,
            style: AppText.bodySm.copyWith(
              color:
                  isActive ? AppColors.textOnPrimary : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationRow(NotificationItem notification) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: AppRadii.brMd,
            ),
            alignment: Alignment.center,
            child: const Icon(Iconsax.notification,
                size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppText.bodyMd.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    StatusChip(
                      label: notification.category,
                      tone: StatusTone.neutral,
                      dense: true,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.subtitle,
                  style: AppText.bodySm
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.description,
                  style:
                      AppText.bodySm.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            notification.time,
            style: AppText.caption.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// Expose the shared tone mapper to dialog files if needed.
StatusTone broadcastStatusTone(String status) => _statusToneFromStatus(status);
