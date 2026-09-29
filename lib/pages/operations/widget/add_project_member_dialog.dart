import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/project_controller.dart';

class AddProjectMemberDialog extends StatefulWidget {
  final int projectId;
  final List<String> existingEmployeeIds;
  const AddProjectMemberDialog({
    super.key,
    required this.projectId,
    this.existingEmployeeIds = const [],
  });

  @override
  State<AddProjectMemberDialog> createState() => AddProjectMemberDialogState();
}

class AddProjectMemberDialogState extends State<AddProjectMemberDialog> {
  final ProjectController controller = Get.find<ProjectController>();
  String? _selectedEmployee;

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: 'Add Member',
      subtitle: 'Assign a team member to this project',
      size: DialogSize.md,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'Choose employee',
            child: Column(
              children: [
                Obx(
                  () => MyDropdown(
                  hintText: 'Select employee',
                  title: 'Employee',
                    initialSelection: _selectedEmployee == null
                        ? null
                        : controller.employees
                              .firstWhereOrNull(
                                (employee) => employee.id == _selectedEmployee,
                              )
                              ?.fullName,
                    items: controller.employees
                        .where(
                          (employee) =>
                              !widget.existingEmployeeIds.contains(employee.id),
                        )
                        .map((employee) => employee.fullName)
                        .toList(),
                    onChanged: (name) {
                      final employee = controller.employees.firstWhereOrNull(
                        (item) => item.fullName == name,
                      );
                      setState(() => _selectedEmployee = employee?.id);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          onTap: () => Navigator.pop(context),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        Obx(
          () => MyElevatedButton(
          width: 140,
          height: 44,
            isLoading: controller.isActionLoading.value,
          child: 'Save Member',
            onTap: _selectedEmployee == null || controller.isActionLoading.value
                ? null
                : () => controller.addProjectEmployee(
                    context,
                    widget.projectId,
                    _selectedEmployee!,
                    widget.existingEmployeeIds,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h4),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
