import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/permission/permission_gate.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/loading_skeleton.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/components/section/responsive_stat_row.dart';
import 'package:bms_front_end/pages/hr/widget/add_leave_request_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/permissions.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:bms_front_end/pages/hr/controller/leave_request_controller.dart';
import 'controller/my_leaves_controller.dart';

class LeavesPage extends StatefulWidget {
  const LeavesPage({super.key});

  @override
  State<LeavesPage> createState() => _LeavesPageState();
}

class _LeavesPageState extends State<LeavesPage> {
  final ScrollController _scrollController = ScrollController();
  final MyLeavesController _ctrl = Get.put(MyLeavesController());

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<LeaveRequestController>()) {
      Get.put(LeaveRequestController());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.fetchMyLeaves(context);
    });
    _ctrl.searchController.addListener(() => _ctrl.onSearchChanged(context));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
        title: 'My Leave Requests',
        subtitle: 'Track, manage and request time off.',
        trailing: PermissionGate(
          require: Perms.leaveRequestsCreate,
          child: MyElevatedButton(
            height: 48,
            icon: const Icon(Iconsax.add_circle,
                color: AppColors.textOnPrimary, size: 18),
            child: 'Request Leave',
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
                          const Text('Leave History', style: AppTextStyles.h3),
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
                      label: 'Personal leave log',
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
                    onTap: () => _ctrl.fetchMyLeaves(context),
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

      if (isNarrow) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            search,
            const SizedBox(height: 12),
            filter,
          ],
        );
      }
      return Row(
        children: [
          Expanded(child: search),
          const SizedBox(width: 12),
          filter,
        ],
      );
    });
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: EmptyState(
        icon: Iconsax.calendar_remove,
        title: 'No leave requests found',
        subtitle: 'Submit a request to take time off.',
        action: PermissionGate(
          require: Perms.leaveRequestsCreate,
          child: MyElevatedButton(
            icon: const Icon(Iconsax.add_circle,
                color: AppColors.textOnPrimary, size: 18),
            child: 'Request Leave',
            onTap: _openRequestDialog,
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 64,
          ),
          child: DataTable(
            dataRowMinHeight: 64,
            dataRowMaxHeight: 72,
            columnSpacing: 28,
            horizontalMargin: 20,
            showBottomBorder: false,
            headingRowColor:
                WidgetStateProperty.all(AppColors.surfaceMuted),
            headingTextStyle: AppTextStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            dividerThickness: 1,
            columns: const [
              DataColumn(label: Text('Leave Type')),
              DataColumn(label: Text('Period')),
              DataColumn(label: Text('Duration')),
              DataColumn(label: Text('Reason')),
              DataColumn(label: Text('Status')),
            ],
            rows: _ctrl.leaveList.map((leave) {
              final startStr = leave.startDate != null
                  ? DateFormat('dd MMM yyyy').format(leave.startDate!)
                  : '-';
              final endStr = leave.endDate != null
                  ? DateFormat('dd MMM yyyy').format(leave.endDate!)
                  : '-';
              final days = leave.durationDays ?? 0;
              final status = (leave.status ?? 'pending');

              return DataRow(cells: [
                // Leave Type
                DataCell(Align(
                  alignment: Alignment.centerLeft,
                  child: StatusChip(
                    label: _formatLeaveType(leave.leaveType),
                    tone: _leaveTypeTone(leave.leaveType),
                    icon: _leaveTypeIcon(leave.leaveType),
                    dense: true,
                  ),
                )),
                // Period
                DataCell(Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      startStr,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (endStr != '-') ...[
                      const SizedBox(height: 2),
                      Text(
                        '→ $endStr',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                )),
                // Duration
                DataCell(Text(
                  '$days day${days == 1 ? '' : 's'}',
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
            }).toList(),
          ),
        ),
      ),
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

  String _titleCase(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
