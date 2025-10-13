import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

class AuditLogPage extends StatefulWidget {
  const AuditLogPage({super.key});

  @override
  State<AuditLogPage> createState() => _AuditLogPageState();
}

class _AuditLogPageState extends State<AuditLogPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    'Audit Log',
                    style: AppText.black_500_32,
                  ),
                  SizedBox(height: 8),
                  MyText(
                    'Track all changes and activities in the system',
                    size: 14,
                    weight: 400,
                    color: Color(0xFF64748B),
                  ),
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
                      hintText: 'Search by event, user, action...',
                      leading: Icon(
                        Icons.search,
                        color: AppColors.grey1.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  const Row(
                    spacing: 15,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SortBar(text: "All Events"),
                      SortBar(text: "Date Range"),
                      SortBar(text: "User"),
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
                      rows: _createRows(context),
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

  List<DataColumn> _createColumns() {
    return const [
      DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: MyText(
          "Event",
        ),
      ),
      DataColumn(
        label: MyText(
          "Description",
        ),
      ),
      DataColumn(
        label: MyText(
          "User",
        ),
      ),
      DataColumn(
        label: MyText(
          "Date & Time",
        ),
      ),
      DataColumn(
        label: MyText(
          "IP Address",
        ),
      ),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    // Mock audit log data
    final List<Map<String, dynamic>> auditLogs = [
      {
        'event': 'Company Profile Updated',
        'description': 'Changed company email address',
        'user': 'John Doe',
        'userEmail': 'john.doe@bomach.com',
        'date': 'Oct 13, 2025',
        'time': '10:30 AM',
        'ip': '192.168.1.100'
      },
      {
        'event': 'Branch Created',
        'description': 'Created new branch in Enugu',
        'user': 'Karen Smith',
        'userEmail': 'karen.smith@bomach.com',
        'date': 'Oct 13, 2025',
        'time': '09:15 AM',
        'ip': '192.168.1.105'
      },
      {
        'event': 'Employee Added',
        'description': 'Added new employee to HR department',
        'user': 'Andrea Wilson',
        'userEmail': 'andrea.wilson@bomach.com',
        'date': 'Oct 12, 2025',
        'time': '04:45 PM',
        'ip': '192.168.1.110'
      },
      {
        'event': 'Security Settings Changed',
        'description': 'Updated password policy requirements',
        'user': 'Michael Brown',
        'userEmail': 'michael.brown@bomach.com',
        'date': 'Oct 12, 2025',
        'time': '02:20 PM',
        'ip': '192.168.1.115'
      },
      {
        'event': 'Invoice Generated',
        'description': 'Generated invoice #INV-2025-001',
        'user': 'Sarah Johnson',
        'userEmail': 'sarah.johnson@bomach.com',
        'date': 'Oct 11, 2025',
        'time': '11:30 AM',
        'ip': '192.168.1.120'
      },
      {
        'event': 'Contract Signed',
        'description': 'Contract #CNT-2025-045 marked as signed',
        'user': 'David Lee',
        'userEmail': 'david.lee@bomach.com',
        'date': 'Oct 11, 2025',
        'time': '09:00 AM',
        'ip': '192.168.1.125'
      },
      {
        'event': 'User Role Modified',
        'description': 'Changed user role from Employee to Manager',
        'user': 'Admin User',
        'userEmail': 'admin@bomach.com',
        'date': 'Oct 10, 2025',
        'time': '03:15 PM',
        'ip': '192.168.1.130'
      },
      {
        'event': 'Document Uploaded',
        'description': 'Uploaded legal document to compliance section',
        'user': 'Emily Davis',
        'userEmail': 'emily.davis@bomach.com',
        'date': 'Oct 10, 2025',
        'time': '01:45 PM',
        'ip': '192.168.1.135'
      },
      {
        'event': 'Project Created',
        'description': 'Created new project: Office Renovation',
        'user': 'Robert Taylor',
        'userEmail': 'robert.taylor@bomach.com',
        'date': 'Oct 09, 2025',
        'time': '10:00 AM',
        'ip': '192.168.1.140'
      },
      {
        'event': 'Budget Approved',
        'description': 'Approved Q4 marketing budget',
        'user': 'Jennifer Martinez',
        'userEmail': 'jennifer.martinez@bomach.com',
        'date': 'Oct 09, 2025',
        'time': '08:30 AM',
        'ip': '192.168.1.145'
      },
    ];

    return auditLogs.map((log) {
      return DataRow(cells: <DataCell>[
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                log['event'],
                size: 14,
                weight: 500,
                isSelectable: false,
              ),
            ],
          ),
        ),
        DataCell(
          SizedBox(
            width: 280,
            child: MyText(
              log['description'],
              size: 14,
              weight: 400,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                width: 36,
                height: 36,
                child: Center(
                  child: MyText(
                    log['user'][0],
                    size: 16,
                    weight: 600,
                    color: AppColors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    log['user'],
                    size: 14,
                    weight: 500,
                    isSelectable: false,
                  ),
                  MyText(
                    log['userEmail'],
                    size: 12,
                    weight: 300,
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
            ],
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                log['date'],
                size: 14,
                weight: 400,
              ),
              MyText(
                log['time'],
                size: 12,
                weight: 300,
                color: const Color(0xFF64748B),
              ),
            ],
          ),
        ),
        DataCell(
          MyText(
            log['ip'],
            size: 14,
            weight: 400,
            color: const Color(0xFF64748B),
          ),
        ),
      ]);
    }).toList();
  }
}
