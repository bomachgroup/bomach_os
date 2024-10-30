import 'package:flutter/material.dart';

import '../../src/constants/colors.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.borderColor, width: 0.6),
      borderRadius: BorderRadius.circular(13),
    );
    return Expanded(
        child: SizedBox(
      height: 45,
      child: TextField(
        decoration: InputDecoration(
            hintText: "Search",
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
            fillColor: const Color(0XFFF5F6FA),
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            border: border,
            enabledBorder: border,
            focusedBorder: border),
      ),
    ));
  }
}
