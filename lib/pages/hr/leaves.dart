import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_button.dart';
import 'package:bms_front_end/components/input/my_input.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LeavesPage extends StatelessWidget {
  const LeavesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leaves',
                    style: AppText.black_600_32,
                  ),
                  Text(
                    'Leaves',
                    style: AppText.black_600_14,
                  ),
                ],
              ),
            ],
          ),
          kSizedBoxBG,
          Wrap(
            spacing: 8, // Horizontal space between items
            runSpacing: 8, // Vertical space when wrapping
            children: [
              MyElevatedButton(
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: AppColors.whiteColor,
                ),
                child: 'New Leave',
                onTap: () {},
              ),
              kSizedBoxWidth,
              SizedBox(
                width: 220,
                height: 48,
                child: MyTextFormField(
                  hintText: 'Search...',
                  leading: Icon(
                    Icons.search,
                    color: AppColors.grey1.withOpacity(0.5),
                  ),
                ),
              ),
              const SortBar(
                text: 'Sort',
              ),
            ],
          ),
          kSizedBox,
          kSizedBoxSM,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: Text(
          "Employee ID",
        ),
      ),
      const DataColumn(
        label: Text(
          "Employee Name",
        ),
      ),
      const DataColumn(
          label: Text(
        "Leave date",
      )),
      const DataColumn(
        label: Text(
          "Duration",
        ),
      ),
      const DataColumn(
        label: Text(
          "Leave Type",
        ),
      ),
      const DataColumn(
        label: Text(
          "Paid",
        ),
      ),
      const DataColumn(
        label: Text(
          "Status",
        ),
      ),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    return List.generate(10, (index) {
      return DataRow(cells: <DataCell>[
        const DataCell(
          Text("#23456"),
        ),
        DataCell(
          onTap: () {},
          GestureDetector(
            onTap: () {
              context.go(RouteConstants.employeeProfile);
            },
            child: Row(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  width: 36,
                  height: 36,
                  child: Image.asset('assets/icons/profileIcon.png'),
                ),
                const SizedBox(
                  width: 8,
                ),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText("Darlene Robertson", size: 16, weight: 400),
                    MyText("UI/UX Designer", size: 14, weight: 300)
                  ],
                ),
              ],
            ),
          ),
        ),
        const DataCell(
          Text("11/02/2024"),
        ),
        const DataCell(
          Text("5 days"),
        ),
        const DataCell(
          Text("Yes"),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 0.6,
                            color: getRandomColorFromList('Earned👍🏼')),
                        color: getRandomColorFromList('Earned👍🏼')
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6)),
                    child: const Center(
                      child: Text("Earned👍🏼"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              Container(
                height: 10,
                width: 10,
                decoration: const ShapeDecoration(
                  color: AppColors.green2,
                  shape: OvalBorder(),
                ),
              ),
              kSizedBoxWidthTiny,
              const Text("Approved"),
            ],
          ),
        ),
      ]);
    });
  }
}
