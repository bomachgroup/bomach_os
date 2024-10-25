import 'package:bms_front_end/components/custom_dropdown.dart';
import 'package:bms_front_end/components/custom_textfield.dart';
import 'package:flutter/material.dart';

class ProfessionalInformation extends StatelessWidget{
  const ProfessionalInformation({super.key});

  @override
  Widget build(BuildContext context) {
return  Column(
  children: [
    const Row(
           children: [
             CustomTxField(hintText: 'Empolyee ID',),
                          SizedBox(width: 23,),
              CustomTxField(hintText: 'User Name',),
           ],
         ),
              const SizedBox(height: 24,),
         Row(
           children: [
             CustomDropdownT(items: const ['kkk','lll'], hintText: 'Select Employment type', onChanged: (String? value) {  },),
                          const SizedBox(width: 23,),
                      CustomDropdownT(items: const ['kkk','lll'], hintText: 'select worksite (optional)', onChanged: (String? value) {  },),
           ],
         ),
           const SizedBox(height: 24,),
             Row(
           children: [
             CustomDropdownT(items: const ['kkk','lll'], hintText: 'Select Designation', onChanged: (String? value) {  },),
                          const SizedBox(width: 23,),
                      CustomDropdownT(items: const ['kkk','lll'], hintText: 'Select Start Date', onChanged: (String? value) {  },),
           ],
         ),
         const SizedBox(height: 24,),
          Row(
            children: [
              CustomDropdownT(items: const ['kkk','lll'], hintText: 'Select Office Location', onChanged: (String? value) {  },),
            ],
          ),
             const SizedBox(height: 24,),
           Row(
             children: [
               CustomDropdownT(items: const ['kkk','lll'], hintText: 'City', onChanged: (String? value) {  },),
                const SizedBox(width: 23,),
                     CustomDropdownT(items: const ['kkk','lll'], hintText: 'State', onChanged: (String? value) {  },),
            const SizedBox(width: 23,),
               CustomDropdownT(items: const ['kkk','lll'], hintText: 'Nationality', onChanged: (String? value) {  },),
             ],
           ),
  ],
);
  }
  
}