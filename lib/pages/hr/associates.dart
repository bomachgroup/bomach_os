import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/nav/three_dot_pop.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/widget/add_associate_dialog.dart';
import 'package:bms_front_end/pages/hr/widget/view_associate_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/color.dart';
import 'package:flutter/material.dart';

class AssociatesPage extends StatefulWidget {
  const AssociatesPage({super.key});

  @override
  State<AssociatesPage> createState() => _AssociatesPageState();
}

class _AssociatesPageState extends State<AssociatesPage> {
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
                        'Associates',
                        style: AppText.black_500_32,
                      ),
                      SizedBox(height: 8),
                      MyText(
                        'Manage external associates and contractors',
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
                    child: "New Associate",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const AddAssociateDialog();
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
                      hintText: 'Search by name, role, company...',
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
                      SortBar(text: "All Roles"),
                      SortBar(text: "Status"),
                      SortBar(text: "Company"),
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
          "Associate ID",
        ),
      ),
      DataColumn(
        label: MyText(
          "Name & Email",
        ),
      ),
      DataColumn(
        label: MyText(
          "Role",
        ),
      ),
      DataColumn(
        label: MyText(
          "Company",
        ),
      ),
      DataColumn(
        label: MyText(
          "Phone",
        ),
      ),
      DataColumn(
        label: MyText(
          "Contract Period",
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
    // Mock associates data
    final List<Map<String, dynamic>> associates = [
      {
        'id': 'ASC-001',
        'name': 'John Mitchell',
        'email': 'john.mitchell@techcorp.com',
        'role': 'IT Consultant',
        'company': 'TechCorp Solutions',
        'phone': '+234 801 234 5678',
        'startDate': 'Jan 2025',
        'endDate': 'Dec 2025',
        'status': 'active',
      },
      {
        'id': 'ASC-002',
        'name': 'Sarah Williams',
        'email': 'sarah.w@designpro.com',
        'role': 'UX Designer',
        'company': 'DesignPro Agency',
        'phone': '+234 802 345 6789',
        'startDate': 'Feb 2025',
        'endDate': 'Jun 2025',
        'status': 'active',
      },
      {
        'id': 'ASC-003',
        'name': 'Michael Chen',
        'email': 'mchen@legaladvisors.com',
        'role': 'Legal Advisor',
        'company': 'Legal Advisors Ltd',
        'phone': '+234 803 456 7890',
        'startDate': 'Mar 2025',
        'endDate': 'Mar 2026',
        'status': 'active',
      },
      {
        'id': 'ASC-004',
        'name': 'Emily Rodriguez',
        'email': 'emily.r@marketingco.com',
        'role': 'Marketing Specialist',
        'company': 'MarketingCo',
        'phone': '+234 804 567 8901',
        'startDate': 'Jan 2025',
        'endDate': 'Jul 2025',
        'status': 'active',
      },
      {
        'id': 'ASC-005',
        'name': 'David Thompson',
        'email': 'dthompson@financeplus.com',
        'role': 'Financial Analyst',
        'company': 'FinancePlus',
        'phone': '+234 805 678 9012',
        'startDate': 'Sep 2024',
        'endDate': 'Dec 2024',
        'status': 'expired',
      },
      {
        'id': 'ASC-006',
        'name': 'Jennifer Lee',
        'email': 'jlee@hrexperts.com',
        'role': 'HR Consultant',
        'company': 'HR Experts Inc',
        'phone': '+234 806 789 0123',
        'startDate': 'Apr 2025',
        'endDate': 'Oct 2025',
        'status': 'active',
      },
      {
        'id': 'ASC-007',
        'name': 'Robert Kumar',
        'email': 'rkumar@techsolutions.com',
        'role': 'Software Developer',
        'company': 'Tech Solutions',
        'phone': '+234 807 890 1234',
        'startDate': 'May 2025',
        'endDate': 'Nov 2025',
        'status': 'active',
      },
      {
        'id': 'ASC-008',
        'name': 'Amanda Brooks',
        'email': 'abrooks@projectmgmt.com',
        'role': 'Project Manager',
        'company': 'Project Mgmt Co',
        'phone': '+234 808 901 2345',
        'startDate': 'Jun 2025',
        'endDate': 'Dec 2025',
        'status': 'pending',
      },
      {
        'id': 'ASC-009',
        'name': 'Thomas Anderson',
        'email': 'tanderson@security.com',
        'role': 'Security Consultant',
        'company': 'SecureIT',
        'phone': '+234 809 012 3456',
        'startDate': 'Feb 2025',
        'endDate': 'Aug 2025',
        'status': 'active',
      },
      {
        'id': 'ASC-010',
        'name': 'Lisa Martinez',
        'email': 'lmartinez@training.com',
        'role': 'Training Specialist',
        'company': 'TrainingPro',
        'phone': '+234 810 123 4567',
        'startDate': 'Oct 2024',
        'endDate': 'Jan 2025',
        'status': 'expired',
      },
    ];

    return associates.map((associate) {
      return DataRow(cells: <DataCell>[
        DataCell(
          MyText(
            associate['id'],
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
                return ViewAssociateDialog(associate: associate);
              },
            );
          },
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
                    associate['name'][0],
                    size: 16,
                    weight: 600,
                    color: AppColors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyText(
                    associate['name'],
                    size: 14,
                    weight: 500,
                    isSelectable: false,
                  ),
                  MyText(
                    associate['email'],
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
            associate['role'],
            size: 14,
            weight: 400,
          ),
        ),
        DataCell(
          MyText(
            associate['company'],
            size: 14,
            weight: 400,
          ),
        ),
        DataCell(
          MyText(
            associate['phone'],
            size: 14,
            weight: 400,
          ),
        ),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyText(
                associate['startDate'],
                size: 12,
                weight: 400,
              ),
              MyText(
                'to ${associate['endDate']}',
                size: 12,
                weight: 300,
                color: const Color(0xFF64748B),
              ),
            ],
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
                        color: getRandomColorFromList(associate['status']),
                      ),
                      color: getRandomColorFromList(associate['status'])
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: MyText(
                      associate['status'] == 'active'
                          ? 'Active'
                          : associate['status'] == 'pending'
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
