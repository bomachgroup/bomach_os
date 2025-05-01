import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/nav/employee_stepper.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/employees_database/widget/employee_table.dart';
import 'package:bms_front_end/pages/project/widget/project_task_table.dart';
import 'package:bms_front_end/pages/project/widget/site_equipment_table.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ProjectWorkSite extends StatefulWidget {
  const ProjectWorkSite({super.key});

  @override
  State<ProjectWorkSite> createState() => _ProjectWorkSiteState();
}

class _ProjectWorkSiteState extends State<ProjectWorkSite> {
  int selectionStepperState = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        kSizedBoxBG,
        Row(
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 20,
                runSpacing: 20,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: const MyText(
                      "Agbani Site, behind Orando fuel station, Eke Agbani",
                      size: 28,
                      weight: 500,
                    ),
                  ),
                  MyElevatedButton(child: "Add Employee", onTap: () {})
                ],
              ),
            ),
          ],
        ),
        kSizedBox,
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
                  title: 'Employees',
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
                    "assets/svg/settings.svg",
                  ),
                  activeIcon: SvgPicture.asset(
                    "assets/svg/settings-filled.svg",
                  ),
                  title: 'Site Equipments',
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
                  title: 'Site Task',
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
        if (selectionStepperState == 0) const EmployeeTable(),
        if (selectionStepperState == 1) const SiteEquipmentTable(),
        if (selectionStepperState == 2) const ProjectTaskTable(),
      ],
    );
  }
}
