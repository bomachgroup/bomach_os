import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../src/model/departments_units_model.dart';
import '../controllers/department_units_controller.dart';

// ═══════════════════════════════════════════════════════════════════
//  SHARED HELPERS
// ═══════════════════════════════════════════════════════════════════

Widget _buildSection({
  required String title,
  String? subtitle,
  required Widget child,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surfaceMuted,
      borderRadius: AppRadii.brLg,
      border: Border.all(color: AppColors.borderSubtle),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h4),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
          ),
        ],
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}

Widget _detailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════
//  CREATE / EDIT DEPARTMENT DIALOG
// ═══════════════════════════════════════════════════════════════════

class CreateDepartmentDialog extends StatefulWidget {
  final Department? department;
  const CreateDepartmentDialog({super.key, this.department});

  @override
  State<CreateDepartmentDialog> createState() => _CreateDepartmentDialogState();
}

class _CreateDepartmentDialogState extends State<CreateDepartmentDialog> {
  final controller = Get.find<DepartmentsUnitsController>();
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool get isEditing => widget.department != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      nameCtrl.text = widget.department!.name;
      descCtrl.text = widget.department!.description;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => DialogScaffold(
          title: isEditing ? 'Edit Department' : 'Create Department',
          subtitle: isEditing
              ? 'Update the department name and description.'
              : 'Add a new department to the organizational structure.',
          size: DialogSize.lg,
          body: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  title: 'Department details',
                  subtitle: 'Give the department a clear identity.',
                  child: Column(
                    children: [
                      MyTextFormField(
                        controller: nameCtrl,
                        title: 'Department Name',
                        hintText: 'e.g. Operations',
                        validator: (val) => (val == null || val.isEmpty)
                            ? 'Name is required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      MyTextFormField(
                        controller: descCtrl,
                        title: 'Description',
                        hintText: 'Describe what this department does',
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            MyOutlinedButton(
              child: 'Cancel',
              height: 44,
              onTap: () => Navigator.pop(context),
              textColor: AppColors.textSecondary,
              borderColor: AppColors.borderStrong,
            ),
            MyElevatedButton(
              width: 140,
              height: 44,
              child: controller.isSaving.value
                  ? 'Saving...'
                  : (isEditing ? 'Update' : 'Save'),
              icon: controller.isSaving.value
                  ? null
                  : const Icon(Iconsax.tick_circle,
                      size: 18, color: AppColors.textOnPrimary),
              onTap: controller.isSaving.value ? null : _onSave,
            ),
          ],
        ));
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    if (isEditing) {
      controller.updateDepartment(
        context,
        departmentId: widget.department!.id,
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
      );
    } else {
      controller.createDepartment(
        context,
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
//  CREATE / EDIT UNIT DIALOG
// ═══════════════════════════════════════════════════════════════════

class CreateUnitDialog extends StatefulWidget {
  final DepartmentUnit? unit;
  const CreateUnitDialog({super.key, this.unit});

  @override
  State<CreateUnitDialog> createState() => _CreateUnitDialogState();
}

class _CreateUnitDialogState extends State<CreateUnitDialog> {
  final controller = Get.find<DepartmentsUnitsController>();
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? selectedDeptId;
  String? selectedDeptLabel;

  bool get isEditing => widget.unit != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      nameCtrl.text = widget.unit!.name;
      descCtrl.text = widget.unit!.description;
      selectedDeptId = widget.unit!.departmentId;
      selectedDeptLabel = widget.unit!.departmentName;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => DialogScaffold(
          title: isEditing ? 'Edit Unit' : 'Create Unit',
          subtitle: isEditing
              ? 'Update the unit name, parent department, and description.'
              : 'Add a new unit under a department.',
          size: DialogSize.lg,
          body: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  title: 'Unit details',
                  subtitle: 'Identify the unit and its parent department.',
                  child: Column(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxWidth < 520;
                          final nameField = MyTextFormField(
                            controller: nameCtrl,
                            title: 'Unit Name',
                            hintText: 'e.g. Fleet Maintenance',
                            validator: (val) => (val == null || val.isEmpty)
                                ? 'Name is required'
                                : null,
                          );

                          final deptField = Obx(() {
                            final items = controller.departmentOptions
                                .map((e) => e['name'] ?? 'Unknown')
                                .toList();
                            return MyDropdown(
                              title: 'Parent Department',
                              hintText: selectedDeptLabel ?? 'Select department',
                              items: items,
                              initialSelection: selectedDeptLabel,
                              onChanged: (name) {
                                try {
                                  final dept = controller.departmentOptions
                                      .firstWhere((e) => e['name'] == name);
                                  setState(() {
                                    selectedDeptId = dept['id'];
                                    selectedDeptLabel = dept['name'];
                                  });
                                } catch (_) {}
                              },
                            );
                          });

                          if (compact) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                nameField,
                                const SizedBox(height: 16),
                                deptField,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: nameField),
                              const SizedBox(width: 16),
                              Expanded(child: deptField),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      MyTextFormField(
                        controller: descCtrl,
                        title: 'Description',
                        hintText: 'Describe what this unit is responsible for',
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            MyOutlinedButton(
              child: 'Cancel',
              height: 44,
              onTap: () => Navigator.pop(context),
              textColor: AppColors.textSecondary,
              borderColor: AppColors.borderStrong,
            ),
            MyElevatedButton(
              width: 140,
              height: 44,
              child: controller.isSaving.value
                  ? 'Saving...'
                  : (isEditing ? 'Update' : 'Save'),
              icon: controller.isSaving.value
                  ? null
                  : const Icon(Iconsax.tick_circle,
                      size: 18, color: AppColors.textOnPrimary),
              onTap: controller.isSaving.value ? null : _onSave,
            ),
          ],
        ));
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDeptId == null && !isEditing) {
      AppToast.error(context, 'Please select a department');
      return;
    }

    final deptId = selectedDeptId ?? widget.unit!.departmentId;

    if (isEditing) {
      controller.updateUnit(
        context,
        unitId: widget.unit!.id!,
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
        departmentId: deptId,
      );
    } else {
      controller.createUnit(
        context,
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
        departmentId: deptId,
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
//  VIEW DEPARTMENT DIALOG
// ═══════════════════════════════════════════════════════════════════

class ViewDepartmentDetailsDialog extends StatelessWidget {
  final Department department;
  const ViewDepartmentDetailsDialog({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    final code =
        'DEP-${department.id.length >= 3 ? department.id.substring(0, 3) : department.id}';

    return DialogScaffold(
      title: 'Department details',
      subtitle: department.name,
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryBanner(
            icon: Iconsax.people,
            title: department.name,
            chips: [
              StatusChip(
                label: 'Code $code',
                tone: StatusTone.primary,
                icon: Iconsax.code,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Department information',
            child: Column(
              children: [
                _detailRow('Department Name', department.name),
                _detailRow('Department Code', code),
                _detailRow(
                  'Description',
                  department.description.isEmpty
                      ? 'No description provided'
                      : department.description,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Close',
          height: 44,
          onTap: () => Navigator.pop(context),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        MyElevatedButton(
          width: 120,
          height: 44,
          child: 'Edit',
          icon: const Icon(Iconsax.edit,
              size: 18, color: AppColors.textOnPrimary),
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (_) => CreateDepartmentDialog(department: department),
            );
          },
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  VIEW UNIT DIALOG
// ═══════════════════════════════════════════════════════════════════

class ViewUnitDetailsDialog extends StatelessWidget {
  final DepartmentUnit unit;
  const ViewUnitDetailsDialog({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    final code = unit.id != null && unit.id!.length >= 3
        ? 'UNIT-${unit.id!.substring(0, 3)}'
        : 'UNIT-${unit.id ?? '?'}';
    final status = unit.status ?? 'Active';

    return DialogScaffold(
      title: 'Unit details',
      subtitle: unit.name,
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryBanner(
            icon: Iconsax.hierarchy,
            title: unit.name,
            chips: [
              StatusChip.fromStatus(status),
              StatusChip(
                label: 'Code $code',
                tone: StatusTone.primary,
                icon: Iconsax.code,
              ),
              if (unit.departmentName != null &&
                  unit.departmentName!.isNotEmpty)
                StatusChip(
                  label: unit.departmentName!,
                  tone: StatusTone.neutral,
                  icon: Iconsax.people,
                ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Unit information',
            child: Column(
              children: [
                _detailRow('Unit Name', unit.name),
                _detailRow('Unit Code', code),
                _detailRow('Department', unit.departmentName ?? '-'),
                _detailRow('Head of Unit', unit.hod ?? 'Not Assigned'),
                _detailRow('Status', status),
                _detailRow(
                  'Description',
                  unit.description.isEmpty
                      ? 'No description provided'
                      : unit.description,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Close',
          height: 44,
          onTap: () => Navigator.pop(context),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        MyElevatedButton(
          width: 120,
          height: 44,
          child: 'Edit',
          icon: const Icon(Iconsax.edit,
              size: 18, color: AppColors.textOnPrimary),
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (_) => CreateUnitDialog(unit: unit),
            );
          },
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SUMMARY BANNER (shared)
// ═══════════════════════════════════════════════════════════════════

Widget _buildSummaryBanner({
  required IconData icon,
  required String title,
  required List<Widget> chips,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surfaceMuted,
      borderRadius: AppRadii.brLg,
      border: Border.all(color: AppColors.borderSubtle),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: AppColors.primarySubtle,
            borderRadius: AppRadii.brLg,
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: chips,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
