import 'package:bms_front_end/views/pages/employees_database/component/employee_documentation.dart';
import 'package:bms_front_end/views/pages/employees_database/component/personalInfo.dart';
import 'package:bms_front_end/views/pages/employees_database/component/professionalInfo.dart';
import 'package:bms_front_end/views/styles/colors_style.dart';
import 'package:bms_front_end/views/styles/textstyle.dart';
import 'package:flutter/material.dart';


class AddEmployesScreen extends StatefulWidget {
  const AddEmployesScreen({
    super.key,
  });

  @override
  State<AddEmployesScreen> createState() => _AddEmployesScreenState();
}

class _AddEmployesScreenState extends State<AddEmployesScreen> {
   final List<Widget> _pages=[
    const PersonalInformation(),
    const ProfessionalInformation(),
    const EmployeeDocumentation(),
  ];
  int selectionStepperState=0;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                   const Text(
              'Employee’s Database',
              style: AppText.black_600_32,
            ),
            const Row(
              children: [
                Text('Employee’s Database',style: AppText.black_400_14,),
                Icon(Icons.arrow_forward_ios_rounded,size: 12,),
                Text('Add New Employee',style: AppText.black_400_14,),
              ],
            ),
            const SizedBox(
              height: 32,
            ),
            Container(
              padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border:
                    Border.all(width: 0.6, color: AppColors.borderColor)),
                    child:   Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // EmployeeInfoStepper(title: const Text('Personal Information'), icon: const Icon(Icons.person), onTap: () {  },),
                        Row(
                          children: [
                            EmployeeInfoStepper(icon: const Icon(Icons.person), title: const Text('Personal Information'),
                            color: selectionStepperState==0?AppColors.buttonColor:Colors.transparent,
                             onTap: () { 
                              setState(() {
                    selectionStepperState=0;
                  });
                              },),
                            const SizedBox(width: 20,),
                             EmployeeInfoStepper(
                              color: selectionStepperState==1?AppColors.buttonColor:Colors.transparent,
                                width: 200,
                              icon: const Icon(Icons.person), title: const Text('Professional Information'),
                               onTap: () {
                                setState(() {
                    selectionStepperState=1;
                  });
                                 },),
                             const SizedBox(width: 20,),
                              EmployeeInfoStepper(
                                color: selectionStepperState==2?AppColors.buttonColor:Colors.transparent,
                                width: 115,
                                icon: const Icon(Icons.person), title: const Text('Documents'),
                                 onTap: () { 
                                  setState(() {
                    selectionStepperState=2;
                  });
                                  },),
                          ],
                        ),
                         const SizedBox(height: 30,),

                          _pages[selectionStepperState],
                          const SizedBox(height: 30,),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Cancel'),
                              SizedBox(width: 20,),
                               Text('Next'),
                            ],
                          )
                      ],
                    ),
            )
      ],
    );
  }
}

// 
class EmployeeInfoStepper extends StatelessWidget {
  final Text title;
  final Color? color;
  final Widget icon;
  final double? width;
  final VoidCallback onTap;
  const EmployeeInfoStepper({
    super.key, required this.title,
     required this.icon, this.width, 
     required this.onTap, this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
         children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
             children: [
               icon,
               title
             ],
           ),
           Container(
             decoration:  BoxDecoration(
              borderRadius: BorderRadius.circular(12),
               color:color?? AppColors.buttonColor
             ),
             width:width??180,
             height: 3,
           )
         ],
       ),
    );
  }
}

