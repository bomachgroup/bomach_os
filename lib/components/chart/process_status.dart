import 'package:bms_front_end/components/text/my_text.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';

class ProgressStatus extends StatefulWidget {
  const ProgressStatus({super.key});

  @override
  State<ProgressStatus> createState() => _ProgressStatusState();
}

class _ProgressStatusState extends State<ProgressStatus> {
  double progress = 0.67;
  String status = "In progress";

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150, // Fixed or dynamic based on your table
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          Stack(
            children: [
              Container(
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 14,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(8),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: MyText(
                    "${(progress * 100).toInt()}%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          kSizedBoxTiny,
          // Status with dropdown
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    height: 8,
                    width: 8,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  kSizedBoxWidthTiny,
                  MyText(status),
                  kSizedBoxWidthSM,
                  const Icon(Iconsax.arrow_down_1, size: 16)
                ],
              )),
        ],
      ),
    );
  }
}
