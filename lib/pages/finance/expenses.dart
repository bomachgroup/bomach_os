import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/finance/controllers/expense_controller.dart';
import 'package:bms_front_end/pages/finance/widget/add_expense_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ExpenseController controller = Get.put(ExpenseController());
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
                      MyText('Expenses', style: AppText.black_500_32),
                    ],
                  ),
                  MyElevatedButton(
                    icon: const Icon(Icons.add_circle_outline_rounded,
                        color: AppColors.white),
                    child: "New Expense",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => const AddExpenseDialog(),
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
                      hintText: 'Search for expense...',
                      leading: Icon(Icons.search,
                          color: AppColors.grey1.withValues(alpha: 0.5)),
                      onChanged: (val) => controller.searchQuery.value = val,
                    ),
                  ),
                  Row(
                    spacing: 15,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () =>
                            controller.fetchExpenses(refresh: true),
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
            if (controller.isLoading.value && controller.expenseList.isEmpty) {
              return const Center(
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator()));
            }
            if (controller.expenseList.isEmpty) {
              return const Center(
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("No expenses found.")));
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
                      constraints:
                          BoxConstraints(minWidth: bodySpace(context)),
                      child: DataTable(
                        dataRowMinHeight: 68,
                        dataRowMaxHeight: 68,
                        columnSpacing: 24,
                        horizontalMargin: 12,
                        columns: const [
                          DataColumn(label: MyText("Date")),
                          DataColumn(label: MyText("Description")),
                          DataColumn(label: MyText("Amount")),
                          DataColumn(label: MyText("Category")),
                          DataColumn(label: MyText("Status")),
                          DataColumn(label: MyText("Action")),
                        ],
                        rows: controller.expenseList.map((expense) {
                          return DataRow(cells: [
                            DataCell(MyText(expense.date)),
                            DataCell(MyText(expense.description)),
                            DataCell(MyText(expense.amount)),
                            DataCell(MyText(expense.category)),
                            DataCell(_statusBadge(expense.status)),
                            DataCell(
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) {
                                  if (value == 'delete') {
                                    controller.deleteExpense(
                                        context, expense.id);
                                  } else if (value == 'approve') {
                                    controller.approveExpense(
                                        context, expense.id);
                                  } else if (value == 'reject') {
                                    controller.rejectExpense(
                                        context, expense.id);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit')),
                                  const PopupMenuItem(
                                      value: 'approve',
                                      child: Text('Approve')),
                                  const PopupMenuItem(
                                      value: 'reject',
                                      child: Text('Reject')),
                                  const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete',
                                          style:
                                              TextStyle(color: Colors.red))),
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

  Widget _statusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'approved':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case 'rejected':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        break;
      case 'pending':
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
