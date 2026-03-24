import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/widget/add_leave_request_dialog.dart';
import 'package:bms_front_end/pages/company/company.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const MyText(
              'My Leaves',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            MyElevatedButton(
              height: 40,
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              child: 'Request Leave',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddLeaveRequestDialog(),
                ).then((_) => _ctrl.fetchMyLeaves(context, refresh: true));
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'View and manage your leave requests',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
        const SizedBox(height: 24),

        // Stats Cards
        Obx(() => _buildStatsRow()),
        const SizedBox(height: 24),

        // Search and Filter
        ResponsiveSubheader(
          title: Obx(() => MyText(
                '${_ctrl.totalCount.value} total requests',
                style: const TextStyle(
                    color: Color(0xFF64748B), fontSize: 13),
              )),
          search: MyTextFormField(
            controller: _ctrl.searchController,
            hintText: 'Search leaves...',
            leading: const Icon(Icons.search, color: Colors.grey, size: 20),
          ),
          action: Obx(() => DropdownButton<String>(
                value: _ctrl.selectedStatusFilter.value,
                underline: const SizedBox(),
                items: _ctrl.statusOptions
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => _ctrl.updateStatusFilter(v, context),
              )),
        ),
        const SizedBox(height: 16),

        // Table
        Obx(() {
          if (_ctrl.isLoading.value && _ctrl.leaveList.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (_ctrl.hasError.value) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(60),
                child: Column(
                  children: [
                    Text('Error: ${_ctrl.errorMessage.value}'),
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
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: Text('No leave requests found'),
              ),
            );
          }

          return Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border:
                      Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      dataRowMinHeight: 56,
                      dataRowMaxHeight: 56,
                      columnSpacing: 24,
                      horizontalMargin: 12,
                      showBottomBorder: true,
                      columns: const [
                        DataColumn(label: MyText('Leave Type')),
                        DataColumn(label: MyText('Start Date')),
                        DataColumn(label: MyText('End Date')),
                        DataColumn(label: MyText('Duration')),
                        DataColumn(label: MyText('Reason')),
                        DataColumn(label: MyText('Status')),
                      ],
                      rows: _ctrl.leaveList.map((leave) {
                        return DataRow(cells: [
                          DataCell(MyText(
                            _formatLeaveType(leave.leaveType),
                            size: 14,
                          )),
                          DataCell(MyText(
                            leave.startDate != null
                                ? DateFormat('dd MMM yyyy')
                                    .format(leave.startDate!)
                                : '-',
                            size: 14,
                          )),
                          DataCell(MyText(
                            leave.endDate != null
                                ? DateFormat('dd MMM yyyy')
                                    .format(leave.endDate!)
                                : '-',
                            size: 14,
                          )),
                          DataCell(MyText(
                            '${leave.durationDays ?? '-'} days',
                            size: 14,
                          )),
                          DataCell(
                            SizedBox(
                              width: 200,
                              child: MyText(
                                leave.reason ?? '-',
                                size: 14,
                                maxLines: 2,
                              ),
                            ),
                          ),
                          DataCell(_buildStatusChip(leave.status ?? 'pending')),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PaginatorFooter(
                currentPage: _ctrl.currentPage.value,
                totalItems: _ctrl.totalCount.value,
                limit: _ctrl.itemsPerPage.value,
                onPageChanged: (p) => _ctrl.changePage(p, context),
                onLimitChanged: (l) => _ctrl.changeLimit(l, context),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildStatsRow() {
    final stats = _ctrl.stats;
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard(
          'Total Requests',
          _ctrl.totalCount.value.toString(),
          const Color(0xFF1976D2),
          Icons.list_alt,
        ),
        _buildStatCard(
          'Pending',
          (stats['pending'] ?? 0).toString(),
          const Color(0xFFC27803),
          Icons.hourglass_empty,
        ),
        _buildStatCard(
          'Approved',
          (stats['approved'] ?? 0).toString(),
          const Color(0xFF27AE60),
          Icons.check_circle_outline,
        ),
        _buildStatCard(
          'Rejected',
          (stats['rejected'] ?? 0).toString(),
          const Color(0xFFEB5757),
          Icons.cancel_outlined,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.05),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
        color = const Color(0xFF27AE60);
        break;
      case 'rejected':
        color = const Color(0xFFEB5757);
        break;
      case 'pending':
        color = const Color(0xFFC27803);
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status[0].toUpperCase() + status.substring(1),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLeaveType(String type) {
    return type
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }
}
