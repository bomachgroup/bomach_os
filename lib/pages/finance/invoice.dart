import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/nav/three_dot_pop.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/pages/finance/widget/add_invoice_dialog.dart';
import 'package:bms_front_end/pages/finance/widget/view_invoice_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  State<InvoicePage> createState() => InvoicePageState();
}

class InvoicePageState extends State<InvoicePage> {
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
        PageHeader(
          title: 'Invoices',
          subtitle: 'Manage all invoices and billing',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyElevatedButton(
                icon: const Icon(
                  Iconsax.add_circle,
                  color: AppColors.textOnPrimary,
                  size: 18,
                ),
                child: 'New Invoice',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const AddInvoiceDialog();
                    },
                  );
                },
              ),
            ],
          ),
        ),
        kSizedBox,
        const Row(
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
                      hintText: 'Search for invoice...',
                      leading: Icon(
                        Iconsax.search_normal_1,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  Row(
                    spacing: 15,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SortBar(text: 'All States'),
                      SortBar(text: 'Status'),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        kSizedBox,
        kSizedBoxSM,
        AppCard(
          padding: const EdgeInsets.all(16),
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
                      headingRowColor: WidgetStateProperty.resolveWith(
                          (states) => AppColors.surfaceMuted),
                      headingTextStyle: AppText.label.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      dataTextStyle: AppText.bodyMd.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      dataRowMinHeight: 68,
                      dataRowMaxHeight: 68,
                      columnSpacing: 24,
                      horizontalMargin: 12,
                      dividerThickness: 1.0,
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
    return const [
      DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: Text('Invoice ID'),
      ),
      DataColumn(label: Text('Client Name')),
      DataColumn(label: Text('Issue Date')),
      DataColumn(label: Text('Due Date')),
      DataColumn(label: Text('Total')),
      DataColumn(label: Text('Status')),
      DataColumn(label: Text('Action')),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    return List.generate(10, (index) {
      return DataRow(cells: <DataCell>[
        DataCell(
          Text(
            'FJ9387HDS',
            style: AppText.bodyMd.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        DataCell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return const InvoiceDetailsDialog();
              },
            );
          },
          Text(
            'MTN Group',
            style: AppText.bodyMd.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        DataCell(
          Text(
            '24-05-2025',
            style: AppText.bodyMd.copyWith(color: AppColors.textSecondary),
          ),
        ),
        DataCell(
          Text(
            '24-05-2025',
            style: AppText.bodyMd.copyWith(color: AppColors.textSecondary),
          ),
        ),
        DataCell(
          Text(
            '₦121,500',
            style: AppText.bodyMd.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
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
