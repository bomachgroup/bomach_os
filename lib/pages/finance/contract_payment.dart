import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bomach_os/components/button/sort_bar.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/nav/three_dot_pop.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/pages/finance/widget/add_contract_payment_dialog.dart';
import 'package:bomach_os/pages/finance/widget/view_contract_payment_dialog.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/spaces.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/helper/responsive_breakpoints.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/components/section/page_header.dart';
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

  Widget _buildMobileCards(BuildContext context) {
    final vendors = [
      ('MTN Group', '121500', '24-05-2025', 'Pending'),
      ('Glo Nigeria', '85000', '30-05-2025', 'Approved'),
      ('Airtel Nigeria', '200000', '15-06-2025', 'Pending'),
      ('9mobile', '45000', '10-06-2025', 'Rejected'),
      ('MainOne Cable', '350000', '20-06-2025', 'Pending'),
    ];

    return Column(
      children: vendors.map((vendor) {
        final tone = vendor.$4 == 'Approved'
            ? StatusTone.success
            : vendor.$4 == 'Pending'
                ? StatusTone.warning
                : StatusTone.danger;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.borderSubtle, width: 0.6),
          ),
          color: AppColors.surface,
          child: InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return ViewContractPaymentDialog(
                    vendorName: vendor.$1,
                    amountDue: vendor.$2,
                    dueDate: vendor.$3,
                    status: vendor.$4,
                  );
                },
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: MyText(
                          vendor.$1,
                          size: 16,
                          weight: 600,
                          style: AppTextStyles.bodyMd,
                        ),
                      ),
                      StatusChip(
                        label: vendor.$4,
                        tone: tone,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const MyText(
                            'Amount Due',
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 4),
                          MyText(
                            '₦${vendor.$2}',
                            size: 14,
                            weight: 600,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const MyText(
                            'Due Date',
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 4),
                          MyText(
                            vendor.$3,
                            size: 14,
                            weight: 500,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showMobile = context.isMobile;

    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Vendor/Contract Payment',
        trailing: MyElevatedButton(
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
        ),
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 15,
                runSpacing: 15,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: showMobile ? double.infinity : 250,
                    child: MyTextFormField(
                      hintText: 'Search for payment...',
                      leading: Icon(
                        Iconsax.search_normal,
                        color: AppColors.neutral500.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  Row(
                    spacing: 15,
                    mainAxisSize: showMobile ? MainAxisSize.max : MainAxisSize.min,
                    children: [
                      Expanded(
                        flex: showMobile ? 1 : 0,
                        child: const SortBar(text: "All States"),
                      ),
                      Expanded(
                        flex: showMobile ? 1 : 0,
                        child: const SortBar(text: "Status"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        if (showMobile)
          _buildMobileCards(context)
        else
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
    final vendors = [
      ('MTN Group', '121500', '24-05-2025', 'Pending'),
      ('Glo Nigeria', '85000', '30-05-2025', 'Approved'),
      ('Airtel Nigeria', '200000', '15-06-2025', 'Pending'),
      ('9mobile', '45000', '10-06-2025', 'Rejected'),
      ('MainOne Cable', '350000', '20-06-2025', 'Pending'),
    ];
    return List.generate(vendors.length, (index) {
      final vendor = vendors[index];
      return DataRow(cells: <DataCell>[
        DataCell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return ViewContractPaymentDialog(
                  vendorName: vendor.$1,
                  amountDue: vendor.$2,
                  dueDate: vendor.$3,
                  status: vendor.$4,
                );
              },
            );
          },
          MyText(
            vendor.$1,
            size: 16,
            weight: 400,
            isSelectable: false,
          ),
        ),
        DataCell(
          MyText(vendor.$2),
        ),
        DataCell(
          MyText(vendor.$3),
        ),
        DataCell(
          StatusChip(label: vendor.$4, tone: StatusTone.warning),
        ),
        const DataCell(
          ThreeDotPop(),
        ),
      ]);
    });
  }
}
