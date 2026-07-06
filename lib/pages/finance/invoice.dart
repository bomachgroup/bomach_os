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
import 'package:bomach_os/pages/finance/models/service_invoice_model_api.dart';
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
  List<ServiceInvoice> get _mockInvoices => [
        ServiceInvoice(
          id: 1, invoiceNumber: 'FJ9387HDS', clientId: 1,
          service: ServiceOut(id: 1, name: 'Telecom'),
          issueDate: '24-05-2025', dueDate: '24-06-2025',
          subtotal: '100000', taxRate: '7.5', taxAmount: '7500',
          totalAmount: '107500', amountPaid: '0', balance: '107500',
          paymentProgress: 0, status: 'pending', notes: '',
          items: [
            InvoiceItemOut(id: 1, description: 'Consulting Service',
                quantity: 1, unitPrice: '100000', total: '100000',
                createdAt: '', updatedAt: ''),
          ],
          createdAt: '', updatedAt: '', createdById: 1,
        ),
        ServiceInvoice(
          id: 2, invoiceNumber: 'GH7890JK', clientId: 2,
          service: ServiceOut(id: 2, name: 'Internet Services'),
          issueDate: '15-05-2025', dueDate: '15-06-2025',
          subtotal: '200000', taxRate: '7.5', taxAmount: '15000',
          totalAmount: '215000', amountPaid: '215000', balance: '0',
          paymentProgress: 100, status: 'paid', notes: 'Paid in full',
          items: [
            InvoiceItemOut(id: 2, description: 'Fiber Optic Installation',
                quantity: 2, unitPrice: '100000', total: '200000',
                createdAt: '', updatedAt: ''),
          ],
          createdAt: '', updatedAt: '', createdById: 1,
        ),
        ServiceInvoice(
          id: 3, invoiceNumber: 'KL4561MN', clientId: 3,
          service: ServiceOut(id: 3, name: 'Cloud Services'),
          issueDate: '10-05-2025', dueDate: '10-06-2025',
          subtotal: '350000', taxRate: '7.5', taxAmount: '26250',
          totalAmount: '376250', amountPaid: '188125', balance: '188125',
          paymentProgress: 50, status: 'overdue', notes: '',
          items: [
            InvoiceItemOut(id: 3, description: 'Cloud Hosting - Annual',
                quantity: 1, unitPrice: '350000', total: '350000',
                createdAt: '', updatedAt: ''),
          ],
          createdAt: '', updatedAt: '', createdById: 2,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final invoices = _mockInvoices;
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
        ResponsiveTable<ServiceInvoice>(
          items: invoices,
          columns: _createColumns(),
          rowBuilder: (invoice, index) => DataRow(cells: <DataCell>[
            DataCell(
              Text(
                invoice.invoiceNumber,
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
                    return InvoiceDetailsDialog(invoice: invoice);
                  },
                );
              },
              Text(
                invoice.service.name,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            DataCell(
              Text(
                invoice.issueDate,
                style: AppTextStyles.bodyMd
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
            DataCell(
              Text(
                invoice.dueDate,
                style: AppTextStyles.bodyMd
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
            DataCell(
              Text(
                '₦${invoice.totalAmount}',
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            DataCell(
              StatusChip(label: invoice.status, tone: StatusTone.warning),
            ),
            const DataCell(
              ThreeDotPop(),
            ),
          ]),
          mobileCardBuilder: (invoice, index) => AppCard(
                        padding: const EdgeInsets.all(16),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return InvoiceDetailsDialog(invoice: invoice);
                },
              );
            },
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(invoice.invoiceNumber,
                        weight: 700, size: 14, color: AppColors.textPrimary),
                    StatusChip(label: invoice.status, tone: StatusTone.warning),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.neutral100,
                      child: Icon(Iconsax.user,
                          size: 16, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MyText(invoice.service.name,
                          weight: 600, size: 14, color: AppColors.textPrimary),
                    ),
                    MyText('₦${invoice.totalAmount}',
                        weight: 700, size: 14, color: AppColors.primary),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MyText('Due Date',
                            size: 11, color: AppColors.textSecondary),
                        const SizedBox(height: 4),
                        MyText(invoice.dueDate,
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
