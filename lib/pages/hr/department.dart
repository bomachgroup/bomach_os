import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'controller/department_controller.dart';
import 'models/department_model.dart';

class DepartmentPage extends StatefulWidget {
  const DepartmentPage({super.key});

  @override
  State<DepartmentPage> createState() => _DepartmentPageState();
}

class _DepartmentPageState extends State<DepartmentPage> {
  final DepartmentController controller = Get.put(DepartmentController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDepartments(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            MyText(
              'Departments',
              style: AppText.black_600_32,
            ),
          ],
        ),
        kSizedBox,
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            MyElevatedButton(
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.white,
              ),
              child: 'New Department',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return const CreateDepartmentDialog();
                  },
                );
              },
            ),
            SizedBox(
              width: 217,
              child: MyTextFormField(
                hintText: 'Search...',
                leading: Icon(
                  Icons.search,
                  color: AppColors.grey1.withValues(alpha: 0.5),
                ),
                onChanged: (value) {
                  controller.onSearch(context, value);
                },
              ),
            ),
            // const SortBar(
            //   text: "Sort",
            // ),
          ],
        ),
        kSizedBoxBG,
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.departments.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: MyText(
                  'No departments found',
                  style: TextStyle(
                    color: AppColors.grey2,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }

          final depts = controller.departments;
          final rowCount =
              (depts.length / (isSmallScreen(context) ? 1 : 2)).ceil();

          return LayoutGrid(
            columnSizes: isSmallScreen(context) ? [1.fr] : [1.fr, 1.fr],
            rowSizes: List.generate(rowCount, (_) => auto),
            columnGap: kDefaultSpaceBG,
            rowGap: kDefaultSpaceBG,
            children:
                depts.map((dept) => DepartmentCard(department: dept)).toList(),
          );
        }),
      ],
    );
  }
}

class DepartmentCard extends StatelessWidget {
  final Department department;

  const DepartmentCard({
    super.key,
    required this.department,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: kDefaultSpace, vertical: kDefaultSpace),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.white,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      department.name.capitalizeFirst ?? department.name,
                      maxLines: 1,
                      style: const TextStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    MyText(
                      '${department.employeeCount} ${department.employeeCount == 1 ? 'Member' : 'Members'}',
                      maxLines: 1,
                      style: const TextStyle(
                        color: AppColors.grey2,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              kSizedBoxWidthSM,
              const MyText(
                'View All',
                isSelectable: false,
                style: TextStyle(
                  color: AppColors.blue,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Divider(),
          kSizedBoxSM,
          if (department.employees.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: MyText(
                'No employees in this department',
                style: TextStyle(
                  color: AppColors.grey2,
                  fontSize: 14,
                ),
              ),
            )
          else
            Column(
              children: List.generate(
                department.employees.length,
                (index) {
                  final employee = department.employees[index];
                  return Column(
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: employee.profilePicture != null
                                ? Image.network(
                                    employee.profilePicture!,
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _defaultAvatar(employee),
                                  )
                                : _defaultAvatar(employee),
                          ),
                          kSizedBoxWidth,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  employee.fullName,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                ),
                                MyText(
                                  employee.employeeLevel?.capitalizeFirst ??
                                      employee.employmentType,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: AppColors.grey2,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          kSizedBoxWidthSM,
                          if (employee.employeeLevel == 'head') ...[
                            const MyText(
                              'HOD',
                              style: TextStyle(
                                color: AppColors.green,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            kSizedBoxWidth,
                          ],
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 13,
                          )
                        ],
                      ),
                      kSizedBox,
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _defaultAvatar(DepartmentEmployee employee) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: AppColors.blue.withValues(alpha: 0.15),
      ),
      child: Center(
        child: Text(
          '${employee.firstName.isNotEmpty ? employee.firstName[0] : ''}${employee.lastName.isNotEmpty ? employee.lastName[0] : ''}',
          style: const TextStyle(
            color: AppColors.blue,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class CreateDepartmentDialog extends StatefulWidget {
  const CreateDepartmentDialog({super.key});

  @override
  State<CreateDepartmentDialog> createState() => _CreateDepartmentDialogState();
}

class _CreateDepartmentDialogState extends State<CreateDepartmentDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.grey4),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyText(
                    'Add Department',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Form fields
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      MyTextFormField(
                        controller: _nameController,
                        hintText: "----",
                        spaceBetweenText: 10,
                        title: 'Name*',
                      ),
                      const SizedBox(height: 24),
                      MyTextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        hintText: '----',
                        spaceBetweenText: 10,
                        title: 'Description',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                    textColor: AppColors.darkGrey1,
                    borderColor: null,
                    child: 'Cancel',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 16),
                  Obx(() {
                    final controller = Get.find<DepartmentController>();
                    return MyElevatedButton(
                      icon: controller.isSaving.value
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : SvgPicture.asset(
                              "assets/svg/check.svg",
                              colorFilter: const ColorFilter.mode(
                                  AppColors.white, BlendMode.srcIn),
                            ),
                      child: 'Save',
                      onTap: controller.isSaving.value
                          ? null
                          : () {
                              if (_nameController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Department name is required'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }
                              controller.createDepartment(
                                context,
                                name: _nameController.text.trim(),
                                description: _descriptionController.text.trim(),
                              );
                            },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
