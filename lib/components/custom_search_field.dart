import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

class CustomSearchField extends StatelessWidget {
  const CustomSearchField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: SizedBox(
      height: 38,
      child: TextField(
        decoration: InputDecoration(
            hintText: 'Search',
            fillColor: const Color(0XFFF5F6FA),
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: AppColors.borderColor, width: 0.6),
                borderRadius: BorderRadius.circular(13)),
            border: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: AppColors.borderColor, width: 0.6),
                borderRadius: BorderRadius.circular(13)),
            disabledBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: AppColors.borderColor, width: 0.6),
                borderRadius: BorderRadius.circular(13))),
      ),
    ));
  }
}
