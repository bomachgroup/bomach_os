import 'package:bomach_os/src/constants/colors.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';

class SortBar extends StatelessWidget {
  final String text;
  const SortBar({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 48,
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: AppColors.neutral500,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Iconsax.arrow_down_1,
            color: AppColors.neutral500.withValues(alpha: 0.5),
            size: 30,
          ),
        ],
      ),
    );
  }
}
