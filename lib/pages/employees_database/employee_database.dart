import 'package:bms_front_end/views/app_routes/app_route_constants.dart';
import 'package:bms_front_end/views/styles/colors_style.dart';
import 'package:bms_front_end/views/styles/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmployeeDatabase extends StatelessWidget {
  final DataTableSource _myData=MyData();
   EmployeeDatabase({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return  Padding(
       padding: const EdgeInsets.symmetric(horizontal: 32.0,vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Employee’s Database',style: AppText.black_600_32,),
                   Text('Employee’s Database',style: AppText.black_600_14,),
                ],
              ),
          
              GestureDetector(
                onTap: () {
                  // locator<NavigationService>().navigateTo(AddEmployee);
                  context.go(RouteConstants.addEmployees);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 16),
                  decoration:  BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.buttonColor
                  ),
                  child:  Row(
                    children: [
                      Container(
                        decoration:  BoxDecoration(
                          border: Border.all(color: AppColors.whiteColor),
                          shape: BoxShape.circle),
                        child: const Icon(Icons.add,color: AppColors.whiteColor,size: 20,)),
                        const SizedBox(width: 10,),
                      const Text('Add New Employee',style: AppText.white_400_16,),
                    ],
                  )),
              ),
            ],
          ),
          const SizedBox(height: 18,),
          Row(
            children: [
               SizedBox(
                width: 276,height: 48,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by name, role, department',
                    fillColor: AppColors.whiteColor,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(16)
                    )
                  ),
                ),
              ),
              const SizedBox(width: 24,),
              const EmployessDatabaseButton(title: 'Enugu',),
            const SizedBox(width: 24,),
              const EmployessDatabaseButton(title: 'Aso villa Estate',),
             const SizedBox(width: 24,),
              const EmployessDatabaseButton(title: 'Department',),
            ],
          ),
          const SizedBox(height: 18,),
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
                  child: DataTable(columns: _createColumns(), rows: _createRows(context)))
        
              ],
            ),
          )
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
        "Status",
      )),
      const DataColumn(
          label: Text(
        "Action",
      )),
    ];
  }
    List<DataRow> _createRows(BuildContext context) {
    return List.generate(10, (index) {
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
           DataCell(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
             width: 90,
            // padding: const EdgeInsets.symmetric(horizontal: 20),
             decoration: BoxDecoration(
              border: Border.all(width: 0.6),
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(6)
            ),
            child: const Center(child: Text("Retired"))),
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

class EmployessDatabaseButton extends StatelessWidget {
  final String title;
  const EmployessDatabaseButton({
    super.key, required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(left: 13,top: 10,bottom: 10,right: 13),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(14)
        ),
      child: Row(
        children: [
          Text(title),
          const SizedBox(width: 6,),
          const Icon(Icons.arrow_drop_down)
        ],
      ),
    );
  }
}

class MyData extends DataTableSource{
  late BuildContext context;
  final List<Map<String, dynamic>> _data= List.generate(10, (index){
    return {
      'EmployeeID':'345321231',
      "Employee Name":'Darlene Robertson',
      'Department':'Design',
      'Designation':"UI/UX Designer",
      'E. Type':'Full-time',
      'Status':'Retired'
    };
  });
  @override
  DataRow? getRow(int index) {
  return DataRow(cells: [
    DataCell(SizedBox(
      width: 90,
       child: Text(_data[index]['EmployeeID'].toString()))),
    DataCell(SizedBox(
      width: 120,
      child: GestureDetector(
        onTap: () {
          // context.go(RouteConstants.employeeProfile);
          // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const EmployeeDatabasePage()));
        },
        child: Text(_data[index]['Employee Name'].toString())))),
    DataCell(SizedBox(
         width: 90,
      child: Text(_data[index]['Department'].toString()))),
    DataCell(
      // placeholder: true,
      SizedBox(
         width: 90,
        child: Text(_data[index]['Designation'].toString()))),
    DataCell(SizedBox(
       width: 90,
      child: Text(_data[index]['E. Type'].toString()))),
    DataCell(SizedBox(
       width: 90,
      child: Text(_data[index]['Status'].toString()))),
    const DataCell(SizedBox(
         width: 90,
      child: Icon(Icons.more_vert_outlined))),
  ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;

  
}