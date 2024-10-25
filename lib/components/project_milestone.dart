import 'package:bms_front_end/views/app_routes/app_route_constants.dart';
import 'package:bms_front_end/views/styles/colors_style.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProjectMilestone extends StatelessWidget {
  const ProjectMilestone({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderColor,width: 0.8),
          borderRadius: BorderRadius.circular(16)
        ),
      child: DataTable(
        columns: _createColumns(),
        rows: _createRows(context)
        ),
    );
  }
      List<DataColumn> _createColumns() {
    return [
    
      const DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
          label: Text(
        "S/N",
      )),
      const DataColumn(
          label: Text(
        "Milestone Title",
      )),
      const DataColumn(
        label: Text("Milestone cost")),
      const DataColumn(
          label: Text(
        "Task count",
      )),
      const DataColumn(
          label: Text(
        "Status",
      )),
        const DataColumn(
          label: Text(
        "Action",
      )),
    ];
  }
  List<DataRow> _createRows(BuildContext context) {
    return List.generate(8, (index) {
      return  DataRow(
        cells: <DataCell>[
         const DataCell(
          SizedBox(
            width: 100,
            child: Text("1")),
        ),
        DataCell(
          onTap: () {

          },
          SizedBox(
            width: 182,
            child: GestureDetector(
              onTap: () {
                  context.go(RouteConstants.employeeProfile);
              },
              child: const Text("Benji user UI"),
            )),
        ),
        const DataCell(
          SizedBox(
            width: 100,
            child: Text("2.00")),
        ),
        const DataCell(
          SizedBox(
             width: 130,
            child: Text("1")),
        ),
         DataCell(
          Container(
            width: 90,
            margin: const EdgeInsets.symmetric(vertical: 8),
          // padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(width: 0.6),
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(6)
            ),
            child: const Center(child: Text("Incomplete"))),
        ),
          const DataCell(
          SizedBox(
            width: 60,
            child: Icon(Icons.more_vert_outlined)),
        ),
      ]);
    });
}
}