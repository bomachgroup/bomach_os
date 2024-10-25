import 'package:bms_front_end/components/custom_dropdown.dart';
import 'package:bms_front_end/components/custom_textfield.dart';
import 'package:bms_front_end/views/styles/colors_style.dart';
import 'package:bms_front_end/views/styles/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateMilestone extends StatelessWidget {
  const CreateMilestone({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppColors.whiteColor
        ),
        width: 800,height: 690,
        child:  Column(
          children: [
             Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Create Milestones',style: AppText.black_500_28,),
                  GestureDetector(
                    onTap: () {
                       context.pop();
                    },
                    child: const Icon(Icons.cancel_outlined))
                ],
              ),
            ),
            const Divider(),
            const SizedBox(height: 28,),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                 
                  children: [
                    CustomTxField(
                      title: 'Milestone title*',
                      hintText: 'Enter Milestone title'),
                      SizedBox(width: 24,),
                      CustomTxField(
                      title: 'Milestone title*',
                      hintText: 'Enter Milestone title'),
                  ],
                ),
                const SizedBox(height: 20,),
                        Row(
                 
                  children: [
                    CustomDropdownT(items: const [], onChanged: (v){}, hintText: 'Marital status'),
                      const SizedBox(width: 24,),
                   CustomDropdownT(items: const [], onChanged: (v){}, hintText: 'Marital status'),
                  ],
                ),
                const SizedBox(height: 20,),
                const Text('Milestone Summary/Description*'),
                const SizedBox(height: 8,),
                Container(
                  height: 89,
                  padding: const EdgeInsets.all(16),
                  decoration:  BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderColor,width: 0.8)
                  ),
                  child: const TextField(
                    maxLines: 10,
                    decoration: InputDecoration(
                      hintText: 'Enter Milestone summary/description',
                      border: OutlineInputBorder(borderSide: BorderSide.none)
                    ),
                  ),
                ),
                       const SizedBox(height: 20,),
                       const Row(
                  
                  children: [
                    CustomTxField(
                      title: 'Start date(optional)*',
                      hintText: '12-10-2024'),
                      SizedBox(width: 24,),
                      CustomTxField(
                      title: 'End date(optional)*',
                      hintText: '01-12-2024'),
                  ],
                ),
              ],
            ),),
            const SizedBox(height: 48,),
             const Divider(),
             Padding(
               padding: const EdgeInsets.all(20.0),
               child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                    const Text('Cancel'),
                  const SizedBox(width: 16,),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.buttonColor,
                      borderRadius: BorderRadius.circular(14)
                    ),
                    child: const Text('Save',style: AppText.white_400_16,)),
              
                ],
               ),
             )
          ],
        ),
      ),
    );
  }
}