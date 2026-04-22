import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/nav/three_dot_pop.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/finance/widget/add_contract_payment_dialog.dart';
import 'package:bms_front_end/pages/finance/widget/view_contract_payment_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

class ContractPaymentPage extends StatefulWidget {
  const ContractPaymentPage({super.key});

  @override
  State<ContractPaymentPage> createState() => ContractPaymentPageState();
}

class ContractPaymentPageState extends State<ContractPaymentPage> {
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
                        'Vendor/Contract Payment',
                        style: AppText.displayLg,
                      ),
                    ],
                  ),
                  MyElevatedButton(
                    icon: const Icon(
                      Iconsax.add_circle,
                      color: AppColors.white,
                    ),
                    child: "New Payment",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const AddContractPaymentDialog();
                        },
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
        kSizedBox,
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 15,
                runSpacing: 15,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 250,
                    child: MyTextFormField(
                      hintText: 'Search for payment...',
                      leading: Icon(
                        Iconsax.search_normal,
                        color: AppColors.neutral500.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  const Row(
                    spacing: 15,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SortBar(text: "All States"),
                      SortBar(text: "Status"),
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
      const DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: MyText(
          "Vendor Name",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Amount Due",
        ),
      ),
      const DataColumn(
          label: MyText(
        "Due Date",
      )),
      const DataColumn(
        label: MyText(
          "Status",
        ),
      ),
      const DataColumn(
        label: MyText(
          "Action",
        ),
      ),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    return List.generate(10, (index) {
      return DataRow(cells: <DataCell>[
        DataCell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return const ViewContractPaymentDialog();
              },
            );
          },
          const MyText(
            "MTN Group",
            size: 16,
            weight: 400,
            isSelectable: false,
          ),
        ),
        const DataCell(
          MyText("121500"),
        ),
        const DataCell(
          MyText("24-05-2025"),
        ),
        const DataCell(
          StatusChip(label: 'Pending', tone: StatusTone.warning),
        ),
        const DataCell(
          ThreeDotPop(),
        ),
      ]);
    });
  }
}
