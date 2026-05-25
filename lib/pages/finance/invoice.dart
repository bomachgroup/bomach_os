import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/sort_bar.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/nav/three_dot_pop.dart';
import 'package:bomach_os/components/paginate/responsive_table.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/pages/finance/widget/add_invoice_dialog.dart';
import 'package:bomach_os/pages/finance/widget/view_invoice_dialog.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/helper/responsive_breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  State<InvoicePage> createState() => InvoicePageState();
}

class InvoicePageState extends State<InvoicePage> {
  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      header: PageHeader(
        title: 'Invoices',
        subtitle: 'Manage all invoices and billing',
        trailing: MyElevatedButton(
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
      ),
      children: [
        // Search and Filters
        context.isMobile
            ? const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MyTextFormField(
                    hintText: 'Search for invoice...',
                    leading: Icon(
                      Iconsax.search_normal_1,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: SortBar(text: 'All States')),
                      SizedBox(width: 12),
                      Expanded(child: SortBar(text: 'Status')),
                    ],
                  ),
                ],
              )
            : const Row(
                children: [
                  SizedBox(
                    width: 300,
                    child: MyTextFormField(
                      hintText: 'Search for invoice...',
                      leading: Icon(
                        Iconsax.search_normal_1,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  Spacer(),
                  SortBar(text: 'All States'),
                  SizedBox(width: 12),
                  SortBar(text: 'Status'),
                ],
              ),
        const SizedBox(height: 24),

        // Invoices Table/List
        // Invoices Table/List
        ResponsiveTable<int>(
          items: List.generate(10, (index) => index),
          columns: _createColumns(),
          rowBuilder: (val, index) => DataRow(cells: <DataCell>[
            DataCell(
              Text(
                'FJ9387HDS',
                style: AppTextStyles.bodyMd.copyWith(
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
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            DataCell(
              Text(
                '24-05-2025',
                style: AppTextStyles.bodyMd
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
            DataCell(
              Text(
                '24-05-2025',
                style: AppTextStyles.bodyMd
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
            DataCell(
              Text(
                '₦121,500',
                style: AppTextStyles.bodyMd.copyWith(
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
          ]),
          mobileCardBuilder: (val, index) => AppCard(
                        padding: const EdgeInsets.all(16),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return const InvoiceDetailsDialog();
                },
              );
            },
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText('FJ9387HDS',
                        weight: 700, size: 14, color: AppColors.textPrimary),
                    StatusChip(label: 'Pending', tone: StatusTone.warning),
                  ],
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.neutral100,
                      child: Icon(Iconsax.user,
                          size: 16, color: AppColors.primary),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: MyText('MTN Group',
                          weight: 600, size: 14, color: AppColors.textPrimary),
                    ),
                    MyText('₦121,500',
                        weight: 700, size: 14, color: AppColors.primary),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText('Due Date',
                            size: 11, color: AppColors.textSecondary),
                        SizedBox(height: 4),
                        MyText('24-05-2025',
                            size: 13,
                            weight: 600,
                            color: AppColors.textPrimary),
                      ],
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Iconsax.more, size: 20),
                    ),
                  ],
                ),
              ],
            ),
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
}
