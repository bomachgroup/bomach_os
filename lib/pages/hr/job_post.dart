import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:bms_front_end/pages/hr/widget/add_job_post_dialog.dart';

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

  String _selectedTab = 'Job Opening';
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
    return LayoutBuilder(builder: (context, constraints) {
      final bool isMobile = constraints.maxWidth < 800;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header
          _buildHeader(context, isMobile),

          kSizedBox,

          // 2. Tab Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _tabs.map((tab) => _buildTabItem(tab)).toList(),
            ),
          ),

          kSizedBox,

          // 3. Body Content
          // FIX: Replaced Expanded with a specific Container/SizedBox.
          // We use a fixed height for the Kanban/Tables to prevent unbounded height error.
          SizedBox(
            height: 650, // Give it enough height for the Kanban board
            child: _buildBodyContent(context, constraints, isMobile),
          ),
        ],
      );
    });
  }

  // --- Header & Navigation Logic ---

  Widget _buildHeader(BuildContext context, bool isMobile) {
    bool showJobPostingsBtn = true;
    String mainBtnText = 'Post Job';
    Color mainBtnColor = const Color(0xFF0055FF);
    Color mainBtnTextColor = Colors.white;
    IconData mainBtnIcon = CupertinoIcons.add;
    bool isOutlinedMain = false;
    VoidCallback onMainAction = () {
      controller.clearForm();
      showDialog(context: context, builder: (_) => const AddJobPostDialog());
    };

    if (_selectedTab == 'Pipeline') {
      showJobPostingsBtn = false;
      mainBtnText = 'Add Candidate';
      onMainAction = () {};
    } else if (_selectedTab == 'Onboarding') {
      showJobPostingsBtn = true;
      mainBtnText = 'Add Staff';
      onMainAction = () {};
    } else if (_selectedTab == 'Offboarding') {
      showJobPostingsBtn = false;
      mainBtnText = 'Initiate Exit';
      mainBtnColor = Colors.red;
      mainBtnTextColor = Colors.red;
      isOutlinedMain = true;
      onMainAction = () {};
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const MyText(
          'Recruitment',
          style: AppText.black_600_32,
        ),
        if (!isMobile)
          Row(
            children: [
              if (showJobPostingsBtn) ...[
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const MyText('Job Postings',
                      style: TextStyle(color: Colors.black87)),
                ),
                kSizedBoxWidth,
              ],
              isOutlinedMain
                  ? OutlinedButton.icon(
                      onPressed: onMainAction,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: mainBtnColor),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      icon:
                          Icon(mainBtnIcon, color: mainBtnTextColor, size: 18),
                      label: MyText(mainBtnText,
                          style: TextStyle(
                              color: mainBtnTextColor,
                              fontWeight: FontWeight.w600)),
                    )
                  : ElevatedButton.icon(
                      onPressed: onMainAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainBtnColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      icon:
                          Icon(mainBtnIcon, color: mainBtnTextColor, size: 18),
                      label: MyText(mainBtnText,
                          style: TextStyle(
                              color: mainBtnTextColor,
                              fontWeight: FontWeight.w600)),
                    ),
            ],
          )
        else
          IconButton(
            onPressed: onMainAction,
            icon: Icon(
              isOutlinedMain
                  ? Icons.exit_to_app
                  : CupertinoIcons.add_circled_solid,
              color: mainBtnColor,
              size: 30,
            ),
          )
      ],
    );
  }

  Widget _buildTabItem(String title) {
    final bool isSelected = _selectedTab == title;
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = title;
          });
        },
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0055FF) : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color:
                  isSelected ? const Color(0xFF0055FF) : Colors.grey.shade300,
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent(
      BuildContext context, BoxConstraints constraints, bool isMobile) {
    switch (_selectedTab) {
      case 'Pipeline':
        return const PipelineTab();
      case 'Onboarding':
        return const OnboardingTab();
      case 'Offboarding':
        return const OffboardingTab();
      case 'Job Opening':
      default:
        return _JobOpeningTable(
            controller: controller,
            constraints: constraints,
            isMobile: isMobile);
    }
  }
}

// ==============================================================================
// 1. JOB OPENING TAB
// ==============================================================================
class _JobOpeningTable extends StatelessWidget {
  final JobPostController controller;
  final BoxConstraints constraints;
  final bool isMobile;

  const _JobOpeningTable({
    required this.controller,
    required this.constraints,
    required this.isMobile,
  });

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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Scrollable Table
          // FIX: Removed Expanded here to avoid conflict
          Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: isMobile ? 800 : constraints.maxWidth - 32,
                ),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (controller.jobList.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(child: MyText("No job postings found.")),
                    );
                  }

                  return DataTable(
                    headingRowHeight: 60,
                    dataRowMinHeight: 70,
                    dataRowMaxHeight: 70,
                    columnSpacing: 20,
                    horizontalMargin: 24,
                    headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                    dividerThickness: 0.5,
                    columns: const [
                      DataColumn(label: MyText("Job Title")),
                      DataColumn(label: MyText("Department")),
                      DataColumn(label: MyText("Location")),
                      DataColumn(label: MyText("Type")),
                      DataColumn(label: MyText("Vacancies")),
                      DataColumn(label: MyText("Status")),
                      DataColumn(label: MyText("Action")),
                    ],
                    rows: _createRows(context, controller.jobList),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DataRow> _createRows(BuildContext context, List<JobPosting> jobs) {
    return jobs.map((job) {
      final bool isActive = job.status.toLowerCase() == 'active';
      final Color statusColor = isActive ? Colors.green : Colors.grey;
      final Color statusBg = isActive
          ? Colors.green.withOpacity(0.1)
          : Colors.grey.withOpacity(0.1);
      final String statusText = isActive ? 'Active' : 'Draft';

      return DataRow(cells: <DataCell>[
        DataCell(
            MyText(job.title, size: 14, weight: 600, color: Colors.black87)),
        DataCell(MyText(job.departmentId,
            size: 14, weight: 600, color: Colors.black87)),
        DataCell(
            MyText(job.branchId, size: 14, weight: 600, color: Colors.black87)),
        DataCell(MyText(_formatEnum(job.jobType),
            size: 14, weight: 600, color: Colors.black87)),
        const DataCell(MyText("2", size: 14, weight: 600, color: Colors.black87)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                        color: statusColor, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                MyText(statusText,
                    size: 12, weight: 600, color: Colors.black54),
              ],
            ),
          ),
        ),
        DataCell(
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
            ),
          ),
        ),
      ]);
    }).toList();
  }
}

class PipelineTab extends StatelessWidget {
  const PipelineTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ApplicantController controller = Get.put(ApplicantController());

    return Column(
      children: [
        _buildFilterBar(context),
        kSizedBox,
        Expanded(
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
              ),
            );
          }),
        ),
        // Paginator (Using simplified version or your custom one)
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.chevron_left)),
              const Text("Page 1 of 1"),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.chevron_right)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Container(); // Placeholder for brevity
  }

  Widget _buildKanbanColumn(BuildContext context,
      {required String title, required List<Applicant> applicants}) {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(right: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText(title, weight: 600, size: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: MyText('${applicants.length}', size: 12, weight: 600),
              )
            ],
          ),
          const SizedBox(height: 16),
          if (applicants.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                  child: Text("No candidates",
                      style: TextStyle(color: Colors.grey[400]))),
            )
          else
            ...applicants.map((app) => _buildCandidateCard(context, app)),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(BuildContext context, Applicant app) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => ViewJobApplicantDialog(applicant: app),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 5,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText('${app.firstName} ${app.lastName}', weight: 700, size: 15),
            const SizedBox(height: 4),
            MyText(app.jobPostingId,
                color: const Color(0xFF0055FF), weight: 500, size: 13),
            const SizedBox(height: 12),
            Container(height: 1, color: Colors.grey.shade100),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText(
                    app.createdAt != null
                        ? "${app.createdAt!.day}/${app.createdAt!.month}/${app.createdAt!.year}"
                        : "N/A",
                    color: Colors.grey.shade500,
                    size: 12),
                // Rating stars if needed
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingTab extends StatelessWidget {
  const OnboardingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_OnboardingEmployee> employees = [
      _OnboardingEmployee(
          name: 'Peace Chukwu',
          id: 'RS9DGB33',
          department: 'Engineering',
          location: 'Enugu',
          hireDate: '25-12-2024',
          progress: 1.0,
          status: 'In-Progress'),
      _OnboardingEmployee(
          name: 'Peace Chukwu',
          id: 'RS9DGB33',
          department: 'Marketing',
          location: 'Ebonyi',
          hireDate: '25-12-2024',
          progress: 0.67,
          status: 'In-Progress'),
      _OnboardingEmployee(
          name: 'Peace Chukwu',
          id: 'RS9DGB33',
          department: 'Operations',
          location: 'Enugu',
          hireDate: '25-12-2024',
          progress: 0.67,
          status: 'In-Progress'),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 1000),
                child: DataTable(
                  headingRowHeight: 60,
                  dataRowMinHeight: 80,
                  dataRowMaxHeight: 80,
                  columnSpacing: 24,
                  horizontalMargin: 24,
                  headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 14),
                  dividerThickness: 0.5,
                  columns: const [
                    DataColumn(label: MyText("Employee")),
                    DataColumn(label: MyText("Department")),
                    DataColumn(label: MyText("Location")),
                    DataColumn(label: MyText("Hire Date")),
                    DataColumn(label: MyText("Status")),
                    DataColumn(label: MyText("Action")),
                  ],
                  rows: employees.map((e) => _buildRow(e)).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildRow(_OnboardingEmployee e) {
    return DataRow(cells: [
      DataCell(Row(children: [
        const CircleAvatar(radius: 20, backgroundColor: Colors.grey),
        const SizedBox(width: 12),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyText(e.name, weight: 600, size: 14),
              const SizedBox(height: 4),
              MyText(e.id, weight: 600, size: 12, color: Colors.black54),
            ])
      ])),
      DataCell(MyText(e.department, weight: 600, size: 14)),
      DataCell(MyText(e.location, weight: 600, size: 14)),
      DataCell(MyText(e.hireDate, weight: 600, size: 14)),
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
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            e.progress == 1.0 ? Colors.green : Colors.amber),
                        minHeight: 6)),
                const SizedBox(height: 8),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: e.progress == 1.0
                                  ? Colors.green
                                  : Colors.amber)),
                      const SizedBox(width: 6),
                      MyText(e.status, size: 11, color: Colors.grey.shade700),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down,
                          size: 14, color: Colors.grey.shade500)
                    ]))
              ]))),
      DataCell(InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white),
              child:
                  const Icon(Icons.more_vert, size: 18, color: Colors.grey)))),
    ]);
  }
}

class _OnboardingEmployee {
  final String name, id, department, location, hireDate, status;
  final double progress;
  _OnboardingEmployee(
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
    final List<_OffboardingEmployee> employees = [
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 1000),
                child: DataTable(
                  headingRowHeight: 60,
                  dataRowMinHeight: 80,
                  dataRowMaxHeight: 80,
                  columnSpacing: 24,
                  horizontalMargin: 24,
                  headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 14),
                  dividerThickness: 0.5,
                  columns: const [
                    DataColumn(label: MyText("Employee")),
                    DataColumn(label: MyText("Department")),
                    DataColumn(label: MyText("Exit Date")),
                    DataColumn(label: MyText("Reason")),
                    DataColumn(label: MyText("Status")),
                    DataColumn(label: MyText("Action")),
                  ],
                  rows: employees.map((e) => _buildRow(e)).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildRow(_OffboardingEmployee e) {
    final bool isCompleted = e.status == 'Completed';
    final Color statusColor = isCompleted ? Colors.green : Colors.amber;
    final Color statusBg = isCompleted
        ? Colors.green.withOpacity(0.1)
        : Colors.amber.withOpacity(0.1);

    return DataRow(cells: [
      DataCell(Row(children: [
        const CircleAvatar(radius: 20, backgroundColor: Colors.grey),
        const SizedBox(width: 12),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyText(e.name, weight: 600, size: 14),
              const SizedBox(height: 4),
              MyText(e.id, weight: 600, size: 12, color: Colors.black54),
            ])
      ])),
      DataCell(MyText(e.department, weight: 600, size: 14)),
      DataCell(MyText(e.exitDate, weight: 600, size: 14)),
      DataCell(MyText(e.reason, weight: 700, size: 14)),
      DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: statusBg, borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: statusColor)),
            const SizedBox(width: 8),
            MyText(e.status, size: 12, color: Colors.black54, weight: 600),
          ]))),
      DataCell(InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white),
              child:
                  const Icon(Icons.more_vert, size: 18, color: Colors.grey)))),
    ]);
  }
}

class _OffboardingEmployee {
  final String name, id, department, exitDate, reason, status;
  _OffboardingEmployee(
      {required this.name,
      required this.id,
      required this.department,
      required this.exitDate,
      required this.reason,
      required this.status});
}
