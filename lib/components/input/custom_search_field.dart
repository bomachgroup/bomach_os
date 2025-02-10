import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';

class CustomSearchField extends StatelessWidget {
  const CustomSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.greyBg,
          borderRadius: BorderRadius.circular(kDefaultSpaceSM),
          border: Border.all(color: AppColors.grey1.withOpacity(0.3)),
        ),
        child: TextField(
          decoration: InputDecoration(
            fillColor: AppColors.greyBg,
            hintText: "Search",
            hintStyle: TextStyle(
              color: AppColors.grey1.withOpacity(0.8),
              fontSize: 16,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.grey1,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }
}
