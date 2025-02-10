import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';

class SortBar extends StatelessWidget {
  const SortBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: 95,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(kDefaultSpaceSM),
        border: Border.all(color: AppColors.grey1.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Sort",
            style: TextStyle(
              color: AppColors.grey1,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.arrow_drop_down_rounded,
            color: AppColors.grey1.withOpacity(0.5),
            size: 30,
          ),
        ],
      ),
    );
  }
}
