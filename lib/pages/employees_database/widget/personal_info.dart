import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class PersonalInformation extends StatefulWidget {
  const PersonalInformation({super.key});

  @override
  State<PersonalInformation> createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        kSizedBox,
        ProfilePicture(
          upload: () {},
        ),
        kSizedBoxBG,
        const Row(
          children: [
            Expanded(
              child: MyTextFormField(
                fillColor: AppColors.greyBg,
                height: 80,
                hintText: 'Enter First name',
              ),
            ),
            kSizedBoxWidth,
            Expanded(
              child: MyTextFormField(
                fillColor: AppColors.greyBg,
                height: 80,
                hintText: 'Enter Last name',
              ),
            ),
          ],
        ),
        kSizedBox,
        const Row(
          children: [
            Expanded(
              child: MyTextFormField(
                fillColor: AppColors.greyBg,
                height: 80,
                hintText: 'Enter Surname name',
              ),
            ),
            kSizedBoxWidth,
            Expanded(
              child: MyTextFormField(
                fillColor: AppColors.greyBg,
                height: 80,
                hintText: 'Enter your Email address',
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
                hintText: 'Gender',
              ),
            ),
            kSizedBoxWidth,
            Expanded(
              child: MyDropdown(
                fillColor: AppColors.greyBg,
                height: 80,
                items: const [],
                onChanged: (val) {},
                hintText: 'Marital status',
              ),
            ),
          ],
        ),
        kSizedBox,
        Row(
          children: [
            const Expanded(
              child: MyTextFormField(
                fillColor: AppColors.greyBg,
                height: 80,
                hintText: 'Mobile number',
              ),
            ),
            kSizedBoxWidth,
            Expanded(
              child: MyTextFormField(
                fillColor: AppColors.greyBg,
                height: 80,
                hintText: "Date of Birth",
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
          hintText: 'Address',
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

class ProfilePicture extends StatelessWidget {
  final VoidCallback upload;
  const ProfilePicture({
    super.key,
    required this.upload,
  });

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      dashPattern: const [10, 10],
      strokeWidth: 2,
      color: AppColors.card,
      borderType: BorderType.RRect,
      radius: const Radius.circular(12),
      child: Container(
        width: 180,
        height: 145,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            kSizedBox,
            SizedBox(
              width: 40,
              height: 40,
              child: Image.asset(
                "assets/image/picture.png",
                width: 30,
                height: 30,
              ),
            ),
            kSizedBox,
            const Text(
              'Add Profile Picture',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.darkGrey3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
