import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/models/work_report_models.dart';
import 'package:bms_front_end/pages/hr/widget/daily_work_report_dialog.dart';
import 'package:bms_front_end/pages/hr/widget/work_report_review_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkReportPage extends StatefulWidget {
  const WorkReportPage({super.key});

  @override
  State<WorkReportPage> createState() => _WorkReportPageState();
}

class _WorkReportPageState extends State<WorkReportPage> {
  final ScrollController _scrollController = ScrollController();
  late List<DailyWorkReport> _workReports;
  String _selectedStatus = 'All Status';
  String _selectedEmployee = 'All Employees';

  @override
  void initState() {
    super.initState();
    _initializeSampleReports();
  }

  void _initializeSampleReports() {
    _workReports = [
      DailyWorkReport(
        id: 'WR001',
        employeeId: 'K997KD',
        employeeName: 'John Michael',
        employeeEmail: 'johnmichael5@gmail.com',
        reportDate: DateTime.now(),
        activities: [
          WorkActivity(
            id: 'WA001',
            taskTitle: 'Dashboard UI Implementation',
            description: 'Designed and implemented the main dashboard layout',
            taskCategory: 'Development',
            hoursSpent: 5.0,
            completed: true,
          ),
          WorkActivity(
            id: 'WA002',
            taskTitle: 'Code Review',
            description: 'Reviewed pull requests from the team',
            taskCategory: 'Code Review',
            hoursSpent: 2.0,
            completed: true,
          ),
        ],
        hoursWorked: 7.0,
        mood: 'Happy',
        challenges:
            'Had some difficulty with responsive design on mobile screens',
        achievements: 'Completed dashboard implementation ahead of schedule',
        nextDayPlan: 'Fix responsive issues and start on profile page',
        submitted: true,
        submittedAt: DateTime.now(),
        approvedBy: 'Sarah Johnson',
        approvedAt: DateTime.now(),
        status: 'Approved',
      ),
      DailyWorkReport(
        id: 'WR002',
        employeeId: 'E002',
        employeeName: 'Sarah Johnson',
        employeeEmail: 'sarah.johnson@gmail.com',
        reportDate: DateTime.now().subtract(const Duration(days: 1)),
        activities: [
          WorkActivity(
            id: 'WA003',
            taskTitle: 'API Integration',
            description: 'Integrated payment gateway API',
            taskCategory: 'Development',
            hoursSpent: 4.0,
            completed: true,
          ),
          WorkActivity(
            id: 'WA004',
            taskTitle: 'Testing Integration',
            description: 'Tested API endpoints for edge cases',
            taskCategory: 'Testing',
            hoursSpent: 3.0,
            completed: true,
          ),
          WorkActivity(
            id: 'WA005',
            taskTitle: 'Documentation',
            description: 'Documented API integration steps',
            taskCategory: 'Documentation',
            hoursSpent: 1.5,
            completed: true,
          ),
        ],
        hoursWorked: 8.5,
        mood: 'Neutral',
        challenges: 'API had rate limiting issues during testing',
        achievements: 'Successfully integrated payment gateway',
        nextDayPlan: 'Deploy payment integration to staging',
        submitted: true,
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        approvedBy: null,
        approvedAt: null,
        status: 'Submitted',
      ),
      DailyWorkReport(
        id: 'WR003',
        employeeId: 'E003',
        employeeName: 'Nicholas Chidera',
        employeeEmail: 'nicholas.chidera@gmail.com',
        reportDate: DateTime.now().subtract(const Duration(days: 2)),
        activities: [
          WorkActivity(
            id: 'WA006',
            taskTitle: 'Database Optimization',
            description: 'Optimized slow database queries',
            taskCategory: 'Development',
            hoursSpent: 6.0,
            completed: true,
          ),
        ],
        hoursWorked: 6.0,
        mood: 'Frustrated',
        challenges:
            'Database query performance was harder to optimize than expected',
        achievements: 'Reduced query time by 40%',
        nextDayPlan: 'Continue optimization on remaining queries',
        submitted: true,
        submittedAt: DateTime.now().subtract(const Duration(days: 2)),
        approvedBy: null,
        approvedAt: null,
        status: 'Submitted',
      ),
      DailyWorkReport(
        id: 'WR004',
        employeeId: 'K997KD',
        employeeName: 'John Michael',
        employeeEmail: 'johnmichael5@gmail.com',
        reportDate: DateTime.now().subtract(const Duration(days: 3)),
        activities: [],
        hoursWorked: 0.0,
        mood: 'Neutral',
        challenges: '',
        achievements: '',
        nextDayPlan: '',
        submitted: false,
        status: 'Draft',
      ),
    ];
  }

  void _handleWorkReportSubmit(DailyWorkReport report) {
    setState(() {
      _workReports.insert(0, report);
    });
  }

  void _handleWorkReportReview(int index, DailyWorkReport updatedReport) {
    setState(() {
      _workReports[index] = updatedReport;
    });
  }

  void _openReviewDialog(
      BuildContext context, int index, DailyWorkReport report) {
    showDialog(
      context: context,
      builder: (context) {
        return WorkReportReviewDialog(
          report: report,
          reviewerName: 'Manager Account', // Should come from logged-in user
          onReviewComplete: (updatedReport) {
            _handleWorkReportReview(index, updatedReport);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<DailyWorkReport> _getFilteredReports() {
    List<DailyWorkReport> filtered = _workReports;

    if (_selectedStatus != 'All Status') {
      filtered =
          filtered.where((report) => report.status == _selectedStatus).toList();
    }

    if (_selectedEmployee != 'All Employees') {
      filtered = filtered
          .where((report) => report.employeeName == _selectedEmployee)
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredReports = _getFilteredReports();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 10,
                runSpacing: 10,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        'Daily Work Reports',
                        style: AppText.black_500_32,
                      ),
                      SizedBox(height: 8),
                      MyText(
                        'Track and manage employee work activities',
                        size: 14,
                        weight: 400,
                        color: Color(0xFF64748B),
                      ),
                    ],
                  ),
                  MyElevatedButton(
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.white,
                    ),
                    child: "Submit Report",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return DailyWorkReportDialog(
                            onSubmit: _handleWorkReportSubmit,
                          );
                        },
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
        kSizedBox,
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 15,
                runSpacing: 15,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 250,
                    child: MyTextFormField(
                      hintText: 'Search by employee name...',
                      leading: Icon(
                        Icons.search,
                        color: AppColors.grey1.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  Row(
                    spacing: 15,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStatusFilter(),
                      _buildEmployeeFilter(),
                    ],
                  )
                ],
              ),
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
                      rows: _createRows(context, filteredReports),
                      showBottomBorder: true,
                    ),
                  ),
                ),
              ),
              const MyPaginator(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD5D5D5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _selectedStatus,
        underline: const SizedBox(),
        items: <String>[
          'All Status',
          'Draft',
          'Submitted',
          'Approved',
          'Rejected'
        ].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: MyText(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedStatus = newValue ?? 'All Status';
          });
        },
      ),
    );
  }

  Widget _buildEmployeeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD5D5D5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _selectedEmployee,
        underline: const SizedBox(),
        items: <String>[
          'All Employees',
          'John Michael',
          'Sarah Johnson',
          'Nicholas Chidera'
        ].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: MyText(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedEmployee = newValue ?? 'All Employees';
          });
        },
      ),
    );
  }

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: MyText(
          "Employee",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Date",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Hours Worked",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Mood",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Activities",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Status",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Action",
        ),
      ),
    ];
  }

  List<DataRow> _createRows(
      BuildContext context, List<DailyWorkReport> reports) {
    return reports.asMap().entries.map((entry) {
      final index = entry.key;
      final report = entry.value;

      return DataRow(cells: <DataCell>[
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyText(
                report.employeeName,
                style: const TextStyle(fontWeight: FontWeight.bold),
                isSelectable: false,
              ),
              MyText(
                report.employeeEmail,
                size: 12,
                color: const Color(0xFF64748B),
                isSelectable: false,
              ),
            ],
          ),
        ),
        DataCell(
          MyText(
            DateFormat('dd MMM yyyy').format(report.reportDate),
          ),
        ),
        DataCell(
          MyText(
            '${report.hoursWorked.toStringAsFixed(1)} hrs',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataCell(
          MyText(
            _getMoodEmoji(report.mood),
            size: 18,
          ),
        ),
        DataCell(
          MyText(
            '${report.activities.length} activities',
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor(report.status),
              borderRadius: BorderRadius.circular(6),
            ),
            child: MyText(
              report.status,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        DataCell(
          _buildActionMenu(context, index, report),
        ),
      ]);
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.green;
      case 'submitted':
        return AppColors.blue;
      case 'draft':
        return const Color(0xFF64748B);
      case 'rejected':
        return AppColors.red;
      default:
        return AppColors.grey1;
    }
  }

  String _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'neutral':
        return '😐';
      case 'tired':
        return '😴';
      case 'frustrated':
        return '😞';
      default:
        return '😐';
    }
  }

  Widget _buildActionMenu(
      BuildContext context, int index, DailyWorkReport report) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (String result) {
        if (result == 'view') {
          _openReviewDialog(context, index, report);
        } else if (result == 'edit') {
          showDialog(
            context: context,
            builder: (context) {
              return DailyWorkReportDialog(
                existingReport: report,
                onSubmit: (updatedReport) {
                  _handleWorkReportReview(index, updatedReport);
                },
              );
            },
          );
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.fact_check_outlined, size: 18),
              SizedBox(width: 8),
              MyText('Review Report', isSelectable: false),
            ],
          ),
        ),
        if (report.status == 'Draft' || report.status == 'Rework Required')
          const PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 18),
                SizedBox(width: 8),
                Text('Edit Report'),
              ],
            ),
          ),
      ],
    );
  }
}
