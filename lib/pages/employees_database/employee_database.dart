import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_button.dart';
import 'package:bms_front_end/components/input/my_input.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmployeeDatabase extends StatelessWidget {
  const EmployeeDatabase({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Employee’s Database',
                          style: AppText.black_600_32,
                        ),
                        Text(
                          'Employee’s Database',
                          style: AppText.black_600_14,
                        ),
                      ],
                    ),
                    MyElevatedButton(
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppColors.whiteColor,
                      ),
                      child: 'Add New Employee',
                      onTap: () {
                        context.go(RouteConstants.addEmployees);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          kSizedBoxBG,
          const Wrap(
            spacing: 8, // Horizontal space between items
            runSpacing: 8, // Vertical space when wrapping
            children: [
              SizedBox(
                width: 276,
                height: 48,
                child: MyTextFormField(
                    hintText: 'Search by name, role, department'),
              ),
              SortBar(
                text: 'Enugu',
              ),
              SortBar(
                text: 'Aso villa Estate',
              ),
              SortBar(
                text: 'Department',
              ),
            ],
          ),
          kSizedBox,
          kSizedBoxSM,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Scrollbar(
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: bodySpace(context),
                      ),
                      child: DataTable(
                          columnSpacing: 24,
                          horizontalMargin: 12,
                          columns: _createColumns(),
                          rows: _createRows(context)),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: Text(
          "Employee ID",
        ),
      ),
      const DataColumn(
        label: Text(
          "Employee Name",
        ),
      ),
      const DataColumn(label: Text("Department")),
      const DataColumn(
          label: Text(
        "Designation",
      )),
      const DataColumn(
        label: Text(
          "E. Type",
        ),
      ),
      const DataColumn(
        label: Text(
          "Status",
        ),
      ),
      const DataColumn(
        label: Text(
          "Action",
        ),
      ),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    return List.generate(10, (index) {
      return DataRow(cells: <DataCell>[
        const DataCell(
          Text("345321231"),
        ),
        DataCell(
          onTap: () {},
          GestureDetector(
            onTap: () {
              context.go(RouteConstants.employeeProfile);
            },
            child: Row(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  width: 36,
                  height: 36,
                  child: Image.asset('assets/icons/profileIcon.png'),
                ),
                const SizedBox(
                  width: 8,
                ),
                const Text("Darlene Robertson"),
              ],
            ),
          ),
        ),
        const DataCell(
          Text("Design"),
        ),
        const DataCell(
          Text("UI/UX Designer"),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 0.6,
                            color: getRandomColorFromList('full-time')),
                        color: getRandomColorFromList('full-time')
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6)),
                    child: const Center(
                      child: Text("Full-time"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 0.6,
                            color: getRandomColorFromList('retired')),
                        color: getRandomColorFromList('retired')
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6)),
                    child: const Center(
                      child: Text("Retired"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const DataCell(
          Icon(Icons.more_vert_outlined),
        ),
      ]);
    });
  }
}
