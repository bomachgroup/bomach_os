import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/permission/permission_gate.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/shadows.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/helper/responsive_breakpoints.dart';
import 'package:bomach_os/src/utils/app_date_format.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:bomach_os/src/utils/number_formatting.dart';

import '../../src/model/employees_model.dart';
import '../../src/services/permission_service.dart';
import 'controller/employees_controller.dart';
import 'employee_profile_data.dart';
import '../../src/services/audit_log_service.dart';
import '../operations/models/models.dart';
import 'models/work_report_model.dart';
import 'widget/add_employee_appraisal.dart';
import 'widget/add_employee_document.dart';
import 'widget/add_new_employee.dart';
import 'widget/exit_employee_dialog.dart';
import 'widget/suspend_employee_dialog.dart';
import 'widget/dynamic_item_list_field.dart';

class EmployeeProfile extends StatefulWidget {
  final Employee? e;
  const EmployeeProfile({super.key, this.e});

  @override
  State<EmployeeProfile> createState() => _EmployeeProfileState();
}

class _EmployeeProfileState extends State<EmployeeProfile> {
  int _selectedTab = 0;

  final EmployeeController controller = Get.isRegistered<EmployeeController>()
      ? Get.find<EmployeeController>()
      : Get.put(EmployeeController());

  Widget _permissionGate({
    Permission? require,
    List<Permission>? anyOf,
    required Widget child,
  }) {
    if (!Get.isRegistered<PermissionService>()) return child;
    return PermissionGate(
      require: require,
      anyOf: anyOf,
      child: child,
    );
  }

  @override
  void initState() {
    super.initState();
    final e = widget.e;
    if (e != null) {
      controller.selectedEmployee.value = e;
      controller.fetchEmployeeById(e.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final employee = controller.selectedEmployee.value ??
          widget.e ??
          ModalRoute.of(context)?.settings.arguments as Employee?;

      if (employee == null) {
        return const Scaffold(
          body: Center(child: Text('Employee not found')),
        );
      }

      if (context.breakpoint.isDesktop) {
        return EmployeeDesktopProfileLayout(
          employee: employee,
          controller: controller,
          editAction: _permissionGate(
            require: Perms.employeesUpdate,
            child: MyElevatedButton(
              child: 'Edit Profile',
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              icon: const Icon(Iconsax.edit,
                  size: 16, color: AppColors.textOnPrimary),
              onTap: () => showDialog(
                context: context,
                builder: (_) => AddEmployeeDialog(employee: employee),
              ),
            ),
          ),
          secondaryAction: _permissionGate(
            require: Perms.performanceReviewsCreate,
            child: MyOutlinedButton(
              child: 'Give Review',
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              icon:
                  const Icon(Iconsax.star1, size: 16, color: AppColors.primary),
              onTap: () => showDialog(
                context: context,
                builder: (_) => EmployeeAppraisalDialog(userId: employee.id),
              ),
            ),
          ),
        );
      }

      return PageScaffold(
        maxContentWidth: 1440,
        header: PageHeader(
          title: employee.fullName,
          subtitle: employee.designation ?? employee.role,
          leading: _backButton(context),
          trailing: _buildHeaderActions(context, employee),
        ),
        children: [
          _buildSummaryCard(context, employee),
          _buildPillTabBar(),
          _buildBody(employee),
        ],
      );
    });
  }

  Widget _backButton(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadii.brMd,
      child: InkWell(
        borderRadius: AppRadii.brMd,
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderStrong),
            borderRadius: AppRadii.brMd,
          ),
          child: const Icon(Iconsax.arrow_left_2,
              size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget? _buildHeaderActions(BuildContext context, Employee employee) {
    final bool isActive = employee.isActive;

    if (context.isMobile) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _permissionGate(
            require: Perms.employeesUpdate,
            child: MyOutlinedButton(
              child: 'Edit',
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              textColor: AppColors.textPrimary,
              borderColor: AppColors.borderStrong,
              icon: const Icon(Iconsax.edit,
                  size: 16, color: AppColors.textPrimary),
              onTap: () => showDialog(
                context: context,
                builder: (_) => AddEmployeeDialog(employee: employee),
              ),
            ),
          ),
          _permissionGate(
            require: Perms.performanceReviewsCreate,
            child: MyElevatedButton(
              child: 'Review',
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              icon: const Icon(Iconsax.star1,
                  color: AppColors.textOnPrimary, size: 16),
              onTap: () => showDialog(
                context: context,
                builder: (_) => EmployeeAppraisalDialog(userId: employee.id),
              ),
            ),
          ),
          _permissionGate(
            anyOf: const [Perms.employeesUpdate, Perms.employeesExit],
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert,
                  size: 20, color: AppColors.textSecondary),
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
              onSelected: (val) =>
                  _handleActionSelected(context, employee, val),
              itemBuilder: (ctx) => _buildMenuItems(isActive),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _permissionGate(
          require: Perms.employeesUpdate,
          child: MyOutlinedButton(
            child: 'Edit Profile',
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            icon: const Icon(Iconsax.edit, size: 16, color: AppColors.primary),
            onTap: () => showDialog(
              context: context,
              builder: (_) => AddEmployeeDialog(employee: employee),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _permissionGate(
          require: Perms.performanceReviewsCreate,
          child: MyElevatedButton(
            child: 'Give Review',
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            icon: const Icon(Iconsax.star1,
                color: AppColors.textOnPrimary, size: 16),
            onTap: () => showDialog(
              context: context,
              builder: (_) => EmployeeAppraisalDialog(userId: employee.id),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _permissionGate(
          anyOf: const [Perms.employeesUpdate, Perms.employeesExit],
          child: PopupMenuButton<String>(
            icon: Container(
              height: 44,
              width: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderStrong),
                borderRadius: AppRadii.brMd,
              ),
              child: const Icon(Icons.more_vert,
                  size: 20, color: AppColors.textPrimary),
            ),
            tooltip: 'More actions',
            shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
            onSelected: (val) => _handleActionSelected(context, employee, val),
            itemBuilder: (ctx) => _buildMenuItems(isActive),
          ),
        ),
      ],
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(bool isActive) {
    return [
      if (isActive)
        const PopupMenuItem(
          value: 'suspend',
          child: Row(
            children: [
              Icon(Iconsax.user_minus, size: 16, color: AppColors.warning),
              SizedBox(width: 10),
              Text('Suspend Employee',
                  style: TextStyle(color: AppColors.warning)),
            ],
          ),
        )
      else
        const PopupMenuItem(
          value: 'activate',
          child: Row(
            children: [
              Icon(Iconsax.user_tick, size: 16, color: AppColors.success),
              SizedBox(width: 10),
              Text('Activate Employee',
                  style: TextStyle(color: AppColors.success)),
            ],
          ),
        ),
      if (isActive)
        const PopupMenuItem(
          value: 'deactivate',
          child: Row(
            children: [
              Icon(Iconsax.user_remove,
                  size: 16, color: AppColors.textSecondary),
              SizedBox(width: 10),
              Text('Deactivate'),
            ],
          ),
        ),
      const PopupMenuDivider(),
      const PopupMenuItem(
        value: 'exit',
        child: Row(
          children: [
            Icon(Iconsax.trash, size: 16, color: AppColors.danger),
            SizedBox(width: 10),
            Text('Exit / Offboard', style: TextStyle(color: AppColors.danger)),
          ],
        ),
      ),
    ];
  }

  void _handleActionSelected(
      BuildContext context, Employee employee, String action) {
    switch (action) {
      case 'suspend':
        showDialog(
          context: context,
          builder: (_) => SuspendEmployeeDialog(employee: employee),
        );
        break;
      case 'activate':
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Activate Employee'),
            content:
                Text('Are you sure you want to activate ${employee.fullName}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success),
                onPressed: () {
                  Navigator.pop(ctx);
                  controller.activateEmployee(context, employee.id);
                },
                child: const Text('Activate'),
              ),
            ],
          ),
        );
        break;
      case 'deactivate':
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Deactivate Employee'),
            content: Text(
                'Are you sure you want to deactivate ${employee.fullName}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                onPressed: () {
                  Navigator.pop(ctx);
                  controller.deactivateEmployee(context, employee.id);
                },
                child: const Text('Deactivate'),
              ),
            ],
          ),
        );
        break;
      case 'exit':
        showDialog(
          context: context,
          builder: (_) => ExitEmployeeDialog(employee: employee),
        );
        break;
    }
  }

  Widget _buildSummaryCard(BuildContext context, Employee employee) {
    final bool isActive = employee.isActive;
    final bool hasPicture = employee.profilePicture != null &&
        employee.profilePicture != 'string' &&
        employee.profilePicture!.isNotEmpty;

    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.sm,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              shape: BoxShape.circle,
              image: hasPicture
                  ? DecorationImage(
                      image: NetworkImage(employee.profilePicture!),
                      fit: BoxFit.cover,
                    )
                  : null,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: !hasPicture
                ? Center(
                    child: Text(
                      employee.firstName.isNotEmpty
                          ? employee.firstName[0].toUpperCase()
                          : '?',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(employee.fullName, style: AppTextStyles.h2),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      employee.designation ?? employee.role,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    StatusChip(
                      label: isActive ? 'Active' : 'Inactive',
                      tone: isActive ? StatusTone.success : StatusTone.neutral,
                      dense: true,
                    ),
                    if ((employee.employmentType ?? '').isNotEmpty)
                      StatusChip(
                        label: employee.employmentType!,
                        tone: _employmentTypeTone(employee.employmentType),
                        dense: true,
                      ),
                    StatusChip(
                      label: employee.isVerified ? 'Verified' : 'Unverified',
                      tone: employee.isVerified
                          ? StatusTone.success
                          : StatusTone.warning,
                      dense: true,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${employee.employeeId ?? employee.id} • ${employee.email}',
                  style: AppTextStyles.bodySm,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  StatusTone _employmentTypeTone(String? type) {
    final t = (type ?? '').toLowerCase();
    if (t.contains('part')) return StatusTone.info;
    if (t.contains('contract')) return StatusTone.warning;
    if (t.contains('intern')) return StatusTone.neutral;
    return StatusTone.primary;
  }

  Widget _buildPillTabBar() {
    const tabs = ['Profile', 'Documents', 'Reviews', 'Benefits'];
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(tabs.length, (index) {
            final isActive = _selectedTab == index;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: AppRadii.brMd,
                  onTap: () => setState(() => _selectedTab = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.surface : Colors.transparent,
                      borderRadius: AppRadii.brMd,
                      boxShadow: isActive ? AppShadows.sm : const <BoxShadow>[],
                    ),
                    child: Text(
                      tabs[index],
                      style: AppTextStyles.bodyMd.copyWith(
                        color: isActive
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildBody(Employee employee) {
    switch (_selectedTab) {
      case 0:
        return _ProfileTab(employee: employee);
      case 1:
        return _DocumentsTab(controller: controller, userId: employee.id);
      case 2:
        return _ReviewsTab(controller: controller, employee: employee);
      case 3:
        return _BenefitsTab(employee: employee);
      default:
        return _ProfileTab(employee: employee);
    }
  }
}

/// Desktop employee detail shell adapted from the Figma `Desktop - 133`
/// employee database design. Values remain API-backed through [Employee].
class EmployeeDesktopProfileLayout extends StatefulWidget {
  final Employee employee;
  final EmployeeController? controller;
  final EmployeeProfileDataSource? dataSource;
  final Widget? editAction;
  final Widget? secondaryAction;

  const EmployeeDesktopProfileLayout({
    super.key,
    required this.employee,
    this.controller,
    this.dataSource,
    this.editAction,
    this.secondaryAction,
  });

  @override
  State<EmployeeDesktopProfileLayout> createState() =>
      _EmployeeDesktopProfileLayoutState();
}

class _EmployeeDesktopProfileLayoutState
    extends State<EmployeeDesktopProfileLayout> {
  String _selectedSection = 'Profile';
  String _selectedInfoTab = 'Personal Information';
  late final EmployeeProfileDataSource _dataSource;
  Future<List<AuditLogResponse>>? _activityFuture;
  Future<List<Task>>? _tasksFuture;
  Future<List<WorkReport>>? _workReportsFuture;

  static const _sections = [
    ('Profile', Iconsax.user),
    ('Activity', Iconsax.activity),
    ('Tasks', Iconsax.task_square),
    ('Work Reports', Iconsax.note_2),
  ];

  static const _infoTabs = [
    'Personal Information',
    'Professional Information',
    'Documents',
  ];

  EmployeeController get _controller =>
      widget.controller ??
      (Get.isRegistered<EmployeeController>()
          ? Get.find<EmployeeController>()
          : Get.put(EmployeeController()));

  String _getRoleOrDesignation(Employee employee) {
    final role = _controller.getRoleNameForEmployee(employee);
    final designation = employee.designation?.trim();
    if (role.isNotEmpty && role != '—' && role != 'Staff') {
      if (designation != null &&
          designation.isNotEmpty &&
          designation != role) {
        return '$role • $designation';
      }
      return role;
    }
    if (designation != null && designation.isNotEmpty) {
      return designation;
    }
    return role.isNotEmpty ? role : 'Staff';
  }

  @override
  void initState() {
    super.initState();
    _dataSource = widget.dataSource ?? ApiEmployeeProfileDataSource();
  }

  @override
  Widget build(BuildContext context) {
    final employee = widget.employee;
    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: "Employee's Database",
        subtitle: "Employee's Database  >  ${employee.fullName}",
      ),
      children: [
        AppCard(
          padding: const EdgeInsets.all(20),
          elevation: AppCardElevation.sm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildEmployeeHeader(employee),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(height: 1, color: AppColors.borderSubtle),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 242, child: _buildSectionNavigation()),
                  const SizedBox(width: 40),
                  Expanded(child: _buildInformationArea(employee)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeHeader(Employee employee) {
    final hasPicture = employee.profilePicture != null &&
        employee.profilePicture!.isNotEmpty &&
        employee.profilePicture != 'string';
    return Row(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: AppRadii.brLg,
            border: Border.all(color: AppColors.borderSubtle),
            image: hasPicture
                ? DecorationImage(
                    image: NetworkImage(employee.profilePicture!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: hasPicture
              ? null
              : Center(
                  child: Text(
                    employee.firstName.isEmpty
                        ? '?'
                        : employee.firstName[0].toUpperCase(),
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(employee.fullName, style: AppTextStyles.h2),
              const SizedBox(height: 8),
              _headerDetail(Iconsax.briefcase, _getRoleOrDesignation(employee)),
              const SizedBox(height: 6),
              _headerDetail(Iconsax.sms, employee.email),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  StatusChip(
                    label: employee.isActive ? 'Active' : 'Inactive',
                    tone: employee.isActive
                        ? StatusTone.success
                        : StatusTone.neutral,
                    dense: true,
                  ),
                  StatusChip(
                    label: employee.isVerified ? 'Verified' : 'Unverified',
                    tone: employee.isVerified
                        ? StatusTone.success
                        : StatusTone.warning,
                    dense: true,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (widget.secondaryAction != null) ...[
          widget.secondaryAction!,
          const SizedBox(width: 12),
        ],
        widget.editAction ??
            MyElevatedButton(
              child: 'Edit Profile',
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              icon: const Icon(Iconsax.edit,
                  size: 16, color: AppColors.textOnPrimary),
              onTap: () {},
            ),
      ],
    );
  }

  Widget _headerDetail(IconData icon, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionNavigation() {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderSubtle),
        borderRadius: AppRadii.brLg,
      ),
      child: Column(
        children: _sections.map((section) {
          final label = section.$1;
          final selected = label == _selectedSection;
          return Material(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: label == _sections.first.$1
                ? const BorderRadius.vertical(top: Radius.circular(16))
                : label == _sections.last.$1
                    ? const BorderRadius.vertical(bottom: Radius.circular(16))
                    : BorderRadius.zero,
            child: InkWell(
              onTap: () => _selectSection(label),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Icon(
                      section.$2,
                      size: 20,
                      color: selected
                          ? AppColors.textOnPrimary
                          : AppColors.textPrimary,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: selected
                              ? AppColors.textOnPrimary
                              : AppColors.textPrimary,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInformationArea(Employee employee) {
    switch (_selectedSection) {
      case 'Activity':
        return _buildActivity(employee);
      case 'Tasks':
        return _buildTasks(employee);
      case 'Work Reports':
        return _buildWorkReports(employee);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoTabs(),
        const SizedBox(height: 24),
        if (_selectedInfoTab == 'Personal Information')
          _buildPersonalInformation(employee)
        else if (_selectedInfoTab == 'Professional Information')
          _buildProfessionalInformation(employee)
        else if (widget.controller != null)
          _DocumentsTab(controller: widget.controller!, userId: employee.id)
        else
          const EmptyState(
            icon: Iconsax.document,
            title: 'Documents unavailable',
            subtitle: 'No document service is connected to this view.',
          ),
      ],
    );
  }

  void _selectSection(String section) {
    if (section == 'Activity' && _activityFuture == null) {
      _activityFuture = _dataSource.loadActivity(widget.employee);
    } else if (section == 'Tasks' && _tasksFuture == null) {
      _tasksFuture = _dataSource.loadTasks(widget.employee);
    } else if (section == 'Work Reports' && _workReportsFuture == null) {
      _workReportsFuture = _dataSource.loadWorkReports(widget.employee);
    }
    setState(() => _selectedSection = section);
  }

  Widget _buildActivity(Employee employee) {
    return _profileDataFuture<AuditLogResponse>(
      future: _activityFuture,
      emptyTitle: 'No activity found',
      emptySubtitle: 'There is no recorded activity for this employee.',
      onRetry: () => setState(() {
        _activityFuture = _dataSource.loadActivity(employee);
      }),
      itemBuilder: (item) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(
          backgroundColor: AppColors.surfaceMuted,
          child: Icon(Iconsax.activity, color: AppColors.primary, size: 18),
        ),
        title:
            Text(item.activity.isEmpty ? 'Employee activity' : item.activity),
        subtitle: Text(
          [item.auditTypeDisplay, item.auditStatusDisplay, item.createdAt]
              .where((part) => part.trim().isNotEmpty)
              .join(' • '),
        ),
      ),
    );
  }

  Widget _buildTasks(Employee employee) {
    return _profileDataFuture<Task>(
      future: _tasksFuture,
      emptyTitle: 'No tasks found',
      emptySubtitle: 'No tasks are assigned to this employee.',
      onRetry: () => setState(() {
        _tasksFuture = _dataSource.loadTasks(employee);
      }),
      itemBuilder: (task) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(
          backgroundColor: AppColors.surfaceMuted,
          child: Icon(Iconsax.task_square, color: AppColors.primary, size: 18),
        ),
        title: Text(task.name),
        subtitle: Text(
          [
            task.status,
            task.priority,
            task.dueDate.isNotEmpty
                ? formatAppDateValue(task.dueDate, fallback: task.dueDate)
                : ''
          ].where((part) => part.trim().isNotEmpty).join(' • '),
        ),
      ),
    );
  }

  Widget _buildWorkReports(Employee employee) {
    return _profileDataFuture<WorkReport>(
      future: _workReportsFuture,
      emptyTitle: 'No work reports found',
      emptySubtitle: 'This employee has no work reports available.',
      onRetry: () => setState(() {
        _workReportsFuture = _dataSource.loadWorkReports(employee);
      }),
      itemBuilder: (report) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(
          backgroundColor: AppColors.surfaceMuted,
          child: Icon(Iconsax.note_2, color: AppColors.primary, size: 18),
        ),
        title: Text(
          report.day == null
              ? 'Work report'
              : DateFormat('dd-MM-yyyy').format(report.day!),
        ),
        subtitle: Text(
          [
            '${report.hoursWorked} hours',
            report.status,
            if (report.workActivities?.trim().isNotEmpty == true)
              report.workActivities!,
          ].join(' • '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Iconsax.arrow_right_3, size: 18),
        onTap: () => _showWorkReportDetail(report.id),
      ),
    );
  }

  Widget _profileDataFuture<T>({
    required Future<List<T>>? future,
    required String emptyTitle,
    required String emptySubtitle,
    required VoidCallback onRetry,
    required Widget Function(T item) itemBuilder,
  }) {
    if (future == null) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Column(
            children: [
              EmptyState(
                icon: Iconsax.info_circle,
                title: 'Unable to load data',
                subtitle: snapshot.error.toString(),
              ),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          );
        }
        final items = snapshot.data ?? <T>[];
        if (items.isEmpty) {
          return EmptyState(
            icon: Iconsax.receipt,
            title: emptyTitle,
            subtitle: emptySubtitle,
          );
        }
        return Column(
          children: items
              .map((item) => Column(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: itemBuilder(item),
                      ),
                      const Divider(height: 1, color: AppColors.borderSubtle),
                    ],
                  ))
              .toList(),
        );
      },
    );
  }

  Future<void> _showWorkReportDetail(String reportId) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => FutureBuilder<WorkReport>(
        future: _dataSource.loadWorkReport(reportId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return AlertDialog(
              title: const Text('Work report unavailable'),
              content: Text(snapshot.error?.toString() ??
                  'The full work report could not be loaded.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          }
          final report = snapshot.data!;
          return AlertDialog(
            title: const Text('Work report'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _reportDetail(
                      'Date',
                      report.day == null
                          ? '—'
                          : DateFormat('dd-MM-yyyy').format(report.day!)),
                  _reportDetail('Hours', '${report.hoursWorked}'),
                  _reportDetail('Operational base', report.operationalBase),
                  _reportDetail('Activities', report.workActivities),
                  _reportDetail('Task details', report.taskDetails),
                  _reportDetail('Next-day plan', report.planNextDay),
                  _reportDetail('Status', report.status),
                  _reportDetail('Feedback', report.feedback),
                  _reportDetail(
                    'Attachments',
                    report.attachments.isEmpty
                        ? 'None'
                        : report.attachments
                            .map((attachment) => attachment.fileUrl)
                            .join('\n'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _reportDetail(String label, String? value) {
    if (value == null || value.trim().isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text('$label: —'),
      );
    }
    final items = WorkReportFormatUtils.parseItems(value);
    if (items.length <= 1) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text('$label: ${items.isNotEmpty ? items.first : value}'),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:'),
          const SizedBox(height: 4),
          ...items.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 2),
                  child: Text('${entry.key + 1}. ${entry.value}'),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildInfoTabs() {
    return Row(
      children: _infoTabs.map((tab) {
        final selected = tab == _selectedInfoTab;
        return Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _selectedInfoTab = tab),
              child: Container(
                padding: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          selected ? AppColors.primary : AppColors.borderSubtle,
                      width: selected ? 2 : 1,
                    ),
                  ),
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMd.copyWith(
                    color:
                        selected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPersonalInformation(Employee employee) {
    return _DesktopInfoGrid(fields: [
      _DesktopInfoField('First Name', employee.firstName),
      _DesktopInfoField('Last Name', employee.lastName),
      _DesktopInfoField('Employee ID', employee.employeeId ?? employee.id),
      _DesktopInfoField('Gender', employee.gender),
      _DesktopInfoField(
        'Date of Birth',
        employee.dateOfBirth == null
            ? null
            : DateFormat('dd-MM-yyyy').format(employee.dateOfBirth!),
      ),
      _DesktopInfoField('Marital Status', employee.maritalStatus),
      _DesktopInfoField('Email', employee.email),
      _DesktopInfoField('Phone', employee.phoneNumber),
      _DesktopInfoField('Address', employee.streetAddress ?? employee.address),
      _DesktopInfoField('City', employee.city),
      _DesktopInfoField('State', employee.state),
      _DesktopInfoField('Nationality', employee.nationality),
    ]);
  }

  Widget _buildProfessionalInformation(Employee employee) {
    return _DesktopInfoGrid(fields: [
      _DesktopInfoField('Role', _controller.getRoleNameForEmployee(employee)),
      _DesktopInfoField(
        'Designation',
        employee.designation?.trim().isNotEmpty == true
            ? employee.designation!
            : '—',
      ),
      _DesktopInfoField('Department', employee.departmentName),
      _DesktopInfoField('Branch', employee.branchName),
      _DesktopInfoField('Unit', employee.departmentUnitName),
      _DesktopInfoField('Employment Type', employee.employmentType),
      _DesktopInfoField('Status', employee.isActive ? 'Active' : 'Inactive'),
      _DesktopInfoField('Reporting To', employee.reportingToName),
      _DesktopInfoField('Location', employee.location),
      _DesktopInfoField(
        'Joining Date',
        employee.startDate == null
            ? null
            : DateFormat('dd-MM-yyyy').format(employee.startDate!),
      ),
      _DesktopInfoField('Work Schedule', employee.workSchedule),
    ]);
  }
}

class _DesktopInfoField {
  final String label;
  final String? value;

  const _DesktopInfoField(this.label, this.value);
}

class _DesktopInfoGrid extends StatelessWidget {
  final List<_DesktopInfoField> fields;

  const _DesktopInfoGrid({required this.fields});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: fields.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 28,
        mainAxisSpacing: 22,
        mainAxisExtent: 58,
      ),
      itemBuilder: (context, index) {
        final field = fields[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.label,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textSecondary,
                )),
            const SizedBox(height: 6),
            Text(
              field.value?.trim().isNotEmpty == true ? field.value! : '—',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: AppColors.borderSubtle),
          ],
        );
      },
    );
  }
}

// ==============================================================================
// TAB 1: PROFILE
// ==============================================================================
class _ProfileTab extends StatelessWidget {
  final Employee employee;
  const _ProfileTab({required this.employee});

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.breakpoint.isDesktop;

    return LayoutBuilder(builder: (context, constraints) {
      final double maxWidth = constraints.maxWidth;
      const double twoColGap = 24.0;
      final leftWidth = isDesktop ? (maxWidth * 0.32) : maxWidth;
      final rightWidth =
          isDesktop ? (maxWidth - leftWidth - twoColGap) : maxWidth;

      return Wrap(
        spacing: twoColGap,
        runSpacing: 24,
        children: [
          SizedBox(
            width: leftWidth,
            child: _InfoCard(
              title: 'Contact Information',
              children: [
                _InfoRow(
                    icon: Iconsax.sms,
                    label: 'Email Address',
                    value: employee.email),
                _InfoRow(
                    icon: Iconsax.call,
                    label: 'Phone Number',
                    value: employee.phoneNumber ?? '—'),
                _InfoRow(
                    icon: Iconsax.location,
                    label: 'Location',
                    value: employee.location ?? employee.branchName ?? '—'),
              ],
            ),
          ),
          SizedBox(
            width: rightWidth,
            child: _InfoCard(
              title: 'Personal Information',
              isGrid: true,
              children: [
                _DataField(
                    label: 'Employee ID',
                    value: employee.employeeId ?? employee.id),
                _DataField(
                    label: 'Date of Birth',
                    value: employee.dateOfBirth != null
                        ? DateFormat('dd-MM-yyyy').format(employee.dateOfBirth!)
                        : '—'),
                _DataField(label: 'Gender', value: employee.gender ?? '—'),
                _DataField(
                    label: 'Marital Status',
                    value: employee.maritalStatus ?? '—'),
                _DataField(
                    label: 'Nationality', value: employee.nationality ?? '—'),
              ],
            ),
          ),
          SizedBox(
            width: leftWidth,
            child: _InfoCard(
              title: 'Manager',
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          AppColors.warning.withValues(alpha: 0.18),
                      radius: 22,
                      child: Text(
                        (employee.reportingToName ?? 'N').isNotEmpty
                            ? (employee.reportingToName ?? 'N')[0].toUpperCase()
                            : 'N',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employee.reportingToName ?? 'Not Assigned',
                            style: AppTextStyles.bodyMd.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Reporting Manager',
                            style: AppTextStyles.bodySm,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: rightWidth,
            child: _InfoCard(
              title: 'Contact Address',
              isGrid: true,
              children: [
                _DataField(label: 'Work Email', value: employee.email),
                _DataField(
                    label: 'Personal Email',
                    value: employee.personalEmail ?? '—'),
                _DataField(label: 'Phone', value: employee.phoneNumber ?? '—'),
                _DataField(
                    label: 'Other Phone',
                    value: employee.otherPhoneNumber ?? '—'),
                _DataField(
                    label: 'Street Address',
                    value: employee.streetAddress ?? employee.address ?? '—'),
                _DataField(label: 'City', value: employee.city ?? '—'),
                _DataField(label: 'State', value: employee.state ?? '—'),
                _DataField(label: 'Zip Code', value: employee.zipCode ?? '—'),
                _DataField(
                    label: 'Emergency Contact',
                    value: employee.emergencyContactName ?? '—'),
                _DataField(
                    label: 'Relationship',
                    value: employee.emergencyContactRelationship ?? '—'),
              ],
            ),
          ),
          SizedBox(
            width: maxWidth,
            child: _InfoCard(
              title: 'Employment',
              isGrid: true,
              children: [
                _DataField(
                  label: 'Role',
                  value: Get.isRegistered<EmployeeController>()
                      ? Get.find<EmployeeController>()
                          .getRoleNameForEmployee(employee)
                      : employee.role,
                ),
                _DataField(
                  label: 'Designation',
                  value: employee.designation?.trim().isNotEmpty == true
                      ? employee.designation!
                      : '—',
                ),
                _DataField(
                    label: 'Department',
                    value: employee.departmentName ??
                        employee.departmentId?.toString() ??
                        '—'),
                _DataField(
                    label: 'Unit', value: employee.departmentUnitName ?? '—'),
                _DataField(
                    label: 'Branch',
                    value: employee.branchName ??
                        employee.branchId?.toString() ??
                        '—'),
                _DataField(label: 'Location', value: employee.location ?? '—'),
                _DataField(
                    label: 'Reporting To',
                    value: employee.reportingToName ?? '—'),
                _DataField(
                    label: 'Employment Type',
                    value: employee.employmentType ?? '—'),
                _DataField(
                  label: 'Status',
                  customValue: StatusChip(
                    label: employee.isActive ? 'Active' : 'Inactive',
                    tone: employee.isActive
                        ? StatusTone.success
                        : StatusTone.neutral,
                    dense: true,
                  ),
                ),
                _DataField(
                    label: 'Joining Date',
                    value: employee.startDate != null
                        ? DateFormat('dd-MM-yyyy').format(employee.startDate!)
                        : '—'),
                _DataField(
                    label: 'Probation Period',
                    value: employee.probationPeriod != null
                        ? '${employee.probationPeriod} Months'
                        : '—'),
              ],
            ),
          ),
          SizedBox(
            width: maxWidth,
            child: _InfoCard(
              title: 'Compensation',
              isGrid: true,
              children: [
                _DataField(
                    label: 'Basic Salary',
                    value: employee.grossSalary != null
                        ? employee.grossSalary!.toNaira()
                        : '₦0.00'),
                _DataField(
                    label: 'Payment Frequency',
                    value: employee.salaryFrequency ?? '—'),
                _DataField(label: 'Bank Name', value: employee.bankName ?? '—'),
                _DataField(
                    label: 'Account Number',
                    value: employee.accountNumber ?? '—'),
                _DataField(label: 'Tax ID', value: employee.taxId ?? '—'),
                _DataField(
                    label: 'Pension Number',
                    value: employee.pensionNumber ?? '—'),
              ],
            ),
          ),
        ],
      );
    });
  }
}

// ==============================================================================
// TAB 2: DOCUMENTS
// ==============================================================================
class _DocumentsTab extends StatefulWidget {
  final EmployeeController controller;
  final String userId;

  const _DocumentsTab({required this.controller, required this.userId});

  @override
  State<_DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<_DocumentsTab> {
  @override
  void initState() {
    super.initState();
    widget.controller.fetchDocuments(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Digital Personnel File',
                          style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                            '${widget.controller.documents.length} document${widget.controller.documents.length == 1 ? '' : 's'} on file',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          )),
                    ],
                  ),
                ),
                MyElevatedButton(
                  child: 'Upload Document',
                  height: 44,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  icon: const Icon(Iconsax.document_upload,
                      color: AppColors.textOnPrimary, size: 16),
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => UploadDocumentDialog(userId: widget.userId),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Obx(() {
            if (widget.controller.isLoadingDocuments.value) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: LoadingSkeleton.listRows(count: 4),
              );
            }

            if (widget.controller.documents.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: EmptyState(
                  icon: Iconsax.document,
                  title: 'No documents found',
                  subtitle:
                      'Upload contracts, IDs, certificates, and other records for this employee.',
                ),
              );
            }

            return Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  color: AppColors.surfaceMuted,
                  child: const Row(
                    children: [
                      Expanded(flex: 4, child: _HeaderCell('Document Title')),
                      Expanded(flex: 2, child: _HeaderCell('Type')),
                      Expanded(flex: 3, child: _HeaderCell('Uploaded By')),
                      SizedBox(width: 60, child: _HeaderCell('')),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.borderSubtle),
                ...widget.controller.documents.map((doc) {
                  final title =
                      doc['name'] ?? doc['document_name'] ?? 'Untitled';
                  final type = doc['type'] ?? doc['document_type'] ?? '—';
                  final uploader = doc['uploaded_by'] ?? '—';
                  final docId = doc['id']?.toString() ?? '';

                  return _buildDocRow(title, type, uploader, docId);
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDocRow(
      String title, String type, String uploader, String docId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: AppRadii.brSm,
                  ),
                  child: const Icon(Iconsax.document,
                      size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    title,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                label: type.toString(),
                tone: StatusTone.neutral,
                dense: true,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              uploader.toString(),
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 60,
            child: Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<String>(
                icon: const Icon(Iconsax.more,
                    size: 18, color: AppColors.textMuted),
                onSelected: (value) {
                  if (value == 'delete' && docId.isNotEmpty) {
                    widget.controller
                        .deleteDocument(context, widget.userId, docId);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// TAB 3: REVIEWS
// ==============================================================================
class _ReviewsTab extends StatefulWidget {
  final EmployeeController controller;
  final Employee employee;

  const _ReviewsTab({required this.controller, required this.employee});

  @override
  State<_ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<_ReviewsTab> {
  @override
  void initState() {
    super.initState();
    widget.controller.fetchReviews(widget.employee.id);
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Performance Reviews',
                          style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                            '${widget.controller.reviews.length} review${widget.controller.reviews.length == 1 ? '' : 's'} recorded',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          )),
                    ],
                  ),
                ),
                const StatusChip(
                  label: 'Performance log',
                  tone: StatusTone.primary,
                  icon: Iconsax.star1,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Obx(() {
            if (widget.controller.isLoadingReviews.value) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: LoadingSkeleton.listRows(count: 4),
              );
            }

            if (widget.controller.reviews.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: EmptyState(
                  icon: Iconsax.star,
                  title: 'No reviews found',
                  subtitle:
                      'Reviews appear here once managers submit performance feedback.',
                ),
              );
            }

            return Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  color: AppColors.surfaceMuted,
                  child: const Row(
                    children: [
                      Expanded(flex: 4, child: _HeaderCell('From')),
                      Expanded(flex: 3, child: _HeaderCell('Date')),
                      Expanded(flex: 3, child: _HeaderCell('Rating')),
                      SizedBox(width: 60, child: _HeaderCell('')),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.borderSubtle),
                ...widget.controller.reviews.map((review) {
                  final reviewerName =
                      review['reviewer_name'] ?? review['from'] ?? 'Unknown';
                  final date = review['created_at'] ?? review['date'] ?? '—';
                  final rating =
                      review['rating'] ?? review['overall_rating'] ?? 0;
                  final reviewId = review['id']?.toString() ?? '';

                  return _buildReviewRow(reviewerName, date, rating, reviewId);
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReviewRow(
      String reviewer, String date, dynamic rating, String reviewId) {
    final int ratingInt =
        rating is int ? rating : (int.tryParse(rating.toString()) ?? 0);
    final String formattedDate =
        date.length > 10 ? date.substring(0, 10) : date;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primarySubtle,
                  child: Text(
                    reviewer.isNotEmpty ? reviewer[0].toUpperCase() : '?',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    reviewer,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              formattedDate,
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < ratingInt ? Iconsax.star1 : Iconsax.star,
                  color: AppColors.warning,
                  size: 16,
                );
              }),
            ),
          ),
          SizedBox(
            width: 60,
            child: Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<String>(
                icon: const Icon(Iconsax.more,
                    size: 18, color: AppColors.textMuted),
                onSelected: (value) {
                  if (value == 'delete' && reviewId.isNotEmpty) {
                    widget.controller
                        .deleteReview(context, widget.employee.id, reviewId);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// TAB 4: BENEFITS
// ==============================================================================
class _BenefitsTab extends StatelessWidget {
  final Employee employee;
  const _BenefitsTab({required this.employee});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 700;
      final colWidth =
          isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth;

      return Wrap(
        spacing: 24,
        runSpacing: 24,
        children: [
          SizedBox(
            width: colWidth,
            child: _InfoCard(
              title: 'Health Insurance (HMO)',
              hasEdit: true,
              children: [
                _DataField(
                    label: 'Current Plan',
                    value: employee.hmoPlan ?? '—',
                    isBoldValue: true),
                _DataField(
                    label: 'HMO ID Number',
                    value: employee.hmoIdNumber ?? '—',
                    isBoldValue: true),
                _DataField(
                    label: 'Dependents Covered',
                    value: employee.hmoDependentsCovered?.toString() ?? '—',
                    isBoldValue: true),
              ],
            ),
          ),
          SizedBox(
            width: colWidth,
            child: _InfoCard(
              title: 'Pension Scheme',
              hasEdit: true,
              children: [
                _DataField(
                    label: 'PFA Provider',
                    value: employee.pfaProvider ?? '—',
                    isBoldValue: true),
                _DataField(
                    label: 'RSA Number',
                    value: employee.rsaNumber ?? '—',
                    isBoldValue: true),
                _DataField(
                    label: 'Employer Contribution',
                    value: employee.employerContribution != null
                        ? '${employee.employerContribution}%'
                        : '—',
                    isBoldValue: true),
              ],
            ),
          ),
          SizedBox(
            width: constraints.maxWidth,
            child: _InfoCard(
              title: 'Allowances & Perks',
              customAction: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadii.brSm,
                ),
                child: Text(
                  'Add',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              children: _buildAllowanceRows(),
            ),
          ),
        ],
      );
    });
  }

  List<Widget> _buildAllowanceRows() {
    final allowances = employee.allowances;
    if (allowances == null || allowances.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'No allowances configured.',
            style:
                AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ];
    }

    return allowances.entries.map((entry) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${entry.value}',
                    style: AppTextStyles.bodySm,
                  ),
                ],
              ),
            ),
            const Icon(Iconsax.trash, color: AppColors.danger, size: 18),
          ],
        ),
      );
    }).toList();
  }
}

// ==============================================================================
// SHARED WIDGETS
// ==============================================================================

class _HeaderCell extends StatelessWidget {
  final String label;
  const _HeaderCell(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.bodySm.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool isGrid;
  final bool hasEdit;
  final Widget? customAction;

  const _InfoCard({
    required this.title,
    required this.children,
    this.isGrid = false,
    this.hasEdit = false,
    this.customAction,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.h4),
              if (customAction != null)
                customAction!
              else if (hasEdit)
                Text(
                  'Edit',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (isGrid)
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 520;
              final colCount = isWide ? 2 : 1;
              const spacing = 20.0;
              final colWidth =
                  (constraints.maxWidth - (spacing * (colCount - 1))) /
                      colCount;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: children
                    .map((c) => SizedBox(width: colWidth, child: c))
                    .toList(),
              );
            })
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: AppRadii.brSm,
            ),
            child: const Icon(Iconsax.location,
                color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: AppTextStyles.bodySm),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).withIcon(icon);
  }
}

extension _IconOverride on Padding {
  Padding withIcon(IconData icon) {
    final row = child as Row;
    final children = List<Widget>.from(row.children);
    final iconBox = children[0] as Container;
    children[0] = Container(
      padding: iconBox.padding,
      decoration: iconBox.decoration,
      child: Icon(icon, color: AppColors.primary, size: 16),
    );
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: row.crossAxisAlignment,
        children: children,
      ),
    );
  }
}

class _DataField extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? customValue;
  final bool isBoldValue;

  const _DataField({
    required this.label,
    this.value,
    this.customValue,
    this.isBoldValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySm),
        const SizedBox(height: 4),
        if (customValue != null)
          customValue!
        else
          Text(
            value ?? '—',
            style: AppTextStyles.bodyMd.copyWith(
              fontWeight: isBoldValue ? FontWeight.w700 : FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
      ],
    );
  }
}
