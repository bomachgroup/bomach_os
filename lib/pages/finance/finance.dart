import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText(
          'Finance Dashboard',
          style: AppText.black_600_32,
        ),
        kSizedBox,
        _buildSummaryGrid(),
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
