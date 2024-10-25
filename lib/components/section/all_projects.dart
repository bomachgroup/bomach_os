import 'package:flutter/material.dart';

class AllProjects extends StatelessWidget {
  const AllProjects({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        border: const TableBorder(
          ),
        // border:  const TableBorder.symmetric(
        //   // outside:  BorderSide(width: 0.5,color: AppColors.cardColor),
        //   borderRadius: BorderRadius.all(Radius.circular(20))
        // ),
           columns: _createColumns(), 
          rows: _createRows()
          ),
    );
  }

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
          label: Text(
        "Project code",
      )),
      const DataColumn(
          label: Text(
        "Project Name",
      )),
      const DataColumn(
        label: Text("Members")),
      const DataColumn(
          label: Text(
        "Client",
      )),
      const DataColumn(
          label: Text(
        "Status",
      )),
        const DataColumn(
          label: Text(
        "actions",
      )),
    ];
  }

  List<DataRow> _createRows() {
    return List.generate(9, (index) {
      return const DataRow(cells: <DataCell>[
        DataCell(
          Text("#234@BMA/ENU"),
        ),
        DataCell(
          SizedBox(
            width: 152,
            child: Text("MTN Plaza Enugu project")),
        ),
        DataCell(
          Text("MTN Plaza Enugu project"),
        ),
        DataCell(
          Text("MTN Plaza Enugu project"),
        ),
        DataCell(
          Text("MTN Plaza Enugu project"),
        ),
          DataCell(
          Text("MTN Plaza Enugu project"),
        ),
      ]);
    });
  }
}