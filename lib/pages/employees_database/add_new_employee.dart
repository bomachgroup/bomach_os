import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/nav/employee_stepper.dart';
import 'package:bms_front_end/components/section/employee_documentation.dart';
import 'package:bms_front_end/components/section/personal_info.dart';
import 'package:bms_front_end/components/section/professional_info.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AddEmployesScreen extends StatefulWidget {
  const AddEmployesScreen({
    super.key,
  });

  @override
  State<AddEmployesScreen> createState() => _AddEmployesScreenState();
}

class _AddEmployesScreenState extends State<AddEmployesScreen> {
  final List<Widget> _pages = [
    const PersonalInformation(),
    const ProfessionalInformation(),
    const EmployeeDocumentation(),
  ];
  int selectionStepperState = 0;
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
            Text(
              'Employee’s Database',
              style: AppText.black_400_14,
            ),
            kSizedBoxWidthSM,
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
            ),
            kSizedBoxWidthSM,
            Text(
              'Add New Employee',
              style: AppText.black_400_14,
            ),
          ],
        ),
        kSizedBoxBG,
        Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 0.6, color: AppColors.borderColor)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EmployeeInfoStepper(
                        isActive: selectionStepperState == 0,
                        icon: SvgPicture.asset(
                          "assets/svg/person.svg",
                        ),
                        activeIcon: SvgPicture.asset(
                          "assets/svg/person-filled.svg",
                        ),
                        title: 'Personal Information',
                        onTap: () {
                          setState(() {
                            selectionStepperState = 0;
                          });
                        },
                      ),
                      kSizedBoxWidth,
                      EmployeeInfoStepper(
                        isActive: selectionStepperState == 1,
                        icon: SvgPicture.asset(
                          "assets/svg/briefcase.svg",
                        ),
                        activeIcon: SvgPicture.asset(
                          "assets/svg/briefcase-filled.svg",
                        ),
                        title: 'Professional Information',
                        onTap: () {
                          setState(() {
                            selectionStepperState = 1;
                          });
                        },
                      ),
                      kSizedBoxWidth,
                      EmployeeInfoStepper(
                        isActive: selectionStepperState == 2,
                        icon: SvgPicture.asset(
                          "assets/svg/document.svg",
                        ),
                        activeIcon: SvgPicture.asset(
                          "assets/svg/document-filled.svg",
                        ),
                        title: 'Documents',
                        onTap: () {
                          setState(() {
                            selectionStepperState = 2;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              kSizedBoxBG,
              _pages[selectionStepperState],
              kSizedBoxBG,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                    textColor: AppColors.blackColor,
                    borderColor: AppColors.borderColor,
                    bgColor: AppColors.greyBg,
                    child: 'Cancel',
                    onTap: () {},
                  ),
                  const SizedBox(width: 16),
                  MyElevatedButton(
                    child: 'Next',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
