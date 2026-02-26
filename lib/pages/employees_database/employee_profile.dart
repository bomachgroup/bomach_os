import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/nav/employee_stepper.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/employees_database/widget/add_note_dialog.dart';
import 'package:bms_front_end/pages/employees_database/widget/assign_task_dialog.dart';
import 'package:bms_front_end/pages/employees_database/widget/documents_table.dart';
import 'package:bms_front_end/pages/employees_database/widget/report_files_table.dart';
import 'package:bms_front_end/pages/operations/widget/project_task_table.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../src/model/employees_model.dart';
import 'add_new_employee.dart';

class EmployeeProfile extends StatefulWidget {
  final Employee? e;
  const EmployeeProfile({super.key, this.e});

  @override
  State<EmployeeProfile> createState() => _EmployeeProfileState();
}

class _EmployeeProfileState extends State<EmployeeProfile> {
  int employeeDetailSelectionState = 0;
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken(BuildContext context) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");
    return token.replaceAll('"', '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final employee =
        widget.e ?? ModalRoute.of(context)?.settings.arguments as Employee?;

    if (employee == null) {
      return const Center(child: Text("Employee not found"));
    }

    final List<Widget> _employeeDetailpages = [
      ProfiledDetail(employee: employee),
      const Center(
          child: Padding(
              padding: EdgeInsets.all(20),
              child: Text("Activity Log Coming Soon"))),
      const Projects(),
      const ProjectTaskTable(projectId: 0),
      const ReportFilesTable(),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CloseButton(),
            const SizedBox(height: 8),
            const MyText(
              'Employee’s Database',
              style: AppText.black_600_32,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const MyText(
                    'Employee’s Database',
                    style: AppText.black_400_14,
                  ),
                ),
                kSizedBoxWidthSM,
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                ),
                kSizedBoxWidthSM,
                MyText(
                  '${employee.firstName} ${employee.lastName}',
                  style: AppText.black_400_14,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(width: 0.6, color: AppColors.border)),
              child: Wrap(
                runSpacing: 20,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(16)),
                        width: 100,
                        height: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: employee.profilePicture != null &&
                                  employee.profilePicture != "string" &&
                                  employee.profilePicture!.isNotEmpty
                              ? Image.network(
                                  employee.profilePicture!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.person, size: 50),
                                )
                              : Center(
                                  child: Text(
                                    employee.firstName.isNotEmpty
                                        ? employee.firstName[0]
                                        : '?',
                                    style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  ),
                                ),
                        ),
                      ),
                      kSizedBoxWidth,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            '${employee.firstName} ${employee.lastName}',
                            size: 24,
                            weight: 600,
                            color: AppColors.black,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                "assets/svg/briefcase.svg",
                                height: 20,
                              ),
                              kSizedBoxWidthSM,
                              MyText(
                                employee.employmentType ?? 'No Role',
                                style: AppText.black_400_16,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                "assets/svg/message.svg",
                                height: 20,
                              ),
                              kSizedBoxWidthSM,
                              MyText(
                                employee.email,
                                style: AppText.black_400_14,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyElevatedButton(
                        icon: SvgPicture.asset(
                          employeeDetailSelectionState == 3
                              ? "assets/svg/add-circle.svg"
                              : "assets/svg/edit-pencil.svg",
                          colorFilter: const ColorFilter.mode(
                              AppColors.white, BlendMode.srcIn),
                        ),
                        child: employeeDetailSelectionState == 3
                            ? "Assign Task"
                            : employeeDetailSelectionState == 4
                                ? "Add Notes"
                                : 'Edit Profile',
                        onTap: () async {
                          if (employeeDetailSelectionState == 3) {
                            showDialog(
                                context: context,
                                builder: (c) => const AssignTaskDialog());
                          } else if (employeeDetailSelectionState == 4) {
                            showDialog(
                                context: context,
                                builder: (c) => const AddNoteDialog());
                          } else {
                            final token = await _getToken(context);
                            if (token != null && context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (c) =>
                                      AddEmployesScreen(token: token),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      kSizedBoxWidth,
                      if (employeeDetailSelectionState == 4)
                        MyElevatedButton(
                          icon: SvgPicture.asset(
                            "assets/svg/upload3.svg",
                            colorFilter: const ColorFilter.mode(
                                AppColors.white, BlendMode.srcIn),
                          ),
                          child: "Upload file",
                          onTap: () {},
                        ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 28),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 242,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _buildSidebarItem(0, 'Profile', "assets/svg/person.svg",
                            "assets/svg/person-filled.svg"),
                        _buildSidebarItem(
                            1,
                            'Activity',
                            "assets/svg/heart-rate.svg",
                            "assets/svg/heart-rate.svg"),
                        _buildSidebarItem(2, 'Projects', "assets/svg/todo2.svg",
                            "assets/svg/todo2.svg"),
                        _buildSidebarItem(3, 'Tasks', "assets/svg/tasks.svg",
                            "assets/svg/tasks.svg"),
                        _buildSidebarItem(4, 'Reports Files',
                            "assets/svg/todo.svg", "assets/svg/todo.svg",
                            isBottom: true),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  child: _employeeDetailpages[employeeDetailSelectionState],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(
      int index, String title, String icon, String activeIcon,
      {bool isBottom = false}) {
    bool isSelected = employeeDetailSelectionState == index;
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.blue : Colors.transparent,
        borderRadius: BorderRadius.vertical(
          top: index == 0 ? const Radius.circular(20) : Radius.zero,
          bottom: isBottom ? const Radius.circular(20) : Radius.zero,
        ),
      ),
      child: ListTile(
        onTap: () => setState(() => employeeDetailSelectionState = index),
        title: MyText(
          title,
          isSelectable: false,
          style: isSelected ? AppText.white_600_16 : AppText.sideMText_300_16,
        ),
        leading: SvgPicture.asset(
          isSelected ? activeIcon : icon,
          colorFilter: ColorFilter.mode(
              isSelected ? AppColors.white : AppColors.black, BlendMode.srcIn),
        ),
      ),
    );
  }
}

class ProfiledDetail extends StatefulWidget {
  final Employee employee;
  const ProfiledDetail({super.key, required this.employee});

  @override
  State<ProfiledDetail> createState() => _ProfiledDetailState();
}

class _ProfiledDetailState extends State<ProfiledDetail> {
  int employeeProfileSelectionStepperState = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _employeeProfilePages = [
      PersonalInfoDetail(employee: widget.employee),
      ProfessionaInfoDetail(employee: widget.employee),
      const DocumentsTable()
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            EmployeeInfoStepper(
              isActive: employeeProfileSelectionStepperState == 0,
              icon: SvgPicture.asset("assets/svg/person.svg"),
              activeIcon: SvgPicture.asset("assets/svg/person-filled.svg"),
              title: 'Personal Information',
              onTap: () =>
                  setState(() => employeeProfileSelectionStepperState = 0),
            ),
            EmployeeInfoStepper(
              isActive: employeeProfileSelectionStepperState == 1,
              icon: SvgPicture.asset("assets/svg/briefcase.svg"),
              activeIcon: SvgPicture.asset("assets/svg/briefcase-filled.svg"),
              title: 'Professional Information',
              onTap: () =>
                  setState(() => employeeProfileSelectionStepperState = 1),
            ),
            EmployeeInfoStepper(
              isActive: employeeProfileSelectionStepperState == 2,
              icon: SvgPicture.asset("assets/svg/document.svg"),
              activeIcon: SvgPicture.asset("assets/svg/document-filled.svg"),
              title: 'Documents',
              onTap: () =>
                  setState(() => employeeProfileSelectionStepperState = 2),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _employeeProfilePages[employeeProfileSelectionStepperState]
      ],
    );
  }
}

class PersonalInfoDetail extends StatelessWidget {
  final Employee employee;
  const PersonalInfoDetail({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ProfileFiedsHolder(title: 'First Name', detail: employee.firstName),
            const SizedBox(width: 24),
            ProfileFiedsHolder(title: 'Last Name', detail: employee.lastName),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            ProfileFiedsHolder(
                title: 'Phone Number', detail: employee.phoneNumber ?? '-'),
            const SizedBox(width: 24),
            ProfileFiedsHolder(title: 'Gender', detail: employee.gender ?? '-'),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            ProfileFiedsHolder(
                title: 'Date of Birth',
                detail: employee.dateOfBirth != null
                    ? DateFormat('MMMM dd, yyyy').format(employee.dateOfBirth!)
                    : '-'),
            const SizedBox(width: 24),
            ProfileFiedsHolder(
                title: 'Marital Status', detail: employee.maritalStatus ?? '-'),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            ProfileFiedsHolder(
                title: 'Address', detail: employee.address ?? '-'),
            const SizedBox(width: 24),
            ProfileFiedsHolder(title: 'City', detail: 'Enugu'),
          ],
        ),
      ],
    );
  }
}

class ProfessionaInfoDetail extends StatelessWidget {
  final Employee employee;
  const ProfessionaInfoDetail({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ProfileFiedsHolder(title: 'Employee ID', detail: employee.id),
            const SizedBox(width: 24),
            ProfileFiedsHolder(title: 'Email', detail: employee.email),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            ProfileFiedsHolder(
                title: 'Employment Type',
                detail: employee.employmentType ?? '-'),
            const SizedBox(width: 24),
            ProfileFiedsHolder(
                title: 'Gross Salary',
                detail: employee.grossSalary != null
                    ? '₦${employee.grossSalary}'
                    : '-'),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            ProfileFiedsHolder(
                title: 'Branch ID',
                detail: employee.branchId?.toString() ?? '-'),
            const SizedBox(width: 24),
            ProfileFiedsHolder(
                title: 'Department ID',
                detail: employee.departmentId?.toString() ?? '-'),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            ProfileFiedsHolder(
                title: 'Start Date',
                detail: employee.startDate != null
                    ? DateFormat('MMMM dd, yyyy').format(employee.startDate!)
                    : '-'),
            const SizedBox(width: 24),
            ProfileFiedsHolder(
                title: 'Status',
                detail: employee.isActive ? 'Active' : 'Inactive'),
          ],
        ),
      ],
    );
  }
}

class ProfileFiedsHolder extends StatelessWidget {
  final String title;
  final String detail;
  const ProfileFiedsHolder({
    super.key,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(
            title,
            style: AppText.sideMText_300_14,
          ),
          const SizedBox(height: 3),
          MyText(
            detail,
            style: AppText.black_400_16,
            maxLines: 2,
          ),
          const Divider()
        ],
      ),
    );
  }
}

class Projects extends StatelessWidget {
  const Projects({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Projects List Coming Soon"));
  }
}
