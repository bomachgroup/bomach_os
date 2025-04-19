import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LeadsPage extends StatelessWidget {
  const LeadsPage({super.key});

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
                    'Leads',
                    style: AppText.black_600_32,
                  ),
                  Text(
                    'Leads',
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
                child: 'New Leads',
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
      DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: Checkbox(value: false, onChanged: (val) {}),
      ),
      const DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: Text(
          "Leads ID",
        ),
      ),
      const DataColumn(
        label: Text(
          "Contact Name",
        ),
      ),
      const DataColumn(
          label: Text(
        "Email",
      )),
      const DataColumn(
        label: Text(
          "Phone no.",
        ),
      ),
      const DataColumn(
        label: Text(
          "Lead Owner",
        ),
      ),
      const DataColumn(
        label: Text(
          "Date of creation",
        ),
      ),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    return List.generate(
      10,
      (index) {
        return DataRow(
          cells: <DataCell>[
            DataCell(
              onTap: () {},
              Checkbox(value: false, onChanged: (val) {}),
            ),
            const DataCell(
              Text("001"),
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
            ),
            const DataCell(
              Text("Jennygroup45@gmail.com"),
            ),
            const DataCell(
              Text("+234 808 986 2487"),
            ),
            const DataCell(
              Text("--"),
            ),
            const DataCell(
              Text("27/09/2024"),
            ),
          ],
        );
      },
    );
  }
}
