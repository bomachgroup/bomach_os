import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/cards/module_shortcut_card.dart';
import 'package:bms_front_end/components/section/module_dashboard.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/permissions.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:bms_front_end/src/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

// Per-card accent palette — keeps the stat tiles visually differentiated.
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
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Finance & Accounting',
            subtitle: 'Invoices, payments, budgets, and financial reporting',
          ),
          kSizedBoxBG,
          _buildSummaryGrid(),
        ],
      ),
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
        _buildSummaryCard(
          value: '452',
          label: 'Total Employees',
          icon: Iconsax.people,
          accent: _accentBlue,
        ),
        _buildSummaryCard(
          value: '\$45,200',
          label: 'Total Expenses',
          icon: Iconsax.money_remove,
          accent: _accentRed,
        ),
        _buildSummaryCard(
          value: '20',
          label: 'Outstanding Invoices',
          icon: Iconsax.receipt_2_1,
          accent: _accentAmber,
        ),
        _buildSummaryCard(
          value: '\$20,000,000',
          label: 'Total Budget',
          icon: Iconsax.wallet_3,
          accent: _accentGreen,
        ),
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
