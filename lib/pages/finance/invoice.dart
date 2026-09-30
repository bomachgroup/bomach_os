import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/nav/three_dot_pop.dart';
import 'package:bomach_os/components/paginate/responsive_table.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/pages/finance/controllers/service_invoice_controller.dart';
import 'package:bomach_os/pages/finance/models/service_invoice_model_api.dart';
import 'package:bomach_os/pages/finance/widget/add_invoice_dialog.dart';
import 'package:bomach_os/pages/finance/widget/view_invoice_dialog.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/helper/responsive_breakpoints.dart';
import 'package:bomach_os/src/utils/number_formatting.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bomach_os/src/utils/app_date_format.dart';

class InvoicePage extends StatelessWidget {
  const InvoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ServiceInvoiceController controller =
        Get.put(ServiceInvoiceController());

    return PageScaffold(
      header: PageHeader(
        title: 'Invoices',
        subtitle: 'Manage all invoices and billing',
        trailing: MyElevatedButton(
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'New Invoice',
          onTap: () => showDialog(
            context: context,
            builder: (context) => const AddInvoiceDialog(),
          ),
        ),
      ),
      children: [
        context.isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MyTextFormField(
                    hintText: 'Search for invoice...',
                    leading: const Icon(Iconsax.search_normal_1,
                        size: 18, color: AppColors.textMuted),
                    onChanged: (val) => controller.onSearchChanged(val),
                  ),
                  const SizedBox(height: 12),
                ],
              )
            : Row(
                children: [
                  SizedBox(
                    width: 300,
                    child: MyTextFormField(
                      hintText: 'Search for invoice...',
                      leading: const Icon(Iconsax.search_normal_1,
                          size: 18, color: AppColors.textMuted),
                      onChanged: (val) => controller.onSearchChanged(val),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
        const SizedBox(height: 24),
        Obx(() {
          if (controller.isLoading.value && controller.invoiceList.isEmpty) {
            return const Center(
                child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator()));
          }
          if (controller.invoiceList.isEmpty) {
            return const Center(
                child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text("No invoices found.")));
          }
          return ResponsiveTable<ServiceInvoice>(
            items: controller.invoiceList,
            columns: const [
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
            ],
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
                    builder: (context) =>
                        InvoiceDetailsDialog(invoice: invoice),
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
                  formatAppDateValue(invoice.issueDate,
                      fallback: invoice.issueDate),
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
              DataCell(
                Text(
                  formatAppDateValue(invoice.dueDate,
                      fallback: invoice.dueDate),
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
              DataCell(
                Text(
                  invoice.totalAmount.toNaira(),
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              DataCell(
                StatusChip(label: invoice.status, tone: StatusTone.warning),
              ),
              const DataCell(ThreeDotPop()),
            ]),
            mobileCardBuilder: (invoice, index) => AppCard(
              padding: const EdgeInsets.all(16),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => InvoiceDetailsDialog(invoice: invoice),
                );
              },
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyText(invoice.invoiceNumber,
                          weight: 700, size: 14, color: AppColors.textPrimary),
                      StatusChip(
                          label: invoice.status, tone: StatusTone.warning),
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
                            weight: 600,
                            size: 14,
                            color: AppColors.textPrimary),
                      ),
                      MyText(invoice.totalAmount.toNaira(),
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
                          MyText(
                              formatAppDateValue(invoice.dueDate,
                                  fallback: invoice.dueDate),
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
          );
        }),
      ],
    );
  }
}
