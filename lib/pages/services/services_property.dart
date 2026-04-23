import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/app_text.dart';
import 'package:bms_front_end/pages/services/widget/service_form_dialog.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.displayLg(
                        'Services',
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      AppText.bodyMd(
                        'Services',
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
                            Iconsax.search_normal,
                            color: AppColors.neutral500.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      const SortBar(text: "Sort"),
                      MyElevatedButton(
                        icon: const Icon(
                          Iconsax.add_circle,
                          color: AppColors.white,
                        ),
                        child: "Add Service",
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return const ServiceFormDialog();
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
              // const PaginatorFooter(),
            ],
          ),
        ),
      ],
    );
  }

  List<DataColumn> _createColumns() {
    return [
      DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: AppText.bodyMd(
          "Service name",
        ),
      ),
      DataColumn(
        label: AppText.bodyMd(
          "Sub service",
        ),
      ),
      DataColumn(
          label: AppText.bodyMd(
        "Added inventory",
      )),
      DataColumn(
        label: AppText.bodyMd(
          "Order sales count",
        ),
      ),
      DataColumn(
        label: AppText.bodyMd(
          "Aurthor date",
        ),
      ),
      DataColumn(
        label: AppText.bodyMd(
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
          AppText.bodyMd(
            "Real Estate",
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.bodyMd(
                "- Development and sales",
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              AppText.bodyMd(
                "- Buy/Sales of property",
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.bodyMd(
                "- Fortress city Estate",
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              AppText.bodyMd(
                "- Bethel city Estate",
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
        ),
        DataCell(
          AppText.bodyMd("10 Order / sales - 35,00"),
        ),
        DataCell(
          AppText.bodyMd("11/02/2024"),
        ),
        DataCell(
          AppText.bodyMd(""),
        ),
      ]);
    });
  }
}
