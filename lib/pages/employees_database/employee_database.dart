import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../src/model/employees_model.dart';
import 'add_new_employee.dart';
import 'controller/employees_controller.dart';
import 'employee_profile.dart';

class EmployeeDatabase extends StatefulWidget {
  const EmployeeDatabase({super.key});

  @override
  State<EmployeeDatabase> createState() => _EmployeeDatabaseState();
}

class _EmployeeDatabaseState extends State<EmployeeDatabase> {
  final EmployeeController controller = Get.put(EmployeeController());
  final _storage = const FlutterSecureStorage();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final token = await _getToken(context);
    if (token != null) {
      controller.fetchEmployees(token);
    }
  }

  Future<String?> _getToken(BuildContext context) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");
    return token.replaceAll('"', '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 10,
                runSpacing: 10,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        'Employee Database',
                        style: AppText.black_500_32,
                      ),
                      SizedBox(height: 8),
                      MyText(
                        'Manage all your employees here',
                        size: 14,
                        weight: 400,
                        color: Color(0xFF64748B),
                      ),
                    ],
                  ),
                  MyElevatedButton(
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.white,
                    ),
                    child: "New Employee",
                    onTap: () async {
                      final token = await _getToken(context);
                      if (token != null && context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => AddEmployesScreen(token: token)),
                        );
                      }
                    },
                  )
                ],
              ),
            ),
          ],
        ),
        kSizedBox,

        // Search Bar
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 15,
                runSpacing: 15,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 250,
                    child: MyTextFormField(
                      hintText: 'Search employees...',
                      leading: Icon(
                        Icons.search,
                        color: AppColors.grey1.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh List',
                  ),
                ],
              ),
            ),
          ],
        ),
        kSizedBox,
        kSizedBoxSM,

        // Data Table
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
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
                      minWidth: MediaQuery.of(context).size.width - 100,
                    ),
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                            child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ));
                      }

                      if (controller.employeeList.isEmpty) {
                        return const Center(
                            child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text("No employees found."),
                        ));
                      }

                      return DataTable(
                        dataRowMinHeight: 68,
                        dataRowMaxHeight: 68,
                        columnSpacing: 24,
                        horizontalMargin: 12,
                        columns: _createColumns(),
                        rows: _createRows(context, controller.employeeList),
                        showBottomBorder: true,
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(label: MyText('Name')),
      const DataColumn(label: MyText('Email')),
      const DataColumn(label: MyText('Phone')),
      const DataColumn(label: MyText('Role')),
      const DataColumn(label: MyText('Status')),
      const DataColumn(label: MyText('Action')),
    ];
  }

  List<DataRow> _createRows(BuildContext context, List<Employee> employees) {
    return employees.map((emp) {
      return DataRow(
        cells: <DataCell>[
          DataCell(
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.greyBg,
                  backgroundImage: emp.profilePicture != null
                      ? NetworkImage(emp.profilePicture!)
                      : null,
                  child: emp.profilePicture == null
                      ? Text(emp.firstName[0],
                          style: const TextStyle(fontSize: 12))
                      : null,
                ),
                const SizedBox(width: 8),
                MyText('${emp.firstName} ${emp.lastName}', weight: 500),
              ],
            ),
          ),
          DataCell(MyText(emp.email)),
          DataCell(MyText(emp.phoneNumber ?? '-')),
          DataCell(MyText(emp.employmentType ?? '-')),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: emp.isActive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                emp.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: emp.isActive ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          DataCell(
            IconButton(
              icon: const Icon(Icons.visibility, color: AppColors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) => EmployeeProfile(e: emp)),
                );
              },
            ),
          ),
        ],
      );
    }).toList();
  }
}
