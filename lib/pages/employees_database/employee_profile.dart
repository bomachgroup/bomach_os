import 'package:bms_front_end/views/pages/employees_database/add_new_employee.dart';
import 'package:bms_front_end/views/styles/colors_style.dart';
import 'package:bms_front_end/views/styles/textstyle.dart';
import 'package:flutter/material.dart';

class  EmployeeProfile extends StatefulWidget {
  const  EmployeeProfile({super.key});

  @override
  State<EmployeeProfile> createState() => _EmployeeProfileState();
}

class _EmployeeProfileState extends State<EmployeeProfile> {
  int employeeDetailSelectionState=0;
    final List<Widget> _employeeDetailpages=[
     const ProfiledDetail(),
    const ReportFiles(),
    const Projects(),
     const Task()
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          const Text('Employee’s Database',style: AppText.black_600_32,),
        const Row(
          children: [
            Text('Employee’s Database',style: AppText.black_400_14,),
            Text('Darlene Robertson',style: AppText.black_400_14,),
          ],
        ),
        const SizedBox(height: 32,),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(width: 0.6,color: AppColors.borderColor)
          ),
          child: Column(
            children: [
             Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.borderColor,
                      borderRadius: BorderRadius.circular(16)
                    ),
                    width: 100,height: 100,),
                     const SizedBox(width: 16,),
                  const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Darlene Robertson',style: AppText.black_500_24,),
                        SizedBox(height: 8,),
                        Text('UI/UX Designer',style: AppText.black_400_16,),
                        SizedBox(height: 8,),
                        Text('Darlenerob1@example.com',style: AppText.black_400_14,),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.buttonColor,
                        borderRadius: BorderRadius.circular(32)
                      ),
                      child:  const Row(
                        children: [
                          Icon(Icons.edit,color: AppColors.whiteColor,),
                          SizedBox(width: 10,),
                          Text('Edit Profile',style: AppText.white_400_16,),
                        ],
                      ),
                    )
                ],
              ),
              const SizedBox(height: 30,),
              const Divider(),
              const SizedBox(height: 28,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 242,
                    decoration:  BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderColor)
                        ),
                        child: Column(children: [
                                    Container(
                                  decoration:  BoxDecoration(
                                    color:employeeDetailSelectionState==0? AppColors.buttonColor:Colors.transparent,
                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20))
                                  ),
                                  child:  ListTile(
                                    onTap: () {
                                      setState(() {
                                        employeeDetailSelectionState=0;
                                      });
                                    },
                                    title: Text('Profile',style:employeeDetailSelectionState==0? AppText.white_600_16:AppText.sideMText_300_16,),
                                    leading:  Icon(Icons.person,color:employeeDetailSelectionState==0? AppColors.whiteColor:Colors.black,),
                                  ),
                                ),
                                        Container(
                                   decoration:  BoxDecoration(
                                    color:employeeDetailSelectionState==1? AppColors.buttonColor:Colors.transparent,
                                    borderRadius: BorderRadius.circular(10)
                                  ),
                                   child: ListTile(
                                     onTap: () {
                                      setState(() {
                                        employeeDetailSelectionState=1;
                                      });
                                    },
                                    title:  Text('Reports Files',style:employeeDetailSelectionState==1? AppText.white_600_16:AppText.sideMText_300_16,),
                                      ),
                                 ),
                                 Container(
                                   decoration:  BoxDecoration(
                                    color:employeeDetailSelectionState==2? AppColors.buttonColor:Colors.transparent,
                                    borderRadius: BorderRadius.circular(10)
                                  ),
                                   child: ListTile(
                                     onTap: () {
                                      setState(() {
                                        employeeDetailSelectionState=2;
                                      });
                                    },
                                    title:  Text('Projects',style:employeeDetailSelectionState==2? AppText.white_600_16:AppText.sideMText_300_16,),
                                    ),
                                 ),
                                   Container(
                                   decoration:  BoxDecoration(
                                    color:employeeDetailSelectionState==3? AppColors.buttonColor:Colors.transparent,
                                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20))
                                  ),
                                   child: ListTile(
                                     onTap: () {
                                      setState(() {
                                        employeeDetailSelectionState=3;
                                      });
                                    },
                                    title:  Text('Tasks',style:employeeDetailSelectionState==3? AppText.white_600_16:AppText.sideMText_300_16,),
                                                                 ),
                                 ),
                        ],),
                  ),
                  const SizedBox(width: 40,),
                  Expanded(child: _employeeDetailpages[employeeDetailSelectionState])
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
class ProfiledDetail extends StatefulWidget {
  const ProfiledDetail({super.key, 
  });

  @override
  State<ProfiledDetail> createState() => _ProfiledDetailState();
}

class _ProfiledDetailState extends State<ProfiledDetail> {
  final List<Widget> _employeeProfilePages=[
    const PersonalInfoDetail(),
    const ProfessionaInfoDetail(),
    const DocumentDetail()
  ];
   int employeeProfileSelectionStepperState=0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
              Row(
                      children: [
                         EmployeeInfoStepper(title: const Text('Personal Information'), 
                         icon: const Icon(Icons.person),
                         color: employeeProfileSelectionStepperState==0?AppColors.buttonColor:Colors.transparent,
                          onTap: () {
                          setState(() {
                       employeeProfileSelectionStepperState=0;
                          });
                           },),
                         const SizedBox(width: 20,),
                         EmployeeInfoStepper(
                          width: 200,
                          color: employeeProfileSelectionStepperState==1?AppColors.buttonColor:Colors.transparent,
                          title: const Text('Professional Information'), icon: const Icon(Icons.person),
                           onTap: () {
     setState(() {
    employeeProfileSelectionStepperState=1;
                          });
     },),
                         const SizedBox(width: 20,),
                         EmployeeInfoStepper(
                           color: employeeProfileSelectionStepperState==2?AppColors.buttonColor:Colors.transparent,
                         width: 115,
                          title: const Text('Documents'), icon: const Icon(Icons.person),
                           onTap: () { 
     setState(() {
    employeeProfileSelectionStepperState=2;
                          });
    },),
                      ],
            ),
      const SizedBox(height: 20,),
      _employeeProfilePages[employeeProfileSelectionStepperState]
      ],
    );
  }
}

class ReportFiles extends StatelessWidget {
  const ReportFiles({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            FileItems(),
            SizedBox(width: 20,),
            FileItems(),
          ],
        ),
         SizedBox(height: 20,),
           Row(
          children: [
            FileItems(),
            SizedBox(width: 20,),
            FileItems(),
          ],
        ),
         SizedBox(height: 20,),
           Row(
          children: [
            FileItems(),
            SizedBox(width: 20,),
            FileItems(),
          ],
        ),
      ],
    );
  }
}

class FileItems extends StatelessWidget {
  const FileItems({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(width: 0.8,color: AppColors.borderColor)
      ),
      child: const Row(
        children: [
          Text('Aso Villa PJ report 12/8/2024.png',style: AppText.black_300_16,),
          SizedBox(width: 21,),
          Icon(Icons.remove_red_eye_sharp),
           SizedBox(width: 16,),
           Icon(Icons.download_for_offline_outlined)
        ],
      ));
  }
}
class Projects extends StatelessWidget {
  const Projects({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
class Task extends StatelessWidget {
  const Task({super.key});

  @override
  Widget build(BuildContext context) {
    return            Container(
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



class DocumentDetail extends StatelessWidget{
  const DocumentDetail({super.key});

  @override
  Widget build(BuildContext context) {
   return  const SingleChildScrollView(
    child: Column(
      children: [
        Row(
          children: [
            DocumentHolder(documentDetail: 'Appointment Letter.pdf',),
            SizedBox(width: 20,),
             DocumentHolder(documentDetail: 'Salary Slip_June.pdf',),
          ],
        ),
        SizedBox(height: 20,),
          Row(
          children: [
            DocumentHolder(documentDetail: 'Salary Slip_May.pdf',),
             SizedBox(width: 20,),
            DocumentHolder(documentDetail: 'Salary Slip_April.pdf',),
          ],
        ),
           SizedBox(height: 20,),
          Row(
          children: [
          DocumentHolder(documentDetail: 'Reliving Letter.pdf',),
           SizedBox(width: 20,),
             DocumentHolder(documentDetail: 'Experience Letter.pdf',),
          ],
        ),
      ],
    ),
   );
  }
  
}

class DocumentHolder extends StatelessWidget {
  final String documentDetail;
  const DocumentHolder({
    super.key, required this.documentDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
     padding: const EdgeInsets.symmetric(horizontal: 16),
     decoration: BoxDecoration(
       // color: AppColors.buttonColor,
       border: Border.all(width: 0.6,color: AppColors.borderColor),
       borderRadius: BorderRadius.circular(14)
     ),
     width: 360,
    height: 56,
     child:  Row(
       children: [
         Text(documentDetail),
         const Spacer(),
         const Icon(Icons.remove_red_eye_sharp),
         const SizedBox(width: 8,),
         const Icon(Icons.download_for_offline)
       ],
     ),
                );
  }
}

class ProfessionaInfoDetail extends StatelessWidget {
  const ProfessionaInfoDetail({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                 Row(
                children: [
                  ProfileFiedsHolder(title: 'Employee ID', detail: '879912390',),
                  SizedBox(width: 24,),
                   ProfileFiedsHolder(title: 'User Name', detail: 'Robertson_UI',),
                ],
              ),
                SizedBox(height: 20,),
                     Row(
                children: [
                  ProfileFiedsHolder(title: 'Employment Type', detail: 'Full-time',),
                  SizedBox(width: 24,),
                   ProfileFiedsHolder(title: 'Email', detail: 'Darlenerob1@example.com',),
                ],
              ),
                SizedBox(height: 20,),
                     Row(

                children: [
                  ProfileFiedsHolder(title: 'Branch', detail: 'Enugu',),
                  SizedBox(width: 24,),
                   ProfileFiedsHolder(title: 'Department', detail: 'Design',),
                ],
              ),
                SizedBox(height: 20,),
                     Row(
                children: [
                  ProfileFiedsHolder(title: 'Designation', detail: 'UI/UX Design',),
                  SizedBox(width: 24,),
                   ProfileFiedsHolder(title: 'Start Date', detail: '1 July,2023',),
                ],
              ),
                SizedBox(height: 20,),
               Row(
                 children: [
                   ProfileFiedsHolder(title: 'Office Location', detail: 'Plot 34, Azuka street, GRA',),
                 ],
               ),
        ],
      ),
    );
  }
}

class PersonalInfoDetail extends StatelessWidget {
  const PersonalInfoDetail({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          Row(
       
            children: [
              ProfileFiedsHolder(title: 'First Name', detail: 'Darlene',),
              SizedBox(width: 24,),
               ProfileFiedsHolder(title: 'Last Name', detail: 'Robertson',),
            ],
          ),  SizedBox(height: 20,),
              Row(
            
            children: [
              ProfileFiedsHolder(title: 'Surname Name', detail: 'Darlene',),
              SizedBox(width: 24,),
               ProfileFiedsHolder(title: 'Gender', detail: 'Male',),
            ],
          ),
            SizedBox(height: 20,),
              Row(
            children: [
              ProfileFiedsHolder(title: 'Date of Birth', detail: 'July, 24, 1999',),
              SizedBox(width: 24,),
               ProfileFiedsHolder(title: 'Marital status', detail: 'Single',),
            ],
          ),
            SizedBox(height: 20,),
              Row(
            children: [
              ProfileFiedsHolder(title: 'Address', detail: 'Plot 34, Azuka street, GRA',),
              SizedBox(width: 24,),
               ProfileFiedsHolder(title: 'City', detail: 'Enugu',),
            ],
          ),
          SizedBox(height: 20,),
              Row(
            children: [
              ProfileFiedsHolder(title: 'State', detail: 'Enugu',),
              SizedBox(width: 24,),
               ProfileFiedsHolder(title: 'Nationality', detail: 'Nigeria',),
            ],
          ),
    
        ],
      ),
    );
  }
}

class ProfileFiedsHolder extends StatelessWidget {
  final String title;
  final String detail;
  const ProfileFiedsHolder({
    super.key, required this.title, required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return  Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,style: AppText.sideMText_300_14,),
          const SizedBox(height: 3,),
          Text(detail,style: AppText.black_400_16,),
          const Divider()
        ],
      ),
    );
  }
}
