import 'package:bms_front_end/components/custom_button.dart';
import 'package:bms_front_end/components/custom_search_field.dart';
import 'package:bms_front_end/views/app_routes/app_route_constants.dart';
import 'package:bms_front_end/views/styles/colors_style.dart';
import 'package:bms_front_end/views/styles/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProjectsPage extends StatelessWidget {
   ProjectsPage({super.key});
  final DataTableSource _myData =MyData();

  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Projects',style: AppText.black_500_32,),
         const Text('Projects',style: AppText.black_400_14,),
              const SizedBox(height: 12,),
              Row(
                children: [
                  CustomButton(child: 'Add New Project', onTap: (){}),
                  const SizedBox(width: 20,),
                  const SizedBox(
                    width: 131,
                    child: CustomSearchField())
                ],
              ),
              const SizedBox(height: 20,),
           Container(
            padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(width: 0.6,color: const Color(0XFFD5D5D5)),
              borderRadius: BorderRadius.circular(16)
            ),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    dataRowHeight: 60,
                    // decoration: BoxDecoration(),
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
          )
      ],
    );
  }
    List<DataColumn> _createColumns() {
    return [
        DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
          label:Container(
            width: 20,height: 20,
            decoration:  BoxDecoration(
              border: Border.all(color: AppColors.borderColor,width: 0.6),
              borderRadius: BorderRadius.circular(8)
            ),
          )),
      const DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
          label: Text(
        "PJ code",
      )),
      const DataColumn(
          label: Text(
        "Project Name",
      )),
      const DataColumn(
        label: Text("Members")),
      const DataColumn(
          label: Text(
        "Start date",
      )),
      const DataColumn(
          label: Text(
        "Deadline",
      )),
        const DataColumn(
          label: Text(
        "Clients",
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
    return List.generate(19, (index) {
      return  DataRow(cells: <DataCell>[
          DataCell(
        Container(
            width: 20,height: 20,
            decoration:  BoxDecoration(
              border: Border.all(color: AppColors.borderColor,width: 0.9),
              borderRadius: BorderRadius.circular(4)
            ),
          )
        ),
        const DataCell(
          SizedBox(
             width: 120,
            child: Text("#234@BMA/ENU")),
        ),
         DataCell(
          SizedBox(
            width: 152,
            child: GestureDetector(
              onTap: () {
                 context.go(RouteConstants.eachprojects);
              },
              child: const Text("Benji Express mobile app project"))),
        ),
        DataCell(
          SizedBox(
            width: 80,
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.buttonColor,
                    shape: BoxShape.circle
                  ),
                  width: 36,height: 36,
                ),
                Positioned(
                  // right: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryColor,
                      shape: BoxShape.circle
                    ),
                    width: 36,height: 36,
                  ),
                ),
              ],
            ),
          ),
        ),
        const DataCell(
          SizedBox(
            width: 100,
            child: Text("27/09/2024")),
        ),
        const DataCell(
          SizedBox(
            width: 100,
            child: Text("27/09/2024")),
        ),
            DataCell(
             SizedBox(
            width: 250,
            child: Row(
              children: [
                Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondaryColor
                ),
                  width: 36,height: 36,
                ),
                const SizedBox(width: 8,),
                const Column(
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 102,height: 14,
                decoration: BoxDecoration(
                  color: AppColors.buttonColor,
                  borderRadius: BorderRadius.circular(12)
                ),
              ),
              const SizedBox(height: 4,),
                  Container(
                width: 102,height: 28,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(12)
                ),
              ),
            ],
          )
        ),
           DataCell(
          SizedBox(
            width: 50,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4,vertical: 4),
              width: 20,height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderColor,)
              ),
              child: const Center(child: Icon(Icons.more_vert_sharp)))),
        ),
      ]);
    });
  }
}

class MyData extends DataTableSource{
  @override
  DataRow? getRow(int index) {
    return const DataRow(cells: [
      DataCell(Text('#455653')),
      DataCell(Text('Benji Express mobile app project')),
      DataCell(Text('data')),
       DataCell(Text('data')),
        DataCell(Text('data')),
         DataCell(Text('data')),
         DataCell(Text('data')),
    ]);
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => 1;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
}