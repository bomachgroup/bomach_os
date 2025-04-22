import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/nav/employee_stepper.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_svg/svg.dart';

class EmployeeProfile extends StatefulWidget {
  const EmployeeProfile({super.key});

  @override
  State<EmployeeProfile> createState() => _EmployeeProfileState();
}

class _EmployeeProfileState extends State<EmployeeProfile> {
  int employeeDetailSelectionState = 0;
  final List<Widget> _employeeDetailpages = [
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
            Text(
              'Darlene Robertson',
              style: AppText.black_400_14,
            ),
          ],
        ),
        const SizedBox(
          height: 32,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 0.6, color: AppColors.borderColor)),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  runSpacing: 20,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: AppColors.borderColor,
                              borderRadius: BorderRadius.circular(16)),
                          width: 100,
                          height: 100,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              "assets/image/man-demo.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        kSizedBoxWidth,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const MyText(
                              'Darlene Robertson',
                              size: 24,
                              weight: 600,
                              color: AppColors.blackColor,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  "assets/svg/briefcase.svg",
                                  height: 20,
                                ),
                                kSizedBoxWidthSM,
                                const Text(
                                  'UI/UX Designer',
                                  style: AppText.black_400_16,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  "assets/svg/message.svg",
                                  height: 20,
                                ),
                                kSizedBoxWidthSM,
                                const Text(
                                  'Darlenerob1@example.com',
                                  style: AppText.black_400_14,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    MyElevatedButton(
                      icon: const Icon(
                        Icons.edit,
                        color: AppColors.whiteColor,
                      ),
                      child: 'Edit Profile',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        const Divider(),
        const SizedBox(
          height: 28,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: isSmallScreen(context) ? 50 : 242,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: employeeDetailSelectionState == 0
                            ? AppColors.blueColor
                            : Colors.transparent,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: ListTile(
                      contentPadding: !isSmallScreen(context)
                          ? null
                          : const EdgeInsets.symmetric(
                              horizontal: 11, vertical: 0),
                      onTap: () {
                        setState(() {
                          employeeDetailSelectionState = 0;
                        });
                      },
                      title: isSmallScreen(context)
                          ? null
                          : Text(
                              'Profile',
                              style: employeeDetailSelectionState == 0
                                  ? AppText.white_600_16
                                  : AppText.sideMText_300_16,
                            ),
                      leading: SvgPicture.asset(
                        employeeDetailSelectionState == 0
                            ? "assets/svg/person-filled.svg"
                            : "assets/svg/person.svg",
                        colorFilter: ColorFilter.mode(
                            employeeDetailSelectionState == 0
                                ? AppColors.whiteColor
                                : AppColors.blackColor,
                            BlendMode.srcIn),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: employeeDetailSelectionState == 1
                            ? AppColors.blueColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      contentPadding: !isSmallScreen(context)
                          ? null
                          : const EdgeInsets.symmetric(
                              horizontal: 11, vertical: 0),
                      onTap: () {
                        setState(() {
                          employeeDetailSelectionState = 1;
                        });
                      },
                      title: isSmallScreen(context)
                          ? null
                          : Text(
                              'Reports Files',
                              style: employeeDetailSelectionState == 1
                                  ? AppText.white_600_16
                                  : AppText.sideMText_300_16,
                            ),
                      leading: SvgPicture.asset(
                        "assets/svg/todo.svg",
                        colorFilter: ColorFilter.mode(
                            employeeDetailSelectionState == 1
                                ? AppColors.whiteColor
                                : AppColors.blackColor,
                            BlendMode.srcIn),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: employeeDetailSelectionState == 2
                            ? AppColors.blueColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      contentPadding: !isSmallScreen(context)
                          ? null
                          : const EdgeInsets.symmetric(
                              horizontal: 11, vertical: 0),
                      onTap: () {
                        setState(() {
                          employeeDetailSelectionState = 2;
                        });
                      },
                      title: isSmallScreen(context)
                          ? null
                          : Text(
                              'Projects',
                              style: employeeDetailSelectionState == 2
                                  ? AppText.white_600_16
                                  : AppText.sideMText_300_16,
                            ),
                      leading: SvgPicture.asset(
                        "assets/svg/todo2.svg",
                        colorFilter: ColorFilter.mode(
                            employeeDetailSelectionState == 2
                                ? AppColors.whiteColor
                                : AppColors.blackColor,
                            BlendMode.srcIn),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: employeeDetailSelectionState == 3
                            ? AppColors.blueColor
                            : Colors.transparent,
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20))),
                    child: ListTile(
                      contentPadding: !isSmallScreen(context)
                          ? null
                          : const EdgeInsets.symmetric(
                              horizontal: 11, vertical: 0),
                      onTap: () {
                        setState(() {
                          employeeDetailSelectionState = 3;
                        });
                      },
                      title: isSmallScreen(context)
                          ? null
                          : Text(
                              'Tasks',
                              style: employeeDetailSelectionState == 3
                                  ? AppText.white_600_16
                                  : AppText.sideMText_300_16,
                            ),
                      leading: SvgPicture.asset(
                        "assets/svg/todo.svg",
                        colorFilter: ColorFilter.mode(
                            employeeDetailSelectionState == 3
                                ? AppColors.whiteColor
                                : AppColors.blackColor,
                            BlendMode.srcIn),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 40,
            ),
            Expanded(child: _employeeDetailpages[employeeDetailSelectionState])
          ],
        ),
      ],
    );
  }
}

class ProfiledDetail extends StatefulWidget {
  const ProfiledDetail({
    super.key,
  });

  @override
  State<ProfiledDetail> createState() => _ProfiledDetailState();
}

class _ProfiledDetailState extends State<ProfiledDetail> {
  final List<Widget> _employeeProfilePages = [
    const PersonalInfoDetail(),
    const ProfessionaInfoDetail(),
    const DocumentDetail()
  ];
  int employeeProfileSelectionStepperState = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              EmployeeInfoStepper(
                isActive: employeeProfileSelectionStepperState == 0,
                icon: SvgPicture.asset(
                  "assets/svg/person.svg",
                ),
                activeIcon: SvgPicture.asset(
                  "assets/svg/person-filled.svg",
                ),
                title: 'Personal Information',
                onTap: () {
                  setState(() {
                    employeeProfileSelectionStepperState = 0;
                  });
                },
              ),
              const SizedBox(
                width: 20,
              ),
              EmployeeInfoStepper(
                isActive: employeeProfileSelectionStepperState == 1,
                icon: SvgPicture.asset(
                  "assets/svg/briefcase.svg",
                ),
                activeIcon: SvgPicture.asset(
                  "assets/svg/briefcase-filled.svg",
                ),
                title: 'Professional Information',
                onTap: () {
                  setState(() {
                    employeeProfileSelectionStepperState = 1;
                  });
                },
              ),
              const SizedBox(
                width: 20,
              ),
              EmployeeInfoStepper(
                isActive: employeeProfileSelectionStepperState == 2,
                icon: SvgPicture.asset(
                  "assets/svg/document.svg",
                ),
                activeIcon: SvgPicture.asset(
                  "assets/svg/document-filled.svg",
                ),
                title: 'Documents',
                onTap: () {
                  setState(() {
                    employeeProfileSelectionStepperState = 2;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        _employeeProfilePages[employeeProfileSelectionStepperState]
      ],
    );
  }
}

class ReportFiles extends StatelessWidget {
  const ReportFiles({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutGrid(
      columnSizes: !isLargeScreen(context) ? [1.fr] : [1.fr, 1.fr],
      rowSizes: const [
        auto,
        auto,
        auto,
        auto,
        auto,
        auto,
      ],
      columnGap: kDefaultSpaceBG,
      rowGap: kDefaultSpaceBG,
      children: const [
        DocumentHolder(documentDetail: "Aso Villa PJ report 12/8/2024.png"),
        DocumentHolder(documentDetail: "Aso Villa PJ report 12/8/2024.png"),
        DocumentHolder(documentDetail: "Aso Villa PJ report 12/8/2024.png"),
        DocumentHolder(documentDetail: "Aso Villa PJ report 12/8/2024.png"),
        DocumentHolder(documentDetail: "Aso Villa PJ report 12/8/2024.png"),
        DocumentHolder(documentDetail: "Aso Villa PJ report 12/8/2024.png"),
      ],
    );
  }
}

class Projects extends StatelessWidget {
  const Projects({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class DocumentDetail extends StatelessWidget {
  const DocumentDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutGrid(
      columnSizes: !isLargeScreen(context) ? [1.fr] : [1.fr, 1.fr],
      rowSizes: const [
        auto,
        auto,
        auto,
        auto,
        auto,
        auto,
      ],
      columnGap: kDefaultSpaceBG,
      rowGap: kDefaultSpaceBG,
      children: const [
        DocumentHolder(documentDetail: "Aso Villa PJ report 12/8/2024.png"),
        DocumentHolder(documentDetail: "Aso Villa PJ report 12/8/2024.png"),
        DocumentHolder(documentDetail: "Aso Villa PJ report 12/8/2024.png"),
        DocumentHolder(documentDetail: "Aso Villa PJ report 12/8/2024.png"),
        DocumentHolder(documentDetail: "Aso Villa PJ report 12/8/2024.png"),
        DocumentHolder(documentDetail: "Aso Villa PJ report 12/8/2024.png"),
      ],
    );
  }
}

class DocumentHolder extends StatelessWidget {
  final String documentDetail;
  const DocumentHolder({
    super.key,
    required this.documentDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          border: Border.all(width: 0.6, color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(14)),
      // width: 360,
      height: 56,
      child: Row(
        children: [
          Expanded(
            child: MyText(
              documentDetail,
              weight: 300,
              size: 16,
              color: AppColors.darkGrey3,
              maxLines: 1,
            ),
          ),
          kSizedBoxWidthSM,
          SvgPicture.asset(
            "assets/svg/eye.svg",
          ),
          kSizedBoxWidthSM,
          SvgPicture.asset(
            "assets/svg/download.svg",
          ),
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
              ProfileFiedsHolder(
                title: 'Employee ID',
                detail: '879912390',
              ),
              SizedBox(
                width: 24,
              ),
              ProfileFiedsHolder(
                title: 'User Name',
                detail: 'Robertson_UI',
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              ProfileFiedsHolder(
                title: 'Employment Type',
                detail: 'Full-time',
              ),
              SizedBox(
                width: 24,
              ),
              ProfileFiedsHolder(
                title: 'Email',
                detail: 'Darlenerob1@example.com',
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              ProfileFiedsHolder(
                title: 'Branch',
                detail: 'Enugu',
              ),
              SizedBox(
                width: 24,
              ),
              ProfileFiedsHolder(
                title: 'Department',
                detail: 'Design',
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              ProfileFiedsHolder(
                title: 'Designation',
                detail: 'UI/UX Design',
              ),
              SizedBox(
                width: 24,
              ),
              ProfileFiedsHolder(
                title: 'Start Date',
                detail: '1 July,2023',
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              ProfileFiedsHolder(
                title: 'Office Location',
                detail: 'Plot 34, Azuka street, GRA',
              ),
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
              ProfileFiedsHolder(
                title: 'First Name',
                detail: 'Darlene',
              ),
              SizedBox(
                width: 24,
              ),
              ProfileFiedsHolder(
                title: 'Last Name',
                detail: 'Robertson',
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              ProfileFiedsHolder(
                title: 'Surname Name',
                detail: 'Darlene',
              ),
              SizedBox(
                width: 24,
              ),
              ProfileFiedsHolder(
                title: 'Gender',
                detail: 'Male',
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              ProfileFiedsHolder(
                title: 'Date of Birth',
                detail: 'July, 24, 1999',
              ),
              SizedBox(
                width: 24,
              ),
              ProfileFiedsHolder(
                title: 'Marital status',
                detail: 'Single',
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              ProfileFiedsHolder(
                title: 'Address',
                detail: 'Plot 34, Azuka street, GRA',
              ),
              SizedBox(
                width: 24,
              ),
              ProfileFiedsHolder(
                title: 'City',
                detail: 'Enugu',
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              ProfileFiedsHolder(
                title: 'State',
                detail: 'Enugu',
              ),
              SizedBox(
                width: 24,
              ),
              ProfileFiedsHolder(
                title: 'Nationality',
                detail: 'Nigeria',
              ),
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
    super.key,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppText.sideMText_300_14,
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            detail,
            style: AppText.black_400_16,
          ),
          const Divider()
        ],
      ),
    );
  }
}

class Task extends StatelessWidget {
  const Task({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// class Task extends StatelessWidget {
//   const Task({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       decoration: BoxDecoration(
//           border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
//           borderRadius: BorderRadius.circular(16)),
//       child: Column(
//         children: [
//           SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: DataTable(
//                   // decoration: BoxDecoration(),
//                   columns: _createColumns(),
//                   rows: _createRows(context))),
//           const SizedBox(
//             height: 4,
//           ),
//           const Divider(),
//           const SizedBox(
//             height: 8,
//           ),
//           const Row(
//             children: [
//               Text('Showing'),
//               Text('Showing 1 to 8 out of 60 records'),
//             ],
//           ),
//           const SizedBox(
//             height: 8,
//           ),
//         ],
//       ),
//     );
//   }

//   List<DataColumn> _createColumns() {
//     return [
//       const DataColumn(
//           headingRowAlignment: MainAxisAlignment.start,
//           label: Text(
//             "Task code",
//           )),
//       const DataColumn(
//           label: Text(
//         "Task Name",
//       )),
//       const DataColumn(label: Text("Assign to")),
//       const DataColumn(
//           label: Text(
//         "Start date",
//       )),
//       const DataColumn(
//           label: Text(
//         "Due date",
//       )),
//       const DataColumn(
//           label: Text(
//         "Status",
//       )),
//     ];
//   }

//   List<DataRow> _createRows(BuildContext context) {
//     return List.generate(10, (index) {
//       return DataRow(cells: <DataCell>[
//         const DataCell(
//           SizedBox(width: 100, child: Text("#1234567")),
//         ),
//         const DataCell(
//           SizedBox(
//               width: 250, child: Text("Benji Express user login Interface")),
//         ),
//         DataCell(
//           SizedBox(
//             width: 70,
//             child: Container(
//               width: 32,
//               height: 32,
//               decoration: const BoxDecoration(
//                   color: AppColors.secondaryColor, shape: BoxShape.circle),
//             ),
//           ),
//         ),
//         const DataCell(
//           SizedBox(width: 100, child: Text("12/10/2023")),
//         ),
//         const DataCell(
//           SizedBox(width: 100, child: Text("02/02/2025")),
//         ),
//         const DataCell(
//           SizedBox(width: 100, child: Text("Undone")),
//         ),
//       ]);
//     });
//   }
// }
