import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_filter_bar.dart';
import 'package:bms_front_end/components/chart/process_status.dart';
import 'package:bms_front_end/components/input/my_checkbox.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Projects',
          style: AppText.black_500_32,
        ),
        const Text(
          'Projects',
          style: AppText.black_400_14,
        ),
        const SizedBox(
          height: 12,
        ),
        Row(
          children: [
            MyElevatedButton(
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.whiteColor,
              ),
              child: 'Add New Project',
              onTap: () {
                context.go(RouteConstants.addEmployees);
              },
            ),
            kSizedBoxWidth,
            SizedBox(
              width: 180,
              child: MyTextFormField(
                hintText: 'Search...',
                leading: Icon(
                  Icons.search,
                  color: AppColors.grey1.withValues(alpha: 0.5),
                ),
              ),
            ),
            kSizedBoxWidth,
            const SortFilterBar(),
          ],
        ),
        kSizedBox,
        kSizedBoxSM,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
              border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
              borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Scrollbar(
                thumbVisibility: true,
                trackVisibility: true,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: bodySpace(context),
                    ),
                    child: DataTable(
                      dataRowMinHeight: 68,
                      dataRowMaxHeight: 68,
                      columnSpacing: 24,
                      horizontalMargin: 12,
                      columns: _createColumns(),
                      rows: _createRows(context),
                      showBottomBorder: true,
                    ),
                  ),
                ),
              ),
              const MyPaginator(),
              const SizedBox(
                height: 8,
              ),
            ],
          ),
        )
      ],
    );
  }

  List<DataColumn> _createColumns() {
    return [
      DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: MyCheckbox(
          isChecked: false,
          onChanged: (value) {},
          backgroundNotCheckedColor: AppColors.transparent,
          borderNotCheckedColor: AppColors.grey4,
        ),
      ),
      const DataColumn(
          headingRowAlignment: MainAxisAlignment.start,
          label: Text(
            "PJ code",
          )),
      const DataColumn(
          label: Text(
        "Project Name",
      )),
      const DataColumn(label: Text("Members")),
      const DataColumn(
          label: Text(
        "Start date",
      )),
      const DataColumn(
          label: Text(
        "Deadline",
      )),
      const DataColumn(
          label: Text(
        "Clients",
      )),
      const DataColumn(
          label: Text(
        "Status",
      )),
      const DataColumn(
          label: Text(
        "Action",
      )),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    return List.generate(10, (index) {
      return DataRow(cells: <DataCell>[
        DataCell(
          MyCheckbox(
            isChecked: false,
            onChanged: (value) {},
            backgroundNotCheckedColor: AppColors.transparent,
            borderNotCheckedColor: AppColors.grey4,
          ),
        ),
        const DataCell(
          SizedBox(width: 120, child: Text("#455653")),
        ),
        DataCell(
          onTap: () {
            context.go(RouteConstants.eachprojects);
          },
          const SizedBox(
              width: 152, child: Text("Benji Express mobile app project")),
        ),
        DataCell(
          SizedBox(
            width: 80,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const SizedBox(),
                Positioned(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.whiteColor,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        "assets/image/man-demo.png",
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: (20),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.whiteColor,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        "assets/icons/profile-icon.png",
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.whiteColor,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        "assets/image/man-demo.png",
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.whiteColor,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        "assets/icons/profile-icon.png",
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const DataCell(
          SizedBox(width: 100, child: Text("27/09/2024")),
        ),
        const DataCell(
          SizedBox(width: 100, child: Text("27/09/2024")),
        ),
        DataCell(
          Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                width: 36,
                height: 36,
                child: Image.asset('assets/icons/profile-icon.png'),
              ),
              const SizedBox(
                width: 8,
              ),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText("Darlene Robertson", size: 16, weight: 400),
                  MyText("MTN Nigeria", size: 14, weight: 300)
                ],
              ),
            ],
          ),
        ),
        const DataCell(
          ProgressStatus(),
        ),
        const DataCell(
          Icon(Icons.more_vert_outlined),
        ),
      ]);
    });
  }
}
