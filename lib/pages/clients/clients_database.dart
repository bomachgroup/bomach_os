import 'package:bms_front_end/components/custom_button.dart';
import 'package:bms_front_end/components/custom_search_field.dart';
import 'package:bms_front_end/views/pages/employees_database/employee_database.dart';
import 'package:bms_front_end/views/styles/colors_style.dart';
import 'package:bms_front_end/views/styles/textstyle.dart';
import 'package:flutter/material.dart';

class ClientsDatabasePage extends StatelessWidget {
  const ClientsDatabasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Clients',style: AppText.black_500_32,),
        const Text('Clients',style: AppText.black_400_14,),
        const SizedBox(height: 32,),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [CustomButton(child: 'New Client ', onTap: (){}),
          const SizedBox(width: 32,),
          const SizedBox(width: 217,height: 48,
            child: CustomSearchField(
              
            ),
          ),
          const SizedBox(width: 32,),
          const EmployessDatabaseButton(title: 'Sort',)
          ]
          ,
        ),
         const SizedBox(height: 22,),
         Container(
           decoration: BoxDecoration(
              border: Border.all(width: 0.6,color: AppColors.borderColor),
              borderRadius: BorderRadius.circular(16)
            ),
           child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      
                      decoration: const BoxDecoration(

                      ),
                      columns: _createColumns(), rows: _createRows(context))),
                      const SizedBox(height: 4,),
                      const Divider(),
                       const SizedBox(height: 8,),
                      const Row(children: [
                        Text('Showing'),
                        Text('Showing 1 to 8 out of 60 records'),
                      ],),
                       const SizedBox(height: 8,),
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
          label: Text(
        "Client ID",
      )),
      const DataColumn(
          label: Text(
        "Client Name",
      )),
      const DataColumn(
        label: Text("Email")),
      const DataColumn(
          label: Text(
        "Phone number",
      )),
      const DataColumn(
          label: Text(overflow: TextOverflow.ellipsis,
        "PJ number",
      )),
      const DataColumn(
          label: Text(
        "Start date",
      )),
        const DataColumn(
          label: Text(
        "Status",
      )),
       const DataColumn(
          label: Icon(Icons.more_vert_rounded)),
    ];
  }
    List<DataRow> _createRows(BuildContext context) {
    return List.generate(10, (index) {
      return  const DataRow(
        cells: <DataCell>[
         DataCell(
          SizedBox(
            width: 80,
            child: Text("#1234567")),
        ),
         DataCell(
          SizedBox(
            width: 250,
            child: Row(
              children: [
                SizedBox(
                  width: 36,height: 36,
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
         DataCell(
          SizedBox(
            width: 200,
            child: Text('Jennygroup45@gmail.com')
          ),
        ),
        DataCell(
          SizedBox(
             width: 150,
            child: Text("+234 808 986 2487")),
        ),
         DataCell(
          SizedBox(
             width: 50,
            child: Text("002")),
        ),
           DataCell(
          SizedBox(
             width: 100,
            child: Text("27/09/2024")),
        ),
         DataCell(
          SizedBox(
             width: 70,
            child: Text("Active")),
        ),
         DataCell(
          SizedBox(
             width: 100,
            child: Text("27/09/2024")),
        ),
       
      ]);
    });
}
}