import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/services/widget/add_service_dialog.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ServicesPropertyPage extends StatefulWidget {
  const ServicesPropertyPage({super.key});

  @override
  State<ServicesPropertyPage> createState() => ServicesPropertyPageState();
}

class ServicesPropertyPageState extends State<ServicesPropertyPage> {
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
        Row(
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 10,
                runSpacing: 10,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        'Services',
                        style: AppText.black_500_32,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      MyText(
                        'Services',
                        style: AppText.black_400_14,
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    children: [
                      SizedBox(
                        width: 150,
                        child: MyTextFormField(
                          hintText: 'Search...',
                          leading: Icon(
                            Icons.search,
                            color: AppColors.grey1.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      const SortBar(text: "Sort"),
                      MyElevatedButton(
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.white,
                        ),
                        child: "Add Service",
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return const AddServiceDialog();
                            },
                          );
                        },
                      )
                    ],
                  )
                ],
              ),
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
        ),
      ],
    );
  }

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: MyText(
          "Service name",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Sub service",
        ),
      ),
      const DataColumn(
          label: MyText(
        "Added inventory",
      )),
      const DataColumn(
        label: MyText(
          "Order sales count",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Aurthor date",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Notes/Comments",
        ),
      ),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    return List.generate(10, (index) {
      return DataRow(cells: <DataCell>[
        DataCell(
          onTap: () {
            context.go(RouteConstants.serviceDetail);
          },
          const MyText(
            "Real Estate",
            isSelectable: false,
          ),
        ),
        const DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                "- Development and sales",
                size: 16,
                weight: 400,
                isSelectable: false,
              ),
              MyText(
                "- Buy/Sales of property",
                size: 16,
                weight: 400,
                isSelectable: false,
              ),
            ],
          ),
        ),
        const DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                "- Fortress city Estate",
                size: 16,
                weight: 400,
                isSelectable: false,
              ),
              MyText(
                "- Bethel city Estate",
                size: 16,
                weight: 400,
                isSelectable: false,
              ),
            ],
          ),
        ),
        const DataCell(
          MyText("10 Order / sales - 35,00"),
        ),
        const DataCell(
          MyText("11/02/2024"),
        ),
        const DataCell(
          MyText(""),
        ),
      ]);
    });
  }
}
