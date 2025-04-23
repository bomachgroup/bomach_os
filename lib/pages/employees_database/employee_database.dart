import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/input/my_checkbox.dart';
import 'package:bms_front_end/components/input/my_radio.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class EmployeeDatabase extends StatefulWidget {
  const EmployeeDatabase({super.key});

  @override
  State<EmployeeDatabase> createState() => _EmployeeDatabaseState();
}

class _EmployeeDatabaseState extends State<EmployeeDatabase> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                      kSizedBoxWidth,
                      MyOutlinedButton(
                        icon: const Icon(
                          Icons.tune,
                          color: AppColors.blackColor,
                        ),
                        textColor: AppColors.blackColor,
                        borderColor: null,
                        child: 'Filter',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return const FilterDialog();
                            },
                          );
                        },
                      ),
                    ],
                  )
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
              child:
                  MyTextFormField(hintText: 'Search by name, role, department'),
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
                      minWidth: bodySpace(context),
                    ),
                    child: DataTable(
                      dataRowMinHeight: 68,
                      dataRowMaxHeight: 68,
                      columnSpacing: 24,
                      horizontalMargin: 12,
                      columns: _createColumns(),
                      rows: _createRows(context),
                      showBottomBorder: true,
                    ),
                  ),
                ),
              ),
              const MyPaginator(),
            ],
          ),
        )
      ],
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
          onTap: () {
            context.go(RouteConstants.employeeProfile);
          },
          Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                width: 36,
                height: 36,
                child: Image.asset('assets/icons/profile-icon.png'),
              ),
              const SizedBox(
                width: 8,
              ),
              const Text("Darlene Robertson"),
            ],
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

class FilterDialog extends StatefulWidget {
  const FilterDialog({super.key});

  @override
  FilterDialogState createState() => FilterDialogState();
}

class FilterDialogState extends State<FilterDialog> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> departments = [
    'Design',
    'HR',
    'Sales',
    'Business Analyst',
    'Project Manager',
    'Java',
    'Python',
    'React JS',
    'Account',
    'Nods JS',
  ];
  final List<String> types = [
    'Full-time',
    'Hybrid',
    'Remote',
    'Intern',
    'Part-time',
  ];

  List<String> selectedDepartments = [
    'Design',
    'Java',
    'Python',
    'Project Manager'
  ];
  String? selectedType;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 383),
        padding: const EdgeInsets.all(kDefaultSpace),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.greyBg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Filter",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            // Search Box
            Row(
              children: [
                Expanded(
                  child: MyTextFormField(
                    controller: _searchController,
                    hintText: "Search Employee",
                    leading: Padding(
                      padding: const EdgeInsets.all(10),
                      child: SvgPicture.asset(
                        "assets/svg/search.svg",
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Department",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: departments.map((dept) {
                final selected = selectedDepartments.contains(dept);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyCheckbox(
                      isChecked: selected,
                      onChanged: (value) {
                        setState(() {
                          selected
                              ? selectedDepartments.remove(dept)
                              : selectedDepartments.add(dept);
                        });
                      },
                    ),
                    kSizedBoxWidthSM,
                    Text(
                      dept,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Select Type",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: types.map((type) {
                return MyRadio<String?>(
                  label: type,
                  value: type,
                  groupValue: selectedType,
                  onChanged: (value) {
                    setState(() {
                      selectedType = value;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: MyOutlinedButton(
                    textColor: AppColors.darkGrey1,
                    borderColor: AppColors.grey3.withValues(alpha: 0.2),
                    child: 'Cancel',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MyElevatedButton(
                    child: 'Apply',
                    onTap: () {},
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
