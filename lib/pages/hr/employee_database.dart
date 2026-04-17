import 'package:bms_front_end/components/permission/permission_gate.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/permissions.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/paginate/my_paginator.dart';
import '../../src/model/employees_model.dart';
import 'controller/employees_controller.dart';
import 'employee_profile.dart';
import 'widget/add_new_employee.dart';

class EmployeeDatabase extends StatefulWidget {
  const EmployeeDatabase({super.key});

  @override
  State<EmployeeDatabase> createState() => _EmployeeDatabaseState();
}

class _EmployeeDatabaseState extends State<EmployeeDatabase>
    with AutomaticKeepAliveClientMixin {
  final EmployeeController controller = Get.put(EmployeeController());
  final ScrollController _scrollController = ScrollController();

  String _selectedTab = 'Active';

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return LayoutBuilder(builder: (context, constraints) {
      final bool isMobile = constraints.maxWidth < 800;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isMobile),
          kSizedBox,
          _buildStatsRow(isMobile),
          kSizedBox,

          if (isMobile) ...[
            _buildSearchBar(),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTabButton('Active'),
                const SizedBox(width: 12),
                _buildTabButton('Past(Alumni)'),
              ],
            ),
          ] else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildTabButton('Active'),
                    const SizedBox(width: 12),
                    _buildTabButton('Past(Alumni)'),
                  ],
                ),
                _buildSearchBar(),
              ],
            ),

          kSizedBox,

          // Table Container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: isMobile ? 900 : constraints.maxWidth - 72,
                      ),
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (controller.errorMessage.value.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Center(
                              child: Column(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: Colors.red, size: 30),
                                  const SizedBox(height: 8),
                                  MyText(controller.errorMessage.value,
                                      color: Colors.red),
                                  TextButton(
                                    onPressed: () =>
                                        controller.fetchEmployees(),
                                    child: const Text("Retry"),
                                  )
                                ],
                              ),
                            ),
                          );
                        }

                        if (controller.employeeList.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Center(child: Text("No employees found.")),
                          );
                        }

                        return DataTable(
                          headingRowHeight: 60,
                          dataRowMinHeight: 80,
                          dataRowMaxHeight: 80,
                          columnSpacing: 24,
                          horizontalMargin: 12,
                          headingTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                          columns: _createColumns(),
                          rows: _createRows(context, controller.employeeList),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 20),
                Obx(() => PaginatorFooter(
                      isMobile: isMobile,
                      totalItems: controller.totalItems.value,
                      limit: controller.limit.value,
                      currentPage: controller.currentPage.value,
                      onPageChanged: (newPage) {
                        controller.changePage(newPage);
                      },
                      onLimitChanged: (newLimit) {
                        controller.changeLimit(newLimit);
                      },
                      limitOptions: const [5, 10, 20, 50],
                    )),
              ],
            ),
          ),
        ],
      );
    });
  }

  // --- Widgets ---

  Widget _buildSearchBar() {
    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        onChanged: (val) {
          controller.onSearchChanged(val);
        },
        decoration: InputDecoration(
          hintText: 'Search employees...',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          border: InputBorder.none,
          icon: Icon(CupertinoIcons.search,
              color: Colors.grey.shade400, size: 20),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const MyText(
          'Employee Directory',
          style: AppText.black_600_32,
        ),
        if (!isMobile)
          Row(
            children: [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Job Postings',
                  style: TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.w600),
                ),
              ),
              kSizedBoxWidth,
              PermissionGate(
                require: Perms.employeesCreate,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const AddEmployeeDialog(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0055FF),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(CupertinoIcons.add,
                      color: Colors.white, size: 18),
                  label: const Text(
                    'Add Employee',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          )
        else
          PermissionGate(
            require: Perms.employeesCreate,
            child: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const AddEmployeeDialog(),
                );
              },
              icon: const Icon(CupertinoIcons.add_circled_solid,
                  color: Color(0xFF0055FF), size: 30),
            ),
          )
      ],
    );
  }

  Widget _buildStatsRow(bool isMobile) {
    return Obx(() {
      final total = controller.totalItems.value;
      final contract = controller.employeeList
          .where((e) =>
              e.employmentType?.toLowerCase().contains('contract') ?? false)
          .length;

      if (isMobile) {
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: _buildStatCard(
                  label: 'Total Employees',
                  value: '$total',
                  borderColor: Colors.green),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _buildStatCard(
                  label: 'Contract Staff',
                  value: '$contract',
                  borderColor: const Color(0xFF0055FF)),
            ),
          ],
        );
      } else {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                  label: 'Total Employees',
                  value: '$total',
                  borderColor: Colors.green),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildStatCard(
                  label: 'Contract Staff',
                  value: '$contract',
                  borderColor: const Color(0xFF0055FF)),
            ),
          ],
        );
      }
    });
  }

  Widget _buildStatCard(
      {required String label,
      required String value,
      required Color borderColor}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(label, size: 14, weight: 600, color: Colors.black54),
          const SizedBox(height: 8),
          MyText(value, size: 32, weight: 700, color: Colors.black87),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title) {
    final bool isSelected = _selectedTab == title;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = title;
        });
        final bool active = (title == 'Active');
        controller.filterByStatus(active);
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0055FF) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? const Color(0xFF0055FF) : Colors.grey.shade300,
          ),
        ),
        child: MyText(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  List<DataColumn> _createColumns() {
    return const [
      DataColumn(label: MyText('Name & ID')),
      DataColumn(label: MyText('Designation')),
      DataColumn(label: MyText('Department')),
      DataColumn(label: MyText('Type')),
      DataColumn(label: MyText('Status')),
      DataColumn(label: MyText('Action')),
    ];
  }

  List<DataRow> _createRows(BuildContext context, List<Employee> employees) {
    return employees.map((emp) {
      final bool isActive = emp.isActive;
      final Color statusColor = isActive ? Colors.green : Colors.red;
      final Color statusBg = isActive
          ? Colors.green.withValues(alpha: 0.1)
          : Colors.red.withValues(alpha: 0.1);
      final String statusText = isActive ? 'Active' : 'Inactive';

      return DataRow(
        cells: <DataCell>[
          DataCell(
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.greyBg,
                  backgroundImage: emp.profilePicture != null &&
                          emp.profilePicture!.isNotEmpty &&
                          emp.profilePicture != 'string'
                      ? NetworkImage(emp.profilePicture!)
                      : null,
                  child: (emp.profilePicture == null ||
                          emp.profilePicture!.isEmpty ||
                          emp.profilePicture == 'string')
                      ? Text(emp.firstName.isNotEmpty ? emp.firstName[0] : '?',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54))
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyText('${emp.firstName} ${emp.lastName}',
                        weight: 600, size: 14),
                    const SizedBox(height: 4),
                    MyText(emp.employeeId ?? emp.id,
                        weight: 600, size: 12, color: Colors.black54),
                  ],
                ),
              ],
            ),
          ),
          DataCell(MyText(emp.designation ?? emp.role,
              weight: 600, size: 14, color: Colors.black54)),
          DataCell(MyText(
              emp.departmentName ?? emp.departmentId?.toString() ?? '-',
              weight: 600,
              size: 14)),
          DataCell(
              MyText(emp.employmentType ?? 'Full-time', weight: 600, size: 14)),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: statusBg, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: statusColor)),
                  const SizedBox(width: 8),
                  MyText(statusText,
                      size: 12, color: Colors.black54, weight: 600),
                ],
              ),
            ),
          ),
          DataCell(
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (c) => EmployeeProfile(e: emp)));
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child:
                    const Icon(Icons.more_vert, size: 18, color: Colors.grey),
              ),
            ),
          ),
        ],
      );
    }).toList();
  }
}
