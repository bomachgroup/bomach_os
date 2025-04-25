import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/input/my_checkbox.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

class LeadsPage extends StatefulWidget {
  const LeadsPage({super.key});

  @override
  State<LeadsPage> createState() => _LeadsPageState();
}

class _LeadsPageState extends State<LeadsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  'Leads',
                  style: AppText.black_600_32,
                ),
                MyText(
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
                color: AppColors.white,
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
                  color: AppColors.grey1.withValues(alpha: 0.5),
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
            children: [
              Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                trackVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
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
          onChanged: (val) {},
          backgroundNotCheckedColor: AppColors.transparent,
          borderNotCheckedColor: AppColors.grey4,
        ),
      ),
      const DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: MyText(
          "Leads ID",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Contact Name",
        ),
      ),
      const DataColumn(
          label: MyText(
        "Email",
      )),
      const DataColumn(
        label: MyText(
          "Phone no.",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Lead Owner",
        ),
      ),
      const DataColumn(
        label: MyText(
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
              MyCheckbox(
                isChecked: false,
                onChanged: (val) {},
                backgroundNotCheckedColor: AppColors.transparent,
                borderNotCheckedColor: AppColors.grey4,
              ),
            ),
            const DataCell(
              MyText("001"),
            ),
            DataCell(
              onTap: () {},
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
              MyText("Jennygroup45@gmail.com"),
            ),
            const DataCell(
              MyText("+234 808 986 2487"),
            ),
            const DataCell(
              MyText("--"),
            ),
            const DataCell(
              MyText("27/09/2024"),
            ),
          ],
        );
      },
    );
  }
}
