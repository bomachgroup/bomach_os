import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/nav/three_dot_pop.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/models/attendance_models.dart';
import 'package:bms_front_end/pages/hr/widget/clock_in_dialog.dart';
import 'package:bms_front_end/pages/hr/widget/view_attendance_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => AttendancePageState();
}

class AttendancePageState extends State<AttendancePage> {
  final ScrollController _scrollController = ScrollController();
  late List<AttendanceRecord> _attendanceRecords;

  @override
  void initState() {
    super.initState();
    _initializeSampleData();
  }

  void _initializeSampleData() {
    _attendanceRecords = [
      AttendanceRecord(
        employeeId: 'K997KD',
        employeeName: 'John Michael',
        employeeEmail: 'johnmichael5@gmail.com',
        date: DateTime.now(),
        checkInTime: DateTime.now().subtract(const Duration(hours: 2)),
        checkOutTime: DateTime.now(),
        status: 'Present',
      ),
      AttendanceRecord(
        employeeId: 'E002',
        employeeName: 'Sarah Johnson',
        employeeEmail: 'sarah.johnson@gmail.com',
        date: DateTime.now(),
        checkInTime: DateTime.now().subtract(const Duration(hours: 3)),
        checkOutTime: null,
        status: 'Present',
      ),
    ];
  }

  void _handleClockIn(AttendanceRecord record) {
    setState(() {
      // Check if record already exists, if so update it
      final existingIndex = _attendanceRecords.indexWhere(
        (r) =>
            r.employeeId == record.employeeId &&
            r.date.day == record.date.day,
      );

      if (existingIndex >= 0) {
        _attendanceRecords[existingIndex] = record;
      } else {
        _attendanceRecords.insert(0, record);
      }
    });
  }

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
                        'Attendance',
                        style: AppText.black_500_32,
                      ),
                    ],
                  ),
                  MyElevatedButton(
                    icon: const Icon(
                      Icons.access_time,
                      color: AppColors.white,
                    ),
                    child: "Clock In",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return ClockInDialog(
                            onClockIn: _handleClockIn,
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
                      hintText: 'Search by name',
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
                      SortBar(text: "All States"),
                      SortBar(text: "Status"),
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
    return [
      const DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: MyText(
          "Employee ID",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Name & Email",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Check-in",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Check-out",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Date",
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

  List<DataRow> _createRows(BuildContext context) {
    return _attendanceRecords.map((record) {
      return DataRow(cells: <DataCell>[
        DataCell(
          MyText(
            record.employeeId,
            size: 16,
            weight: 400,
            isSelectable: false,
          ),
        ),
        DataCell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return const ViewAttendanceDialog();
              },
            );
          },
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyText(
                record.employeeName,
                style: const TextStyle(fontWeight: FontWeight.bold),
                isSelectable: false,
              ),
              MyText(
                record.employeeEmail,
                isSelectable: false,
              ),
            ],
          ),
        ),
        DataCell(
          MyText(
            record.checkInTime != null
                ? DateFormat('HH:mm:ss').format(record.checkInTime!)
                : '---',
          ),
        ),
        DataCell(
          MyText(
            record.checkOutTime != null
                ? DateFormat('HH:mm:ss').format(record.checkOutTime!)
                : '---',
          ),
        ),
        DataCell(
          MyText(
            DateFormat('dd-MM-yyyy').format(record.date),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor(record.status),
              borderRadius: BorderRadius.circular(6),
            ),
            child: MyText(
              record.status,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const DataCell(
          ThreeDotPop(),
        ),
      ]);
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AppColors.green;
      case 'absent':
        return AppColors.red;
      case 'late':
        return const Color(0xFFFFA500);
      case 'early leave':
        return const Color(0xFFFF6B6B);
      case 'on leave':
        return const Color(0xFF9B59B6);
      case 'half day':
        return const Color(0xFF3498DB);
      case 'remote':
        return const Color(0xFF27AE60);
      default:
        return AppColors.grey1;
    }
  }
}
