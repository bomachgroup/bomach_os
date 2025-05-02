import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/input/my_checkbox.dart';
import 'package:bms_front_end/components/input/my_radio.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/employees_database/widget/employee_table.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class EmployeeDatabase extends StatefulWidget {
  const EmployeeDatabase({super.key});

  @override
  State<EmployeeDatabase> createState() => _EmployeeDatabaseState();
}

class _EmployeeDatabaseState extends State<EmployeeDatabase> {
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
                      MyText(
                        'Employee’s Database',
                        style: AppText.black_600_32,
                      ),
                      MyText(
                        'Employee’s Database',
                        style: AppText.black_600_14,
                      ),
                    ],
                  ),
                  Wrap(
                    runSpacing: 15,
                    children: [
                      MyElevatedButton(
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.white,
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
                          color: AppColors.black,
                        ),
                        textColor: AppColors.black,
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
        const EmployeeTable(),
      ],
    );
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
              child: MyText("Filter",
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
              child: MyText("Department",
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
                    MyText(
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
              child: MyText("Select Type",
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
