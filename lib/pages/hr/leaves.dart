import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/paginate/my_paginator.dart';
import 'package:bomach_os/components/paginate/responsive_table.dart';
import 'package:bomach_os/components/permission/permission_gate.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/components/section/responsive_stat_row.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/pages/hr/widget/add_leave_request_dialog.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:bomach_os/pages/hr/controller/leave_request_controller.dart';
import 'controller/my_leaves_controller.dart';
import 'models/leave_request_model.dart';
import 'widget/view_leave_request_dialog.dart';

class LeavesPage extends StatefulWidget {
  final int? initialRequestId;
  const LeavesPage({super.key, this.initialRequestId});

  @override
  State<LeavesPage> createState() => _LeavesPageState();
}

class _LeavesPageState extends State<LeavesPage> {
  final MyLeavesController _ctrl = Get.put(MyLeavesController());
  late final VoidCallback _searchListener;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<LeaveRequestController>()) {
      Get.put(LeaveRequestController());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialRequest();
    });
    _searchListener = () => _ctrl.onSearchChanged(context);
    _ctrl.searchController.addListener(_searchListener);
  }

  @override
  void dispose() {
    _ctrl.searchController.removeListener(_searchListener);
    super.dispose();
  }

  Future<void> _loadInitialRequest() async {
    final requestId = widget.initialRequestId;
    if (requestId != null) {
      _ctrl
        ..selectedRequestKind.value = 'all'
        ..selectedStatusFilter.value = 'All'
        ..currentPage.value = 1;
      _ctrl.clearSearch();
    }
    await _ctrl.fetchMyLeaves(context, requestId: requestId);
    if (!mounted || requestId == null) return;
    final request =
        _ctrl.leaveList.firstWhereOrNull((item) => item.id == requestId);
    if (request == null) {
      AppToast.warning(
          context, 'This request is not available in your personal records.');
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (_) => ViewLeaveRequestDialog(request: request),
    );
  }

  void _openRequestDialog() {
    showDialog(
      context: context,
      builder: (_) => const AddLeaveRequestDialog(),
    ).then((_) => _ctrl.fetchMyLeaves(context, refresh: true));
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'My Leave & Attendance Requests',
        subtitle: 'Track leave, absence, and late-arrival reports.',
        trailing: PermissionGate(
          require: Perms.leaveRequestsCreate,
          child: MyElevatedButton(
            height: 48,
            icon: const Icon(Iconsax.add_circle,
                color: AppColors.textOnPrimary, size: 18),
            child: 'New Request',
            onTap: _openRequestDialog,
          ),
        ),
      ),
      children: [
        Obx(() => _buildStatsRow()),
        _buildTableCard(),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Stats Row
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    final stats = _ctrl.stats;
    return ResponsiveStatRow(
      cards: [
        _buildStatCard(
          label: 'Total Requests',
          value: _ctrl.totalCount.value.toString(),
          icon: Iconsax.task_square,
          tone: StatusTone.primary,
        ),
        _buildStatCard(
          label: 'Pending',
          value: (stats['pending'] ?? 0).toString(),
          icon: Iconsax.timer,
          tone: StatusTone.warning,
        ),
        _buildStatCard(
          label: 'Approved',
          value: (stats['approved'] ?? 0).toString(),
          icon: Iconsax.tick_circle,
          tone: StatusTone.success,
        ),
        _buildStatCard(
          label: 'Rejected',
          value: (stats['rejected'] ?? 0).toString(),
          icon: Iconsax.close_circle,
          tone: StatusTone.danger,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required StatusTone tone,
  }) {
    final color = _toneColor(tone);
    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.sm,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppRadii.brMd,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppTextStyles.h1.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _toneColor(StatusTone tone) {
    switch (tone) {
      case StatusTone.success:
        return AppColors.success;
      case StatusTone.warning:
        return AppColors.warning;
      case StatusTone.danger:
        return AppColors.danger;
      case StatusTone.info:
        return AppColors.info;
      case StatusTone.primary:
        return AppColors.primary;
      case StatusTone.neutral:
        return AppColors.textSecondary;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Table Section
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTableCard() {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('My Requests', style: AppTextStyles.h3),
                          const SizedBox(height: 4),
                          Obx(() => Text(
                                '${_ctrl.totalCount.value} request${_ctrl.totalCount.value == 1 ? '' : 's'} on record',
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              )),
                        ],
                      ),
                    ),
                    const StatusChip(
                      label: 'Personal record',
                      tone: StatusTone.primary,
                      icon: Iconsax.calendar_1,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFilterRow(),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Obx(() {
            if (_ctrl.isLoading.value && _ctrl.leaveList.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: LoadingSkeleton.listRows(count: 5),
              );
            }
            if (_ctrl.hasError.value) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: EmptyState(
                  icon: Iconsax.danger,
                  title: 'Unable to load leaves',
                  subtitle: _ctrl.errorMessage.value,
                  action: MyElevatedButton(
                    child: 'Retry',
                    onTap: () => _ctrl.fetchMyLeaves(
                      context,
                      requestId: widget.initialRequestId,
                    ),
                  ),
                ),
              );
            }
            if (_ctrl.leaveList.isEmpty) {
              return _buildEmptyState();
            }
            return Column(
              children: [
                _buildTable(),
                const Divider(height: 1, color: AppColors.borderSubtle),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: PaginatorFooter(
                    currentPage: _ctrl.currentPage.value,
                    totalItems: _ctrl.totalCount.value,
                    limit: _ctrl.itemsPerPage.value,
                    onPageChanged: (p) => _ctrl.changePage(p, context),
                    onLimitChanged: (l) => _ctrl.changeLimit(l, context),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 640;
      final search = MyTextFormField(
        controller: _ctrl.searchController,
        hintText: 'Search leaves by type or reason',
        height: 48,
        leading: const Icon(Iconsax.search_normal,
            size: 18, color: AppColors.textMuted),
      );
      final filter = Obx(() => SizedBox(
            width: isNarrow ? double.infinity : 220,
            child: MyDropdown(
              hintText: _ctrl.selectedStatusFilter.value,
              initialSelection: _ctrl.selectedStatusFilter.value,
              items: _ctrl.statusOptions,
              onChanged: (v) => _ctrl.updateStatusFilter(v, context),
            ),
          ));
      final kindFilter = Obx(() {
        final selected = _ctrl.selectedRequestKind.value;
        final selectionLabel = _requestKindFilterLabel(selected);
        return SizedBox(
          width: isNarrow ? double.infinity : 190,
          child: MyDropdown(
            hintText: selectionLabel,
            initialSelection: selectionLabel,
            items: const [
              'All request types',
              'Leave',
              'Absence',
              'Late arrival',
            ],
            onChanged: (label) => _ctrl.updateRequestKindFilter(
              switch (label) {
                'Leave' => 'leave',
                'Absence' => 'absence',
                'Late arrival' => 'running_late',
                _ => 'all',
              },
              context,
            ),
          ),
        );
      });

      if (isNarrow) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            search,
            const SizedBox(height: 12),
            filter,
            const SizedBox(height: 12),
            kindFilter,
          ],
        );
      }
      return Row(
        children: [
          Expanded(child: search),
          const SizedBox(width: 12),
          filter,
          const SizedBox(width: 12),
          kindFilter,
        ],
      );
    });
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: EmptyState(
        icon: Iconsax.calendar_remove,
        title: 'No requests found',
        subtitle: 'Submit a leave, absence, or late-arrival report.',
        action: PermissionGate(
          require: Perms.leaveRequestsCreate,
          child: MyElevatedButton(
            icon: const Icon(Iconsax.add_circle,
                color: AppColors.textOnPrimary, size: 18),
            child: 'New Request',
            onTap: _openRequestDialog,
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    return ResponsiveTable(
      items: _ctrl.leaveList,
      columns: const [
        DataColumn(label: Text('Request Type')),
        DataColumn(label: Text('Period')),
        DataColumn(label: Text('Duration')),
        DataColumn(label: Text('Reason')),
        DataColumn(label: Text('Status')),
      ],
      rowBuilder: (leave, index) {
        final period = _periodLabel(leave);
        final duration = _durationLabel(leave);
        final status = (leave.status ?? 'pending');

        return DataRow(cells: [
          // Leave Type
          DataCell(Align(
            alignment: Alignment.centerLeft,
            child: StatusChip(
              label: _requestTypeLabel(leave),
              tone: _requestTypeTone(leave),
              icon: _requestTypeIcon(leave),
              dense: true,
            ),
          )),
          // Period
          DataCell(Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                period,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )),
          // Duration
          DataCell(Text(
            duration,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          )),
          // Reason
          DataCell(SizedBox(
            width: 220,
            child: Text(
              leave.reason ?? '-',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          )),
          // Status
          DataCell(Align(
            alignment: Alignment.centerLeft,
            child: StatusChip(
              label: _titleCase(status),
              tone: _statusTone(status),
              icon: _statusIcon(status),
              dense: true,
            ),
          )),
        ]);
      },
      mobileCardBuilder: (leave, index) {
        final period = _periodLabel(leave);
        final duration = _durationLabel(leave);
        final status = (leave.status ?? 'pending');

        return AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusChip(
                    label: _requestTypeLabel(leave),
                    tone: _requestTypeTone(leave),
                    icon: _requestTypeIcon(leave),
                    dense: true,
                  ),
                  StatusChip(
                    label: _titleCase(status),
                    tone: _statusTone(status),
                    dense: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MyText('Period',
                            size: 11, color: AppColors.textSecondary),
                        const SizedBox(height: 4),
                        MyText(period,
                            size: 13,
                            weight: 600,
                            color: AppColors.textPrimary),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const MyText('Duration',
                          size: 11, color: AppColors.textSecondary),
                      const SizedBox(height: 4),
                      MyText(duration,
                          size: 13, weight: 700, color: AppColors.primary),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              const MyText('Reason', size: 11, color: AppColors.textSecondary),
              const SizedBox(height: 4),
              MyText(leave.reason ?? '-',
                  size: 13, color: AppColors.textPrimary, maxLines: 2),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  StatusTone _statusTone(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return StatusTone.success;
      case 'rejected':
        return StatusTone.danger;
      case 'pending':
        return StatusTone.warning;
      case 'cancelled':
      case 'canceled':
        return StatusTone.neutral;
      default:
        return StatusTone.neutral;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Iconsax.tick_circle;
      case 'rejected':
        return Iconsax.close_circle;
      case 'pending':
        return Iconsax.timer;
      default:
        return Iconsax.record_circle;
    }
  }

  StatusTone _leaveTypeTone(String type) {
    switch (type.toLowerCase()) {
      case 'sick_leave':
      case 'sick leave':
        return StatusTone.info;
      case 'annual_leave':
      case 'annual leave':
        return StatusTone.primary;
      case 'unpaid_leave':
        return StatusTone.neutral;
      case 'maternity_leave':
      case 'paternity_leave':
        return StatusTone.warning;
      case 'emergency_leave':
        return StatusTone.danger;
      default:
        return StatusTone.info;
    }
  }

  IconData _leaveTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'sick_leave':
      case 'sick leave':
        return Iconsax.hospital;
      case 'annual_leave':
      case 'annual leave':
        return Iconsax.sun;
      case 'maternity_leave':
      case 'paternity_leave':
        return Iconsax.milk;
      case 'emergency_leave':
        return Iconsax.warning_2;
      default:
        return Iconsax.calendar_1;
    }
  }

  String _formatLeaveType(String type) {
    return type
        .replaceAll('_', ' ')
        .split(' ')
        .map(
            (w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  String _requestTypeLabel(LeaveRequest request) =>
      switch (request.requestKind) {
        'absence' => 'Absence report',
        'running_late' => 'Late-arrival report',
        _ => _formatLeaveType(request.leaveType).isEmpty
            ? 'Leave request'
            : _formatLeaveType(request.leaveType),
      };

  StatusTone _requestTypeTone(LeaveRequest request) =>
      switch (request.requestKind) {
        'absence' => StatusTone.info,
        'running_late' => StatusTone.warning,
        _ => _leaveTypeTone(request.leaveType),
      };

  IconData _requestTypeIcon(LeaveRequest request) =>
      switch (request.requestKind) {
        'absence' => Iconsax.document_text,
        'running_late' => Iconsax.clock,
        _ => _leaveTypeIcon(request.leaveType),
      };

  String _periodLabel(LeaveRequest request) {
    final start = request.startDate;
    if (start == null) return 'Date unavailable';
    final startLabel = DateFormat('dd MMM yyyy').format(start);
    if (request.requestKind == 'running_late' || request.endDate == null) {
      return startLabel;
    }
    final endLabel = DateFormat('dd MMM yyyy').format(request.endDate!);
    return startLabel == endLabel ? startLabel : '$startLabel - $endLabel';
  }

  String _durationLabel(LeaveRequest request) {
    if (request.requestKind == 'running_late') return 'Not applicable';
    final days = request.durationDays;
    if (days == null) return '—';
    return '$days day${days == 1 ? '' : 's'}';
  }

  String _requestKindFilterLabel(String kind) => switch (kind) {
        'leave' => 'Leave',
        'absence' => 'Absence',
        'running_late' => 'Late arrival',
        _ => 'All request types',
      };

  String _titleCase(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
