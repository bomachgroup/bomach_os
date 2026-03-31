import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/widget/add_leave_request_dialog.dart';
import 'package:bms_front_end/pages/company/company.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero Banner ──────────────────────────────────────────────
          _buildHeroBanner(),
          const SizedBox(height: 24),

          // ── Stats Row ────────────────────────────────────────────────
          Obx(() => _buildStatsRow()),
          const SizedBox(height: 28),

          // ── Table Section ────────────────────────────────────────────
          _buildTableSection(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Hero Banner
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0055FF), Color(0xFF1A3FCC), Color(0xFF0D2B99)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0055FF).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.event_note_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          // Text
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  'My Leave Requests',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 4),
                MyText(
                  'Track, manage and request time off',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // CTA button
          ElevatedButton.icon(
            onPressed: _openRequestDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0055FF),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text(
              'Request Leave',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Stats Row
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    final stats = _ctrl.stats;
    final cards = [
      _StatDef(
        label: 'Total Requests',
        value: _ctrl.totalCount.value.toString(),
        icon: Icons.list_alt_rounded,
        color: const Color(0xFF6366F1),
      ),
      _StatDef(
        label: 'Pending',
        value: (stats['pending'] ?? 0).toString(),
        icon: Icons.hourglass_top_rounded,
        color: const Color(0xFFF59E0B),
      ),
      _StatDef(
        label: 'Approved',
        value: (stats['approved'] ?? 0).toString(),
        icon: Icons.check_circle_rounded,
        color: const Color(0xFF10B981),
      ),
      _StatDef(
        label: 'Rejected',
        value: (stats['rejected'] ?? 0).toString(),
        icon: Icons.cancel_rounded,
        color: const Color(0xFFEF4444),
      ),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 700;
      if (isNarrow) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards
              .map((c) => SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: _buildStatCard(c),
                  ))
              .toList(),
        );
      }
      return Row(
        children: cards
            .map((c) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: c == cards.last ? 0 : 12),
                    child: _buildStatCard(c),
                  ),
                ))
            .toList(),
      );
    });
  }

  Widget _buildStatCard(_StatDef s) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: s.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(s.icon, color: s.color, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: s.color,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                s.label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Table Section
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTableSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ResponsiveSubheader(
              title: Obx(() => Row(
                    children: [
                      const Text(
                        'Leave History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_ctrl.totalCount.value}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blue,
                          ),
                        ),
                      ),
                    ],
                  )),
              search: MyTextFormField(
                controller: _ctrl.searchController,
                hintText: 'Search leaves...',
                leading: const Icon(Icons.search, color: Colors.grey, size: 20),
              ),
              action: Obx(() => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _ctrl.selectedStatusFilter.value,
                        isDense: true,
                        items: _ctrl.statusOptions
                            .map((s) =>
                                DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) =>
                            _ctrl.updateStatusFilter(v, context),
                      ),
                    ),
                  )),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE8ECF0)),

          // Body
          Obx(() {
            if (_ctrl.isLoading.value && _ctrl.leaveList.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (_ctrl.hasError.value) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          size: 40, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                        _ctrl.errorMessage.value,
                        style: const TextStyle(
                            color: Color(0xFF64748B), fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      MyElevatedButton(
                        child: 'Retry',
                        onTap: () => _ctrl.fetchMyLeaves(context),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (_ctrl.leaveList.isEmpty) {
              return _buildEmptyState();
            }
            return _buildTable();
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.event_busy_rounded,
                  size: 30, color: Color(0xFF6366F1)),
            ),
            const SizedBox(height: 16),
            const Text(
              'No leave requests found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Submit a request to take time off',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _openRequestDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Request Leave',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    return Column(
      children: [
        Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: DataTable(
              dataRowMinHeight: 60,
              dataRowMaxHeight: 60,
              columnSpacing: 28,
              horizontalMargin: 20,
              showBottomBorder: false,
              headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFF8FAFC)),
              headingTextStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
              columns: const [
                DataColumn(label: Text('LEAVE TYPE')),
                DataColumn(label: Text('PERIOD')),
                DataColumn(label: Text('DURATION')),
                DataColumn(label: Text('REASON')),
                DataColumn(label: Text('STATUS')),
              ],
              rows: _ctrl.leaveList.map((leave) {
                final startStr = leave.startDate != null
                    ? DateFormat('dd MMM yyyy').format(leave.startDate!)
                    : '-';
                final endStr = leave.endDate != null
                    ? DateFormat('dd MMM yyyy').format(leave.endDate!)
                    : '-';

                return DataRow(cells: [
                  // Leave Type with icon
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _leaveTypeColor(leave.leaveType)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _leaveTypeIcon(leave.leaveType),
                          size: 14,
                          color: _leaveTypeColor(leave.leaveType),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _formatLeaveType(leave.leaveType),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  )),

                  // Period
                  DataCell(Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(startStr,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0F172A))),
                      Text(
                        endStr == '-' ? '' : '→ $endStr',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  )),

                  // Duration
                  DataCell(Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${leave.durationDays ?? '-'} day${(leave.durationDays ?? 0) == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                  )),

                  // Reason
                  DataCell(SizedBox(
                    width: 220,
                    child: Text(
                      leave.reason ?? '-',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF475569)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),

                  // Status
                  DataCell(_buildStatusChip(leave.status ?? 'pending')),
                ]);
              }).toList(),
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE8ECF0)),
        Padding(
          padding: const EdgeInsets.all(16),
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
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    switch (status.toLowerCase()) {
      case 'approved':
        color = const Color(0xFF10B981);
        icon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        color = const Color(0xFFEF4444);
        icon = Icons.cancel_rounded;
        break;
      case 'pending':
        color = const Color(0xFFF59E0B);
        icon = Icons.hourglass_top_rounded;
        break;
      default:
        color = Colors.grey;
        icon = Icons.circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Text(
            status[0].toUpperCase() + status.substring(1),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _leaveTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'sick_leave':
      case 'sick leave':
        return const Color(0xFFEF4444);
      case 'annual_leave':
      case 'annual leave':
        return const Color(0xFF6366F1);
      case 'maternity_leave':
      case 'paternity_leave':
        return const Color(0xFFEC4899);
      case 'emergency_leave':
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF0EA5E9);
    }
  }

  IconData _leaveTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'sick_leave':
      case 'sick leave':
        return Icons.local_hospital_rounded;
      case 'annual_leave':
      case 'annual leave':
        return Icons.beach_access_rounded;
      case 'maternity_leave':
      case 'paternity_leave':
        return Icons.child_friendly_rounded;
      case 'emergency_leave':
        return Icons.warning_amber_rounded;
      default:
        return Icons.event_note_rounded;
    }
  }

  String _formatLeaveType(String type) {
    return type
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty
            ? '${w[0].toUpperCase()}${w.substring(1)}'
            : '')
        .join(' ');
  }
}

// ─── Internal helper model ────────────────────────────────────────────────────

class _StatDef {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatDef({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}
