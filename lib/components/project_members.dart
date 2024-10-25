import 'package:bms_front_end/views/app_routes/app_route_constants.dart';
import 'package:bms_front_end/views/styles/colors_style.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProjectMembers extends StatelessWidget {
  const ProjectMembers({super.key});

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
        "Employee ID",
      )),
      const DataColumn(
          label: Text(
        "Employee Name",
      )),
      const DataColumn(
        label: Text("Department")),
      const DataColumn(
          label: Text(
        "Designation",
      )),
      const DataColumn(
          label: Text(
        "E. Type",
      )),
        const DataColumn(
          label: Text(
        "Action",
      )),
    ];
  }
  List<DataRow> _createRows(BuildContext context) {
    return List.generate(3, (index) {
      return  DataRow(
        cells: <DataCell>[
         const DataCell(
          SizedBox(
            width: 100,
            child: Text("345321231")),
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
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondaryColor,
                    ),
                    
                    width: 36,height: 36,
                  ),
                  const SizedBox(width: 8,),
                  const Text("Darlene Robertson"),
                ],
              ),
            )),
        ),
        const DataCell(
          SizedBox(
            width: 100,
            child: Text("Design")),
        ),
        const DataCell(
          SizedBox(
             width: 130,
            child: Text("UI/UX Designer")),
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
            child: const Center(child: Text("Full-time"))),
        ),
        //    DataCell(
        //   Container(
        //     margin: const EdgeInsets.symmetric(vertical: 8),
        //      width: 90,
        //     // padding: const EdgeInsets.symmetric(horizontal: 20),
        //      decoration: BoxDecoration(
        //       border: Border.all(width: 0.6),
        //       color: AppColors.whiteColor,
        //       borderRadius: BorderRadius.circular(6)
        //     ),
        //     child: const Center(child: Text("Retired"))),
        // ),
          const DataCell(
          SizedBox(
            width: 60,
            child: Icon(Icons.more_vert_outlined)),
        ),
      ]);
    });
}
}