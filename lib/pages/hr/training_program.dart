import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/nav/three_dot_pop.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/widget/add_program_dialog.dart';
import 'package:bms_front_end/pages/hr/widget/view_program_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/pages/company/company.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'controller/training_program_controller.dart';

class TrainingProgramPage extends StatefulWidget {
  const TrainingProgramPage({super.key});

  @override
  State<TrainingProgramPage> createState() => TrainingProgramPageState();
}

class TrainingProgramPageState extends State<TrainingProgramPage> {
  final ScrollController _scrollController = ScrollController();
  final TrainingProgramController _ctrl = Get.put(TrainingProgramController());
  final _storage = const FlutterSecureStorage();

  // Colors
  final Color _blueColor = const Color(0xFF1976D2);
  final Color _greenColor = const Color(0xFF27AE60);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.fetchData();
    });
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
        // --- 1. Header ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const MyText(
              'Training & Development',
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
                Obx(() => MyElevatedButton(
                      icon: const Icon(Icons.add_circle_outline_rounded,
                          color: AppColors.white, size: 20),
                      child: _ctrl.activeTab.value == 'Training Programs'
                          ? "Create Program"
                          : "Log Assessment",
                      onTap: () async {
                        if (_ctrl.activeTab.value == 'Training Programs') {
                          final token =
                              await _storage.read(key: 'access_token');
                          if (token != null && context.mounted) {
                            String cleanToken = token
                                .replaceAll('"', '')
                                .replaceAll('Bearer ', '')
                                .trim();
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  AddProgramDialog(token: cleanToken),
                            );
                          }
                        }
                      },
                    )),
              ],
            )
          ],
        ),
        const SizedBox(height: 24),

        // --- 2. Stats Cards ---
        Obx(() => ResponsiveStatRow(
              cards: [
                _buildStatCard(
                  title: 'Total Programs',
                  count: _ctrl.stats['totalPrograms'].toString(),
                  borderColor: _blueColor,
                  countColor: _blueColor,
                ),
                _buildStatCard(
                  title: 'Total Enrolled',
                  count: _ctrl.stats['totalEnrolled'].toString(),
                  borderColor: _greenColor,
                  countColor: _greenColor,
                ),
              ],
            )),
        const SizedBox(height: 32),

        // --- 3. Tabs ---
        Obx(() => Row(
              children: [
                _buildTabButton('Training Programs',
                    _ctrl.activeTab.value == 'Training Programs'),
                const SizedBox(width: 12),
                _buildTabButton('Skill Assessments',
                    _ctrl.activeTab.value == 'Skill Assessments'),
              ],
            )),
        const SizedBox(height: 24),

        // --- 4. Main Content Area (Filters + Table) ---
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
          ),
          child: Column(
            children: [
              // Filters
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 300,
                    child: MyTextFormField(
                      controller: _ctrl.searchController,
                      hintText: 'Search...',
                      leading: Icon(Icons.search,
                          color: AppColors.grey1.withValues(alpha: 0.5)),
                    ),
                  ),
                  Row(
                    children: [
                      _buildDropdownFilter("All Departments"),
                      const SizedBox(width: 12),
                      _buildStatusFilter(),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Table
              Obx(() {
                if (_ctrl.isLoading.value) {
                  return const SizedBox(
                      height: 300,
                      child: Center(child: CircularProgressIndicator()));
                }

                if (_ctrl.totalCount.value == 0) {
                  return const SizedBox(
                      height: 200,
                      child: Center(child: Text("No records found.")));
                }

                return Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: SizedBox(
                    width: double.infinity,
                    child: _ctrl.activeTab.value == 'Training Programs'
                        ? _buildProgramsTable()
                        : _buildAssessmentsTable(),
                  ),
                );
              }),

              const SizedBox(height: 16),
              const Divider(color: Color(0xFFEEEEEE)),
              const SizedBox(height: 16),

              // --- 5. Pagination ---
              Obx(() => PaginatorFooter(
                    totalItems: _ctrl.totalCount.value,
                    limit: _ctrl.itemsPerPage.value,
                    currentPage: _ctrl.currentPage.value,
                    onPageChanged: (newPage) => _ctrl.changePage(newPage),
                    onLimitChanged: (newLimit) => _ctrl.changeLimit(newLimit),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  // --- UI Components ---

  Widget _buildProgramsTable() {
    return DataTable(
      headingRowColor: MaterialStateProperty.all(Colors.transparent),
      dataRowColor: MaterialStateProperty.all(Colors.transparent),
      columnSpacing: 20,
      horizontalMargin: 0,
      headingTextStyle: const TextStyle(
          fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 14),
      columns: const [
        DataColumn(label: Text("Program")),
        DataColumn(label: Text("Category")),
        DataColumn(label: Text("Dates")),
        DataColumn(label: Text("Applicants")),
        DataColumn(label: Text("Mode")),
        DataColumn(label: Text("Status")),
        DataColumn(label: Text("Action")),
      ],
      rows: _ctrl.programList.map((program) {
        return DataRow(cells: [
          DataCell(
            InkWell(
              onTap: () async {
                final token = await _storage.read(key: 'access_token');
                if (token != null && context.mounted) {
                  String cleanToken = token
                      .replaceAll('"', '')
                      .replaceAll('Bearer ', '')
                      .trim();
                  showDialog(
                      context: context,
                      builder: (_) => ViewProgramDialog(
                          program: program, token: cleanToken));
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(program.programName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const Text("3 Weeks",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54)), // Dummy Data
                ],
              ),
            ),
          ),
          const DataCell(Text("Management")), // Dummy Data
          DataCell(Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  program.startDate != null
                      ? DateFormat('yyyy-MM-dd').format(program.startDate!)
                      : '-',
                  style: const TextStyle(fontSize: 13)),
              Text(
                  "to ${program.endDate != null ? DateFormat('yyyy-MM-dd').format(program.endDate!) : '-'}",
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          )),
          const DataCell(Text("5")), // Dummy Data
          DataCell(_buildModeBadge("Online")), // Dummy Data
          DataCell(_buildStatusBadge(program.status)),
          DataCell(ThreeDotPop(
            onTapView: () async {
              final token = await _storage.read(key: 'access_token');
              if (token != null && context.mounted) {
                String cleanToken =
                    token.replaceAll('"', '').replaceAll('Bearer ', '').trim();
                showDialog(
                    context: context,
                    builder: (_) =>
                        ViewProgramDialog(program: program, token: cleanToken));
              }
            },
          )),
        ]);
      }).toList(),
    );
  }

  Widget _buildAssessmentsTable() {
    return DataTable(
      headingRowColor: MaterialStateProperty.all(Colors.transparent),
      dataRowColor: MaterialStateProperty.all(Colors.transparent),
      columnSpacing: 20,
      horizontalMargin: 0,
      headingTextStyle: const TextStyle(
          fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 14),
      columns: const [
        DataColumn(label: Text("Employee")),
        DataColumn(label: Text("Identified Gap")),
        DataColumn(label: Text("Priority")),
        DataColumn(label: Text("Requested By")),
        DataColumn(label: Text("Status")),
        DataColumn(label: Text("Action")),
      ],
      rows: _ctrl.assessmentList.map((item) {
        return DataRow(cells: [
          DataCell(Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFE3F2FD),
                child: Text(
                    item.employeeName.isNotEmpty ? item.employeeName[0] : 'U',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2))),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.employeeName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(item.employeeRole,
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          )),
          DataCell(Text(item.gap,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          DataCell(_buildPriorityBadge(item.priority)),
          DataCell(Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFE3F2FD),
                child: Text(
                    item.requestedByName.isNotEmpty
                        ? item.requestedByName[0]
                        : 'U',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2))),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.requestedByName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  const Text("Software Engineer",
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          )),
          DataCell(_buildStatusBadge(item.status)),
          const DataCell(ThreeDotPop()),
        ]);
      }).toList(),
    );
  }

  Widget _buildStatCard(
      {required String title,
      required String count,
      required Color borderColor,
      required Color countColor}) {
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
      onTap: () => _ctrl.setActiveTab(text),
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
              fontWeight: FontWeight.w600,
              fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
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
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              onChanged: (val) => _ctrl.updateStatusFilter(val),
              items: _ctrl.statusOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
          )),
    );
  }

  Widget _buildDropdownFilter(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(text,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black54)
        ],
      ),
    );
  }

  Widget _buildModeBadge(String mode) {
    bool isOnline = mode.toLowerCase() == 'online';
    Color bg = isOnline ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5);
    Color txt = isOnline ? const Color(0xFF2E7D32) : Colors.black54;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(mode,
          style:
              TextStyle(color: txt, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color bg;
    Color txt;
    if (priority == 'High') {
      bg = const Color(0xFFFFEBEE);
      txt = const Color(0xFFC62828);
    } else if (priority == 'Medium') {
      bg = const Color(0xFFFFF8E1);
      txt = const Color(0xFFF9A825);
    } else {
      bg = const Color(0xFFE3F2FD);
      txt = const Color(0xFF1565C0);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(priority,
          style:
              TextStyle(color: txt, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color dot;
    String s = status.toLowerCase();

    if (s == 'active' || s == 'scheduled' || s == 'approved') {
      bg = const Color(0xFFF0FDF4); // Light Green
      dot = const Color(0xFF22C55E);
    } else if (s == 'pending') {
      bg = const Color(0xFFFFFBEB); // Light Yellow
      dot = const Color(0xFFF59E0B);
    } else {
      bg = const Color(0xFFF3F4F6); // Grey
      dot = const Color(0xFF9CA3AF);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(toBeginningOfSentenceCase(status) ?? status,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, size: 14, color: Colors.black54)
        ],
      ),
    );
  }
}
