import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/pages/finance/controllers/budget_controller.dart';
import 'package:bomach_os/pages/finance/widget/add_budget_dialog.dart';
import 'package:bomach_os/pages/finance/widget/view_budget_dialog.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/spaces.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:bomach_os/src/helper/responsive_breakpoints.dart';
import 'package:get/get.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BudgetController controller = Get.put(BudgetController());
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
                      MyText('Budget', style: AppTextStyles.displayLg),
                    ],
                  ),
                  MyElevatedButton(
                    icon: const Icon(Iconsax.add_circle,
                        color: AppColors.white),
                    child: "New Budget",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => const AddBudgetDialog(),
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
                      hintText: 'Search for budget...',
                      leading: Icon(Iconsax.search_normal,
                          color: AppColors.neutral500.withValues(alpha: 0.5)),
                      onChanged: (val) => controller.searchQuery.value = val,
                    ),
                  ),
                  Row(
                    spacing: 15,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Iconsax.refresh),
                        onPressed: () => controller.fetchBudgets(refresh: true),
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
            if (controller.isLoading.value && controller.budgetList.isEmpty) {
              return const Center(
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator()));
            }
            if (controller.budgetList.isEmpty) {
              return const Center(
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("No budgets found.")));
            }
            if (context.isMobile) {
              return Column(
                children: controller.budgetList.map((budget) => _buildMobileCard(context, budget, controller)).toList(),
              );
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
                          DataColumn(label: MyText("Branch")),
                          DataColumn(label: MyText("Department")),
                          DataColumn(label: MyText("Fiscal Period")),
                          DataColumn(label: MyText("Amount")),
                          DataColumn(label: MyText("Spent")),
                          DataColumn(label: MyText("Remaining")),
                          DataColumn(label: MyText("Action")),
                        ],
                        rows: controller.budgetList.map((budget) {
                          return DataRow(cells: [
                            DataCell(MyText(budget.branchName)),
                            DataCell(MyText(budget.departmentName)),
                            DataCell(MyText(budget.fiscalPeriod)),
                            DataCell(MyText(budget.amount)),
                            DataCell(MyText(budget.currentSpend)),
                            DataCell(MyText(budget.remainingBudget)),
                            DataCell(
                                PopupMenuButton<String>(
                                  icon: const Icon(Iconsax.more),
                                  onSelected: (value) {
                                    if (value == 'view') {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            ViewBudgetDialog(budget: budget),
                                      );
                                    } else if (value == 'delete') {
                                      controller.deleteBudget(context, budget.id);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                        value: 'view', child: Text('View')),
                                    const PopupMenuItem(
                                        value: 'edit', child: Text('Edit')),
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

  Widget _buildMobileCard(BuildContext context, budget, BudgetController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  budget.branchName,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              MyText(
                budget.fiscalPeriod,
                size: 13,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 4),
          MyText(
            budget.departmentName,
            size: 13,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MyText(
                    'Budget Limit',
                    size: 11,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 2),
                  MyText(
                    budget.amount,
                    size: 14,
                    weight: 600,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const MyText(
                    'Spent',
                    size: 11,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 2),
                  MyText(
                    budget.currentSpend,
                    size: 14,
                    weight: 600,
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const MyText(
                    'Remaining',
                    size: 11,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 2),
                  MyText(
                    budget.remainingBudget,
                    size: 14,
                    weight: 600,
                    color: AppColors.success,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PopupMenuButton<String>(
                icon: const Icon(Iconsax.more),
                onSelected: (value) {
                  if (value == 'view') {
                    showDialog(
                      context: context,
                      builder: (context) => ViewBudgetDialog(budget: budget),
                    );
                  } else if (value == 'delete') {
                    controller.deleteBudget(context, budget.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: Colors.red))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
