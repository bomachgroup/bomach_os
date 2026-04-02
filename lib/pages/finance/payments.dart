import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/finance/controllers/payment_controller.dart';
import 'package:bms_front_end/pages/finance/widget/add_payment_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PaymentController controller = Get.put(PaymentController());
    final ScrollController scrollController = ScrollController();

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
                      MyText('Payments', style: AppText.black_500_32),
                    ],
                  ),
                  MyElevatedButton(
                    icon: const Icon(Icons.add_circle_outline_rounded,
                        color: AppColors.white),
                    child: "New Payment",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => const AddPaymentDialog(),
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
                      leading: Icon(Icons.search,
                          color: AppColors.grey1.withValues(alpha: 0.5)),
                    ),
                  ),
                  Row(
                    spacing: 15,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () =>
                            controller.fetchPayments(refresh: true),
                      ),
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
          child: Obx(() {
            if (controller.isLoading.value && controller.paymentList.isEmpty) {
              return const Center(
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator()));
            }
            if (controller.paymentList.isEmpty) {
              return const Center(
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("No payments found.")));
            }
            return Column(
              children: [
                Scrollbar(
                  controller: scrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: bodySpace(context)),
                      child: DataTable(
                        dataRowMinHeight: 68,
                        dataRowMaxHeight: 68,
                        columnSpacing: 24,
                        horizontalMargin: 12,
                        columns: const [
                          DataColumn(label: MyText("Reference")),
                          DataColumn(label: MyText("Invoice ID")),
                          DataColumn(label: MyText("Amount")),
                          DataColumn(label: MyText("Method")),
                          DataColumn(label: MyText("Date")),
                          DataColumn(label: MyText("Action")),
                        ],
                        rows: controller.paymentList.map((payment) {
                          return DataRow(cells: [
                            DataCell(MyText(payment.paymentReference)),
                            DataCell(MyText(payment.invoiceId.toString())),
                            DataCell(MyText(payment.amount)),
                            DataCell(MyText(payment.paymentMethod)),
                            DataCell(MyText(payment.paymentDate)),
                            DataCell(
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) {
                                  if (value == 'delete') {
                                    controller.deletePayment(
                                        context, payment.id);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete',
                                          style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            ),
                          ]);
                        }).toList(),
                        showBottomBorder: true,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
