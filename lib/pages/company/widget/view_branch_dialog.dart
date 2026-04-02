import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/model/branch_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/branch_controller.dart';
import 'add_branch_dialog.dart';

class ViewBranchDialog extends StatefulWidget {
  const ViewBranchDialog({super.key});

  @override
  State<ViewBranchDialog> createState() => _ViewBranchDialogState();
}

class _ViewBranchDialogState extends State<ViewBranchDialog>
    with SingleTickerProviderStateMixin {
  final BranchController controller = Get.find<BranchController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        child: Obx(() {
          if (controller.isLoadingDetail.value) {
            return const SizedBox(
              height: 300,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final branch = controller.currentBranch.value;
          if (branch == null) {
            return const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: Text("No branch data available")),
            );
          }

          return Column(
            children: [
              // Header
              _buildHeader(branch),
              const Divider(height: 1),

              // Tabs
              Container(
                color: const Color(0xFFF8FAFC),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppColors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.blue,
                  indicatorWeight: 2,
                  labelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w400),
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Departments'),
                    Tab(text: 'Projects'),
                    Tab(text: 'Financial'),
                    Tab(text: 'People'),
                  ],
                ),
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(branch),
                    _buildDepartmentsTab(),
                    _buildProjectsTab(),
                    _buildFinancialTab(),
                    _buildPeopleTab(branch),
                  ],
                ),
              ),

              // Footer
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyElevatedButton(
                      width: 120,
                      child: "Edit Branch",
                      onTap: () {
                        Navigator.pop(context);
                        controller.loadFilterResources();
                        showDialog(
                          context: context,
                          builder: (_) => AddBranchDialog(branchToEdit: branch),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader(Branch branch) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Branch icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.business, color: AppColors.blue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: MyText(
                        branch.branchName,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(branch.operationalStatusDisplay),
                  ],
                ),
                const SizedBox(height: 4),
                MyText(
                  "${branch.branchRoleDisplay} | ID: #${branch.id}",
                  size: 12,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // ─── OVERVIEW TAB ───
  Widget _buildOverviewTab(Branch branch) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branch Details
          _buildSectionTitle("Branch Details"),
          const SizedBox(height: 12),
          _buildDetailGrid([
            _DetailItem("Branch Name", branch.branchName),
            _DetailItem("Branch Type", branch.branchRoleDisplay),
            _DetailItem("Branch ID",
                branch.branchId.isNotEmpty ? branch.branchId : "#${branch.id}"),
            _DetailItem(
                "Status",
                branch.operationalStatusDisplay.isNotEmpty
                    ? branch.operationalStatusDisplay
                    : (branch.isOperational
                        ? "Operational"
                        : "Non-Operational")),
            if (branch.createdAt.isNotEmpty)
              _DetailItem("Created", branch.createdAt.split('T').first),
            if (branch.updatedAt.isNotEmpty)
              _DetailItem("Updated", branch.updatedAt.split('T').first),
          ]),

          const SizedBox(height: 24),

          // Location & Contact (enriched with country/state detail endpoints)
          _buildSectionTitle("Location & Contact"),
          const SizedBox(height: 12),
          Obx(() {
            final countryDetail = controller.currentCountryDetail.value;
            final stateDetail = controller.currentStateDetail.value;

            final countryDisplay = countryDetail != null
                ? "${countryDetail.name} (${countryDetail.code})"
                : branch.countryName;

            final stateDisplay = stateDetail != null
                ? "${stateDetail.name} (${stateDetail.code})"
                : branch.stateName;

            return _buildDetailGrid([
              _DetailItem("Address", branch.officeAddress),
              _DetailItem("LGA / State", "${branch.lga}, $stateDisplay"),
              _DetailItem("Country", countryDisplay),
              _DetailItem("Email", branch.contactEmail),
              _DetailItem("Phone", branch.contactPhone),
              _DetailItem("Active", branch.isActive ? "Yes" : "No"),
            ]);
          }),

          const SizedBox(height: 24),

          // Manager
          _buildSectionTitle("Management"),
          const SizedBox(height: 12),
          _buildManagerCard(branch),

          // Performance metrics
          if (controller.currentPerformance.value != null) ...[
            const SizedBox(height: 24),
            _buildSectionTitle("Performance Overview"),
            const SizedBox(height: 12),
            _buildPerformanceMetrics(controller.currentPerformance.value!),
          ],

          // Notes
          if (branch.notes.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionTitle("Notes"),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                branch.notes,
                style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── DEPARTMENTS TAB (Mock) ───
  Widget _buildDepartmentsTab() {
    final mockDepartments = [
      {
        "name": "Operations",
        "head": "John Doe",
        "employees": 12,
        "status": "Active"
      },
      {
        "name": "Finance",
        "head": "Jane Smith",
        "employees": 8,
        "status": "Active"
      },
      {
        "name": "Human Resources",
        "head": "Mike Johnson",
        "employees": 5,
        "status": "Active"
      },
      {
        "name": "Marketing",
        "head": "Sarah Williams",
        "employees": 6,
        "status": "Active"
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle("Departments"),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${mockDepartments.length} departments",
                  style: const TextStyle(
                    color: AppColors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...mockDepartments.map((dept) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.groups_outlined,
                          color: Colors.blue, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dept["name"] as String,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text("Head: ${dept["head"]}",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    Text("${dept["employees"]} staff",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(width: 12),
                    _buildStatusBadge(dept["status"] as String),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          _buildMockDataNotice(),
        ],
      ),
    );
  }

  // ─── PROJECTS TAB (Mock) ───
  Widget _buildProjectsTab() {
    final mockProjects = [
      {
        "name": "Office Renovation",
        "status": "In Progress",
        "progress": 0.65,
        "deadline": "Mar 30, 2026"
      },
      {
        "name": "IT Infrastructure Upgrade",
        "status": "Planning",
        "progress": 0.2,
        "deadline": "Apr 15, 2026"
      },
      {
        "name": "Client Onboarding Portal",
        "status": "Completed",
        "progress": 1.0,
        "deadline": "Feb 28, 2026"
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Branch Projects"),
          const SizedBox(height: 16),
          ...mockProjects.map((proj) {
            final progress = proj["progress"] as double;
            Color progressColor = Colors.blue;
            if (progress >= 1.0) progressColor = Colors.green;
            if (progress < 0.3) progressColor = Colors.orange;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(proj["name"] as String,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                      ),
                      _buildStatusBadge(proj["status"] as String),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey.shade200,
                            color: progressColor,
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text("${(progress * 100).toInt()}%",
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text("Deadline: ${proj["deadline"]}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          _buildMockDataNotice(),
        ],
      ),
    );
  }

  // ─── FINANCIAL TAB (Mock) ───
  Widget _buildFinancialTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Financial Summary"),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildFinancialCard(
                  "Revenue", "N12,500,000", Icons.trending_up, Colors.green),
              _buildFinancialCard(
                  "Expenses", "N8,200,000", Icons.trending_down, Colors.red),
              _buildFinancialCard(
                  "Profit", "N4,300,000", Icons.account_balance, Colors.blue),
              _buildFinancialCard(
                  "Budget", "N15,000,000", Icons.pie_chart, Colors.orange),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle("Recent Transactions"),
          const SizedBox(height: 12),
          ..._buildMockTransactions(),
          const SizedBox(height: 12),
          _buildMockDataNotice(),
        ],
      ),
    );
  }

  List<Widget> _buildMockTransactions() {
    final transactions = [
      {
        "desc": "Office Supplies Purchase",
        "amount": "-N45,000",
        "date": "Mar 10, 2026",
        "type": "expense"
      },
      {
        "desc": "Client Payment - ABC Corp",
        "amount": "+N1,200,000",
        "date": "Mar 08, 2026",
        "type": "income"
      },
      {
        "desc": "Staff Salary Payment",
        "amount": "-N3,500,000",
        "date": "Mar 01, 2026",
        "type": "expense"
      },
      {
        "desc": "Service Revenue - XYZ Ltd",
        "amount": "+N800,000",
        "date": "Feb 28, 2026",
        "type": "income"
      },
    ];

    return transactions.map((tx) {
      final isIncome = tx["type"] == "income";
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (isIncome ? Colors.green : Colors.red)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIncome ? Colors.green : Colors.red,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx["desc"]!,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                  Text(tx["date"]!,
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            Text(
              tx["amount"]!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // ─── PEOPLE TAB ───
  Widget _buildPeopleTab(Branch branch) {
    final mockPeople = [
      {
        "name":
            branch.managerName.isNotEmpty ? branch.managerName : "Unassigned",
        "role": "Branch Manager",
        "status": "Active"
      },
      {
        "name": "Assistant Manager",
        "role": "Asst. Branch Manager",
        "status": "Active"
      },
      {"name": "Front Desk Officer", "role": "Reception", "status": "Active"},
      {"name": "Security Officer", "role": "Security", "status": "Active"},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle("Staff"),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${mockPeople.length} staff",
                  style: const TextStyle(
                    color: AppColors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...mockPeople.asMap().entries.map((entry) {
            final person = entry.value;
            final color = [
              Colors.blue,
              Colors.purple,
              Colors.orange,
              Colors.teal
            ][entry.key % 4];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Text(
                      (person["name"] as String).isNotEmpty
                          ? (person["name"] as String)[0].toUpperCase()
                          : "?",
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(person["name"] as String,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(person["role"] as String,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  _buildStatusBadge(person["status"] as String),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          _buildMockDataNotice(),
        ],
      ),
    );
  }

  // ─── SHARED WIDGETS ───

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildDetailGrid(List<_DetailItem> items) {
    return Wrap(
      spacing: 24,
      runSpacing: 12,
      children: items.map((item) {
        return SizedBox(
          width: 320,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  item.label,
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: Text(
                  item.value.isNotEmpty ? item.value : "-",
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildManagerCard(Branch branch) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.blue, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  branch.managerName.isNotEmpty
                      ? branch.managerName
                      : "Unassigned",
                  weight: 600,
                  size: 14,
                ),
                const MyText("Branch Manager", size: 12, color: Colors.grey),
              ],
            ),
          ),
          _buildStatusBadge(
              branch.managerName.isNotEmpty ? "Assigned" : "Unassigned"),
        ],
      ),
    );
  }

  Widget _buildFinancialCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      width: 165,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status.toLowerCase().contains('active') ||
        status.toLowerCase().contains('operational') ||
        status.toLowerCase().contains('completed') ||
        status.toLowerCase().contains('assigned')) {
      color = Colors.green;
    } else if (status.toLowerCase().contains('inactive') ||
        status.toLowerCase().contains('closed') ||
        status.toLowerCase().contains('unassigned')) {
      color = Colors.red;
    } else if (status.toLowerCase().contains('progress') ||
        status.toLowerCase().contains('planning') ||
        status.toLowerCase().contains('maintenance')) {
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status,
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildPerformanceMetrics(BranchPerformance performance) {
    final metrics = performance.metrics;
    if (metrics.isEmpty) {
      return const Text("No metrics available",
          style: TextStyle(color: Colors.grey, fontSize: 13));
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: metrics.entries.map((e) {
        return Container(
          padding: const EdgeInsets.all(12),
          width: 150,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                e.key.replaceAll('_', ' ').toUpperCase(),
                style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "${e.value}",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMockDataNotice() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.amber),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              "This tab uses sample data. API integration pending.",
              style: TextStyle(fontSize: 11, color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem {
  final String label;
  final String value;
  _DetailItem(this.label, this.value);
}
