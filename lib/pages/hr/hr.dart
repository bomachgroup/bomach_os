import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

class HRPage extends StatefulWidget {
  const HRPage({super.key});

  @override
  State<HRPage> createState() => _HRPageState();
}

class _HRPageState extends State<HRPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText(
          'HR Dashboard',
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
          label: 'Employees',
          subtext: "2 new Employees added!",
          smallIcon: Container(
            height: 15,
            width: 15,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.green.withValues(alpha: 0.2),
            ),
            child: const Icon(
              CupertinoIcons.add,
              size: 8,
            ),
          ),
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
          subtext: "2 new Leaves added!",
          smallIcon: Container(
            height: 15,
            width: 15,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.green.withValues(alpha: 0.2),
            ),
            child: const Icon(
              CupertinoIcons.add,
              size: 8,
            ),
          ),
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
          subtext: "2 Open Positions added!",
          smallIcon: Container(
            height: 15,
            width: 15,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.green.withValues(alpha: 0.2),
            ),
            child: const Icon(
              CupertinoIcons.add,
              size: 8,
            ),
          ),
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
    Widget? smallIcon,
    String? subtext,
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
            if (subtext != null)
              Row(
                children: [
                  smallIcon ?? const SizedBox(),
                  kSizedBoxWidthSM,
                  Expanded(
                    child: MyText(
                      subtext,
                      // overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.darkBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
