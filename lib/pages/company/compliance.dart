import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/nav/three_dot_pop.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/company/widget/add_compliance_dialog.dart';
import 'package:bms_front_end/pages/company/widget/view_compliance_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/color.dart';
import 'package:flutter/material.dart';

class CompliancePage extends StatefulWidget {
  const CompliancePage({super.key});

  @override
  State<CompliancePage> createState() => _CompliancePageState();
}

class _CompliancePageState extends State<CompliancePage> {
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
                        'Compliance Records',
                        style: AppText.black_500_32,
                      ),
                      SizedBox(height: 8),
                      MyText(
                        'Manage regulatory compliance and documentation',
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
                    child: "New Compliance Record",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const AddComplianceDialog();
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
                      hintText: 'Search by type, user, status...',
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
                      SortBar(text: "All Types"),
                      SortBar(text: "Status"),
                      SortBar(text: "Date Range"),
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
          "Compliance ID",
        ),
      ),
      DataColumn(
        label: MyText(
          "Type",
        ),
      ),
      DataColumn(
        label: MyText(
          "Submitted By",
        ),
      ),
      DataColumn(
        label: MyText(
          "Date Submitted",
        ),
      ),
      DataColumn(
        label: MyText(
          "Expiry Date",
        ),
      ),
      DataColumn(
        label: MyText(
          "Status",
        ),
      ),
      DataColumn(
        label: MyText(
          "Action",
        ),
      ),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    // Mock compliance data
    final List<Map<String, dynamic>> complianceRecords = [
      {
        'id': '#CMP-2025-001',
        'type': 'Tax Compliance',
        'user': 'John Doe',
        'userEmail': 'john.doe@bomach.com',
        'dateSubmitted': 'Oct 10, 2025',
        'expiryDate': 'Dec 31, 2025',
        'status': 'approved',
      },
      {
        'id': '#CMP-2025-002',
        'type': 'Environmental Permit',
        'user': 'Sarah Johnson',
        'userEmail': 'sarah.johnson@bomach.com',
        'dateSubmitted': 'Oct 08, 2025',
        'expiryDate': 'Oct 08, 2026',
        'status': 'pending',
      },
      {
        'id': '#CMP-2025-003',
        'type': 'Safety Certificate',
        'user': 'Michael Brown',
        'userEmail': 'michael.brown@bomach.com',
        'dateSubmitted': 'Oct 05, 2025',
        'expiryDate': 'Oct 05, 2026',
        'status': 'approved',
      },
      {
        'id': '#CMP-2025-004',
        'type': 'Business License',
        'user': 'Emily Davis',
        'userEmail': 'emily.davis@bomach.com',
        'dateSubmitted': 'Oct 01, 2025',
        'expiryDate': 'Sep 30, 2026',
        'status': 'approved',
      },
      {
        'id': '#CMP-2025-005',
        'type': 'Insurance Policy',
        'user': 'David Lee',
        'userEmail': 'david.lee@bomach.com',
        'dateSubmitted': 'Sep 28, 2025',
        'expiryDate': 'Sep 28, 2026',
        'status': 'pending',
      },
      {
        'id': '#CMP-2025-006',
        'type': 'Data Protection',
        'user': 'Jennifer Martinez',
        'userEmail': 'jennifer.martinez@bomach.com',
        'dateSubmitted': 'Sep 25, 2025',
        'expiryDate': 'Dec 31, 2025',
        'status': 'expired',
      },
      {
        'id': '#CMP-2025-007',
        'type': 'Health & Safety',
        'user': 'Robert Taylor',
        'userEmail': 'robert.taylor@bomach.com',
        'dateSubmitted': 'Sep 20, 2025',
        'expiryDate': 'Sep 20, 2026',
        'status': 'approved',
      },
      {
        'id': '#CMP-2025-008',
        'type': 'Labor Compliance',
        'user': 'Karen Smith',
        'userEmail': 'karen.smith@bomach.com',
        'dateSubmitted': 'Sep 15, 2025',
        'expiryDate': 'Dec 31, 2025',
        'status': 'pending',
      },
      {
        'id': '#CMP-2025-009',
        'type': 'Building Permit',
        'user': 'Andrea Wilson',
        'userEmail': 'andrea.wilson@bomach.com',
        'dateSubmitted': 'Sep 10, 2025',
        'expiryDate': 'Mar 10, 2026',
        'status': 'approved',
      },
      {
        'id': '#CMP-2025-010',
        'type': 'Financial Audit',
        'user': 'Thomas Anderson',
        'userEmail': 'thomas.anderson@bomach.com',
        'dateSubmitted': 'Sep 05, 2025',
        'expiryDate': 'Dec 31, 2025',
        'status': 'expired',
      },
    ];

    return complianceRecords.map((record) {
      return DataRow(cells: <DataCell>[
        DataCell(
          MyText(
            record['id'],
            size: 14,
            weight: 500,
            isSelectable: false,
          ),
        ),
        DataCell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return ViewComplianceDialog(record: record);
              },
            );
          },
          MyText(
            record['type'],
            size: 14,
            weight: 500,
            color: AppColors.blue,
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
                    record['user'][0],
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
                    record['user'],
                    size: 14,
                    weight: 400,
                    isSelectable: false,
                  ),
                  MyText(
                    record['userEmail'],
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
          MyText(
            record['dateSubmitted'],
            size: 14,
            weight: 400,
          ),
        ),
        DataCell(
          MyText(
            record['expiryDate'],
            size: 14,
            weight: 400,
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.6,
                        color: getRandomColorFromList(record['status']),
                      ),
                      color: getRandomColorFromList(record['status'])
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: MyText(
                      record['status'] == 'approved'
                          ? 'Approved'
                          : record['status'] == 'pending'
                              ? 'Pending'
                              : 'Expired',
                      size: 12,
                      weight: 500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const DataCell(
          ThreeDotPop(),
        ),
      ]);
    }).toList();
  }
}
