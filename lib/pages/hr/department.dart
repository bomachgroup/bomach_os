import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controller/department_controller.dart';
import 'models/department_model.dart';

class DepartmentPage extends StatefulWidget {
  const DepartmentPage({super.key});

  @override
  State<DepartmentPage> createState() => _DepartmentPageState();
}

class _DepartmentPageState extends State<DepartmentPage> {
  final DepartmentController controller = Get.put(DepartmentController());
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDepartments(context);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Departments',
        subtitle:
            'Organise teams and members across departments and units.',
        trailing: MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'New Department',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const CreateDepartmentDialog(),
            );
          },
        ),
      ),
      children: [
        _buildToolbar(),
        Obx(() {
          if (controller.isLoading.value && controller.departments.isEmpty) {
            return LoadingSkeleton.listRows(count: 4, rowHeight: 120);
          }

          if (controller.departments.isEmpty) {
            return AppCard(
              padding: const EdgeInsets.all(24),
              child: EmptyState(
                icon: Iconsax.building,
                title: 'No departments yet',
                subtitle:
                    'Create a department to start organising employees and units.',
                action: MyOutlinedButton(
                  child: 'New Department',
                  icon: const Icon(Iconsax.add_circle,
                      size: 18, color: AppColors.primary),
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => const CreateDepartmentDialog(),
                  ),
                ),
              ),
            );
          }

          final depts = controller.departments;
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final cols = isWide ? 2 : 1;
              final rowCount = (depts.length / cols).ceil();
              return LayoutGrid(
                columnSizes: List.generate(cols, (_) => 1.fr),
                rowSizes: List.generate(rowCount, (_) => auto),
                columnGap: 20,
                rowGap: 20,
                children: depts
                    .map((dept) => DepartmentCard(department: dept))
                    .toList(),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildToolbar() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: MyTextFormField(
        controller: _searchController,
        hintText: 'Search departments by name',
        height: 48,
        leading: const Icon(Iconsax.search_normal,
            size: 18, color: AppColors.textMuted),
        onChanged: (value) {
          controller.onSearch(context, value);
        },
      ),
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
    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: AppRadii.brLg,
                ),
                alignment: Alignment.center,
                child: const Icon(Iconsax.building,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      department.name.capitalizeFirst ?? department.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${department.employeeCount} '
                      '${department.employeeCount == 1 ? 'member' : 'members'}',
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const StatusChip(
                label: 'Active',
                tone: StatusTone.success,
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 12),
          if (department.employees.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No employees in this department',
                style:
                    AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              ),
            )
          else
            Column(
              children: List.generate(
                department.employees.length,
                (index) {
                  final employee = department.employees[index];
                  final isLast = index == department.employees.length - 1;
                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                    child: _EmployeeRow(employee: employee),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _EmployeeRow extends StatelessWidget {
  final DepartmentEmployee employee;

  const _EmployeeRow({required this.employee});

  Widget _avatar() {
    if (employee.profilePicture != null && employee.profilePicture!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Image.network(
          employee.profilePicture!,
          height: 40,
          width: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _defaultAvatar(),
        ),
      );
    }
    return _defaultAvatar();
  }

  Widget _defaultAvatar() {
    final initials =
        '${employee.firstName.isNotEmpty ? employee.firstName[0] : ''}'
        '${employee.lastName.isNotEmpty ? employee.lastName[0] : ''}';
    return Container(
      height: 40,
      width: 40,
      decoration: const BoxDecoration(
        color: AppColors.primarySubtle,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: AppTextStyles.label.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHead = employee.employeeLevel == 'head';
    return Row(
      children: [
        _avatar(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                employee.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                employee.employeeLevel?.capitalizeFirst ??
                    employee.employmentType,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        if (isHead) ...[
          const StatusChip(
            label: 'HOD',
            tone: StatusTone.success,
            dense: true,
          ),
          const SizedBox(width: 8),
        ],
        const Icon(
          Iconsax.arrow_right_3,
          size: 14,
          color: AppColors.textMuted,
        ),
      ],
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
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: 'Add Department',
      subtitle: 'Create a new department to organise teams and members.',
      size: DialogSize.md,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Department details',
              subtitle: 'Provide a name and an optional description.',
              child: Column(
                children: [
                  MyTextFormField(
                    controller: _nameController,
                    title: 'Name*',
                    hintText: 'e.g. Engineering',
                    validator: (val) =>
                        (val == null || val.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  MyTextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    title: 'Description',
                    hintText: 'What does this department do?',
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
        Obx(() {
          final controller = Get.find<DepartmentController>();
          return MyElevatedButton(
            width: 120,
            height: 44,
            child: controller.isSaving.value ? 'Saving...' : 'Save',
            icon: controller.isSaving.value
                ? null
                : const Icon(Iconsax.tick_circle,
                    size: 18, color: AppColors.textOnPrimary),
            onTap: controller.isSaving.value
                ? null
                : () {
                    if (_nameController.text.trim().isEmpty) {
                      AppToast.error(
                          context, 'Department name is required');
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
    );
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
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
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
