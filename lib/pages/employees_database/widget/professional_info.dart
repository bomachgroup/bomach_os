import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';

class ProfessionalInformation extends StatefulWidget {
  const ProfessionalInformation({super.key});

  @override
  State<ProfessionalInformation> createState() =>
      _ProfessionalInformationState();
}

class _ProfessionalInformationState extends State<ProfessionalInformation> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        kSizedBox,
        const Row(
          children: [
            Expanded(
              child: MyTextFormField(
                fillColor: AppColors.greyBg,
                height: 80,
                hintText: 'Empolyee ID',
              ),
            ),
            kSizedBoxWidth,
            Expanded(
              child: MyTextFormField(
                fillColor: AppColors.greyBg,
                height: 80,
                hintText: 'User Name',
              ),
            ),
          ],
        ),
        kSizedBox,
        Row(
          children: [
            Expanded(
              child: MyDropdown(
                fillColor: AppColors.greyBg,
                height: 80,
                items: const [],
                onChanged: (val) {},
                hintText: 'Select Employment type',
              ),
            ),
            kSizedBoxWidth,
            Expanded(
              child: MyDropdown(
                fillColor: AppColors.greyBg,
                height: 80,
                items: const [],
                onChanged: (val) {},
                hintText: 'Select worksite (optional)',
              ),
            ),
          ],
        ),
        kSizedBox,
        Row(
          children: [
            Expanded(
              child: MyDropdown(
                fillColor: AppColors.greyBg,
                height: 80,
                items: const [],
                onChanged: (val) {},
                hintText: 'Select Branch',
              ),
            ),
            kSizedBoxWidth,
            Expanded(
              child: MyDropdown(
                fillColor: AppColors.greyBg,
                height: 80,
                items: const [],
                onChanged: (val) {},
                hintText: 'Select Department',
              ),
            ),
          ],
        ),
        kSizedBox,
        Row(
          children: [
            Expanded(
              child: MyDropdown(
                fillColor: AppColors.greyBg,
                height: 80,
                items: const ['dfd', 'wdds'],
                onChanged: (val) {},
                hintText: 'Select Designation',
              ),
            ),
            kSizedBoxWidth,
            Expanded(
              child: MyTextFormField(
                fillColor: AppColors.greyBg,
                height: 80,
                hintText: "Select Start Date",
                onTap: () async {
                  //   DateTime? picked = await showDatePicker(
                  //     context: context,
                  //     initialDate: DateTime.now(),
                  //     firstDate: DateTime(2020),
                  //     lastDate: DateTime(2100),
                  //   );
                  //   if (picked != null) {
                  //     startDateController2.text =
                  //         picked.toLocal().toString().split(' ')[0];
                  //   }
                },
              ),
            ),
          ],
        ),
        kSizedBox,
        MyDropdown(
          fillColor: AppColors.greyBg,
          height: 80,
          items: const [],
          onChanged: (val) {},
          hintText: 'Select Office Location',
        ),
        kSizedBox,
        Row(
          children: [
            Expanded(
              child: MyDropdown(
                fillColor: AppColors.greyBg,
                height: 80,
                items: const [],
                onChanged: (val) {},
                hintText: 'City',
              ),
            ),
            kSizedBoxWidth,
            Expanded(
              child: MyDropdown(
                fillColor: AppColors.greyBg,
                height: 80,
                items: const [],
                onChanged: (val) {},
                hintText: 'State',
              ),
            ),
            kSizedBoxWidth,
            Expanded(
              child: MyDropdown(
                fillColor: AppColors.greyBg,
                height: 80,
                items: const [],
                onChanged: (val) {},
                hintText: 'Nationality',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
