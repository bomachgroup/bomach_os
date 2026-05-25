import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/components/paginate/responsive_table.dart';
import 'package:bomach_os/pages/hr/widget/add_job_post_dialog.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controller/applicant_controller.dart';
import 'controller/jobposting_control.dart';
import 'models/applicant_model.dart';
import 'models/job_posting.dart';
import 'widget/view_job_applicant_dialog.dart';

class JobPostPage extends StatefulWidget {
  const JobPostPage({super.key});

  @override
  State<JobPostPage> createState() => JobPostPageState();
}

class JobPostPageState extends State<JobPostPage> {
  final JobPostController controller = Get.put(JobPostController());
  final RxString _selectedTab = 'Job Opening'.obs;

  final List<String> _tabs = [
    'Pipeline',
    'Job Opening',
    'Onboarding',
    'Offboarding'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchJobPostings(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => PageScaffold(
          header: PageHeader(
            title: 'Recruitment',
            subtitle:
                'Manage job postings, pipelines, and onboarding processes.',
            trailing: _buildHeaderActions(),
          ),
          children: [
            // Tab Bar
            AppCard(
              padding: const EdgeInsets.all(8),
              elevation: AppCardElevation.sm,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _tabs.map((tab) => _buildTabItem(tab)).toList(),
                ),
              ),
            ),

            // Body content
            _buildBodyContent(),
          ],
        ));
  }

  Widget _buildHeaderActions() {
    String mainBtnText = 'Post Job';
    IconData mainBtnIcon = Iconsax.add_circle;
    Color mainBtnColor = AppColors.primary;

    void onMainAction() {
      controller.clearForm();
      showDialog(context: context, builder: (_) => const AddJobPostDialog());
    }

    if (_selectedTab.value == 'Pipeline') {
      mainBtnText = 'Add Candidate';
    } else if (_selectedTab.value == 'Onboarding') {
      mainBtnText = 'Add Staff';
    } else if (_selectedTab.value == 'Offboarding') {
      mainBtnText = 'Initiate Exit';
      mainBtnColor = AppColors.danger;
      mainBtnIcon = Iconsax.logout;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_selectedTab.value == 'Job Opening' ||
            _selectedTab.value == 'Onboarding') ...[
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('View All Postings'),
          ),
          const SizedBox(width: 12),
        ],
        MyElevatedButton(
          height: 48,
          bgColor: mainBtnColor,
          icon: Icon(mainBtnIcon, color: AppColors.white, size: 18),
          child: mainBtnText,
          onTap: onMainAction,
        ),
      ],
    );
  }

  Widget _buildTabItem(String title) {
    final bool isSelected = _selectedTab.value == title;
    return GestureDetector(
      onTap: () => _selectedTab.value = title,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: AppTextStyles.bodySm.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    switch (_selectedTab.value) {
      case 'Pipeline':
        return const PipelineTab();
      case 'Onboarding':
        return const OnboardingTab();
      case 'Offboarding':
        return const OffboardingTab();
      default:
        // Pass controller to the table
        return _JobOpeningTable(controller: controller);
    }
  }
}

// ==============================================================================
// 1. JOB OPENING TAB
// ==============================================================================
class _JobOpeningTable extends StatelessWidget {
  final JobPostController controller;

  const _JobOpeningTable({required this.controller});

  String _formatEnum(String text) {
    if (text.isEmpty) return 'N/A';
    if (text.toUpperCase() == 'FULL_TIME') return 'Full-time';
    return text
        .split('_')
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Padding(
            padding: EdgeInsets.all(48.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (controller.jobList.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(48.0),
            child: Center(child: MyText("No job postings found.")),
          );
        }

        return ResponsiveTable<JobPosting>(
          items: controller.jobList,
          columns: const [
            DataColumn(label: Text("Job Title")),
            DataColumn(label: Text("Department")),
            DataColumn(label: Text("Location")),
            DataColumn(label: Text("Type")),
            DataColumn(label: Text("Vacancies")),
            DataColumn(label: Text("Status")),
            DataColumn(label: Text("Action")),
          ],
          rowBuilder: (job, index) {
            final bool isActive = job.status.toLowerCase() == 'active';
            final Color statusColor =
                isActive ? AppColors.success : AppColors.neutral400;
            final Color statusBg = statusColor.withValues(alpha: 0.1);
            final String statusText = isActive ? 'Active' : 'Draft';

            return DataRow(cells: <DataCell>[
              DataCell(MyText(job.title,
                  size: 14, weight: 600, color: AppColors.textPrimary)),
              DataCell(MyText(job.departmentId,
                  size: 14, color: AppColors.textSecondary)),
              DataCell(MyText(job.branchId,
                  size: 14, color: AppColors.textSecondary)),
              DataCell(MyText(_formatEnum(job.jobType),
                  size: 14, color: AppColors.textSecondary)),
              const DataCell(
                  MyText("2", size: 14, color: AppColors.textSecondary)),
              DataCell(
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                            color: statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      MyText(statusText,
                          size: 12, weight: 600, color: statusColor),
                    ],
                  ),
                ),
              ),
              DataCell(
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Iconsax.more,
                      size: 18, color: AppColors.textSecondary),
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    backgroundColor: AppColors.neutral100,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ]);
          },
          mobileCardBuilder: (job, index) {
            final bool isActive = job.status.toLowerCase() == 'active';
            final Color statusColor =
                isActive ? AppColors.success : AppColors.neutral400;
            final Color statusBg = statusColor.withValues(alpha: 0.1);
            final String statusText = isActive ? 'Active' : 'Draft';

            return AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: MyText(job.title,
                            size: 16, weight: 700, color: AppColors.textPrimary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: MyText(statusText,
                            size: 11, weight: 600, color: statusColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Iconsax.location,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      MyText(job.branchId,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 16),
                      const Icon(Iconsax.briefcase,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      MyText(_formatEnum(job.jobType),
                          size: 12, color: AppColors.textSecondary),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const MyText('Department',
                              size: 11, color: AppColors.textSecondary),
                          const SizedBox(height: 4),
                          MyText(job.departmentId,
                              size: 13,
                              weight: 600,
                              color: AppColors.textPrimary),
                        ],
                      ),
                      MyElevatedButton(
                        height: 36,
                        bgColor: AppColors.neutral100,
                        textColor: AppColors.textPrimary,
                        child: 'Manage',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

// ==============================================================================
// 2. PIPELINE TAB
// ==============================================================================
class PipelineTab extends StatelessWidget {
  const PipelineTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ApplicantController controller = Get.put(ApplicantController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kanban Board
        SizedBox(
          height: 600, // Fixed height for Kanban area
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.applicantList.isEmpty) {
              return const Center(
                  child: Text("No candidates found in pipeline."));
            }

            return Scrollbar(
              thumbVisibility: true,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildKanbanColumn(context,
                      title: 'Applied',
                      applicants: controller.appliedApplicants),
                  _buildKanbanColumn(context,
                      title: 'Shortlisted',
                      applicants: controller.shortlistedApplicants),
                  _buildKanbanColumn(context,
                      title: 'Interviewed',
                      applicants: controller.interviewedApplicants),
                  _buildKanbanColumn(context,
                      title: 'Hired', applicants: controller.hiredApplicants),
                ],
              ),
            );
          }),
        ),

        const SizedBox(height: 16),

        // Paginator
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text("Page 1 of 1", style: AppTextStyles.bodySm),
              const SizedBox(width: 16),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Iconsax.arrow_left_2, size: 20)),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Iconsax.arrow_right_3, size: 20)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKanbanColumn(BuildContext context,
      {required String title, required List<Applicant> applicants}) {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText(title,
                  weight: 700, size: 16, color: AppColors.textPrimary),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: MyText('${applicants.length}',
                    size: 12, weight: 700, color: AppColors.primary),
              )
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AppCard(
              backgroundColor: AppColors.neutral100,
              padding: const EdgeInsets.all(12),
              child: applicants.isEmpty
                  ? Center(
                      child: Text("No candidates",
                          style: AppTextStyles.bodySm
                              .copyWith(color: AppColors.textSecondary)))
                  : ListView.separated(
                      itemCount: applicants.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _buildCandidateCard(context, applicants[index]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(BuildContext context, Applicant app) {
    return AppCard(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => ViewJobApplicantDialog(applicant: app),
        );
      },
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText('${app.firstName} ${app.lastName}',
              weight: 700, size: 15, color: AppColors.textPrimary),
          const SizedBox(height: 4),
          MyText(app.jobPostingId,
              color: AppColors.primary, weight: 600, size: 13),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Iconsax.calendar,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  MyText(
                    app.createdAt != null
                        ? "${app.createdAt!.day}/${app.createdAt!.month}/${app.createdAt!.year}"
                        : "N/A",
                    color: AppColors.textSecondary,
                    size: 12,
                  ),
                ],
              ),
              const Icon(Iconsax.more,
                  size: 16, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

class OnboardingTab extends StatelessWidget {
  const OnboardingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_OnboardingEmployee> employees = [
      const _OnboardingEmployee(
          name: 'Peace Chukwu',
          id: 'RS9DGB33',
          department: 'Engineering',
          location: 'Enugu',
          hireDate: '25-12-2024',
          progress: 1.0,
          status: 'In-Progress'),
      const _OnboardingEmployee(
          name: 'Peace Chukwu',
          id: 'RS9DGB33',
          department: 'Marketing',
          location: 'Ebonyi',
          hireDate: '25-12-2024',
          progress: 0.67,
          status: 'In-Progress'),
      const _OnboardingEmployee(
          name: 'Peace Chukwu',
          id: 'RS9DGB33',
          department: 'Operations',
          location: 'Enugu',
          hireDate: '25-12-2024',
          progress: 0.67,
          status: 'In-Progress'),
    ];

    return ResponsiveTable<_OnboardingEmployee>(
      items: employees,
      columns: const [
        DataColumn(label: Text("Employee")),
        DataColumn(label: Text("Department")),
        DataColumn(label: Text("Location")),
        DataColumn(label: Text("Hire Date")),
        DataColumn(label: Text("Status")),
        DataColumn(label: Text("Action")),
      ],
      rowBuilder: (e, index) => DataRow(cells: [
        DataCell(Row(children: [
          const CircleAvatar(radius: 18, backgroundColor: AppColors.neutral200),
          const SizedBox(width: 12),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyText(e.name,
                    weight: 600, size: 14, color: AppColors.textPrimary),
                const SizedBox(height: 2),
                MyText(e.id,
                    weight: 500, size: 12, color: AppColors.textSecondary),
              ])
        ])),
        DataCell(MyText(e.department, size: 14, color: AppColors.textSecondary)),
        DataCell(MyText(e.location, size: 14, color: AppColors.textSecondary)),
        DataCell(MyText(e.hireDate, size: 14, color: AppColors.textSecondary)),
        DataCell(SizedBox(
            width: 140,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                          value: e.progress,
                          backgroundColor: AppColors.neutral100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              e.progress == 1.0
                                  ? AppColors.success
                                  : AppColors.warning),
                          minHeight: 6)),
                  const SizedBox(height: 8),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppColors.neutral100,
                          borderRadius: BorderRadius.circular(6)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: e.progress == 1.0
                                    ? AppColors.success
                                    : AppColors.warning)),
                        const SizedBox(width: 6),
                        MyText(e.status,
                            size: 11,
                            color: AppColors.textSecondary,
                            weight: 600),
                        const SizedBox(width: 4),
                        const Icon(Iconsax.arrow_down_1,
                            size: 14, color: AppColors.textSecondary)
                      ]))
                ]))),
        DataCell(IconButton(
          onPressed: () {},
          icon: const Icon(Iconsax.more,
              size: 18, color: AppColors.textSecondary),
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(8),
            backgroundColor: AppColors.neutral100,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        )),
      ]),
      mobileCardBuilder: (e, index) => AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                    radius: 20, backgroundColor: AppColors.neutral200),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(e.name,
                          weight: 600, size: 15, color: AppColors.textPrimary),
                      MyText(e.id,
                          weight: 500,
                          size: 12,
                          color: AppColors.textSecondary),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Iconsax.more, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MyText('Department',
                          size: 11, color: AppColors.textSecondary),
                      MyText(e.department,
                          size: 13,
                          weight: 600,
                          color: AppColors.textPrimary),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MyText('Location',
                          size: 11, color: AppColors.textSecondary),
                      MyText(e.location,
                          size: 13,
                          weight: 600,
                          color: AppColors.textPrimary),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const MyText('Onboarding Progress',
                size: 11, color: AppColors.textSecondary),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: e.progress,
                      backgroundColor: AppColors.neutral100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          e.progress == 1.0
                              ? AppColors.success
                              : AppColors.warning),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                MyText('${(e.progress * 100).toInt()}%',
                    size: 12, weight: 700, color: AppColors.textPrimary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingEmployee {
  final String name, id, department, location, hireDate, status;
  final double progress;
  const _OnboardingEmployee(
      {required this.name,
      required this.id,
      required this.department,
      required this.location,
      required this.hireDate,
      required this.progress,
      required this.status});
}

// ==============================================================================
// 4. OFFBOARDING TAB
// ==============================================================================
class OffboardingTab extends StatelessWidget {
  const OffboardingTab({super.key});

  @override
  Widget build(BuildContext context) {
    const List<_OffboardingEmployee> employees = [
      _OffboardingEmployee(
          name: 'Peace Chukwu',
          id: 'RS9DGB33',
          department: 'Engineering',
          exitDate: '25-12-2024',
          reason: 'Relocation',
          status: 'Completed'),
      _OffboardingEmployee(
          name: 'Peace Chukwu',
          id: 'RS9DGB33',
          department: 'Marketing',
          exitDate: '25-12-2024',
          reason: 'Contract-End',
          status: 'In-Progress'),
      _OffboardingEmployee(
          name: 'Peace Chukwu',
          id: 'RS9DGB33',
          department: 'Operations',
          exitDate: '25-12-2024',
          reason: 'Contract-End',
          status: 'In-Progress'),
    ];

    return ResponsiveTable<_OffboardingEmployee>(
      items: employees,
      columns: const [
        DataColumn(label: Text("Employee")),
        DataColumn(label: Text("Department")),
        DataColumn(label: Text("Exit Date")),
        DataColumn(label: Text("Reason")),
        DataColumn(label: Text("Status")),
        DataColumn(label: Text("Action")),
      ],
      rowBuilder: (e, index) {
        final bool isCompleted = e.status == 'Completed';
        final Color statusColor =
            isCompleted ? AppColors.success : AppColors.warning;
        final Color statusBg = statusColor.withValues(alpha: 0.1);

        return DataRow(cells: [
          DataCell(Row(children: [
            const CircleAvatar(
                radius: 18, backgroundColor: AppColors.neutral200),
            const SizedBox(width: 12),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyText(e.name,
                      weight: 600, size: 14, color: AppColors.textPrimary),
                  const SizedBox(height: 2),
                  MyText(e.id,
                      weight: 500, size: 12, color: AppColors.textSecondary),
                ])
          ])),
          DataCell(
              MyText(e.department, size: 14, color: AppColors.textSecondary)),
          DataCell(MyText(e.exitDate, size: 14, color: AppColors.textSecondary)),
          DataCell(MyText(e.reason,
              weight: 600, size: 14, color: AppColors.textPrimary)),
          DataCell(Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: statusBg, borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: statusColor)),
                const SizedBox(width: 6),
                MyText(e.status, size: 12, color: statusColor, weight: 600),
              ]))),
          DataCell(IconButton(
            onPressed: () {},
            icon: const Icon(Iconsax.more,
                size: 18, color: AppColors.textSecondary),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              backgroundColor: AppColors.neutral100,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          )),
        ]);
      },
      mobileCardBuilder: (e, index) {
        final bool isCompleted = e.status == 'Completed';
        final Color statusColor =
            isCompleted ? AppColors.success : AppColors.warning;
        final Color statusBg = statusColor.withValues(alpha: 0.1);

        return AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                      radius: 20, backgroundColor: AppColors.neutral200),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(e.name,
                            weight: 600,
                            size: 15,
                            color: AppColors.textPrimary),
                        MyText(e.id,
                            weight: 500,
                            size: 12,
                            color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: MyText(e.status,
                        size: 11, weight: 600, color: statusColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MyText('Department',
                            size: 11, color: AppColors.textSecondary),
                        MyText(e.department,
                            size: 13,
                            weight: 600,
                            color: AppColors.textPrimary),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MyText('Exit Date',
                            size: 11, color: AppColors.textSecondary),
                        MyText(e.exitDate,
                            size: 13,
                            weight: 600,
                            color: AppColors.textPrimary),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MyText('Reason',
                          size: 11, color: AppColors.textSecondary),
                      MyText(e.reason,
                          size: 13,
                          weight: 600,
                          color: AppColors.textPrimary),
                    ],
                  ),
                  MyElevatedButton(
                    height: 36,
                    bgColor: AppColors.neutral100,
                    textColor: AppColors.textPrimary,
                    child: 'Details',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OffboardingEmployee {
  final String name, id, department, exitDate, reason, status;
  const _OffboardingEmployee(
      {required this.name,
      required this.id,
      required this.department,
      required this.exitDate,
      required this.reason,
      required this.status});
}
