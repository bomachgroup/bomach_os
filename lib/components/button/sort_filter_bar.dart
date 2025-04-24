import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

class SortFilterBar extends StatelessWidget {
  const SortFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.grey1.withValues(alpha: 0.3)),
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
              color: AppColors.grey1.withValues(alpha: 0.3),
              thickness: 1,
              width: 20, // space between items
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: "A - Z",
                items: const [
                  DropdownMenuItem(value: "A - Z", child: Text("A - Z")),
                  DropdownMenuItem(value: "Z - A", child: Text("Z - A")),
                ],
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                onChanged: (value) {},
              ),
            ),
            VerticalDivider(
              color: AppColors.grey1.withValues(alpha: 0.3),
              thickness: 1,
              width: 20,
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: "Status",
                items: const [
                  DropdownMenuItem(value: "Status", child: Text("Status")),
                  DropdownMenuItem(value: "Active", child: Text("Active")),
                  DropdownMenuItem(value: "Inactive", child: Text("Inactive")),
                ],
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                onChanged: (value) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
