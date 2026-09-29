import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/nav/three_dot_pop.dart';
import 'package:bomach_os/components/paginate/my_paginator.dart';
import 'package:bomach_os/components/paginate/responsive_table.dart';
import 'package:bomach_os/components/permission/permission_gate.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/components/section/responsive_stat_row.dart';
import 'package:bomach_os/pages/hr/widget/add_leave_request_dialog.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/constants/shadows.dart';
import 'package:bomach_os/src/helper/responsive_breakpoints.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:bomach_os/components/chip/status_chip.dart';

import 'controller/leave_request_controller.dart';
import 'models/leave_request_model.dart';
import 'widget/view_leave_request_dialog.dart';

class LeaveRequestPage extends StatefulWidget {
  const LeaveRequestPage({super.key});

  @override
  State<LeaveRequestPage> createState() => LeaveRequestPageState();
}

class LeaveRequestPageState extends State<LeaveRequestPage> {
  final ScrollController _scrollController = ScrollController();
  final LeaveRequestController _ctrl = Get.put(LeaveRequestController());
  late final VoidCallback _searchListener;

  @override
  void initState() {
    super.initState();
    _searchListener = () => _ctrl.onSearchChanged(context);
    _ctrl.searchController.addListener(_searchListener);
    if (Get.find<PermissionService>().has(Perms.leaveRequestsList)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _ctrl.fetchLeaveRequests(context);
      });
    }
  }

  @override
  void dispose() {
    _ctrl.searchController.removeListener(_searchListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PermissionGate(
      require: Perms.leaveRequestsList,
      fallback: const PageScaffold(
        maxContentWidth: 1440,
        header: PageHeader(title: 'Leave Requests'),
        children: [
          AppCard(
            child: EmptyState(
              title: 'Access restricted',
              subtitle: 'Your role does not include access to this page.',
            ),
          ),
        ],
      ),
      child: _buildAuthorizedPage(context),
    );
  }

  Widget _buildAuthorizedPage(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Leave & Attendance Requests',
        subtitle: 'Review leave, absence, and late-arrival requests.',
        trailing: PermissionGate(
          require: Perms.leaveRequestsCreate,
          child: MyElevatedButton(
            height: 48,
            icon: const Icon(Iconsax.add_circle,
                color: AppColors.textOnPrimary, size: 20),
            child: 'New Leave Request',
            onTap: () => showDialog(
              context: context,
              builder: (_) => const AddLeaveRequestDialog(),
            ),
          ),
        ),
      ),
      children: [
        Obx(() => _ctrl.isLoading.value && _ctrl.totalCount.value == 0
            ? LoadingSkeleton.statRow()
            : ResponsiveStatRow(
                cards: [
                  _StatCard(
                    title: 'Pending Requests',
                    count: _ctrl.stats['pending'].toString(),
                    icon: Iconsax.timer,
                    accent: AppColors.warning,
                  ),
                  _StatCard(
                    title: 'On Leave Today',
                    count: _ctrl.stats['onLeave'].toString(),
                    icon: Iconsax.user_tag,
                    accent: AppColors.primary,
                  ),
                  _StatCard(
                    title: 'Approved This Month',
                    count: _ctrl.stats['approved'].toString(),
                    icon: Iconsax.tick_circle,
                    accent: AppColors.success,
                  ),
                  _StatCard(
                    title: 'Rejected',
                    count: _ctrl.stats['rejected'].toString(),
                    icon: Iconsax.close_circle,
                    accent: AppColors.danger,
                  ),
                ],
              )),
        const SizedBox(height: 24),
        Obx(() => Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildTabButton('All', _ctrl.activeTab.value == 'All'),
                _buildTabButton('Pending Approvals',
                    _ctrl.activeTab.value == 'Pending Approvals'),
                _buildTabButton('History', _ctrl.activeTab.value == 'History'),
              ],
            )),
        const SizedBox(height: 20),
        Text('Request category',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 10),
        Obx(() => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryButton('all', 'All requests'),
                  _buildCategoryButton('leave', 'Leave'),
                  _buildCategoryButton('absence', 'Absence'),
                  _buildCategoryButton('running_late', 'Late arrival'),
                ],
              ),
            )),
        const SizedBox(height: 16),
        AppCard(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 640;
            final search = SizedBox(
              width: isNarrow ? double.infinity : 360,
              child: MyTextFormField(
                controller: _ctrl.searchController,
                hintText: 'Search employees or reasons',
                leading: const Icon(Iconsax.search_normal,
                    color: AppColors.textMuted, size: 18),
              ),
            );
            final statusFilter = SizedBox(
              width: isNarrow ? double.infinity : 220,
              child: Obx(() => DropdownButtonFormField<String>(
                    key: ValueKey(_ctrl.selectedStatusFilter.value),
                    initialValue: _ctrl.selectedStatusFilter.value,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      filled: true,
                      fillColor: AppColors.surfaceMuted,
                      border: OutlineInputBorder(
                        borderRadius: AppRadii.brMd,
                        borderSide: BorderSide(color: AppColors.borderSubtle),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadii.brMd,
                        borderSide: BorderSide(color: AppColors.borderSubtle),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    items: _ctrl.filterStatusOptions
                        .map((value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        _ctrl.updateStatusFilter(value, context),
                  )),
            );

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  search,
                  const SizedBox(height: 12),
                  statusFilter,
                ],
              );
            }
            return Wrap(
              spacing: 14,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [search, statusFilter],
            );
          }),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (_ctrl.isLoading.value) {
            return context.isMobile
                ? LoadingSkeleton.listRows(count: 5)
                : LoadingSkeleton.table(rows: 5);
          }

          if (_ctrl.hasError.value) {
            return AppCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.danger,
                      size: 30, color: AppColors.warning),
                  const SizedBox(height: 12),
                  const Text('We could not load leave requests.',
                      style: AppTextStyles.h4, textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text('Check your connection and try again.',
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _ctrl.fetchLeaveRequests(context),
                    icon: const Icon(Iconsax.refresh),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            );
          }

          if (_ctrl.leaveList.isEmpty) {
            return EmptyState.noResults(
              title: 'No requests found',
              subtitle: 'Try adjusting the status, category, or search.',
            );
          }

          return Column(
            children: [
              ResponsiveTable<LeaveRequest>(
                items: _ctrl.leaveList,
                columns: const [
                  DataColumn(label: Text('Request')),
                  DataColumn(label: Text('Employee')),
                  DataColumn(label: Text('Period')),
                  DataColumn(label: Text('Duration')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rowBuilder: (request, _) => _buildDataRow(context, request),
                mobileCardBuilder: (request, _) =>
                    _buildMobileCard(context, request),
              ),
              const Divider(height: 1, color: AppColors.borderSubtle),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: PaginatorFooter(
                  totalItems: _ctrl.totalCount.value,
                  limit: _ctrl.itemsPerPage.value,
                  currentPage: _ctrl.currentPage.value,
                  onPageChanged: (page) => _ctrl.changePage(page, context),
                  onLimitChanged: (limit) => _ctrl.changeLimit(limit, context),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  DataRow _buildDataRow(BuildContext context, LeaveRequest request) {
    final isLate = request.requestKind == 'running_late';
    final duration = request.durationDays ??
        (request.startDate != null && request.endDate != null
            ? request.endDate!.difference(request.startDate!).inDays + 1
            : 0);

    return DataRow(cells: [
      DataCell(SizedBox(
        width: 150,
        child: Text(_categoryLabel(request),
            style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600)),
      )),
      DataCell(SizedBox(
        width: 190,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.employeeName?.isNotEmpty == true
                  ? request.employeeName!
                  : request.employeeId,
              style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
            if ((request.employeeCode ?? '').isNotEmpty)
              Text(request.employeeCode!,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      )),
      DataCell(SizedBox(
        width: 180,
        child: Text(_periodLabel(request), style: AppTextStyles.bodySm),
      )),
      DataCell(Text(
        isLate ? '—' : '$duration day${duration == 1 ? '' : 's'}',
        style: AppTextStyles.bodySm,
      )),
      DataCell(
          StatusChip.fromStatus(request.status?.toLowerCase() ?? 'pending')),
      DataCell(_buildRequestActions(context, request)),
    ]);
  }

  String _categoryLabel(LeaveRequest request) {
    return switch (request.requestKind) {
      'absence' => 'Absence request',
      'running_late' => 'Late-arrival report',
      _ => request.leaveType.isEmpty
          ? 'Leave request'
          : toBeginningOfSentenceCase(request.leaveType.replaceAll('_', ' ')),
    };
  }

  String _periodLabel(LeaveRequest request) {
    if (request.startDate == null) return 'Date not provided';
    final start = DateFormat('dd MMM yyyy').format(request.startDate!);
    if (request.requestKind == 'running_late' || request.endDate == null) {
      return start;
    }
    final end = DateFormat('dd MMM yyyy').format(request.endDate!);
    return start == end ? start : '$start - $end';
  }

  Widget _buildRequestActions(BuildContext context, LeaveRequest request) {
    final permissions = Get.find<PermissionService>();
    final canEditRequest = (request.status ?? '').toLowerCase() == 'pending' &&
        request.requestKind == 'leave';

    return Obx(() {
      // ignore: unused_local_variable
      final _ = permissions.version;
      return ThreeDotPop(
        onTapView: () => _openView(context, request),
        onTapEdit: canEditRequest && permissions.has(Perms.leaveRequestsUpdate)
            ? () => _openEdit(context, request)
            : null,
      );
    });
  }

  void _openView(BuildContext context, LeaveRequest request) {
    showDialog(
      context: context,
      builder: (_) => ViewLeaveRequestDialog(request: request),
    );
  }

  void _openEdit(BuildContext context, LeaveRequest request) {
    _ctrl.populateForm(request);
    showDialog(
      context: context,
      builder: (_) => AddLeaveRequestDialog(request: request),
    );
  }

  // --- Helper Widgets ---

  Widget _buildTabButton(String text, bool isActive, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () => _ctrl.setActiveTab(text, context),
      borderRadius: AppRadii.brPill,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surface,
          borderRadius: AppRadii.brPill,
          border: Border.all(
              color: isActive ? AppColors.primary : AppColors.borderSubtle),
        ),
        child: Text(
          text,
          style: AppTextStyles.bodySm.copyWith(
            color: isActive ? AppColors.textOnPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String value, String label) {
    final isActive = _ctrl.selectedRequestKind.value == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: _buildTabButton(label, isActive,
          onTap: () => _ctrl.updateRequestKindFilter(value, context)),
    );
  }

  Widget _buildMobileCard(BuildContext context, LeaveRequest r) {
    final isLate = r.requestKind == 'running_late';
    final status = r.status?.toLowerCase() ?? 'pending';
    final duration = r.durationDays ??
        (r.endDate != null && r.startDate != null
            ? r.endDate!.difference(r.startDate!).inDays + 1
            : 0);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.sm,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _categoryLabel(r),
                  style: AppTextStyles.bodyMd
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              StatusChip.fromStatus(status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.surfaceMuted,
                radius: 16,
                child: Icon(Iconsax.profile_circle,
                    color: AppColors.textMuted, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.employeeName?.isNotEmpty == true
                          ? r.employeeName!
                          : r.employeeId,
                      style: AppTextStyles.bodySm
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    if ((r.employeeCode ?? '').isNotEmpty ||
                        (r.branchName ?? '').isNotEmpty)
                      Text(
                        [
                          if ((r.employeeCode ?? '').isNotEmpty)
                            r.employeeCode!,
                          if ((r.branchName ?? '').isNotEmpty) r.branchName!,
                        ].join(' · '),
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLate ? 'Reported' : 'Duration',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted),
                  ),
                  Text(
                    isLate
                        ? (r.createdAt == null
                            ? 'Today'
                            : DateFormat('dd MMM, h:mm a').format(r.createdAt!))
                        : '$duration Day${duration != 1 ? 's' : ''}',
                    style: AppTextStyles.bodySm
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isLate ? 'Report date' : 'Dates',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted),
                  ),
                  Text(_periodLabel(r), style: AppTextStyles.bodySm),
                ],
              ),
            ],
          ),
          if (r.reason != null && r.reason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Reason: ${r.reason!}',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: _buildRequestActions(context, r),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color accent;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: AppRadii.brSm,
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: AppTextStyles.h1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
