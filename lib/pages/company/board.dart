import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/paginate/my_paginator.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/shadows.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/board_model.dart';
import 'package:bomach_os/src/model/company_model.dart';
import 'package:bomach_os/src/model/employees_model.dart';
import 'package:bomach_os/src/model/partner_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'controllers/board_controller.dart';
import 'controllers/company_controller.dart';
import 'widget/add_partner_dialog.dart';
import 'widget/add_shareholder_dialog.dart';
import 'widget/board_meeting_dialogs.dart';
import 'widget/board_resolution_dialogs.dart';

const List<String> _boardTabs = [
  'Meetings',
  'Resolutions',
  'Investors',
  'Associates',
  'Partners',
];

class BoardPage extends StatelessWidget {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BoardController controller = Get.put(BoardController());
    // Ensure CompanyController is registered for downstream lookups (Get.find).
    Get.put(CompanyController());

    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Board',
        subtitle:
            'Manage Board meetings, resolutions, investors, associates, and partners.',
        trailing: Obx(() => _buildHeaderAction(context, controller)),
      ),
      children: [
        Obx(() => _buildTabBar(controller)),
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
    );
  }

  Widget _buildHeaderAction(BuildContext context, BoardController controller) {
    switch (controller.currentTab.value) {
      case 'Meetings':
        return MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'New Meeting',
          onTap: () => showDialog(
            context: context,
            builder: (_) => const ScheduleMeetingDialog(),
          ),
        );
      case 'Resolutions':
        return MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'New Resolution',
          onTap: () => showDialog(
            context: context,
            builder: (_) => const NewResolutionDialog(),
          ),
        );
      case 'Investors':
        return MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'New Shareholder',
          onTap: () => showDialog(
            context: context,
            builder: (_) => const AddShareholderDialog(),
          ),
        );
      case 'Partners':
        return MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'New Partner',
          onTap: () => showDialog(
            context: context,
            builder: (_) => const AddPartnerDialog(),
          ),
        );
      case 'Associates':
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTabBar(BoardController controller) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _boardTabs
              .map((label) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _buildTabButton(controller, label),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTabButton(BoardController controller, String label) {
    final isActive = controller.currentTab.value == label;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadii.brMd,
        onTap: () => controller.currentTab.value = label,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.surface : Colors.transparent,
            borderRadius: AppRadii.brMd,
            boxShadow: isActive ? AppShadows.sm : const <BoxShadow>[],
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyMd.copyWith(
              color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
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
  List<Widget> trailingFilters = const [],
}) {
  return AppCard(
    padding: const EdgeInsets.all(16),
    elevation: AppCardElevation.sm,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 1080;

        final search = MyTextFormField(
          hintText: searchHint,
          height: 48,
          onChanged: onSearchChanged,
          leading: const Icon(Iconsax.search_normal,
              size: 18, color: AppColors.textMuted),
        );

        if (trailingFilters.isEmpty) {
          return search;
        }

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              search,
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: trailingFilters,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: search),
            const SizedBox(width: 16),
            Expanded(
              flex: 4,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: trailingFilters,
              ),
            ),
          ],
        );
      },
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
    elevation: AppCardElevation.md,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
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
                      style: AppTextStyles.bodyMd.copyWith(
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
    style: AppTextStyles.bodySm.copyWith(
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

PopupMenuItem<String> _menuItem({
  required String value,
  required IconData icon,
  required String label,
  bool destructive = false,
}) {
  final color = destructive ? AppColors.danger : AppColors.textSecondary;
  return PopupMenuItem<String>(
    value: value,
    child: Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodyMd.copyWith(
            color: destructive ? AppColors.danger : AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildToolbar(
          searchHint: 'Search meetings by title or agenda',
          onSearchChanged: controller.onMeetingSearchChanged,
        ),
        const SizedBox(height: 16),
        Obx(() {
          final loading = controller.isLoadingMeetings.value &&
              controller.meetingList.isEmpty;
          final isEmpty = !controller.isLoadingMeetings.value &&
              controller.meetingList.isEmpty;

          return _buildTableCard(
            title: 'Meetings register',
            subtitle: loading
                ? 'Loading meetings...'
                : '${controller.meetingTotalItems.value} meetings scheduled',
            headerTrailing: const StatusChip(
              label: 'Governance calendar',
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
                          title: 'No meetings scheduled',
                          subtitle: 'Schedule a new meeting to get started.',
                          action: MyElevatedButton(
                            child: 'New Meeting',
                            icon: const Icon(Iconsax.add_circle,
                                size: 18, color: AppColors.textOnPrimary),
                            onTap: () => showDialog(
                              context: context,
                              builder: (_) => const ScheduleMeetingDialog(),
                            ),
                          ),
                        ),
                      )
                    : _buildMeetingTable(context),
            footer: _tablePaginator(
              Obx(() => PaginatorFooter(
                    totalItems: controller.meetingTotalItems.value,
                    limit: controller.meetingLimit.value,
                    currentPage: controller.meetingCurrentPage.value,
                    onPageChanged: controller.meetingGoToPage,
                    onLimitChanged: controller.meetingSetLimit,
                  )),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMeetingTable(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: AppColors.surfaceMuted,
          child: Row(
            children: [
              _buildHeaderCell('Title', flex: 3),
              _buildHeaderCell('Date & Time', flex: 2),
              _buildHeaderCell('Agenda', flex: 3),
              _buildHeaderCell('Status', flex: 2),
              _buildHeaderCell('', width: 48),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderSubtle),
        ...controller.meetingList.map((m) => _buildMeetingRow(context, m)),
      ],
    );
  }

  Widget _buildMeetingRow(BuildContext context, BoardMeeting meeting) {
    String displayDate = meeting.meetingDate;
    try {
      final parsed = DateTime.parse(meeting.meetingDate);
      displayDate = DateFormat('MMM d, yyyy').format(parsed);
    } catch (_) {}

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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              meeting.title,
              style: AppTextStyles.bodyMd.copyWith(
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
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (meeting.meetingTime.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    displayTime,
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              meeting.agenda,
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                label: meeting.statusDisplay.isEmpty
                    ? 'Unknown'
                    : meeting.statusDisplay,
                tone: _meetingStatusTone(meeting.statusDisplay),
              ),
            ),
          ),
          SizedBox(width: 48, child: _buildActionMenu(context, meeting)),
        ],
      ),
    );
  }

  StatusTone _meetingStatusTone(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
      case 'pending':
      case 'postponed':
      case 'scheduled':
        return StatusTone.warning;
      case 'completed':
        return StatusTone.success;
      case 'cancelled':
        return StatusTone.danger;
      case 'in progress':
        return StatusTone.info;
      default:
        return StatusTone.neutral;
    }
  }

  Widget _buildActionMenu(BuildContext context, BoardMeeting meeting) {
    return PopupMenuButton<String>(
      icon: const Icon(Iconsax.more, size: 18, color: AppColors.textSecondary),
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
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
            final confirmed = await DialogScaffold.show<bool>(
              context,
              title: 'Cancel Meeting',
              size: DialogSize.sm,
              body: Text('Are you sure you want to cancel "${meeting.title}"?',
                  style: AppTextStyles.bodyMd),
              actions: [
                MyOutlinedButton(
                  child: 'No',
                  height: 44,
                  onTap: () => Navigator.pop(context, false),
                  textColor: AppColors.textSecondary,
                  borderColor: AppColors.borderStrong,
                ),
                MyElevatedButton(
                  width: 150,
                  height: 44,
                  child: 'Yes, Cancel',
                  onTap: () => Navigator.pop(context, true),
                ),
              ],
            );
            if (confirmed == true && context.mounted) {
              controller.cancelMeeting(context, meeting.id);
            }
            break;
        }
      },
      itemBuilder: (_) => [
        _menuItem(value: 'view', icon: Iconsax.eye, label: 'View Details'),
        _menuItem(value: 'edit', icon: Iconsax.edit, label: 'Edit'),
        _menuItem(
            value: 'delete',
            icon: Iconsax.close_circle,
            label: 'Cancel',
            destructive: true),
      ],
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildToolbar(
          searchHint: 'Search resolutions by title or type',
          onSearchChanged: controller.onResolutionSearchChanged,
        ),
        const SizedBox(height: 16),
        Obx(() {
          final loading = controller.isLoadingResolutions.value &&
              controller.resolutionList.isEmpty;
          final isEmpty = !controller.isLoadingResolutions.value &&
              controller.resolutionList.isEmpty;

          return _buildTableCard(
            title: 'Resolutions register',
            subtitle: loading
                ? 'Loading resolutions...'
                : '${controller.resolutionTotalItems.value} resolutions on record',
            headerTrailing: const StatusChip(
              label: 'Governance decisions',
              tone: StatusTone.primary,
              icon: Iconsax.judge,
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
                          icon: Iconsax.judge,
                          title: 'No resolutions yet',
                          subtitle: 'Create a new resolution to get started.',
                          action: MyElevatedButton(
                            child: 'New Resolution',
                            icon: const Icon(Iconsax.add_circle,
                                size: 18, color: AppColors.textOnPrimary),
                            onTap: () => showDialog(
                              context: context,
                              builder: (_) => const NewResolutionDialog(),
                            ),
                          ),
                        ),
                      )
                    : _buildResolutionTable(context),
            footer: _tablePaginator(
              Obx(() => PaginatorFooter(
                    totalItems: controller.resolutionTotalItems.value,
                    limit: controller.resolutionLimit.value,
                    currentPage: controller.resolutionCurrentPage.value,
                    onPageChanged: controller.resolutionGoToPage,
                    onLimitChanged: controller.resolutionSetLimit,
                  )),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildResolutionTable(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: AppColors.surfaceMuted,
          child: Row(
            children: [
              _buildHeaderCell('Title', flex: 3),
              _buildHeaderCell('Type', flex: 2),
              _buildHeaderCell('Date', flex: 2),
              _buildHeaderCell('Status', flex: 2),
              _buildHeaderCell('', width: 48),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderSubtle),
        ...controller.resolutionList
            .map((r) => _buildResolutionRow(context, r)),
      ],
    );
  }

  Widget _buildResolutionRow(BuildContext context, BoardResolution resolution) {
    String displayDate = resolution.resolutionDate;
    try {
      final parsed = DateTime.parse(resolution.resolutionDate);
      displayDate = DateFormat('MMM d, yyyy').format(parsed);
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              resolution.title,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              resolution.resolutionTypeDisplay,
              style:
                  AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              displayDate,
              style:
                  AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                label: resolution.statusDisplay.isEmpty
                    ? 'Unknown'
                    : resolution.statusDisplay,
                tone: _resolutionStatusTone(resolution.statusDisplay),
              ),
            ),
          ),
          SizedBox(width: 48, child: _buildActionMenu(context, resolution)),
        ],
      ),
    );
  }

  StatusTone _resolutionStatusTone(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'signed':
        return StatusTone.success;
      case 'pending':
        return StatusTone.warning;
      case 'rejected':
        return StatusTone.danger;
      case 'archived':
      case 'draft':
        return StatusTone.neutral;
      default:
        return StatusTone.neutral;
    }
  }

  Widget _buildActionMenu(BuildContext context, BoardResolution resolution) {
    return PopupMenuButton<String>(
      icon: const Icon(Iconsax.more, size: 18, color: AppColors.textSecondary),
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
      onSelected: (value) async {
        switch (value) {
          case 'view':
            showDialog(
              context: context,
              builder: (_) => ViewResolutionDialog(resolution: resolution),
            );
            break;
          case 'edit':
            showDialog(
              context: context,
              builder: (_) => NewResolutionDialog(resolution: resolution),
            );
            break;
          case 'delete':
            final confirmed = await DialogScaffold.show<bool>(
              context,
              title: 'Archive Resolution',
              size: DialogSize.sm,
              body: Text(
                'Are you sure you want to archive "${resolution.title}"?',
                style: AppTextStyles.bodyMd,
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
                  child: 'Archive',
                  onTap: () => Navigator.pop(context, true),
                ),
              ],
            );
            if (confirmed == true && context.mounted) {
              controller.archiveResolution(context, resolution.id);
            }
            break;
        }
      },
      itemBuilder: (_) => [
        _menuItem(value: 'view', icon: Iconsax.eye, label: 'View Details'),
        _menuItem(value: 'edit', icon: Iconsax.edit, label: 'Edit'),
        _menuItem(
            value: 'delete',
            icon: Iconsax.archive_1,
            label: 'Archive',
            destructive: true),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  INVESTORS TAB (Shareholders)
// ═══════════════════════════════════════════════════════════════════

class _InvestorsTab extends StatelessWidget {
  final BoardController controller;
  const _InvestorsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    final companyCtrl = Get.find<CompanyController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildToolbar(
          searchHint: 'Search shareholders by name or email',
          onSearchChanged: (_) {}, // CompanyController owns shareholders
        ),
        const SizedBox(height: 16),
        Obx(() {
          final loading = companyCtrl.isShareholdersLoading.value &&
              companyCtrl.shareholders.isEmpty;
          final isEmpty = !companyCtrl.isShareholdersLoading.value &&
              companyCtrl.shareholders.isEmpty;

          return _buildTableCard(
            title: 'Shareholders register',
            subtitle: loading
                ? 'Loading shareholders...'
                : '${companyCtrl.shareholders.length} active ownership records',
            headerTrailing: const StatusChip(
              label: 'Ownership directory',
              tone: StatusTone.primary,
              icon: Iconsax.profile_2user,
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
                          icon: Iconsax.profile_2user,
                          title: 'No shareholders yet',
                          subtitle:
                              'Add shareholders to track ownership and share distribution.',
                          action: MyElevatedButton(
                            child: 'New Shareholder',
                            icon: const Icon(Iconsax.add_circle,
                                size: 18, color: AppColors.textOnPrimary),
                            onTap: () => showDialog(
                              context: context,
                              builder: (_) => const AddShareholderDialog(),
                            ),
                          ),
                        ),
                      )
                    : _buildShareholderTable(context, companyCtrl),
          );
        }),
      ],
    );
  }

  Widget _buildShareholderTable(
      BuildContext context, CompanyController companyCtrl) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: AppColors.surfaceMuted,
          child: Row(
            children: [
              _buildHeaderCell('Name', flex: 3),
              _buildHeaderCell('Email', flex: 3),
              _buildHeaderCell('Title', flex: 2),
              _buildHeaderCell('Share %', flex: 1),
              _buildHeaderCell('Board', flex: 1),
              _buildHeaderCell('', width: 48),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderSubtle),
        ...companyCtrl.shareholders
            .map((s) => _buildShareholderRow(context, s, companyCtrl)),
      ],
    );
  }

  Widget _buildShareholderRow(
      BuildContext context, Shareholder s, CompanyController ctrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primarySubtle,
                  child: Text(
                    s.firstName.isNotEmpty ? s.firstName[0].toUpperCase() : '?',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    s.fullName,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              s.email,
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              s.titleDisplay,
              style:
                  AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${s.sharePercentage}%',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Icon(
              s.isBoardMember ? Iconsax.tick_circle : Iconsax.close_circle,
              size: 18,
              color: s.isBoardMember ? AppColors.success : AppColors.textMuted,
            ),
          ),
          SizedBox(
            width: 48,
            child: PopupMenuButton<String>(
              icon: const Icon(Iconsax.more,
                  size: 18, color: AppColors.textSecondary),
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
              onSelected: (value) async {
                switch (value) {
                  case 'edit':
                    showDialog(
                      context: context,
                      builder: (_) => AddShareholderDialog(shareholder: s),
                    );
                    break;
                  case 'delete':
                    final confirmed = await DialogScaffold.show<bool>(
                      context,
                      title: 'Delete Shareholder',
                      size: DialogSize.sm,
                      body: Text(
                          'Are you sure you want to remove ${s.fullName}?',
                          style: AppTextStyles.bodyMd),
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
                          onTap: () => Navigator.pop(context, true),
                        ),
                      ],
                    );
                    if (confirmed == true && context.mounted) {
                      ctrl.deleteShareholder(context, s.id);
                    }
                    break;
                }
              },
              itemBuilder: (_) => [
                _menuItem(value: 'edit', icon: Iconsax.edit, label: 'Edit'),
                _menuItem(
                    value: 'delete',
                    icon: Iconsax.trash,
                    label: 'Delete',
                    destructive: true),
              ],
            ),
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
      emptyIcon: Iconsax.people,
      emptyTitle: 'No associates found',
      emptySubtitle: 'Associates will appear here once added.',
      headerTitle: 'Associates directory',
      headerChipLabel: 'Company associates',
      searchHint: 'Search associates by name or email',
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
//  PARTNERS TAB
// ═══════════════════════════════════════════════════════════════════

class _PartnersTab extends StatelessWidget {
  final BoardController controller;
  const _PartnersTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildToolbar(
          searchHint: 'Search partners by name, email, or category',
          onSearchChanged: controller.onPartnerSearchChanged,
        ),
        const SizedBox(height: 16),
        Obx(() {
          final loading = controller.isLoadingPartners.value &&
              controller.partnerList.isEmpty;
          final isEmpty = !controller.isLoadingPartners.value &&
              controller.partnerList.isEmpty;

          return _buildTableCard(
            title: 'Partners register',
            subtitle: loading
                ? 'Loading partners...'
                : '${controller.partnerTotalItems.value} partners onboarded',
            headerTrailing: const StatusChip(
              label: 'Partner network',
              tone: StatusTone.primary,
              icon: Iconsax.briefcase,
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
                          icon: Iconsax.briefcase,
                          title: 'No partners found',
                          subtitle:
                              'Add partners to manage agreements and relationships.',
                          action: MyElevatedButton(
                            child: 'New Partner',
                            icon: const Icon(Iconsax.add_circle,
                                size: 18, color: AppColors.textOnPrimary),
                            onTap: () => showDialog(
                              context: context,
                              builder: (_) => const AddPartnerDialog(),
                            ),
                          ),
                        ),
                      )
                    : _buildPartnerTable(context),
            footer: _tablePaginator(
              Obx(() => PaginatorFooter(
                    currentPage: controller.partnerCurrentPage.value,
                    totalItems: controller.partnerTotalItems.value,
                    limit: controller.partnerLimit.value,
                    onPageChanged: controller.partnerGoToPage,
                    onLimitChanged: controller.partnerSetLimit,
                  )),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPartnerTable(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: AppColors.surfaceMuted,
          child: Row(
            children: [
              _buildHeaderCell('Name', flex: 3),
              _buildHeaderCell('Email', flex: 3),
              _buildHeaderCell('Category', flex: 2),
              _buildHeaderCell('Status', flex: 2),
              _buildHeaderCell('Agreements', flex: 1),
              _buildHeaderCell('', width: 48),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderSubtle),
        ...controller.partnerList.map((p) => _buildPartnerRow(context, p)),
      ],
    );
  }

  Widget _buildPartnerRow(BuildContext context, Partner p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primarySubtle,
                  child: Text(
                    p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    p.name,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              p.email,
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              p.categoryDisplay,
              style:
                  AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                label: p.statusDisplay.isEmpty ? 'Unknown' : p.statusDisplay,
                tone: _partnerStatusTone(p.status),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${p.agreementCount}',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: PopupMenuButton<String>(
              icon: const Icon(Iconsax.more,
                  size: 18, color: AppColors.textSecondary),
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
              onSelected: (value) async {
                switch (value) {
                  case 'edit':
                    showDialog(
                      context: context,
                      builder: (_) => AddPartnerDialog(partner: p),
                    );
                    break;
                  case 'delete':
                    final confirmed = await DialogScaffold.show<bool>(
                      context,
                      title: 'Delete Partner',
                      size: DialogSize.sm,
                      body: Text(
                        'Are you sure you want to delete "${p.name}"? This will also delete all associated agreements.',
                        style: AppTextStyles.bodyMd,
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
                          onTap: () => Navigator.pop(context, true),
                        ),
                      ],
                    );
                    if (confirmed == true && context.mounted) {
                      controller.deletePartner(context, p.id);
                    }
                    break;
                }
              },
              itemBuilder: (_) => [
                _menuItem(value: 'edit', icon: Iconsax.edit, label: 'Edit'),
                _menuItem(
                    value: 'delete',
                    icon: Iconsax.trash,
                    label: 'Delete',
                    destructive: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  StatusTone _partnerStatusTone(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return StatusTone.success;
      case 'inactive':
        return StatusTone.neutral;
      case 'suspended':
        return StatusTone.danger;
      default:
        return StatusTone.neutral;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SHARED EMPLOYEE LIST TAB (Associates)
// ═══════════════════════════════════════════════════════════════════

class _EmployeeListTab extends StatelessWidget {
  final BoardController controller;
  final String tabLabel;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final String headerTitle;
  final String headerChipLabel;
  final String searchHint;
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
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.headerTitle,
    required this.headerChipLabel,
    required this.searchHint,
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildToolbar(
          searchHint: searchHint,
          onSearchChanged: onSearchChanged,
        ),
        const SizedBox(height: 16),
        Obx(() {
          final loading = isLoading.value && employeeList.isEmpty;
          final isEmpty = !isLoading.value && employeeList.isEmpty;

          return _buildTableCard(
            title: headerTitle,
            subtitle: loading
                ? 'Loading $tabLabel...'
                : '${totalItems.value} records available',
            headerTrailing: StatusChip(
              label: headerChipLabel,
              tone: StatusTone.primary,
              icon: emptyIcon,
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
                          icon: emptyIcon,
                          title: emptyTitle,
                          subtitle: emptySubtitle,
                        ),
                      )
                    : _buildEmployeeTable(context),
            footer: _tablePaginator(
              Obx(() => PaginatorFooter(
                    totalItems: totalItems.value,
                    limit: limit.value,
                    currentPage: currentPage.value,
                    onPageChanged: onPageChanged,
                    onLimitChanged: onLimitChanged,
                  )),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEmployeeTable(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 980) {
          return _buildEmployeeCards(context);
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              color: AppColors.surfaceMuted,
              child: Row(
                children: [
                  _buildHeaderCell('Name', flex: 3),
                  const SizedBox(width: 16),
                  _buildHeaderCell('Email', flex: 3),
                  const SizedBox(width: 16),
                  _buildHeaderCell('Phone', flex: 2),
                  const SizedBox(width: 16),
                  _buildHeaderCell('Department', flex: 2),
                  const SizedBox(width: 16),
                  _buildHeaderCell('Status', flex: 2),
                  const SizedBox(width: 16),
                  _buildHeaderCell('', width: 48),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderSubtle),
            ...employeeList.map((e) => _buildEmployeeRow(context, e)),
          ],
        );
      },
    );
  }

  Widget _buildEmployeeCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: employeeList.map((employee) {
          final hasPicture = employee.profilePicture != null &&
              employee.profilePicture!.isNotEmpty &&
              employee.profilePicture != 'string';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.brMd,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEmployeeIdentity(employee, hasPicture),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 14,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildInfoLine('Email', employee.email),
                    _buildInfoLine('Phone', employee.phoneNumber ?? '-'),
                    _buildInfoLine(
                        'Department', employee.departmentName ?? '-'),
                    StatusChip.fromStatus(
                      employee.isActive ? 'Active' : 'Inactive',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () => _showViewDialog(context, employee),
                    icon: const Icon(Iconsax.eye, size: 16),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.borderStrong),
                      minimumSize: const Size(0, 42),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: const RoundedRectangleBorder(
                          borderRadius: AppRadii.brMd),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmployeeIdentity(Employee employee, bool hasPicture) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primarySubtle,
          backgroundImage:
              hasPicture ? NetworkImage(employee.profilePicture!) : null,
          child: !hasPicture
              ? Text(
                  employee.firstName.isNotEmpty
                      ? employee.firstName[0].toUpperCase()
                      : '?',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                employee.fullName,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (employee.role.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  employee.role,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeRow(BuildContext context, Employee employee) {
    final hasPicture = employee.profilePicture != null &&
        employee.profilePicture!.isNotEmpty &&
        employee.profilePicture != 'string';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildEmployeeIdentity(employee, hasPicture),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              employee.email,
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              employee.phoneNumber ?? '—',
              style:
                  AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              employee.departmentName ?? '—',
              style:
                  AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip.fromStatus(
                employee.isActive ? 'Active' : 'Inactive',
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 48,
            child: PopupMenuButton<String>(
              icon: const Icon(Iconsax.more,
                  size: 18, color: AppColors.textSecondary),
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
              onSelected: (value) {
                if (value == 'view') {
                  _showViewDialog(context, employee);
                }
              },
              itemBuilder: (_) => [
                _menuItem(
                    value: 'view', icon: Iconsax.eye, label: 'View Details'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoLine(String label, String value) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 260),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showViewDialog(BuildContext context, Employee employee) {
    String joinDate = '—';
    if (employee.startDate != null) {
      joinDate = DateFormat('MMMM d, yyyy').format(employee.startDate!);
    }

    final hasPicture = employee.profilePicture != null &&
        employee.profilePicture!.isNotEmpty &&
        employee.profilePicture != 'string';

    DialogScaffold.show(
      context,
      title: '$tabLabel Details',
      subtitle: employee.role.isNotEmpty ? employee.role : null,
      size: DialogSize.md,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: AppRadii.brLg,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primarySubtle,
                  backgroundImage: hasPicture
                      ? NetworkImage(employee.profilePicture!)
                      : null,
                  child: !hasPicture
                      ? Text(
                          employee.firstName.isNotEmpty
                              ? employee.firstName[0].toUpperCase()
                              : '?',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(employee.fullName, style: AppTextStyles.h3),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          StatusChip.fromStatus(
                              employee.isActive ? 'Active' : 'Inactive'),
                          if (employee.role.isNotEmpty)
                            StatusChip(
                              label: employee.role,
                              tone: StatusTone.neutral,
                              icon: Iconsax.briefcase,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _detailRow('Email', employee.email),
          _detailRow('Phone', employee.phoneNumber ?? '—'),
          _detailRow('Department', employee.departmentName ?? '—'),
          _detailRow('Branch', employee.branchName ?? '—'),
          _detailRow('Join Date', joinDate),
          if (employee.employmentType != null)
            _detailRow('Employment Type', employee.employmentType!),
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
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
