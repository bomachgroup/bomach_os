import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/src/helper/responsive_breakpoints.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/paginate/my_paginator.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/broadcast_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'controllers/broadcast_controller.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:bomach_os/src/utils/notification_destination.dart';
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
        return Obx(() {
          final canMarkAll =
              Get.find<PermissionService>().has(Perms.notificationsMarkAllRead);
          final markAll = controller.unreadCount.value > 0 && canMarkAll;
          return MyOutlinedButton(
            height: 48,
            icon: Icon(
              markAll ? Iconsax.tick_circle : Iconsax.refresh,
              color: AppColors.primary,
              size: 18,
            ),
            child: markAll ? 'Mark all read' : 'Refresh inbox',
            disable: controller.isLoadingNotifications.value,
            onTap: markAll
                ? controller.markAllRead
                : () => controller.fetchNotifications(refresh: true),
          );
        });
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTabBar(BroadcastController controller) {
    final visibleTabs = _broadcastTabs.where((tab) {
      return tab != 'Notifications' ||
          Get.find<PermissionService>().has(Perms.notificationsList);
    }).toList();
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: AppCard(
        padding: const EdgeInsets.all(6),
        elevation: AppCardElevation.sm,
        child: Row(
          children: visibleTabs.map((tab) {
            final isSelected = controller.currentTab.value == tab;
            return Expanded(
              child: InkWell(
                onTap: () => controller.setCurrentTab(tab),
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
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
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
                    Text(title, style: AppTextStyles.h3),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySm.copyWith(
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
        icon:
            const Icon(Iconsax.edit, size: 16, color: AppColors.textOnPrimary),
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
                          subtitle: 'Create a new announcement to get started.',
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
    return Column(
      children: controller.announcementList
          .map((a) => _buildAnnouncementTile(context, a))
          .toList(),
    );
  }

  Widget _buildAnnouncementTile(
      BuildContext context, Announcement announcement) {
    String displayDate = '';
    try {
      final parsed = DateTime.parse(announcement.publishAt);
      displayDate = DateFormat('dd-MM-yyyy').format(parsed);
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
          ),
          child: Row(
            children: [
              // ── Icon avatar ──
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: AppRadii.brSm,
                ),
                alignment: Alignment.center,
                child: const Icon(Iconsax.notification_bing,
                    size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              // ── Title + type ──
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      announcement.title,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      announcement.announcementTypeDisplay.isNotEmpty
                          ? announcement.announcementTypeDisplay
                          : '—',
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              // ── Date ──
              SizedBox(
                width: 130,
                child: Row(
                  children: [
                    const Icon(Iconsax.calendar_1,
                        size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        displayDate.isNotEmpty ? displayDate : '—',
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // ── Status ──
              const SizedBox(width: 16),
              StatusChip(
                label: announcement.isActive ? 'Active' : 'Inactive',
                tone: announcement.isActive
                    ? StatusTone.success
                    : StatusTone.neutral,
                dense: true,
              ),
              const SizedBox(width: 8),
              // ── Actions ──
              _buildRowActions(
                onView: () => showDialog(
                  context: context,
                  builder: (_) =>
                      ViewAnnouncementDialog(announcement: announcement),
                ),
                onEdit: () => showDialog(
                  context: context,
                  builder: (_) =>
                      CreateEditAnnouncementDialog(announcement: announcement),
                ),
                onDelete: () =>
                    _confirmDeleteAnnouncement(context, announcement),
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
        style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
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

class _EventsTab extends StatefulWidget {
  final BroadcastController controller;
  const _EventsTab({required this.controller});

  @override
  State<_EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<_EventsTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  List<BroadcastEvent> _getEventsForDay(DateTime day) {
    return widget.controller.eventList.where((event) {
      final date = parseApiDateTime(event.eventTimeFrom);
      if (date == null) return false;
      return isSameDay(date, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildToolbar(
          searchHint: 'Search events by title or audience',
          onSearchChanged: widget.controller.onEventSearchChanged,
        ),
        const SizedBox(height: 16),
        Obx(() {
          final loading = widget.controller.isLoadingEvents.value &&
              widget.controller.eventList.isEmpty;

          if (loading) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: LoadingSkeleton.listRows(count: 5),
            );
          }

          final dayEvents = _getEventsForDay(_selectedDay ?? DateTime.now());
          final showMobile = context.isMobile;

          final calendarCard = AppCard(
            padding: const EdgeInsets.all(16),
            elevation: AppCardElevation.sm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Event Calendar',
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 12),
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  eventLoader: _getEventsForDay,
                  calendarStyle: CalendarStyle(
                    todayDecoration: const BoxDecoration(
                      color: AppColors.primarySubtle,
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 3,
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: AppTextStyles.bodyLg.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    leftChevronIcon: const Icon(
                      Iconsax.arrow_left_2,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    rightChevronIcon: const Icon(
                      Iconsax.arrow_right_3,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          );

          final eventsListCard = AppCard(
            padding: EdgeInsets.zero,
            elevation: AppCardElevation.sm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedDay == null
                                  ? 'Select a date'
                                  : DateFormat('dd-MM-yyyy')
                                      .format(_selectedDay!),
                              style: AppTextStyles.h3,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${dayEvents.length} event(s) scheduled',
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      MyElevatedButton(
                        height: 38,
                        child: 'New Event',
                        icon: const Icon(Iconsax.add_circle,
                            size: 16, color: AppColors.textOnPrimary),
                        onTap: () => showDialog(
                          context: context,
                          builder: (_) => const CreateEditEventDialog(),
                        ).then((_) =>
                            widget.controller.fetchEvents(refresh: true)),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.borderSubtle),
                if (dayEvents.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: EmptyState(
                      icon: Iconsax.calendar_1,
                      title: 'No events on this day',
                      subtitle: 'Select another day or create a new event.',
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dayEvents.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: AppColors.borderSubtle),
                    itemBuilder: (context, index) {
                      final event = dayEvents[index];
                      return _buildEventItem(context, event);
                    },
                  ),
              ],
            ),
          );

          if (showMobile) {
            return Column(
              children: [
                calendarCard,
                const SizedBox(height: 16),
                eventsListCard,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: calendarCard,
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 5,
                child: eventsListCard,
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildEventItem(BuildContext context, BroadcastEvent event) {
    String displayTime = '';
    final from = parseApiDateTime(event.eventTimeFrom);
    final to = parseApiDateTime(event.eventTimeTo);
    if (from != null && to != null) {
      displayTime =
          '${DateFormat('h:mm a').format(from)} - ${DateFormat('h:mm a').format(to)}';
    } else {
      displayTime = event.eventTimeFrom;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: AppTextStyles.bodyLg.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Iconsax.clock,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          displayTime,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (event.meetingLocation.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Iconsax.location,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            event.meetingLocation,
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              StatusChip(
                label: event.eventTypeDisplay.isNotEmpty
                    ? event.eventTypeDisplay
                    : event.eventType,
                tone: StatusTone.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Target Audience Labels
              Expanded(
                child: event.targetAudienceLabels.isEmpty
                    ? const SizedBox.shrink()
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
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyOutlinedButton(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => ViewEventDialog(event: event),
                    ),
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    textColor: AppColors.textSecondary,
                    borderColor: AppColors.borderStrong,
                    child: 'View',
                  ),
                  const SizedBox(width: 8),
                  MyElevatedButton(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: 'Edit',
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => CreateEditEventDialog(event: event),
                    ).then((_) => widget.controller.fetchEvents(refresh: true)),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () => _confirmDeleteEvent(context, event),
                    icon: const Icon(Iconsax.trash,
                        size: 16, color: AppColors.danger),
                    tooltip: 'Delete',
                    splashRadius: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ],
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
        style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
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
      widget.controller.deleteEvent(context, event.id);
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
    'All',
    'Unread',
    'Read',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          elevation: AppCardElevation.sm,
          child: LayoutBuilder(builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 520;
            final filters = Obx(() => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: _filters
                      .map((label) => _buildFilterChip(
                          label, controller.notificationFilter.value))
                      .toList(),
                ));
            final refresh = Obx(() => IconButton(
                  tooltip: 'Refresh inbox',
                  onPressed: controller.isLoadingNotifications.value
                      ? null
                      : () => controller.fetchNotifications(refresh: true),
                  icon: controller.isLoadingNotifications.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Iconsax.refresh, size: 18),
                ));
            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: filters),
                      refresh,
                    ],
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: filters),
                refresh,
              ],
            );
          }),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final items = controller.filteredNotifications;
          if (items.isEmpty && controller.isLoadingNotifications.value) {
            return AppCard(
              padding: const EdgeInsets.all(20),
              elevation: AppCardElevation.md,
              child: LoadingSkeleton.listRows(count: 5),
            );
          }
          if (items.isEmpty) {
            return const AppCard(
              padding: EdgeInsets.zero,
              elevation: AppCardElevation.md,
              child: Padding(
                padding: EdgeInsets.all(24),
                child: EmptyState(
                  icon: Iconsax.notification,
                  title: 'No notifications',
                  subtitle: 'There are no notifications in this view.',
                ),
              ),
            );
          }

          return _buildTableCard(
            title: 'Notifications inbox',
            subtitle:
                '${controller.notificationTotalCount.value} notifications · ${controller.unreadCount.value} unread',
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
                  _buildNotificationRow(context, items[i]),
                  if (i != items.length - 1)
                    const Divider(height: 1, color: AppColors.borderSubtle),
                ],
              ],
            ),
          );
        }),
        Obx(() {
          if (controller.notificationError.value.isEmpty) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: AppCard(
              padding: const EdgeInsets.all(14),
              elevation: AppCardElevation.sm,
              child: Row(
                children: [
                  const Icon(Iconsax.warning_2,
                      size: 18, color: AppColors.warning),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Inbox could not be refreshed. ${controller.notificationError.value}',
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        controller.fetchNotifications(refresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
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
            style: AppTextStyles.bodySm.copyWith(
              color:
                  isActive ? AppColors.textOnPrimary : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationRow(
      BuildContext context, NotificationItem notification) {
    final unread = !notification.isRead;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await controller.markNotificationRead(notification);
          if (!context.mounted) return;
          final destination = NotificationDestination.routeFor(notification);
          if (destination != null) {
            context.go(destination);
            return;
          }
          showDialog<void>(
            context: context,
            builder: (_) => _NotificationDetailDialog(item: notification),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          color:
              unread ? AppColors.primarySubtle.withValues(alpha: 0.28) : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      unread ? AppColors.primarySubtle : AppColors.surfaceMuted,
                  borderRadius: AppRadii.brMd,
                ),
                alignment: Alignment.center,
                child: Icon(
                  _notificationIcon(
                      notification.eventType ?? notification.notificationType),
                  size: 18,
                  color: unread ? AppColors.primary : AppColors.textSecondary,
                ),
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
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight:
                                  unread ? FontWeight.w700 : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (unread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        StatusChip(
                          label: notification.category,
                          tone: StatusTone.neutral,
                          dense: true,
                        ),
                        if (notification.priority.toLowerCase() != 'normal')
                          StatusChip(
                            label: _label(notification.priority),
                            tone:
                                notification.priority.toLowerCase() == 'urgent'
                                    ? StatusTone.danger
                                    : StatusTone.warning,
                            dense: true,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _timeAgo(notification.createdAt),
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _notificationIcon(String raw) {
    final type = raw.toLowerCase();
    if (type.contains('work_location')) return Iconsax.location;
    if (type.contains('attendance')) return Iconsax.clock;
    if (type.contains('task')) return Iconsax.task_square;
    if (type.contains('leave')) return Iconsax.calendar;
    if (type.contains('payment') || type.contains('invoice'))
      return Iconsax.wallet;
    return Iconsax.notification;
  }

  String _timeAgo(String raw) {
    if (raw.isEmpty) return 'Recently';
    try {
      final date = DateTime.parse(raw).toLocal();
      final diff = DateTime.now().difference(date);
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'Now';
    } catch (_) {
      return raw;
    }
  }

  String _label(String value) => value
      .replaceAll('_', ' ')
      .split(' ')
      .map((part) =>
          part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

class _NotificationDetailDialog extends StatelessWidget {
  const _NotificationDetailDialog({required this.item});
  final NotificationItem item;

  @override
  Widget build(BuildContext context) => DialogScaffold(
        title: item.title,
        subtitle: '${item.category} · ${_formatDate(item.createdAt)}',
        size: DialogSize.md,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(item.description,
                style: AppTextStyles.bodyMd.copyWith(height: 1.5)),
            if (item.eventType?.isNotEmpty == true ||
                item.priority.toLowerCase() != 'normal') ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (item.eventType?.isNotEmpty == true)
                    StatusChip(
                      label: _label(item.eventType!),
                      tone: StatusTone.primary,
                    ),
                  if (item.priority.toLowerCase() != 'normal')
                    StatusChip(
                      label: _label(item.priority),
                      tone: item.priority.toLowerCase() == 'urgent'
                          ? StatusTone.danger
                          : StatusTone.warning,
                    ),
                ],
              ),
            ],
            if (item.metadata.isNotEmpty) ...[
              const SizedBox(height: 18),
              const Text('Details', style: AppTextStyles.h4),
              const SizedBox(height: 8),
              ...item.metadata.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(_label(entry.key),
                              style: AppTextStyles.bodySm
                                  .copyWith(color: AppColors.textSecondary)),
                        ),
                        Expanded(
                          child: Text('${entry.value}',
                              style: AppTextStyles.bodySm
                                  .copyWith(color: AppColors.textPrimary)),
                        ),
                      ],
                    ),
                  )),
            ],
            if (item.entityType.isNotEmpty || item.entityId.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                [
                  if (item.entityType.isNotEmpty) _label(item.entityType),
                  if (item.entityId.isNotEmpty) '#${item.entityId}',
                  if (item.action.isNotEmpty) _label(item.action),
                ].join(' · '),
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.textMuted),
              ),
            ],
          ],
        ),
        actions: [
          MyOutlinedButton(
            child: 'Close',
            height: 44,
            onTap: () => Navigator.pop(context),
            textColor: AppColors.textSecondary,
            borderColor: AppColors.borderStrong,
          ),
        ],
      );

  static String _formatDate(String raw) {
    if (raw.isEmpty) return 'Recently';
    try {
      return DateFormat('d MMM yyyy, h:mm a')
          .format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return raw;
    }
  }

  static String _label(String value) => value
      .replaceAll('_', ' ')
      .split(' ')
      .map((part) =>
          part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

// Expose the shared tone mapper to dialog files if needed.
StatusTone broadcastStatusTone(String status) => _statusToneFromStatus(status);
