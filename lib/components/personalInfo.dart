import 'package:bms_front_end/components/custom_dropdown.dart';
import 'package:bms_front_end/components/custom_textfield.dart';
import 'package:bms_front_end/views/styles/colors_style.dart';
import 'package:flutter/material.dart';

class PersonalInformation extends StatelessWidget{
  const PersonalInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return   SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration:  BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(18)
            ),
            width: 143,height: 119,
          ),
          const SizedBox(height: 20,),
          const Row(
            children: [
              CustomTxField(hintText: 'Enter First name',),
              SizedBox(width: 23,),
              CustomTxField(hintText: 'Enter Last name',),
            ],
          ),
           const SizedBox(height: 24,),
            const Row(
            children: [
              CustomTxField(hintText: 'Enter Surname name',),
              SizedBox(width: 23,),
              CustomTxField(hintText: 'Enter your Email address',),
            ],
          ),
           const SizedBox(height: 24,),
           Row(
            children: [
              CustomDropdownT(items: const [],
               onChanged: (String? value) {  },
                hintText: 'Gender',),
                const SizedBox(width: 23,),
                 CustomDropdownT(items: const [],
               onChanged: (String? value) {  },
                hintText: 'Marital status',),
            ],
           ), const SizedBox(height: 24,),
           Row(
             children: [
               CustomDropdownT(items: const [], onChanged: (v){}, hintText: 'Address'),
             ],
           ), const SizedBox(height: 24,),
            Row(
             children: [
               CustomDropdownT(items: const [], onChanged: (v){}, hintText: 'City'),
               const SizedBox(width: 23,),
               CustomDropdownT(items: const [], onChanged: (v){}, hintText: 'State'),
               const SizedBox(width: 23,),
               CustomDropdownT(items: const [], onChanged: (v){}, hintText: 'Nationality'),
             ],
           )
          //  const SizedBox(height: 24,),
          //  CustomDropdownT(items: const [],
          //      onChanged: (String? value) {  },
          //       hintText: 'Gender',),
        ],
      ),
    );
  }

}
