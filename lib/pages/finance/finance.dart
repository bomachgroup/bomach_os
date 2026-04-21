import 'package:bms_front_end/components/cards/module_shortcut_card.dart';
import 'package:bms_front_end/components/section/module_dashboard.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/permissions.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:bms_front_end/src/services/permission_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:get/get.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText(
            'Finance Dashboard',
            style: AppText.black_500_32,
          ),
          const SizedBox(height: 6),
          const MyText(
            'Budgets, invoices, payments, and expenses at a glance',
            style: AppText.black_400_14,
          ),
          kSizedBox,
          _buildQuickNav(),
          kSizedBoxBG,
          _buildSummaryGrid(),
        ],
      ),
    );
  }

  Widget _buildQuickNav() {
    final perms = Get.find<PermissionService>();
    ModuleShortcutCard card({
      required IconData icon,
      required String title,
      required String subtitle,
      required String route,
      required List<String> resources,
    }) =>
        ModuleShortcutCard(
          icon: icon,
          title: title,
          subtitle: subtitle,
          route: route,
          enabled: perms.canAccessRoute(route, resources),
        );

    return ModuleQuickNav(
      shortcuts: [
        card(
          icon: Icons.receipt_long_outlined,
          title: 'Invoices',
          subtitle: 'Issue and track billings',
          route: RouteConstants.invoice,
          resources: const [PermissionConstants.resEstateInvoices],
        ),
        card(
          icon: Icons.payments_outlined,
          title: 'Payments',
          subtitle: 'Record incoming funds',
          route: RouteConstants.payment,
          resources: const [PermissionConstants.resPayments],
        ),
        card(
          icon: Icons.money_off_csred_outlined,
          title: 'Expenses',
          subtitle: 'Review and approve spend',
          route: RouteConstants.expense,
          resources: const [PermissionConstants.resExpenses],
        ),
        card(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Budgets',
          subtitle: 'Plan and allocate funds',
          route: RouteConstants.budget,
          resources: const [PermissionConstants.resBudgets],
        ),
      ],
    );
  }

  Widget _buildSummaryGrid() {
    return LayoutGrid(
      columnSizes: isSmallScreen(context) ? [1.fr] : [1.fr, 1.fr],
      rowSizes: isSmallScreen(context)
          ? [
              auto,
              auto,
              auto,
              auto,
            ]
          : const [
              auto,
              auto,
            ],
      columnGap: kDefaultSpaceBG,
      rowGap: kDefaultSpaceBG,
      children: [
        _buildSummaryCard(
          value: '452',
          label: 'Total Employees',
          bigIcon: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.blue.withValues(alpha: 0.15)),
            child: const Icon(
              CupertinoIcons.person_2,
              size: 20,
            ),
          ),
        ),
        _buildSummaryCard(
          value: '452',
          label: 'Total Expenses',
          bigIcon: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.blue.withValues(alpha: 0.15)),
            child: const Icon(
              CupertinoIcons.person_2,
              size: 20,
            ),
          ),
        ),
        _buildSummaryCard(
          value: '20',
          label: 'Outstanding Invoices',
          bigIcon: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.blue.withValues(alpha: 0.15)),
            child: const Icon(
              CupertinoIcons.person_2,
              size: 20,
            ),
          ),
        ),
        _buildSummaryCard(
          value: '20,000,000',
          label: 'Total Budget',
          bigIcon: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.blue.withValues(alpha: 0.15)),
            child: const Icon(
              CupertinoIcons.person_2,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String value,
    required String label,
    required Widget bigIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText(
                    value,
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  bigIcon,
                ],
              ),
            ),
            MyText(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
