import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/models/disciplinary_process_models.dart';
import 'package:bms_front_end/pages/hr/widget/add_disciplinary_case_dialog.dart';
import 'package:bms_front_end/pages/hr/widget/appeal_disciplinary_case_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DisciplinaryProcessPage extends StatefulWidget {
  const DisciplinaryProcessPage({super.key});

  @override
  State<DisciplinaryProcessPage> createState() => _DisciplinaryProcessPageState();
}

class _DisciplinaryProcessPageState extends State<DisciplinaryProcessPage> {
  final ScrollController _scrollController = ScrollController();
  late List<DisciplinaryCaseRecord> _cases;
  String _selectedStatus = 'All Status';

  @override
  void initState() {
    super.initState();
    _initializeSampleData();
  }

  void _initializeSampleData() {
    _cases = [
      DisciplinaryCaseRecord(
        caseId: 'DC001',
        employeeId: 'E001',
        employeeName: 'James Smith',
        employeeEmail: 'james.smith@company.com',
        department: 'Operations',
        position: 'Operations Manager',
        branch: 'Lagos',
        actionType: DisciplinaryActionType.suspension,
        violation: 'Unauthorized Absence',
        description: 'Employee was absent for 3 consecutive days without prior notice or communication',
        dateOfViolation: DateTime.now().subtract(const Duration(days: 10)),
        dateInitiated: DateTime.now().subtract(const Duration(days: 8)),
        effectiveDate: DateTime.now().subtract(const Duration(days: 5)),
        status: 'Approved',
        suspensionStartDate: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        suspensionEndDate: DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        suspensionDays: 10,
        severancePaymentDue: false,
        appealFiled: false,
        investigatedBy: 'Margaret Johnson',
        approvedBy: 'Chief HR Officer',
        approvalDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
      DisciplinaryCaseRecord(
        caseId: 'DC002',
        employeeId: 'E002',
        employeeName: 'Patricia Evans',
        employeeEmail: 'patricia.evans@company.com',
        department: 'Finance',
        position: 'Finance Officer',
        branch: 'Enugu',
        actionType: DisciplinaryActionType.writtenWarning,
        violation: 'Breach of Confidentiality',
        description: 'Disclosed confidential financial information in a public forum',
        dateOfViolation: DateTime.now().subtract(const Duration(days: 15)),
        dateInitiated: DateTime.now().subtract(const Duration(days: 12)),
        effectiveDate: DateTime.now().subtract(const Duration(days: 10)),
        status: 'Completed',
        severancePaymentDue: false,
        appealFiled: false,
        investigatedBy: 'David Brown',
        approvedBy: 'Finance Director',
        approvalDate: DateTime.now().subtract(const Duration(days: 10)),
      ),
      DisciplinaryCaseRecord(
        caseId: 'DC003',
        employeeId: 'E003',
        employeeName: 'Robert Johnson',
        employeeEmail: 'robert.johnson@company.com',
        department: 'Sales',
        position: 'Sales Manager',
        branch: 'Lagos',
        actionType: DisciplinaryActionType.termination,
        violation: 'Gross Misconduct & Insubordination',
        description: 'Repeated insubordination towards management and involvement in company asset theft',
        dateOfViolation: DateTime.now().subtract(const Duration(days: 20)),
        dateInitiated: DateTime.now().subtract(const Duration(days: 18)),
        effectiveDate: DateTime.now().subtract(const Duration(days: 5)),
        status: 'Completed',
        terminationReason: 'Gross misconduct - theft and insubordination',
        severancePaymentDue: true,
        severanceAmount: 250000.0,
        investigatedBy: 'Sarah Mitchell',
        approvedBy: 'Managing Director',
        approvalDate: DateTime.now().subtract(const Duration(days: 5)),
        appealFiled: true,
        appealReason: 'Wrongful termination - insufficient evidence',
        appealStatus: 'Pending',
      ),
      DisciplinaryCaseRecord(
        caseId: 'DC004',
        employeeId: 'E004',
        employeeName: 'Angela Davis',
        employeeEmail: 'angela.davis@company.com',
        department: 'HR',
        position: 'HR Specialist',
        branch: 'Abuja',
        actionType: DisciplinaryActionType.verbalWarning,
        violation: 'Attendance Issue',
        description: 'Repeated late arrivals to office without valid reason (3 times in a month)',
        dateOfViolation: DateTime.now().subtract(const Duration(days: 5)),
        dateInitiated: DateTime.now().subtract(const Duration(days: 3)),
        status: 'In Progress',
        severancePaymentDue: false,
        appealFiled: false,
        investigatedBy: 'Michael Chen',
      ),
      DisciplinaryCaseRecord(
        caseId: 'DC005',
        employeeId: 'E005',
        employeeName: 'Christopher Lopez',
        employeeEmail: 'christopher.lopez@company.com',
        department: 'IT',
        position: 'Systems Administrator',
        branch: 'Lagos',
        actionType: DisciplinaryActionType.finalWarning,
        violation: 'Performance & Conduct',
        description: 'Continued poor performance despite previous warnings and unsafe system practices',
        dateOfViolation: DateTime.now().subtract(const Duration(days: 8)),
        dateInitiated: DateTime.now().subtract(const Duration(days: 6)),
        effectiveDate: DateTime.now().subtract(const Duration(days: 3)),
        status: 'Approved',
        severancePaymentDue: false,
        appealFiled: false,
        investigatedBy: 'Emily Rodriguez',
        approvedBy: 'IT Director',
        approvalDate: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  void _handleCaseSubmit(DisciplinaryCaseRecord newCase) {
    setState(() {
      _cases.insert(0, newCase);
    });
  }

  void _handleAppealSubmit(DisciplinaryCaseRecord appealedCase) {
    setState(() {
      final index = _cases.indexWhere((c) => c.caseId == appealedCase.caseId);
      if (index != -1) {
        _cases[index] = appealedCase;
      }
    });
  }

  List<DisciplinaryCaseRecord> _getFilteredCases() {
    if (_selectedStatus == 'All Status') {
      return _cases;
    }
    return _cases.where((caseRecord) => caseRecord.status == _selectedStatus).toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCases = _getFilteredCases();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
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
                        'Disciplinary Process',
                        style: AppText.black_500_32,
                      ),
                      SizedBox(height: 8),
                      MyText(
                        'Track and manage disciplinary cases and actions',
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
                    child: "New Case",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AddDisciplinaryCaseDialog(
                            onSubmit: _handleCaseSubmit,
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

        // Search and Filters
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
                      hintText: 'Search by name or case ID...',
                      leading: Icon(
                        Icons.search,
                        color: AppColors.grey1.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  _buildStatusFilter(),
                ],
              ),
            ),
          ],
        ),
        kSizedBox,
        kSizedBoxSM,

        // Data Table
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
                      minWidth: MediaQuery.of(context).size.width - 100,
                    ),
                    child: DataTable(
                      dataRowMinHeight: 68,
                      dataRowMaxHeight: 68,
                      columnSpacing: 24,
                      horizontalMargin: 12,
                      columns: _createColumns(),
                      rows: _createRows(context, filteredCases),
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
          'Pending',
          'In Progress',
          'Approved',
          'Completed',
          'Appealed'
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

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: MyText('Employee'),
      ),
      const DataColumn(
        label: MyText('Department'),
      ),
      const DataColumn(
        label: MyText('Action Type'),
      ),
      const DataColumn(
        label: MyText('Violation'),
      ),
      const DataColumn(
        label: MyText('Date'),
      ),
      const DataColumn(
        label: MyText('Status'),
      ),
      const DataColumn(
        label: MyText('Action'),
      ),
    ];
  }

  List<DataRow> _createRows(
      BuildContext context, List<DisciplinaryCaseRecord> cases) {
    return cases.asMap().entries.map((entry) {
      final caseRecord = entry.value;

      return DataRow(
        cells: <DataCell>[
          DataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyText(
                  caseRecord.employeeName,
                  style: AppText.black_500_16,
                ),
                MyText(
                  caseRecord.employeeEmail,
                  style: AppText.sideMText_300_14,
                ),
              ],
            ),
          ),
          DataCell(
            MyText(caseRecord.department),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: HexColor(caseRecord.actionType.color)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: MyText(
                caseRecord.actionType.displayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: HexColor(caseRecord.actionType.color),
                ),
              ),
            ),
          ),
          DataCell(
            MyText(
              caseRecord.violation,
              style: AppText.sideMText_300_14,
            ),
          ),
          DataCell(
            MyText(
              DateFormat('dd MMM yyyy').format(caseRecord.dateOfViolation),
              style: AppText.sideMText_300_14,
            ),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    HexColor(caseRecord.getStatusColor()).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: MyText(
                caseRecord.status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: HexColor(caseRecord.getStatusColor()),
                ),
              ),
            ),
          ),
          DataCell(
            Row(
              spacing: 8,
              children: [
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: MyText('View ${caseRecord.caseId} details'),
                      ),
                    );
                  },
                  child: const Icon(Icons.visibility, size: 20, color: AppColors.blue),
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: MyText('Edit ${caseRecord.caseId}'),
                      ),
                    );
                  },
                  child: const Icon(Icons.edit, size: 20, color: AppColors.grey1),
                ),
                if (!caseRecord.appealFiled && caseRecord.status == 'Completed')
                  Tooltip(
                    message: 'Appeal Case',
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AppealDisciplinaryCaseDialog(
                              caseRecord: caseRecord,
                              onSubmit: _handleAppealSubmit,
                            );
                          },
                        );
                      },
                      child: const Icon(Icons.info_outline,
                          size: 20, color: AppColors.red),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }
}

// Helper function to convert hex color string to Color
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
