import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

class CustomDropdownT extends StatefulWidget {
  final List<String> items;
  final String? title;
  final String? initialValue;
  final ValueChanged<String?> onChanged;
  final String hintText;
  const CustomDropdownT({
    super.key,
    required this.items,
    this.initialValue,
    required this.onChanged,
    required this.hintText,
    this.title,
  });

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdownT> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    // widget.items.sort();
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title ?? '',
            style: AppText.black_400_16,
          ),
          DropdownButtonFormField<String>(
            focusColor: AppColors.backgroundColor,
            value: selectedValue,
            isExpanded: true,
            decoration: InputDecoration(
                // suffixIcon: Image.asset('assets/icons/arrowDown.png'),
                fillColor: Colors.transparent,
                filled: true,
                // contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                border: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: AppColors.borderColor, width: 1),
                    borderRadius: BorderRadius.circular(16)),
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: AppColors.borderColor, width: 1),
                    borderRadius: BorderRadius.circular(16)),
                hintText: widget.hintText,
                hintTextDirection: TextDirection.ltr),
            items: widget.items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedValue = newValue;
              });
              widget.onChanged(newValue);
            },
            icon: Image.asset(
              'assets/icons/Drop Down.png',
            ),
            dropdownColor: AppColors.backgroundColor,
          ),
        ],
      ),
    );
  }
}
