import 'package:bms_front_end/components/custom_button.dart';
import 'package:bms_front_end/components/custom_search_field.dart';
import 'package:bms_front_end/views/pages/projects/components/create_milestone.dart';
import 'package:bms_front_end/views/pages/projects/components/projectOverview.dart';
import 'package:bms_front_end/views/pages/projects/components/project_associate.dart';
import 'package:bms_front_end/views/pages/projects/components/project_files.dart';
import 'package:bms_front_end/views/pages/projects/components/project_meetings.dart';
import 'package:bms_front_end/views/pages/projects/components/project_members.dart';
import 'package:bms_front_end/views/pages/projects/components/project_milestone.dart';
import 'package:bms_front_end/views/pages/projects/components/project_task.dart';
import 'package:bms_front_end/views/pages/projects/components/project_work_sites.dart';
import 'package:bms_front_end/views/styles/colors_style.dart';
import 'package:bms_front_end/views/styles/textstyle.dart';
import 'package:flutter/material.dart';

class EachProjects extends StatefulWidget {
  const EachProjects({super.key});

  @override
  State<EachProjects> createState() => _EachProjectsState();
}

class _EachProjectsState extends State<EachProjects> {
  final List<Widget> _pages=[
    const ProjectOverview(),
    const ProjectMembers(),
    const ProjectWorkSite(),
    const ProjectFiles(),
    const ProjectMilestone(),
    const ProjectTask(),
    const ProjectAssociate(),
    const ProjectMeetings()
  ];
  int projectMemberState=0;
  @override
  Widget build(BuildContext context) {
    return  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Projects',style: AppText.black_500_32,),
              const Spacer(),
              const SizedBox(
                width: 108,
                child: CustomSearchField()),
                const SizedBox(width: 20,),
            projectMemberState==0?CustomButton(child: 'Add New Employee', onTap: (){})
            : projectMemberState==1?CustomButton(child: 'Add Project membe', onTap: (){})
            :projectMemberState==4?CustomButton(child: 'Create milestone', onTap: (){
              showDialog(context: context, builder: (context){
                return  const AlertDialog(
                  contentPadding: EdgeInsets.all(0),
                  content: CreateMilestone(),
                );
              });
            }):const SizedBox()
            ],
          ),
          const Row(
            children: [
              Text('Projects',style: AppText.black_400_14,),
              SizedBox(width: 8,),
              Icon(Icons.arrow_forward_ios_outlined,size: 12,),
              SizedBox(width: 8,),
                Text('Benji express project ',style: AppText.black_400_14,),
            ],
          ),
          const SizedBox(height: 21,),
           SizedBox(
            height: 50,
             child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                InButton(title: 'Overview', onTap: (){
                  setState(() {
                    projectMemberState=0;
                  });
                }, isSelected: projectMemberState==0,),
                const SizedBox(width: 10,),
             InButton(title: 'Members', onTap: (){
               setState(() {
                    projectMemberState=1;
                  });
             }, isSelected: projectMemberState==1,),
                const SizedBox(width: 10,),
               InButton(title: 'Work site', onTap: (){
                 setState(() {
                    projectMemberState=2;
                  });
               }, isSelected: projectMemberState==2,),
                const SizedBox(width: 10,),
                InButton(title: 'Files', onTap: (){
                   setState(() {
                    projectMemberState=3;
                  });
                }, isSelected: projectMemberState==3,),
                const SizedBox(width: 10,),
                InButton(title: 'Milestone', onTap: (){
                   setState(() {
                    projectMemberState=4;
                  });
                }, isSelected: projectMemberState==4,),
                const SizedBox(width: 10,),
                InButton(title: 'Tasks', onTap: (){
                   setState(() {
                    projectMemberState=5;
                  });
                }, isSelected: projectMemberState==5,),
                const SizedBox(width: 10,),
                InButton(title: 'Associates', onTap: (){
                   setState(() {
                    projectMemberState=6;
                  });
                }, isSelected: projectMemberState==6,),
                 const SizedBox(width: 10,),
                InButton(title: 'Meetings', onTap: (){
                   setState(() {
                    projectMemberState=7;
                  });
                }, isSelected: projectMemberState==7,),
              ],
                  ),
           ),
          const SizedBox(height: 23,),
          Container(
            child: _pages[projectMemberState]
          )
          
        ],
      );
  }
}

// class CreateMilestone extends StatelessWidget {
//   const CreateMilestone({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(24),
//           color: AppColors.whiteColor
//         ),
//         width: 800,height: 690,
//         child:  Column(
//           children: [
//             const Padding(
//               padding: EdgeInsets.all(20.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text('Create Milestones',style: AppText.black_500_28,),
//                   Icon(Icons.cancel_outlined)
//                 ],
//               ),
//             ),
//             const Divider(),
//             const SizedBox(height: 28,),
//             Padding(padding: const EdgeInsets.symmetric(horizontal: 48),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Row(
                 
//                   children: [
//                     CustomTxField(
//                       title: 'Milestone title*',
//                       hintText: 'Enter Milestone title'),
//                       SizedBox(width: 24,),
//                       CustomTxField(
//                       title: 'Milestone title*',
//                       hintText: 'Enter Milestone title'),
//                   ],
//                 ),
//                 const SizedBox(height: 20,),
//                         Row(
                 
//                   children: [
//                     CustomDropdownT(items: const [], onChanged: (v){}, hintText: 'Marital status'),
//                       const SizedBox(width: 24,),
//                    CustomDropdownT(items: const [], onChanged: (v){}, hintText: 'Marital status'),
//                   ],
//                 ),
//                 const SizedBox(height: 20,),
//                 const Text('Milestone Summary/Description*'),
//                 const SizedBox(height: 8,),
//                 Container(
//                   height: 89,
//                   padding: const EdgeInsets.all(16),
//                   decoration:  BoxDecoration(
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: AppColors.borderColor,width: 0.8)
//                   ),
//                   child: const TextField(
//                     maxLines: 10,
//                     decoration: InputDecoration(
//                       hintText: 'Enter Milestone summary/description',
//                       border: OutlineInputBorder(borderSide: BorderSide.none)
//                     ),
//                   ),
//                 ),
//                        const SizedBox(height: 20,),
//                        const Row(
                  
//                   children: [
//                     CustomTxField(
//                       title: 'Start date(optional)*',
//                       hintText: '12-10-2024'),
//                       SizedBox(width: 24,),
//                       CustomTxField(
//                       title: 'End date(optional)*',
//                       hintText: '01-12-2024'),
//                   ],
//                 ),
//               ],
//             ),),
//             const SizedBox(height: 48,),
//              const Divider(),
//              Padding(
//                padding: const EdgeInsets.all(20.0),
//                child: Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                     const Text('Cancel'),
//                   const SizedBox(width: 16,),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 16),
//                     decoration: BoxDecoration(
//                       color: AppColors.buttonColor,
//                       borderRadius: BorderRadius.circular(14)
//                     ),
//                     child: const Text('Save',style: AppText.white_400_16,)),
              
//                 ],
//                ),
//              )
//           ],
//         ),
//       ),
//     );
//   }
// }



class InButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  const InButton({
    super.key, required this.title, required this.onTap,required this.isSelected, 
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32,vertical: 10),
        decoration: BoxDecoration(
          border:isSelected?Border.all(color: AppColors.buttonColor) :Border.all(color: AppColors.borderColor,width: 0.6),
          color:isSelected? AppColors.buttonColor:Colors.transparent,
          borderRadius: BorderRadius.circular(16)
        ),
        child: Text(title,style:isSelected? AppText.white_300_16:AppText.black_300_16,),
      ),
    );
  }
}