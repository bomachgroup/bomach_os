import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

class MyText extends StatelessWidget {
  final String text;
  final double size;
  final Color color;
  final int weight;
  const MyText(
    this.text, {
    super.key,
    required this.size,
    required this.weight,
    this.color = AppColors.blackColor,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: color, fontSize: size, fontWeight: getWeight()),
    );
  }

  FontWeight? getWeight() {
    final data = {
      100: FontWeight.w100,
      200: FontWeight.w200,
      300: FontWeight.w300,
      400: FontWeight.w400,
      500: FontWeight.w500,
      600: FontWeight.w600,
      700: FontWeight.w700,
      800: FontWeight.w800,
      900: FontWeight.w900,
    };
    return data[weight];
  }
}
