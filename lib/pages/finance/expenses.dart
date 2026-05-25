import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/paginate/responsive_table.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/pages/finance/controllers/expense_controller.dart';
import 'package:bomach_os/pages/finance/widget/add_expense_dialog.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/helper/responsive_breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ExpenseController controller = Get.put(ExpenseController());

    return PageScaffold(
      header: PageHeader(
        title: 'Expenses',
        subtitle: 'Track and manage company expenses',
        trailing: MyElevatedButton(
          icon: const Icon(Iconsax.add_circle, color: AppColors.white),
          child: "New Expense",
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const AddExpenseDialog(),
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
                    hintText: 'Search for expense...',
                    leading: Icon(Iconsax.search_normal,
                        color: AppColors.neutral500.withValues(alpha: 0.5)),
                    onChanged: (val) => controller.searchQuery.value = val,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Iconsax.refresh),
                      onPressed: () => controller.fetchExpenses(refresh: true),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  SizedBox(
                    width: 300,
                    child: MyTextFormField(
                      hintText: 'Search for expense...',
                      leading: Icon(Iconsax.search_normal,
                          color: AppColors.neutral500.withValues(alpha: 0.5)),
                      onChanged: (val) => controller.searchQuery.value = val,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Iconsax.refresh),
                    onPressed: () => controller.fetchExpenses(refresh: true),
                  ),
                ],
              ),
        const SizedBox(height: 24),

        // Expenses Table/List
        // Expenses Table/List
        Obx(() {
          if (controller.isLoading.value && controller.expenseList.isEmpty) {
            return const Center(
                child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator()));
          }
          if (controller.expenseList.isEmpty) {
            return const Center(
                child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text("No expenses found.")));
          }
          return ResponsiveTable(
            items: controller.expenseList,
            columns: const [
              DataColumn(label: MyText("Date")),
              DataColumn(label: MyText("Description")),
              DataColumn(label: MyText("Amount")),
              DataColumn(label: MyText("Category")),
              DataColumn(label: MyText("Status")),
              DataColumn(label: MyText("Action")),
            ],
            rowBuilder: (expense, index) => DataRow(cells: [
              DataCell(MyText(expense.date)),
              DataCell(MyText(expense.description)),
              DataCell(MyText(expense.amount)),
              DataCell(MyText(expense.category)),
              DataCell(StatusChip.fromStatus(expense.status, dense: true)),
              DataCell(
                PopupMenuButton<String>(
                  icon: const Icon(Iconsax.more),
                  onSelected: (value) {
                    if (value == 'delete') {
                      controller.deleteExpense(context, expense.id);
                    } else if (value == 'approve') {
                      controller.approveExpense(context, expense.id);
                    } else if (value == 'reject') {
                      controller.rejectExpense(context, expense.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                        value: 'approve', child: Text('Approve')),
                    const PopupMenuItem(
                        value: 'reject', child: Text('Reject')),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete',
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
              ),
            ]),
            mobileCardBuilder: (expense, index) => AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusChip.fromStatus(expense.status, dense: true),
                      MyText(expense.amount,
                          weight: 700, size: 14, color: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 12),
                  MyText(expense.description,
                      weight: 600, size: 15, color: AppColors.textPrimary),
                  const SizedBox(height: 4),
                  MyText(expense.category,
                      size: 13, color: AppColors.textSecondary),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyText(expense.date,
                          size: 12, color: AppColors.textSecondary),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              controller.approveExpense(context, expense.id);
                            },
                            icon: const Icon(Iconsax.tick_circle,
                                size: 18, color: AppColors.success),
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  AppColors.success.withValues(alpha: 0.1),
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              controller.deleteExpense(context, expense.id);
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
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
