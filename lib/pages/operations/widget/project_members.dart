import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/operations/controllers/project_controller.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/helper/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProjectMembers extends StatefulWidget {
  final int projectId;
  const ProjectMembers({super.key, required this.projectId});

  @override
  State<ProjectMembers> createState() => _ProjectMembersState();
}

class _ProjectMembersState extends State<ProjectMembers> {
  final ScrollController _scrollController = ScrollController();
  late final ProjectController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ProjectController>()
        ? Get.find<ProjectController>()
        : Get.put(ProjectController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchProjectEmployees(context, widget.projectId);
    });
  }

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
      child: Obx(() {
        if (controller.isLoadingEmployees.value) {
          return const Center(
              child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator()));
        }

        if (controller.projectEmployees.isEmpty) {
          return const Center(
              child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text("No members assigned to this project.")));
        }

        return Column(
          children: [
            Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: bodySpace(context)),
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
          ],
        );
      }),
    );
  }

  List<DataColumn> _createColumns() {
    return const [
      DataColumn(
          headingRowAlignment: MainAxisAlignment.start,
          label: MyText("Employee ID")),
      DataColumn(label: MyText("Employee Name")),
      DataColumn(label: MyText("Department")),
      DataColumn(label: MyText("Designation")),
      DataColumn(label: MyText("E. Type")),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    final employees = controller.projectEmployees;
    return employees.map((emp) {
      return DataRow(cells: <DataCell>[
        DataCell(MyText(emp.employeeId)),
        DataCell(
          Row(
            children: [
              Container(
                decoration: const BoxDecoration(shape: BoxShape.circle),
                width: 36,
                height: 36,
                child: Image.asset('assets/icons/profile-icon.png'),
              ),
              const SizedBox(width: 8),
              MyText(emp.fullName, isSelectable: false),
            ],
          ),
        ),
        DataCell(MyText(emp.departmentName)),
        DataCell(MyText(emp.position)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
                border: Border.all(
                    width: 0.6,
                    color: getRandomColorFromList(emp.employmentType)),
                color: getRandomColorFromList(emp.employmentType)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6)),
            child:
                MyText(emp.employmentType.isEmpty ? '-' : emp.employmentType),
          ),
        ),
      ]);
    }).toList();
  }
}
