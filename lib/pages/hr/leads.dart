import 'package:bms_front_end/components/input/search_field.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

import '../../components/button/custom_button.dart';
import '../../components/input/custom_search_field.dart';
import '../employees_database/employee_database.dart';

class LeadsPage extends StatefulWidget {
  const LeadsPage({super.key});

  @override
  State<LeadsPage> createState() => _LeadsPageState();
}

class _LeadsPageState extends State<LeadsPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Leads',
          style: AppText.black_500_32,
        ),
        const Text(
          'Leads',
          style: AppText.black_400_14,
        ),
        const SizedBox(
          height: 32,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CustomButton(child: 'New Leads', onTap: () {}),
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
            const EmployessDatabaseButton(
              title: 'Sort',
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
      ],
    );
  }
}

List<DataColumn> _createColumns() {
  return [
    DataColumn(label: Checkbox(value: false, onChanged: (value) {})),
    const DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: Text(
          "Leads ID",
        )),
    const DataColumn(
        label: Text(
      "Contact Name",
    )),
    const DataColumn(label: Text("Email")),
    const DataColumn(
        label: Text(
      "Phone number",
    )),
    const DataColumn(
        label: Expanded(
      child: Text(
        overflow: TextOverflow.ellipsis,
        "Lead Owner",
      ),
    )),
    const DataColumn(
        label: Expanded(
      child: Text(
        "Date of Creation",
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
        SizedBox(width: 80, child: Text("001")),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Jane Okoro"),
                    Text("Jenny group of company"),
                  ],
                ),
              ],
            )),
      ),
      const DataCell(
        SizedBox(width: 200, child: Text('Jennygroup45@gmail.com')),
      ),
      const DataCell(
        SizedBox(width: 150, child: Text("+234 808 986 2487")),
      ),
      const DataCell(
        SizedBox(width: 50, child: Text("--")),
      ),
      const DataCell(
        SizedBox(width: 100, child: Text("27/09/2024")),
      ),
    ]);
  });
}
