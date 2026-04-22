import 'package:bms_front_end/src/constants/colors.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';

class SortFilterBar2 extends StatelessWidget {
  const SortFilterBar2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.neutral500.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        // This ensures children take the full height
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text("Sort by", style: TextStyle(fontSize: 16)),
            ),
            VerticalDivider(
              color: AppColors.neutral500.withValues(alpha: 0.3),
              thickness: 1,
              width: 20, // space between items
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: "Branch",
                items: const [
                  DropdownMenuItem(value: "Branch", child: Text("Branch")),
                  DropdownMenuItem(value: "Branch2", child: Text("Branch2")),
                ],
                icon: const Icon(Iconsax.arrow_down_1),
                onChanged: (value) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
