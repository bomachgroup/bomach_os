import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

class MyRadio<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T?> onChanged;
  final String label;

  const MyRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioTheme(
            data: RadioThemeData(
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.blue; // active fill
                }
                return AppColors.darkGrey2; // inactive border
              }),
            ),
            child: Radio<T>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
