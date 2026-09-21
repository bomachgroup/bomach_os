import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/spaces.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controllers/finance_dashboard_controller.dart';

const Color _accentBlue = AppColors.primary;
const Color _accentRed = AppColors.danger;
const Color _accentAmber = AppColors.warning;
const Color _accentGreen = AppColors.success;

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  late final FinanceDashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(FinanceDashboardController());
    controller.fetchStats();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      header: const PageHeader(
        title: 'Finance & Accounting',
        subtitle: 'Invoices, payments, budgets, and financial reporting',
      ),
      children: [
        _buildSummaryGrid(),
      ],
    );
  }

  Widget _buildSummaryGrid() {
    return LayoutGrid(
      columnSizes: isSmallScreen(context) ? [1.fr] : [1.fr, 1.fr],
      rowSizes: isSmallScreen(context)
          ? [auto, auto, auto, auto]
          : const [auto, auto],
      columnGap: kDefaultSpaceBG,
      rowGap: kDefaultSpaceBG,
      children: [
        Obx(() => _buildSummaryCard(
              value: controller.isLoading.value
                  ? '-'
                  : controller.totalExpenses.value,
              label: 'Total Expenses',
              icon: Iconsax.money_remove,
              accent: _accentRed,
            )),
        Obx(() => _buildSummaryCard(
              value: controller.isLoading.value
                  ? '-'
                  : controller.totalExpensesAmount.value,
              label: 'Total Amount',
              icon: Iconsax.money_send,
              accent: _accentBlue,
            )),
        Obx(() => _buildSummaryCard(
              value: controller.isLoading.value
                  ? '-'
                  : controller.outstandingInvoices.value,
              label: 'Outstanding Invoices',
              icon: Iconsax.receipt_2_1,
              accent: _accentAmber,
            )),
        Obx(() => _buildSummaryCard(
              value: controller.isLoading.value
                  ? '-'
                  : controller.totalBudgetAmount.value,
              label: 'Total Budget',
              icon: Iconsax.wallet_3,
              accent: _accentGreen,
            )),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String value,
    required String label,
    required IconData icon,
    required Color accent,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.displayMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  borderRadius: AppRadii.brMd,
                  color: accent.withValues(alpha: 0.12),
                ),
                child: Icon(icon, size: 22, color: accent),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
