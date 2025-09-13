import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

class Star5 extends StatelessWidget {
  const Star5({super.key});

  @override
  Widget build(BuildContext context) {
    const int totalStars = 5;
    const int filledStars = 4;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalStars, (index) {
        return Icon(
          Icons.star,
          color: index < filledStars ? AppColors.orange : AppColors.grey4,
          size: 30,
        );
      }),
    );
  }
}
