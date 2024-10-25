import 'package:bms_front_end/components/custom_button.dart';
import 'package:bms_front_end/components/custom_dropdown.dart';
import 'package:bms_front_end/components/custom_search_field.dart';
import 'package:bms_front_end/components/custom_textfield.dart';
import 'package:bms_front_end/views/styles/colors_style.dart';
import 'package:bms_front_end/views/styles/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return   Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tasks',style: AppText.black_500_32,),
         const SizedBox(height: 8,),
        const Text('Tasks',style: AppText.black_400_14,),
        const SizedBox(height: 17,),
        Row(
          children: [
            const SizedBox(
              width: 217,height: 48,
              child: CustomSearchField()),
              const SizedBox(width: 16,),
          CustomButton(
            icon: const Icon(Icons.add,color: AppColors.whiteColor,),
            child: 'Add Task', onTap: (){
              showDialog(context: context, builder: (context){
                return    const AlertDialog(
                  contentPadding: EdgeInsets.all(0),
                  content: addTask(),
                );
              });
            })
          ],
        ),
        const SizedBox(height: 12,),
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
    
      const DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
          label: Text(
        "Task code",
      )),
      const DataColumn(
          label: Text(
        "Task Name",
      )),
      const DataColumn(
        label: Text("Assign to")),
      const DataColumn(
          label: Text(
        "Start date",
      )),
      const DataColumn(
          label: Text(
        "Due date",
      )),
        const DataColumn(
          label: Text(
        "Status",
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
            child: Text("#1234567")),
        ),
        const DataCell(
          SizedBox(
            width: 250,
            child: Text("Benji Express user login Interface")),
        ),
         DataCell(
          SizedBox(
            width: 70,
            child: Container(
              width: 32,height: 32,
              decoration: const BoxDecoration(
                color: AppColors.secondaryColor,
                shape: BoxShape.circle
              ),
            ),
          ),
        ),
        const DataCell(
          SizedBox(
             width: 100,
            child: Text("12/10/2023")),
        ),
         const DataCell(
          SizedBox(
             width: 100,
            child: Text("02/02/2025")),
        ),
           const DataCell(
          SizedBox(
             width: 100,
            child: Text("Undone")),
        ),
       
      ]);
    });
}
}

class addTask extends StatelessWidget {
  const addTask({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 700,
      height: 700,
      child: Column(
        children: [
           Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Add Task',style: AppText.black_500_24,),
                GestureDetector(
                  onTap: () {
                   context.pop();
                  },
                  child: const Icon(Icons.cancel_outlined))
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 32,),
          Expanded(
            child: ListView(
              children: [
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 51.0),
                     child: Column(
                       children: [
                         Row(
                                children: [
                                  const CustomTxField(hintText: '--',title: 'Task Name',),
                                  const SizedBox(width: 24,),
                                  CustomDropdownT(
                                    title: 'Task Categories*',
                                    items: const [], onChanged: (String? value){}, hintText: '--')
                                ],
                              ),
                              const SizedBox(height: 20,),
                                                  Row(
                          children: [
                      
                            CustomDropdownT(
                              title: 'Project*',
                              items: const [], onChanged: (String? value){}, hintText: '--'),
                            const SizedBox(width: 24,),
                            const CustomTxField(hintText: '--',title: 'Short Code',),
                          ],
                        ),
                          const SizedBox(height: 20,),
                      
                          Row(
                          children: [
                      
                            CustomDropdownT(
                              title: 'Assign to*',
                              items: const [], onChanged: (String? value){}, hintText: '--'),
                            const SizedBox(width: 24,),
                            const CustomTxField(hintText: '--',title: 'Start date*',),
                          ],
                        ),const SizedBox(height: 20,),
                                   Row(
                          children: [
                            const CustomTxField(
                              hintText: '--',title: 'Deadline(optional)*',),
                            const SizedBox(width: 24,),
                            CustomDropdownT(
                              title: 'Taks status*',
                              items: const [], onChanged: (String? value){}, hintText: '--')
                          ],
                        ),const SizedBox(height: 20,),
                                 const Row(
                          children: [
                            CustomTxField(
                              hintText: '--',title: 'Task summary/Note*',),
                                
                          ],
                        ),
                    
                       ],
                     ),
                   ),
                         const SizedBox(height: 51,),
                          const Divider(),
                           Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 51.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            const Text('Other Details',style: AppText.black_600_32,),
                               const SizedBox(height: 20,),
                  const Row(
                    children: [
                      Text('Repeat'),
                       Text('Time estimate '),
                    ],
                  ),
                  const SizedBox(height: 20,),
                                     Row(
                        children: [
                          CustomDropdownT(items: const [], onChanged: (v){}, hintText: 'Repeat every*'),
                          const SizedBox(width: 24,),
                             CustomDropdownT(items: const [], onChanged: (v){}, hintText: 'Time*'),
                        ],
                       ),
                            const SizedBox(height: 20,),
                        const Text('Upload File (optional)*'),
                        const SizedBox(height: 8,),
                       Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.buttonColor),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          children: [
                            Text('Drag & Drop or choose file to upload'),
                            Text('Supported formats :doc, pdf')
                          ],
                        ),
                       )
                              ],
                            ),
                          )
              ],
            ),
          ),
            const SizedBox(height: 51,),
          const Divider(),
        
           Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Cancel'),const SizedBox(width: 16,), 
                Container(
                  padding:const EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.buttonColor
                  ),
                  child: const Text('Save',style: AppText.black_400_14,)),
              ],
            ),
          ),
    
        ],
      ),
    );
  }
}