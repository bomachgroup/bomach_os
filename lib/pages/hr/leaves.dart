import 'package:flutter/material.dart';

import '../../components/button/custom_button.dart';
import '../../components/input/search_field.dart';
import '../../src/constants/textstyle.dart';
import '../employees_database/employee_database.dart';

class Leaves extends StatefulWidget {
  const Leaves({super.key});

  @override
  State<Leaves> createState() => _LeavesState();
}

class _LeavesState extends State<Leaves> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text(
        'Leaves',
        style: AppText.black_500_32,
      ),
      const Text(
        'Leaves',
        style: AppText.black_400_14,
      ),
      const SizedBox(
        height: 32,
      ),
      Wrap(
        runSpacing: 20,
        children: [
          SizedBox(
              width: 150,
              child: CustomButton(child: 'New Leave', onTap: () {})),
          const SizedBox(
            width: 32,
          ),
          const SizedBox(
            width: 217,
            height: 45,
            child: SearchField(),
          ),
          const SizedBox(
            width: 32,
          ),
          const SizedBox(
            width: 150,
            child: EmployessDatabaseButton(
              title: 'Sort',
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 22,
      ),
      Container(
        decoration: BoxDecoration(
            border: Border.all(width: 0.6, color: const Color(0xFFB5B5B5)),
            borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                    decoration: const BoxDecoration(),
                    columns: _createColumns(),
                    rows: _createRows(context))),
            const SizedBox(
              height: 4,
            ),
            const Divider(),
            const SizedBox(
              height: 8,
            ),
            const Row(
              children: [
                Text('Showing'),
                Text('Showing 1 to 8 out of 60 records'),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    ]);
  }
}

List<DataColumn> _createColumns() {
  return [
    DataColumn(label: Checkbox(value: false, onChanged: (value) {})),
    const DataColumn(
        // headingRowAlignment: MainAxisAlignment.start,
        label: Expanded(
      child: Text(
        overflow: TextOverflow.ellipsis,
        "Employee ID",
      ),
    )),
    const DataColumn(
        label: Expanded(
      child: Text(
        overflow: TextOverflow.ellipsis,
        "Employee Name",
      ),
    )),
    const DataColumn(label: Text("Leave date")),
    const DataColumn(
        label: Text(
      "Duration",
    )),
    const DataColumn(
        label: Expanded(
      child: Text(
        overflow: TextOverflow.ellipsis,
        "Leave Type",
      ),
    )),
    const DataColumn(
        label: Expanded(
      child: Text(
        "Paid",
        overflow: TextOverflow.ellipsis,
      ),
    )),
    const DataColumn(
        label: Expanded(
      child: Text(
        "Status",
        overflow: TextOverflow.ellipsis,
      ),
    )),
  ];
}

List<DataRow> _createRows(BuildContext context) {
  return List.generate(10, (index) {
    return DataRow(cells: <DataCell>[
      DataCell(SizedBox(
        height: 40,
        child: Checkbox(value: false, onChanged: (value) {}),
      )),
      const DataCell(
        SizedBox(width: 80, child: Text("#1234567")),
      ),
      const DataCell(
        SizedBox(
            width: 250,
            child: Row(
              children: [
                SizedBox(
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.amber,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Darlene"),
                    Text("UI/UX Designer"),
                  ],
                ),
              ],
            )),
      ),
      const DataCell(
        SizedBox(width: 200, child: Text('11/01/2024')),
      ),
      const DataCell(
        SizedBox(width: 150, child: Text("5days")),
      ),
      DataCell(
        SizedBox(
            height: 30,
            // width: 50,
            child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.green.withOpacity(0.8), width: 1.5),
                    color: Colors.green.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(
                  "Sick",
                  style: TextStyle(
                    color: Colors.green.withOpacity(0.8),
                  ),
                ))),
      ),
      const DataCell(
        SizedBox(width: 100, child: Text("Yes")),
      ),
      const DataCell(
        SizedBox(
            width: 100,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange,
                  radius: 6,
                ),
                SizedBox(
                  width: 5,
                ),
                Text("Pending"),
              ],
            )),
      ),
    ]);
  });
}
