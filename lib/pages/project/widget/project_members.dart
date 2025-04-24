import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/helper/color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProjectMembers extends StatefulWidget {
  const ProjectMembers({super.key});

  @override
  State<ProjectMembers> createState() => _ProjectMembersState();
}

class _ProjectMembersState extends State<ProjectMembers> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: Text(
          "Employee ID",
        ),
      ),
      const DataColumn(
        label: Text(
          "Employee Name",
        ),
      ),
      const DataColumn(label: Text("Department")),
      const DataColumn(
          label: Text(
        "Designation",
      )),
      const DataColumn(
        label: Text(
          "E. Type",
        ),
      ),
      const DataColumn(
        label: Text(
          "Action",
        ),
      ),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    return List.generate(10, (index) {
      return DataRow(cells: <DataCell>[
        const DataCell(
          Text("345321231"),
        ),
        DataCell(
          onTap: () {
            context.go(RouteConstants.employeeProfile);
          },
          Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                width: 36,
                height: 36,
                child: Image.asset('assets/icons/profile-icon.png'),
              ),
              const SizedBox(
                width: 8,
              ),
              const Text("Darlene Robertson"),
            ],
          ),
        ),
        const DataCell(
          Text("Design"),
        ),
        const DataCell(
          Text("UI/UX Designer"),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 0.6,
                            color: getRandomColorFromList('full-time')),
                        color: getRandomColorFromList('full-time')
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6)),
                    child: const Center(
                      child: Text("Full-time"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const DataCell(
          Icon(Icons.more_vert_outlined),
        ),
      ]);
    });
  }
}
