import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/nav/three_dot_pop.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/widget/add_leave_request_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/pages/company/company.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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

  // Colors
  final Color _orangeColor = const Color(0xFFC27803);
  final Color _blueColor = const Color(0xFF1976D2);
  final Color _greenColor = const Color(0xFF27AE60);
  final Color _greenBg = const Color(0xFFE8F5E9);
  final Color _redColor = const Color(0xFFEB5757);
  final Color _redBg = const Color(0xFFFFEBEE);
  final Color _orangeBg = const Color(0xFFFDF6E7);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.fetchLeaveRequests(context);
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
        // --- 1. Header Section ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const MyText(
              'Leave Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 18),
                  ),
                  child: const Text(
                    "Leave Policy",
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                const SizedBox(width: 12),
                MyElevatedButton(
                  icon: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: AppColors.white,
                    size: 20,
                  ),
                  child: "Leave Application",
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const AddLeaveRequestDialog();
                      },
                    );
                  },
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 24),

        // --- 2. Stats Cards Section ---
        Obx(() => ResponsiveStatRow(
              cards: [
                _buildStatCard(
                  title: 'Pending Requests',
                  count: _ctrl.stats['pending'].toString(),
                  borderColor: _orangeColor,
                  countColor: _orangeColor,
                ),
                _buildStatCard(
                  title: 'On Leave Today',
                  count: _ctrl.stats['onLeave'].toString(),
                  borderColor: _blueColor,
                  countColor: _blueColor,
                ),
                _buildStatCard(
                  title: 'Approved This Month',
                  count: _ctrl.stats['approved'].toString(),
                  borderColor: _greenColor,
                  countColor: _greenColor,
                ),
                _buildStatCard(
                  title: 'Rejected',
                  count: _ctrl.stats['rejected'].toString(),
                  borderColor: _redColor,
                  countColor: _redColor,
                ),
              ],
            )),
        const SizedBox(height: 32),

        // --- 3. Tabs Section ---
        Obx(() => Row(
              children: [
                _buildTabButton('All', _ctrl.activeTab.value == 'All'),
                const SizedBox(width: 12),
                _buildTabButton('Pending Approvals',
                    _ctrl.activeTab.value == 'Pending Approvals'),
                const SizedBox(width: 12),
                _buildTabButton('History', _ctrl.activeTab.value == 'History'),
              ],
            )),
        const SizedBox(height: 24),

        // --- 4. Filters & Table Section ---
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filters Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // --- Search Field ---
                  SizedBox(
                    width: 300,
                    child: MyTextFormField(
                      controller: _ctrl.searchController,
                      hintText: 'Search...',
                      leading: Icon(
                        Icons.search,
                        color: AppColors.grey1.withValues(alpha: 0.5),
                      ),
                    ),
                  ),

                  // --- Status Filter (Dropdown) ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200)),
                    child: Obx(() => DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _ctrl.selectedStatusFilter.value,
                            icon: const Icon(Icons.keyboard_arrow_down,
                                size: 18, color: Colors.black54),
                            elevation: 4,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black87),
                            onChanged: (String? newValue) {
                              _ctrl.updateStatusFilter(newValue, context);
                            },
                            items: _ctrl.filterStatusOptions
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Data Table
              Obx(() {
                if (_ctrl.isLoading.value) {
                  return const SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (_ctrl.hasError.value) {
                  return Center(
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: AppColors.red),
                        const SizedBox(height: 8),
                        Text(_ctrl.errorMessage.value),
                        TextButton(
                            onPressed: () => _ctrl.fetchLeaveRequests(context),
                            child: const Text("Retry"))
                      ],
                    ),
                  );
                }

                if (_ctrl.leaveList.isEmpty) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: Text("No records found")),
                  );
                }

                return Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      headingRowColor:
                          MaterialStateProperty.all(Colors.transparent),
                      dataRowColor:
                          MaterialStateProperty.all(Colors.transparent),
                      columnSpacing: 20,
                      horizontalMargin: 0,
                      headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                          fontSize: 14),
                      dataRowMaxHeight: 72,
                      columns: _createColumns(),
                      rows: _createRows(context, _ctrl.leaveList),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // --- 5. Pagination Footer ---
              const Divider(color: Color(0xFFEEEEEE)),
              const SizedBox(height: 16),

              Obx(() => PaginatorFooter(
                    totalItems: _ctrl.totalCount.value,
                    limit: _ctrl.itemsPerPage.value,
                    currentPage: _ctrl.currentPage.value,
                    onPageChanged: (newPage) {
                      _ctrl.changePage(newPage, context);
                    },
                    onLimitChanged: (newLimit) {
                      _ctrl.changeLimit(newLimit, context);
                    },
                  )),
            ],
          ),
        ),
      ],
    );
  }

  // --- Helper Widgets ---

  Widget _buildStatCard({
    required String title,
    required String count,
    required Color borderColor,
    required Color countColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87)),
          const SizedBox(height: 12),
          Text(count,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: countColor)),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, bool isActive) {
    return InkWell(
      onTap: () => _ctrl.setActiveTab(text, context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? _blueColor : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: isActive ? _blueColor : const Color(0xFFE0E0E0)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // --- Table Configuration ---

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(label: Text("Employee")),
      const DataColumn(label: Text("Leave Type")),
      const DataColumn(label: Text("Dates")),
      const DataColumn(label: Text("Days")),
      const DataColumn(label: Text("Reason")),
      const DataColumn(label: Text("Status")),
      const DataColumn(label: Text("Action")),
    ];
  }

  List<DataRow> _createRows(BuildContext context, List<LeaveRequest> items) {
    return items.map((r) {
      final duration = r.durationDays ??
          (r.endDate != null && r.startDate != null
              ? r.endDate!.difference(r.startDate!).inDays + 1
              : 0);

      final status = r.status?.toLowerCase() ?? 'pending';

      return DataRow(
        cells: <DataCell>[
          DataCell(
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFEEEEEE),
                  radius: 18,
                  child: const Icon(Icons.person, color: Colors.grey, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      r.employeeId,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const Text(
                      "Software Engineer",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          DataCell(Text(
            toBeginningOfSentenceCase(r.leaveType.replaceAll('_', ' ')) ??
                r.leaveType,
            style: const TextStyle(fontWeight: FontWeight.w500),
          )),
          DataCell(Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r.startDate != null
                    ? DateFormat('yyyy-MM-dd').format(r.startDate!)
                    : '',
                style: const TextStyle(fontSize: 13),
              ),
              Text(
                "to ${r.endDate != null ? DateFormat('yyyy-MM-dd').format(r.endDate!) : ''}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          )),
          DataCell(Text(duration.toString())),
          DataCell(SizedBox(
            width: 150,
            child: Text(
              r.reason ?? "No reason",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          )),
          DataCell(_buildStatusBadge(status)),
          DataCell(
            ThreeDotPop(
              onTapView: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return ViewLeaveRequestDialog(request: r);
                  },
                );
              },
              onTapEdit: () {
                _ctrl.populateForm(r);
                showDialog(
                    context: context,
                    builder: (_) => AddLeaveRequestDialog(request: r));
              },
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    String label;

    if (status == 'approved') {
      bg = _greenBg;
      text = _greenColor;
      label = "Approved";
    } else if (status == 'rejected') {
      bg = _redBg;
      text = _redColor;
      label = "Rejected";
    } else {
      bg = _orangeBg;
      text = _orangeColor;
      label = "Pending";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: text, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
                color: text, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, size: 14, color: text)
        ],
      ),
    );
  }
}
