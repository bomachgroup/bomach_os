import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/nav/three_dot_pop.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/widget/add_loan_dialog.dart';
import 'package:bms_front_end/pages/hr/widget/view_loans_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'controller/loans_controller.dart';

class LoanPage extends StatefulWidget {
  const LoanPage({super.key});

  @override
  State<LoanPage> createState() => _LoanPageState();
}

class _LoanPageState extends State<LoanPage> {
  final LoanController _ctrl = Get.put(LoanController());
  final ScrollController _scrollController = ScrollController();

  // Colors from design
  final Color _blueColor = const Color(0xFF1976D2);
  final Color _greenBg = const Color(0xFFF0FDF4);
  final Color _greenTxt = const Color(0xFF22C55E);
  final Color _redBg = const Color(0xFFFEF2F2);
  final Color _redTxt = const Color(0xFFEF4444);
  final Color _yellowBg = const Color(0xFFFFFBEB);
  final Color _yellowTxt = const Color(0xFFF59E0B);

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
              'Loans',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                MyElevatedButton(
                  icon: const Icon(Icons.add_circle_outline_rounded,
                      color: AppColors.white, size: 20),
                  child: "New Loan Application",
                  onTap: () {
                    // Standard Flutter Dialog
                    showDialog(
                        context: context,
                        builder: (ctx) => const AddLoanDialog());
                  },
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 24),

        // --- 2. Tabs ---
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

        // --- 3. Content Card ---
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
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
                      leading: Icon(
                        Icons.search,
                        color: AppColors.grey1.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  _buildStatusFilter(),
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

                if (_ctrl.displayedLoans.isEmpty) {
                  return const SizedBox(
                      height: 200,
                      child: Center(child: Text("No loans found.")));
                }

                return Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      headingRowColor:
                          WidgetStateProperty.all(Colors.transparent),
                      dataRowColor:
                          WidgetStateProperty.all(Colors.transparent),
                      columnSpacing: 20,
                      horizontalMargin: 0,
                      headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                          fontSize: 14),
                      columns: const [
                        DataColumn(label: Text("Employee")),
                        DataColumn(label: Text("Loan Amount")),
                        DataColumn(label: Text("Repayment Date")),
                        DataColumn(label: Text("Reason")),
                        DataColumn(label: Text("Status")),
                        DataColumn(label: Text("Action")),
                      ],
                      rows: _ctrl.displayedLoans.map((loan) {
                        return DataRow(cells: [
                          DataCell(Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: const Color(0xFFE3F2FD),
                                child: Text(loan.employeeName[0],
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
                                  Text(loan.employeeName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                  Text(loan.employeeRole,
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ],
                          )),
                          DataCell(Text(
                            NumberFormat.currency(symbol: '₦', decimalDigits: 0)
                                .format(loan.amount),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          )),
                          DataCell(Text(
                            DateFormat('yyyy-MM-dd').format(loan.repaymentDate),
                            style: const TextStyle(fontSize: 13),
                          )),
                          DataCell(Text(
                            loan.reason,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500),
                          )),
                          DataCell(_buildStatusBadge(loan.status)),
                          DataCell(ThreeDotPop(
                            onTapView: () {
                              showDialog(
                                  context: context,
                                  builder: (_) => ViewLoanDialog(
                                        loan: loan,
                                      ));
                            },
                            onTapEdit:   () {
                    // Standard Flutter Dialog
                    showDialog(
                        context: context,
                        builder: (ctx) =>  AddLoanDialog(loanToEdit: loan));
                  },
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),
              const Divider(color: Color(0xFFEEEEEE)),
              const SizedBox(height: 16),

              // Pagination
              Obx(() => PaginatorFooter(
                    totalItems: _ctrl.totalItems.value,
                    limit: _ctrl.itemsPerPage.value,
                    currentPage: _ctrl.currentPage.value,
                    onPageChanged: (page) => _ctrl.changePage(page),
                    onLimitChanged: (limit) => _ctrl.changeLimit(limit),
                  )),
            ],
          ),
        )
      ],
    );
  }

  // --- Widgets ---

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
            fontSize: 14,
          ),
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

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color dot;

    if (status == 'Approved') {
      bg = _greenBg;
      dot = _greenTxt;
    } else if (status == 'Rejected') {
      bg = _redBg;
      dot = _redTxt;
    } else {
      bg = _yellowBg;
      dot = _yellowTxt;
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
          Text(status,
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
