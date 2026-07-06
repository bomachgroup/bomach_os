import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/paginate/responsive_table.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/pages/finance/controllers/payment_controller.dart';
import 'package:bomach_os/pages/finance/widget/add_payment_dialog.dart';
import 'package:bomach_os/pages/finance/widget/view_payment_dialog.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/helper/responsive_breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PaymentController controller = Get.put(PaymentController());

    return PageScaffold(
      header: PageHeader(
        title: 'Payments',
        subtitle: 'Manage and track all customer payments',
        trailing: MyElevatedButton(
          icon: const Icon(Iconsax.add_circle, color: AppColors.white),
          child: "New Payment",
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const AddPaymentDialog(),
            );
          },
        ),
      ),
      children: [
        // Search and Filters
        context.isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MyTextFormField(
                    hintText: 'Search for payment...',
                    leading: Icon(Iconsax.search_normal,
                        color: AppColors.neutral500.withValues(alpha: 0.5)),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Iconsax.refresh),
                      onPressed: () => controller.fetchPayments(refresh: true),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  SizedBox(
                    width: 300,
                    child: MyTextFormField(
                      hintText: 'Search for payment...',
                      leading: Icon(Iconsax.search_normal,
                          color: AppColors.neutral500.withValues(alpha: 0.5)),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Iconsax.refresh),
                    onPressed: () => controller.fetchPayments(refresh: true),
                  ),
                ],
              ),
        const SizedBox(height: 24),

        // Payments Table/List
        // Payments Table/List
        Obx(() {
          if (controller.isLoading.value && controller.paymentList.isEmpty) {
            return const Center(
                child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator()));
          }
          if (controller.paymentList.isEmpty) {
            return const Center(
                child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text("No payments found.")));
          }
          return ResponsiveTable(
            items: controller.paymentList,
            columns: const [
              DataColumn(label: MyText("Reference")),
              DataColumn(label: MyText("Invoice ID")),
              DataColumn(label: MyText("Amount")),
              DataColumn(label: MyText("Method")),
              DataColumn(label: MyText("Date")),
              DataColumn(label: MyText("Action")),
            ],
            rowBuilder: (payment, index) => DataRow(cells: [
              DataCell(MyText(payment.paymentReference)),
              DataCell(MyText(payment.invoiceId.toString())),
              DataCell(MyText(payment.amount)),
              DataCell(MyText(payment.paymentMethod)),
              DataCell(MyText(payment.paymentDate)),
              DataCell(
                PopupMenuButton<String>(
                  icon: const Icon(Iconsax.more),
                  onSelected: (value) {
                    if (value == 'view') {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            ViewPaymentDialog(payment: payment),
                      );
                    } else if (value == 'delete') {
                      controller.deletePayment(context, payment.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'view', child: Text('View')),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete',
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
              ),
            ]),
            mobileCardBuilder: (payment, index) => AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyText(payment.paymentReference,
                          weight: 700, size: 14, color: AppColors.textPrimary),
                      MyText(payment.amount,
                          weight: 700, size: 14, color: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const MyText('Invoice ID',
                              size: 11, color: AppColors.textSecondary),
                          const SizedBox(height: 4),
                          MyText(payment.invoiceId.toString(),
                              size: 13,
                              weight: 600,
                              color: AppColors.textPrimary),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const MyText('Method',
                              size: 11, color: AppColors.textSecondary),
                          const SizedBox(height: 4),
                          MyText(payment.paymentMethod,
                              size: 13,
                              weight: 600,
                              color: AppColors.textPrimary),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyText(payment.paymentDate,
                          size: 12, color: AppColors.textSecondary),
                      IconButton(
                        onPressed: () {
                          controller.deletePayment(context, payment.id);
                        },
                        icon: const Icon(Iconsax.trash,
                            size: 18, color: AppColors.danger),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              AppColors.danger.withValues(alpha: 0.1),
                          padding: const EdgeInsets.all(8),
                        ),
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
